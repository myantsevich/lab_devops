sleep 180s
yum -y install openldap-clients
yum -y install nss-pam-ldapd

authconfig --enableldap --enableldapauth --ldapserver=10.13.1.13 --ldapbasedn="dc=devopsldab,dc=com" --enablemkhomedir --update
sed -i "s@PasswordAuthentication no@PasswordAuthentication yes@"  /etc/ssh/sshd_config
systemctl restart sshd
systemctl restart nslcd
getent passwd 
