#!/bin/bash
sleep 200s
sudo yum -y install openldap-clients nss-pam-ldapd
sudo yum install -y nss-pam-ldapd
ldapserver= 10.13.0.13
ldapbasedn="dc=devopsldab"

sudo authconfig --enableldap --enableldapauth --ldapserver= 10.13.0.13 --ldapbasedn="dc=devopsldab,dc=com" --enablemkhomedir --update
sudo sed -i "s@PasswordAuthentication no@PasswordAuthentication yes@"  /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl restart nslcd
getent passwd 
