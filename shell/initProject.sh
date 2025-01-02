#!/bin/bash
# by skywalkerwei 2018.12.03

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if command_exists composer; then
	echo "composer 已安装"
else
	wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer
	chmod a+x /usr/local/bin/composer
fi


composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
echo "composer源 已切换"

D_Info=('base' 'fasebase')
if [ -z ${DSelect} ]; then
   DSelect="1"
   echo "You have 2 options for your project install."
   echo "1: Install ${D_Info[0]}  (Default)"
   echo "2: Install ${D_Info[1]}"
   read -p "Enter your choice (1, 2): " DSelect
fi

read -p "输入你的项目名称: " projectName;

if [ "${DSelect}" = "1" ]; then
   composer create-project kyle/admin  $projectName
else 
   composer create-project kyle/fastbase  $projectName
fi