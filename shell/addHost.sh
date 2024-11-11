#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Add_VHost()
{
    domain=""
    while :;do
        echo "Please enter domain(example: www.imguo.com): "
        read domain
        if [ "${domain}" != "" ]; then
            if [ -f "/etc/nginx/conf.d/${domain}.conf" ]; then
                echo " ${domain} is exist,please check!"
                exit 1
            else
                echo " Your domain: ${domain}"
            fi
            break
        else
            echo "Domain name can't be empty!"
        fi
    done

    vhostdir="/www/${domain}"
    echo "Please enter the directory for the domain: $domain"
    echo "Default directory: /var/www/html/${domain}: "
    read vhostdir
    if [ "${vhostdir}" == "" ]; then
        vhostdir="/var/www/html/${domain}"
    fi
    echo "Virtual Host Directory: ${vhostdir}"


        cat >"/etc/nginx/conf.d/${domain}.conf"<<EOF
server
    {
    listen 80;
    listen 443 ssl;
    server_name ${domain};
    root   ${vhostdir};
    index  index.php index.html index.htm;

    ssl_certificate /etc/nginx/conf.d/certs/base.crt;
    ssl_certificate_key /etc/nginx/conf.d/certs/base.key;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; 
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
    ssl_prefer_server_ciphers on;

    location / {
        index  index.htm index.html index.php;
        if (!-e \$request_filename) {
                rewrite ^(.*)$ /index.php?s=\$1 last;
                break;
        }
    }

   location ~ \.php$ {
        fastcgi_pass   php:9000;
        fastcgi_index  index.php;
        include        fastcgi_params;
        fastcgi_param  PATH_INFO \$fastcgi_path_info;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
    }

}
EOF

    echo "Test Nginx configure file......"
    nginx -t
    echo "Reload Nginx......"
    nginx -s reload


}


Add_VHost