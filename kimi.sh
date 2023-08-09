 #!/bin/bash

uChar="Hello Linux ！";    #欢迎词
echo $uChar;

#操作项目
action_list[0]="update";            #系统更新
action_list[1]="vim";               #安装vim
action_list[2]="clash";
action_list[3]="chrome";
action_list[4]="nginx";
action_list[5]="php-fpm";
action_list[6]="mysql-server";
action_list[7]="phpmyadmin";
action_list[8]="curl";
action_list[9]="git";



#输出选项
for i in ${!action_list[*]}
do
    printf "%d %c %s\n" $i . ${action_list[i]};
done
echo "请输入选项对应的数字：";
read uNum;

case $uNum in
        1|4|5|6|7|8|9)
        printf "%s %s\n" 开始安装 ${action_list[$uNum]};
        printf "%s %s %s %s\n" apt install ${action_list[$uNum]} -y;
        apt install ${action_list[$uNum]} -y
    ;;
    0)  echo "开始检查系统更新";
        echo "apt update;";
        apt update;
        echo "开始执行系统更新";
        echo "apt upgrade;";
        apt upgrade
    ;;
    2)  cp="0.20.31";
        up="Clash.for.windows-"$cp"-x64-linux.tar.gz"
        url="https://github.com/Fndroid/clash_for_windows_pkg/releases/download/"$cp"/"$up;
        echo "执行安装clash for windows,开始下载安装包";   
        echo "wget "$url;
        wget $url;
        echo "解压至/etc";
        echo "sudo tar -zvxf ./"$up" -C /etc";
        sudo tar -zvxf ./$up -C /etc;
        echo "开启cfw";
        echo "/etc/Clash.for.windows-"$cp"-x64-linux/cfw;";
        /etc/Clash.for.windows-$cp-x64-linux/cfw;
        echo "删除安装包";
        echo "#rm ./"$up;
        rm ./$up
    ;;
    3)  url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb";
        echo "执行安装google-chrome,开始下载安装包";  
        echo "wget "$url;
        wget $url;
        echo "正在执行安装...";
        echo "apt install ./google-chrome-stable_current_amd64.deb -y;";
        apt install ./google-chrome-stable_current_amd64.deb -y;
        echo "打开google-chrome";
        google-chrome;
        echo "打开密钥环配置";
        seahorse;
        echo "删除安装包";
        echo "rm ./google-chrome-stable_current_amd64.deb;";
        rm ./google-chrome-stable_current_amd64.deb
    ;;
esac

echo "安装结束，1.退出 2.继续";
read uCh;
if test $uCh = 1
then
    echo '感谢使用，bye';
    exit;
else
    echo "清除屏幕，并重新进入";
    clear;
    ./test.sh;
fi
