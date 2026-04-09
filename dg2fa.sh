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
        sed -i "1i 127.0.0.1       $new_hostname" /etc/hosts
        echo "主机名修改完成。"

        # 更新软件包列表并安装Google Authenticator和时间同步相关包
        echo "更新软件包列表并安装Google Authenticator和时间同步组件..."
        apt update && apt install -y libpam-google-authenticator systemd-timesyncd

        # 修改时区为上海并配置时间同步（完全按文章方法）
        read -p "是否要修改时区并配置时间同步？(y/n，默认为y): " response
        if [ "$response" = "y" ] || [ -z "$response" ]; then
            echo "修改时区为上海..."
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
            echo "时区修改完成。"

            # ---- 按文章配置systemd-timesyncd时间同步开始 ----
            echo -e "\n[+] 正在按Debian 12标准配置systemd-timesyncd时间同步..."
            
            # 1. 启用并启动systemd-timesyncd服务（文章步骤2）
            systemctl enable systemd-timesyncd
            systemctl start systemd-timesyncd
            echo "[*] systemd-timesyncd服务已启用并启动"

            # 2. 备份原有timesyncd配置（新增，防止配置丢失）
            cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.bak
            echo "[*] 已备份原有timesyncd配置至 /etc/systemd/timesyncd.conf.bak"

            # 3. 配置NTP服务器（文章步骤3，替换为国内优质服务器）
            cat > /etc/systemd/timesyncd.conf << EOF
[Time]
NTP=ntp.aliyun.com ntp1.aliyun.com ntp.tencent.com cn.pool.ntp.org
FallbackNTP=time.windows.com time.apple.com
EOF
            echo "[*] 已写入国内NTP服务器配置"

            # 4. 重启NTP服务应用更改（文章步骤4）
            systemctl restart systemd-timesyncd
            echo "[*] systemd-timesyncd服务已重启"

            # 5. 检查时间同步状态（文章步骤5）
            echo -e "\n[*] 时间同步状态检查："
            timedatectl status

            # 6. 设置RTC硬件时钟使用UTC（文章步骤6）
            timedatectl set-local-rtc 0
            echo "[*] 已设置RTC硬件时钟使用UTC"

            # 验证当前时间
            echo "[+] 时间同步配置完成，当前时间：$(date)"
            # ---- 按文章配置systemd-timesyncd时间同步结束 ----
        else
            echo "跳过时区修改和时间同步配置。"
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
        echo "无效的选项，退出脚本。"
        ;;
esac
