sleep 60s
yum -y install epel-release
yum install -y openldap 
yum install -y openldap-servers
yum install -y openldap-clients
systemctl start slapd
systemctl enable slapd
firewall-cmd --add-service=ldap

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

ldapadd -Y EXTERNAL -H ldapi:/// -f ./ldaprootpasswd.ldif 
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap/DB_CONFIG

# Import schemas
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

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

ldapmodify -Y EXTERNAL -H ldapi:/// -f ./ldapdomain.ldif

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

ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w $pass -f ./baseldapdomain.ldif

#Create the definitions for a LDAP group
cat << EOF > ./ldapgroup.ldif
dn: cn=Manager,ou=Group,dc=devopsldab,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

#Create another LDIF file and pass for user
ldapadd -x  -w $pass -D "cn=Manager,dc=devopsldab,dc=com" -f ./ldapgroup.ldif
userpass="Epam2020"
slappasswd -s $userpass > .user
user=$(cat ".user")

cat << EOF > ./ldapuser.ldif 
dn: uid=customuser,ou=People,dc=devopsldab,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: customuser
uid: customuser
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/customuser
userPassword: $user
loginShell: /bin/bash
gecos: customuser
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
EOF

ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w $pass -f  ./ldapuser.ldif

#install phpldapadmin

yum --enablerepo=epel -y install phpldapadmin

#changing in config.php
sed -i "s@// \$servers->setValue('login','attr','dn');@\$servers->setValue('login','attr','dn');@" /etc/phpldapadmin/config.php
sed -i "s@\$servers->setValue('login','attr','uid');@// \$servers->setValue('login','attr','uid');@" /etc/phpldapadmin/config.php

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
cp ./phpldapadmin.conf /etc/httpd/conf.d/phpldapadmin.conf

#go
systemctl restart slapd
systemctl restart httpd
