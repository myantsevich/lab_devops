#!/bin/bash
#sudo -i
#install ldap server
sudo yum install openldap openldap-servers openldap-clients -y
sudo systemctl start slapd
sudo systemctl enable slapd
sudo firewall-cmd --add-service=ldap

#generate pass
rootpass="Epam2020"
slappasswd -s $rootpass > .pass
pass=$(cat ".pass")


cat << EOF > ./ldaprootpasswd.ldif
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass
EOF

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f ldaprootpasswd.ldif 
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG

# Import schemas
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#Add domain
cat << EOF > ./ldapdomain.ldif
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
read by dn.base="cn=Manager,dc=devopsldab,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=devopsldab,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=devopsldab,dc=com" write by * read
EOF

sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f ldapdomain.ldif

#Add root to server
cat << EOF > ./baseldapdomain.ldif
dn: dc=devopsldab,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: devopsldab com
dc: devopsldab

dn: cn=Manager,dc=devopsldab,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: Group
EOF

sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -W $pass -f baseldapdomain.ldif

#Create the definitions for a LDAP group
cat << EOF > ./ldapgroup.ldif
dn: cn=Manager,ou=Group,dc=devopsldab,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

#Create another LDIF file and pass for user
sudo ldapadd -x  -W $pass -D "cn=Manager,dc=devopsldab,dc=com" -f ldapgroup.ldif
userpass="Epam2020"
slappasswd -s $userpass > .user
user=$(cat ".user")

cat << EOF > ./ldapuser.ldif 
dn: uid=user,ou=People,dc=devopsldab,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: tecmint
uid: tecmint
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/user
userPassword: $user
loginShell: /bin/bash
gecos: user
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
EOF

sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -W $pass -f  ldapuser.ldif

#install phpldapadmin

sudo yum --enablerepo=epel -y install phpldapadmin

#changing in config.php
sudo sed -i "s@// \$servers->setValue('login','attr','dn');@\$servers->setValue('login','attr','dn');@" /etc/phpldapadmin/config.php
sudo sed -i "s@\$servers->setValue('login','attr','uid');@// \$servers->setValue('login','attr','uid');@" /etc/phpldapadmin/config.php

#changing in phpldapadmin.conf
cat << EOF > ./phpldapadmin.conf
Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    # Apache 2.4
    Require all granted
  </IfModule>
  <IfModule !mod_authz_core.c>
    # Apache 2.2
    Order Deny,Allow
    Deny from all
    Allow from 0.0.0.0/0
    Allow from ::1
  </IfModule>
</Directory>
EOF
sudo cp ./phpldapadmin.conf /etc/httpd/conf.d/phpldapadmin.conf

#go
sudo systemctl restart httpd
