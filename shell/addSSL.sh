#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


Install_Check_Acme()
{
    if [ -s ~/.acme.sh/acme.sh  ]; then
        echo "~/.acme.sh/acme.sh [found]"
    else
        sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
        apk update
        apk add --no-cache curl openssl socat
        curl https://get.acme.sh | sh
    fi
}


Add_Letsencrypt()
{
    domain=""
    while :;do
        echo "Please enter domain(example: www.imguo.com): "
        read domain
        if [ "${domain}" != "" ]; then
            # if [ -f "/etc/nginx/conf.d/${domain}.conf" ]; then
            #     echo " ${domain} ,please check!"
            # else
            #     echo " Your domain: ${domain}"
            #     exit 1
            # fi
            break
        else
            echo "Domain name can't be empty!"
        fi
    done
    Install_Check_Acme
    ~/.acme.sh/acme.sh --issue -d ${domain} --nginx
    ~/.acme.sh/acme.sh --installcert -d ${domain} --key-file /etc/nginx/conf.d/certs/${domain}.key --fullchain-file /etc/nginx/conf.d/certs/${domain}.cer --reloadcmd "nginx -s reload"

}

Add_Letsencrypt