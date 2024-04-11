#!/bin/bash

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
        echo "主机名修改完成。"

        # 更新软件包列表并安装Google Authenticator和ntpdate
        echo "更新软件包列表并安装Google Authenticator和ntpdate..."
        apt update && apt install -y libpam-google-authenticator ntpdate
        echo -e "Google Authenticator安装完成，下面即将配置验证器。\n配置验证器时会有多次询问，请详细查看：\n1.是否启用基于时间的一次性密码验证，建议选择 y，然后使用谷歌验证器扫描二维码。\n2.是否在用户目录下更新验证文件，建议选择 y\n3.是否禁止一个口令多次使用，防止中间人攻击，建议选择 y\n4.【最长的一段】是否延长口令验证时间，避免客户端与服务器时间误差，除非时间同步很差，否则建议选择 n\n5.是否限制尝试次数，防止暴力攻击，建议选择 y"

        # 修改时区为上海并同步时间
        echo "修改时区为上海并同步时间..."
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        ntpdate time.nist.gov
        echo "时区和时间同步完成。"

        # 配置Google Authenticator
        echo "配置Google Authenticator..."
        google-authenticator
        echo "Google Authenticator配置完成。"

        # 配置PAM文件
        echo "配置PAM文件..."
        echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd
        echo "PAM文件配置完成。"

        # 修改ssh配置文件
        echo "修改ssh配置文件..."
        sed -i -r 's#^(KbdInteractiveAuthentication) no$#\1 yes#; s#(ChallengeResponseAuthentication) no#\1 yes#g' /etc/ssh/sshd_config
        echo "ssh配置文件修改完成。"

        # 重启SSH
        echo "重启SSH服务..."
        service ssh restart
        echo "SSH服务重启完成。"
        echo "Google Authenticator安装和配置完成。"
        ;;
    2)
        # 卸载 Google Authenticator
        echo "卸载 Google Authenticator..."
        apt remove --purge -y libpam-google-authenticator
        echo "Google Authenticator卸载完成。"

        # 恢复 PAM 文件
        echo "恢复 PAM 文件..."
        sed -i '/pam_google_authenticator.so/d' /etc/pam.d/sshd
        echo "PAM 文件恢复完成。"

        # 恢复 ssh 配置文件
        echo "恢复 ssh 配置文件..."
        sed -i -r 's#^(KbdInteractiveAuthentication) yes$#\1 no#; s#(ChallengeResponseAuthentication) yes#\1 no#g' /etc/ssh/sshd_config
        echo "ssh 配置文件恢复完成。"

        # 重启 SSH
        echo "重启 SSH 服务..."
        service ssh restart
        echo "SSH 服务重启完成。"
        echo "Google Authenticator卸载和恢复完成。"
        ;;
    3)
        echo "退出脚本。"
        ;;
    *)
        echo "无效选项。"
        ;;
esac
