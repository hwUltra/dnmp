DNMP（Docker + Nginx + MySQL + PHP7/5 + Redis）是一款全功能的**LNMP一键安装程序**。


# 目录
- [1.快速使用](#1快速使用)
- [2.docker管理容器](#2docker管理 )
    - [2.1 docker管理php](#21-docker管理php) 
    - [2.2 docker管理nginx](#22-docker管理nginx)
    - [2.3 docker管理mysql](#23-docker管理mysql)
    - [2.4 docker管理redis](#24-docker管理redis)
    - [2.5 docker管理Crontab](#25-docker管理crontab)
    - [2.6 docker管理webSocket ](#26-docker管理websocket)
- [3.php相关管理](#3php相关管理)
    - [3.1 php切换版本](#31-切换php版本)
    - [3.2 php安装扩展](#32-php怎么安装扩展)
    - [3.3 composer管理](#33-composer管理)
- [4.nginx站点的配置](#4nginx站点的配置)
- [5.使用Log](#5使用log)
    - [5.1 Nginx日志](#51-nginx日志)
    - [5.2 PHP-FPM日志](#52-php-fpm日志)
    - [5.3 MySQL日志](#53-mysql日志)
- [6.可视化界面管理](#6可视化界面管理)
    - [6.1 phpMyAdmin](#61-phpmyadmin)
    - [6.2 phpRedisAdmin](#62-phpredisadmin)
    - [6.3 portainer](#63-portainer)
- [7.在正式环境中安全使用](#7在正式环境中安全使用)
- [8.jenkins使用](#8jenkins使用)
    - [8.1 jenkins配置webhook插件](#81-jenkins配置webhook插件)



## 1.快速使用
1.  **通过脚本一键安装   docker  和docker-compose，并通过docker安装dnmp**

- 使用 docker_install.sh脚本(redhat 系列linux)

- 使用su -切换到root用户

- 执行chmod a+x docker_install.sh  给脚本添加可执行的权限

- sh  docker_install.sh  执行脚本 等待安装完毕即可  

   （默认的dnmp安装在/wwwroot下面，所有在vagrant中可以设置/wwwroot的共享目录）



**2：测试是否安装成功**

访问在浏览器中访问：

 - [http://虚拟机的ip地址](http://虚拟机的ip地址)： 默认*http*站点
 - [https://虚拟机的ip地址](https:/虚拟机的ip地址)： 自定义证书*https*站点，访问时浏览器会有安全提示，忽略提示访问即可
 - [http://虚拟机的ip地址:9080](http://虚拟机的ip地址:9080)  可以打开phpMysAdmin的面板操作数据库
 - [http://虚拟机的ip地址:9081](http://虚拟机的ip地址:9081)  可以打开phpRedisAdmin
 - [http://虚拟机的ip地址:8888](http://虚拟机的ip地址:8888)   可以打开docker的图形化管理工具，可以查看镜像 容器 安装等  账号admin  密码123123123
默认情况下该虚拟机指向的项目根目录：在/www/lnmp-docker/wwwroot/base/public

要修改端口、日志文件位置、以及是否替换source.list文件等，请修改.env文件，然后重新构建：
```bash
$ docker-compose build php    # 重建单个服务
$ docker-compose build          # 重建全部服务

```


## 2.docker管理 

### 2.1 docker管理php

    进入php容器  docker exec -it dnmp-php sh
    重启php服务  docker-compose restart php
      
     修改配置文件 php.init，可使用该命令重新加载配置文件。
     修改配置文件 www.conf，可使用该命令重新加载配置文件。
    
    服务管理
    
    配置测试：docker exec -it dnmp-php bash -c "/usr/local/php/sbin/php-fpm -t"
    启动：docker exec -it dnmp-php bash -c "/usr/local/php/sbin/php-fpm"
    关闭：docker exec -it dnmp-php bash -c "kill -INT 1"
    重启：docker exec -it dnmp-php bash -c "kill -USR2 1"
    查看php-fpm进程数：docker exec -it dnmp-php bash -c "ps aux | grep -c php-fpm"
    查看PHP版本：docker exec -it dnmp-php bash -c "/usr/local/php/bin/php -v"
    
    tips:如果执行上述命名提示the input device is not a TTY.  If you are using mintty, try prefixing the command with 'winpty' 错误，可在前面加上winpty 即可


### 2.2 docker管理nginx

      docker exec dnmp-nginx nginx -s reload    重启nginx
       在容器内执行shell命令：
       docker exec -it dnmp-nginx sh -c "ps -aef | grep nginx | grep -v grep | grep master |awk '{print $2}'"

### 2.3 docker管理mysql

    进入mysql容器  docker exec -it dnmp-mysql sh
    
    修改配置文件 my.cnf，重新加载：docker-compose restart mysql
    
    容器内连接：mysql -uroot -p123456
    
    外部宿主机连接：mysql -h 127.0.0.1 -P 3308 -uroot -p123456
    
    数据-备份-恢复
    
    导出（备份）
    导出数据库中的所有表结构和数据：docker exec -it dnmp-mysql mysqldump -uroot -p123456 test > test.sql
    只导结构不导数据：docker exec -it dnmp-mysql mysqldump --opt -d -uroot -p123456 test > test.sql
    只导数据不导结构：docker exec -it dnmp-mysql mysqldump -t -uroot -p123456 test > test.sql
    导出特定表的结构：docker exec -it dnmp-mysql mysqldump -t -uroot -p123456 --table user > user.sql
    导入（恢复）docker exec -i dnmp-mysql -uroot -p123456 test < /home/www/test.sql
    如果导入不成功，检查sql文件头部：mysqldump: [Warning] Using a password on the command line interface can be insecure.是否存在该内容，有则删除即可

### 2.4 docker管理redis

    连接Redis容器：docker exec -it dnmp-redis redis-cli -h 127.0.0.1 -p 63789
    
    通过容器连接：docker exec -it dnmp-redis redis-cli -h dnmp-redis -p 63789
    
    单独重启redis服务 docker-compose up --no-deps -d redis
    
    外部宿主机连接：redis-cli -h 127.0.0.1 -p 63789  

### 2.5 docker管理crontab

    执行方案
    1、使用主机的cron实现定时任务（推荐）
    2、创建一个新容器专门执行定时任务，crontab for docker
    3、在原有容器上安装cron，里面运行2个进程


### 2.6 docker管理websocket

     1.进入dnmp-php容器：docker exec -it dnmp-php sh
     2.以daemon（守护进程）方式启动 workerman / swoole
     3.宿主机平滑重启 
     4.env 配置了对应对外端口
     5.防火墙问题，如果使用阿里云ESC，请在安全组增加入方向和出方向端口配置
         协议类型：自定义 TCP
         端口范围：9573/9573  （env对应配置）
         授权对象：0.0.0.0/0
     6.通过telnet命令检测远程端口是否打开



## 3.php相关管理

### 3.1 切换PHP版本

PHP的很多功能都是通过扩展实现，而安装扩展是一个略费时间的过程，
所以，除PHP内置扩展外，在`env.sample`文件中我们仅默认安装少量扩展，
如果要安装更多扩展，请打开你的`.env`文件修改如下的PHP配置，
增加需要的PHP扩展：
```bash
PHP_EXTENSIONS=pdo_mysql,opcache,redis       # PHP 要安装的扩展列表，英文逗号隔开
PHP_EXTENSIONS=opcache,redis                 # PHP 要安装的扩展列表，英文逗号隔开
```
然后重新build PHP镜像。
```bash
docker-compose build php
```
可用的扩展请看同文件的`env.sample`注释块说明。

### 3.3 快速安装php扩展

```sh
docker exec -it php /bin/sh

install-php-extensions memcached 



## 4.nginx站点的配置   

- 复制  /dnmp/services/nginx/conf.d/localhost.conf文件  在同一个目录下，自定义名称（例如anfo.conf）

- 更改其中的域名地址 和站点目录

  ​          server_name  站点的域名;
  ​           root   站点的目录;

- 在虚拟机中创建对应的站点目录文件夹，将代码放在此文件夹中

- 在本机的host文件中添加ip 和域名地址绑定
- 使用acme.sh为网站免费添加https
 ​ 改用中科大源

   >sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
   >
   >apk update
   
- 用curl下载安装acme.sh，并开启自动更新

   >apk add --no-cache curl openssl socat
   
   >curl https://get.acme.sh | sh   

- 生成证书

   > ~/.acme.sh/acme.sh --issue -d www.xx.com --nginx
  
- 将证书复制到指定目录并设置自动更新,输入如下命令

   > ~/.acme.sh/acme.sh --installcert -d xx.com \
   > 
   > --key-file /etc/nginx/conf.d/ssl/xx.com/xx.key \
   >                    
   > --fullchain-file /etc/nginx/conf.d/ssl/xx.com/fullchain.cer \
   >                     
   > --reloadcmd "nginx -s reload"
   
- nginx配置文件中导入证书，设置证书生效

   >ssl_certificate /etc/nginx/conf.d/ssl/xx.com/fullchain.cer; 
  
   >ssl_certificate_key /etc/nginx/conf.d/ssl/xx.com/xx.key;  
   


## 5.使用Log

Log文件生成的位置依赖于conf下各log配置的值。

### 5.1 Nginx日志
Nginx日志是我们用得最多的日志，所以我们放在lnmp的安装目录/www/lnmp-docker/目录`log`下。

`log`会目录映射Nginx容器的`/var/log/nginx`目录，所以在Nginx配置文件中，需要输出log的位置，我们需要配置到`/var/log/nginx`目录，如：

```
error_log  /var/log/nginx/nginx.localhost.error.log  warn;
```


### 5.2 PHP-FPM日志
大部分情况下，PHP-FPM的日志都会输出到Nginx的日志中，所以不需要额外配置。

另外，建议直接在PHP中打开错误日志：
```php
error_reporting(E_ALL);
ini_set('error_reporting', 'on');
ini_set('display_errors', 'on');
```

如果确实需要，可按一下步骤开启（在容器中）。

1. 进入容器，创建日志文件并修改权限：
    ```bash
    $ docker exec -it dnmp_php_1 /bin/bash
    $ mkdir /var/log/php
    $ cd /var/log/php
    $ touch php-fpm.error.log
    $ chmod a+w php-fpm.error.log
    ```
2. 主机上打开并修改PHP-FPM的配置文件`conf/php-fpm.conf`，找到如下一行，删除注释，并改值为：
    ```
    php_admin_value[error_log] = /var/log/php/php-fpm.error.log
    ```
3. 重启PHP-FPM容器。

### 5.3 MySQL日志
因为MySQL容器中的MySQL使用的是`mysql`用户启动，它无法自行在`/var/log`下的增加日志文件。所以，我们把MySQL的日志放在与data一样的目录，即项目的`mysql`目录下，对应容器中的`/var/lib/mysql/`目录。
```bash
slow-query-log-file     = /var/lib/mysql/mysql.slow.log
log-error               = /var/lib/mysql/mysql.error.log
```
以上是mysql.conf中的日志文件的配置。



## 6.可视化界面管理
本项目默认在`docker-compose.yml`中开启了用于MySQL在线管理的*phpMyAdmin*，以及用于redis在线管理的*phpRedisAdmin*，可以根据需要修改或删除。

### 6.1 phpmyadmin
phpMyAdmin容器映射到主机的端口地址是：`9080`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:9080

```

MySQL连接信息：
```
- username：root
- password：123456
```


### 6.2 phpredisadmin
phpRedisAdmin容器映射到主机的端口地址是：`9081`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:9081
```

### 6.3 portainer
portainer容器映射到主机的端口地址是：`8888`，所以主机上访问docker可视化界面的地址是：
```
http://localhost:8888
```

## 7.在正式环境中安全使用
要在正式环境中使用，请：
1. 在php.ini中关闭XDebug调试
2. 增强MySQL数据库访问的安全策略
3. 增强redis访问的安全策略


## 8.jenkins使用
 Jenkins是一个开源软件项目，用于监控持续重复的工作，旨在提供一个开放易用的软件平台，使软件的持续集成变成可能

### 8.1 jenkins配置webhook插件
 jenkins配置webhook插件:实现项目代码与git同步

- 安装Gogs webhook 插件  
  打开 系统管理 -> 管理插件 -> 可选插件 ，在右上角的输入框中输入“gogs”来筛选插件：进行插件的安装

- 构建任务  
  1：点击  新建任务 ，输入任务名，选择"构建一个自由风格的软件项目"  
  2：配置任务  
     > 添加任务描述  

     > Gogs Webhook勾选-->use Gogs sercret  
  
     > 源码管理，其他设置成默认即可 （重要）
     ![](https://raw.githubusercontent.com/sqq12345/e0702/master/%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20190625184058.png)
  
- git添加webhook  
  进入git项目，点击  【仓库设置 ->管理web钩子 ->添加web钩子 ->选择Gogs 设置推送地址 触发事件 勾选是否激活 】 即可  
  
    推送地址格式：    http(s)://<你的Jenkins域名地址>:8083/gogs-webhook/?job=<你的Jenkins任务名>
  
    你的Jenkins任务名：来源第一步创建的用户名  
  ![](https://raw.githubusercontent.com/sqq12345/e0702/master/%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_20190626092600.png)
- 测试是否配置成功  
   往git中推送数据，查看Jenkins服务器端是否直接自动同步数据

