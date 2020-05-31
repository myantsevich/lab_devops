#! /bin/bash
sudo yum install nginx -y

sudo systemctl enable nginx
sudo systemctl start nginx

sudo cat > /usr/share/nginx/html/index.html <<EOF 
<html>

 <head>
  <meta charset="utf-8">
  <title>Welcome page</title>
 </head>
 <body>
  <p>¯\_(ツ)_/¯</p>
  <p>Hello from Marina</p>
 </body>
 
</html>
EOF