#!/bin/bash

# 检测操作系统
get_os_type() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif [ -f /etc/centos-release ]; then
        OS="centos"
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    else
        OS="unknown"
    fi
    echo $OS
}

OS_TYPE=$(get_os_type)

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
        sed -i "1i 127.0.0.1       $new_hostname" /etc/hosts
        echo "主机名修改完成。"

        # 检测操作系统并安装所需软件
        echo "检测操作系统..."
        if [ "$OS_TYPE" == "ubuntu" ] || [ "$OS_TYPE" == "debian" ]; then
            echo "操作系统为 $OS_TYPE，使用 apt 安装..."
            apt update && apt install -y libpam-google-authenticator ntpdate
        elif [ "$OS_TYPE" == "centos" ] || [ "$OS_TYPE" == "rhel" ]; then
            echo "操作系统为 $OS_TYPE，使用 yum 安装..."
            yum install -y epel-release
            yum install -y libpam-google-authenticator ntpdate
        else
            echo "无法识别的操作系统：$OS_TYPE，请手动安装依赖。"
            exit 1
        fi

        # 修改时区为上海并同步时间
        read -p "是否要修改时区并同步时间？(y/n，默认为y): " response
        if [ "$response" = "y" ] || [ -z "$response" ]; then
            echo "修改时区为上海并同步时间..."
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            ntpdate time.nist.gov
            echo "时区和时间同步完成。"

            # ---- 自动时间同步功能增强开始 ----
            echo -e "\n[+] 正在配置多时间服务器自动同步..."

            # 定义多个时间服务器
            NTP_SERVERS=(
              "ntp.aliyun.com"
              "ntp1.aliyun.com"
              "ntp.tencent.com"
              "time.windows.com"
              "cn.pool.ntp.org"
            )

            echo "[*] 立即同步一次系统时间..."
            for server in "${NTP_SERVERS[@]}"; do
              echo "  -> 正在尝试服务器：$server"
              if ntpdate -u "$server" >/dev/null 2>&1; then
                hwclock -w
                echo "  ✓ 同步成功：$server"
                break
              else
                echo "  ✗ 同步失败：$server"
              fi
            done

            echo "[*] 添加 crontab 定时任务：每小时同步一次时间..."
            (crontab -l 2>/dev/null | grep -v 'ntpdate' ; echo "0 * * * * (ntpdate -u ntp.aliyun.com || ntpdate -u ntp1.aliyun.com || ntpdate -u ntp.tencent.com || ntpdate -u time.windows.com || ntpdate -u cn.pool.ntp.org) > /dev/null 2>&1 && hwclock -w") | crontab -

            echo "[+] 多服务器时间同步配置完成"
            # ---- 自动时间同步功能增强结束 ----
        else
            echo "跳过修改时区和同步时间。"
        fi

        # 安装前说明
        echo -e "Google Authenticator安装完成，下面即将配置验证器。\n配置验证器时会有多次询问，请详细查看：\n1.是否启用基于时间的一次性密码验证，建议选择 y，然后使用谷歌验证器扫描二维码。\n2.是否在用户目录下更新验证文件，建议选择 y\n3.是否禁止一个口令多次使用，防止中间人攻击，建议选择 y\n4.【最长的一段】是否延长口令验证时间，避免客户端与服务器时间误差，除非时间同步很差，否则建议选择 n\n5.是否限制尝试次数，防止暴力攻击，建议选择 y"

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
        apt remove --purge -y libpam-google-authenticator || yum remove -y libpam-google-authenticator
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
        echo "无效的选项，退出脚本。"
        ;;
esac
