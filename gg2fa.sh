#!/bin/bash

# 判断系统类型
if [ -f /etc/debian_version ]; then
    SYSTEM_TYPE="debian"
elif [ -f /etc/redhat-release ]; then
    SYSTEM_TYPE="centos"
else
    echo "不支持的系统。"
    exit 1
fi

# 提示用户选择
echo "请选择操作："
echo "1. 安装并配置 Google Authenticator"
echo "2. 卸载Google Authenticator并恢复ssh相关配置"
echo "3. 退出脚本"
read -p "请输入选项 (1、2 或 3): " option

# 根据用户选择执行相应操作
case $option in
    1)
        # 修改主机名
        read -p "修改主机名，方便区分记忆: " new_hostname
        hostnamectl set-hostname "$new_hostname"

        # 更新软件包列表并安装Google Authenticator和ntpdate
        echo "更新软件包列表并安装Google Authenticator和ntpdate..."
        if [ "$SYSTEM_TYPE" == "debian" ]; then
            apt update && apt install -y libpam-google-authenticator ntpdate
        elif [ "$SYSTEM_TYPE" == "centos" ]; then
            yum update && yum install -y google-authenticator-libpam ntpdate
        fi

        # 修改时区为上海并同步时间
        echo "修改时区为上海并同步时间..."
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        ntpdate time.nist.gov

        # 配置Google Authenticator
        echo "配置Google Authenticator..."
        google-authenticator

        # 配置PAM文件
        echo "配置PAM文件..."
        echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd

        # 修改ssh配置文件
        echo "修改ssh配置文件..."
        sed -i -r 's#^(KbdInteractiveAuthentication) no$#\1 yes#; s#(ChallengeResponseAuthentication) no#\1 yes#g' /etc/ssh/sshd_config

        # 重启SSH
        echo "重启SSH服务..."
        if [ "$SYSTEM_TYPE" == "debian" ]; then
            service ssh restart
        elif [ "$SYSTEM_TYPE" == "centos" ]; then
            systemctl restart sshd
        fi
        echo "Google Authenticator安装和配置完成。"
        ;;
    2)
        # 卸载 Google Authenticator
        echo "卸载 Google Authenticator..."
        if [ "$SYSTEM_TYPE" == "debian" ]; then
            apt remove --purge -y libpam-google-authenticator
        elif [ "$SYSTEM_TYPE" == "centos" ]; then
            yum remove -y google-authenticator-libpam
        fi

        # 恢复 PAM 文件
        echo "恢复 PAM 文件..."
        sed -i '/pam_google_authenticator.so/d' /etc/pam.d/sshd

        # 恢复 ssh 配置文件
        echo "恢复 ssh 配置文件..."
        sed -i -r 's#^(KbdInteractiveAuthentication) yes$#\1 no#; s#(ChallengeResponseAuthentication) yes#\1 no#g' /etc/ssh/sshd_config

        # 重启 SSH
        echo "重启 SSH 服务..."
        if [ "$SYSTEM_TYPE" == "debian" ]; then
            service ssh restart
        elif [ "$SYSTEM_TYPE" == "centos" ]; then
            systemctl restart sshd
        fi
        echo "Google Authenticator卸载和恢复完成。"
        ;;
    3)
        echo "退出脚本。"
        ;;
    *)
        echo "无效选项。"
        ;;
esac
