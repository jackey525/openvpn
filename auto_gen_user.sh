#!/bin/bash

PASS_LENGTH=8

for p in $(seq 1 10);                                    
do  
    openssl rand -base64 48 | cut -c1-$PASS_LENGTH  
done 

