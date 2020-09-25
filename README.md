# openvpn 2.4.9

## Usage

### Server

First, clone repo and make the script openvpn-install.sh executable:

```
git clone https://github.com/jackey525/openvpn.git
chmod +x openvpn-install.sh
```

Then run it:

```
./openvpn-install.sh
```
### client

When OpenVPN is installed, 
you can make a client.ovpn to connect server(fill remoteIP to yours.)  
and get ca.crt from server (/etc/openvpn/) and save it near to client.ovpn

$ vi client.ovpn

```
client
dev tun
proto udp               # protocol
remote remoteIP 1194    # set ip and port
resolv-retry infinite   
nobind
persist-key
persist-tun
ca ca.crt               # ca (path to cert)
verb 5
auth-user-pass          # use user/pass method to login
```

=============== Some vpn client as below ===============

Windows:
```
On Windows, you will need the official OpenVPN Community Edition binaries which come with a GUI. 

Place your .ovpn configuration file into the proper directory, C:\Program Files\OpenVPN\config, 
and click Connect in the GUI. OpenVPN GUI on Windows must be executed with administrative privileges.
```

macOS:
```
On macOS, the open source application Tunnelblick provides an interface similar to the OpenVPN GUI on Windows, 
and comes with OpenVPN and the required TUN/TAP drivers. 

As with Windows, the only step required is to place your .ovpn configuration file into 
the ~/Library/Application Support/Tunnelblick/Configurations directory. 

Alternatively, you can double-click on your .ovpn file.
```
Linux:
```
On Linux, you should install OpenVPN from your distribution’s official repositories. 

You can then invoke OpenVPN by executing:

$ sudo openvpn --config ~/path/to/client.ovpn
```

=============== description ===============

checkpsw.sh        #  login script
psw-file           #  user password file 
auto_gen_user.sh   #  auto 10 passwords that are generated with 10 digits
