#! /bin/bash


# Set DIR params
OPENVPN_DIR=/etc/openvpn/
OPENVPN_RSA_DIR=$OPENVPN_DIR/easy-rsa/
OPENVPN_KEYS=$OPENVPN_RSA_DIR/keys


# update and install package

sudo yum update -y
sudo yum install epel-release -y
sudo yum update -y
sudo yum install -y openvpn wget

# install EasyESA to build cert
wget -O /tmp/easyrsa https://github.com/OpenVPN/easy-rsa-old/archive/2.3.3.tar.gz
tar xfz /tmp/easyrsa
sudo mkdir /etc/openvpn/easy-rsa

# copy easy-rsa tools to build server cert
sudo cp -rf easy-rsa-old-2.3.3/easy-rsa/2.0/* $OPENVPN_RSA_DIR

sudo mkdir $OPENVPN_KEYS

sudo cp -rf vars $OPENVPN_RSA_DIR

# copy script to OPENVPN_DIR
sudo cp checkpsw.sh psw-file $OPENVPN_DIR

cd $OPENVPN_RSA_DIR

source ./vars

./clean-all        # clear all keys and certs in the keys folder

./build-ca --batch    # build ca.key ca.cert

./pkitool --server server --batch   # build server key and server cert

./build-dh --batch

# copy server certs and keys to  /etc/openvpn
cd $OPENVPN_KEYS

sudo cp dh2048.pem ca.crt server.crt server.key $OPENVPN_DIR

# Add server config to /etc/openvpn
# moify /etc/openvpn/server.conf using script checkpsw.sh to check login

echo '
port 1194       # port 
proto udp       # protocol
dev tun         # tunnel mode
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
reneg-sec 0
ca ca.crt        # ca cert path
cert server.crt  # server cert path
key server.key   # server key path
dh dh2048.pem    
topology subnet

# tunnel 通道 
server 10.8.0.0 255.255.255.0            # tunnel pool
push "route 192.168.0.0 255.255.255.0"   # allow user to access 192.168.0.x subnet

ifconfig-pool-persist ipp.txt   # long-term persist user list
push "redirect-gateway def1 bypass-dhcp"  # redirect traffic
push "dhcp-option DNS 8.8.8.8"    # user can use Google’s public DNS 
push "dhcp-option DNS 8.8.8.4"    # user can use Google’s public DNS 

keepalive 10 120    # tunnel survival time  10 secs ping once，120 secs timeout
cipher AES-256-CBC
client-to-client    # user can connect to each other
max-clients 100     # allow 100 clients
user nobody
group nobody
persist-key
persist-tun
status openvpn-status.log   # log
log         openvpn.log     # log
verb 5
explicit-exit-notify 0      # do not send exit notifications 


script-security 3          # script security
auth-user-pass-verify /etc/openvpn/checkpsw.sh via-env # login using env pass to script validation 
client-cert-not-required   # cancel client cert
username-as-common-name' > $OPENVPN_DIR/server.conf

# modify priority
chmod 775 $OPENVPN_DIR/psw-file
chmod +x $OPENVPN_DIR/checkpsw.sh
touch $OPENVPN_DIR/openvpn-password.log

echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.conf
sysctl --system

# build nat POSTROUTING from 10.8.0.0/24
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# start openvpn service
systemctl -f enable openvpn@server.service
systemctl start openvpn@server.service


# Celebrate!
echo ""
echo "#############################################################"
echo "log file"
echo "tail -f /etc/openvpn/openvpn.log"
echo "#############################################################"
