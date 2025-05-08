#!/bin/bash

echo "本脚本用于快速配置Git SSH连接。"

# 设置GitHub的user name和email
echo "请输入您的Git用户名:"
read git_username
git config --global user.name "$git_username"

echo "请输入您的Git邮箱:"
read git_email
git config --global user.email "$git_email"

# 生成一个新的SSH密钥
echo ""
echo "生成新的SSH密钥..."
echo "接下来的输入中，你可以持续的回车"
ssh-keygen -t rsa -C "$git_email"

# 获取SSH密钥文件路径
ssh_key_path=$(echo ~)/.ssh/id_rsa

# 将SSH私钥添加到 ssh-agent
echo ""
echo "将SSH私钥添加到ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add "$ssh_key_path"

# 将SSH公钥添加到GitHub账户
echo ""
echo "将SSH公钥添加到GitHub账户..."
ssh_key_pub=$(echo ~)/.ssh/id_rsa.pub
if command -v xclip >/dev/null; then
    echo "复制SSH公钥内容到剪贴板..."
    xclip -selection clipboard < "$ssh_key_pub"
else
    echo "无法自动复制SSH公钥，请手动复制以下内容："
    cat "$ssh_key_pub"
fi

echo ""
echo "请在 Github 页面进行配置"
echo "1.请登录GitHub，点击头像，然后在 Settings 页面点击左侧 SSH and GPG keys，随后请点击右上角绿色的 New SSH key。"
echo "2.在Title输入框内，为您的新key取个名字，在Key输入框内，粘贴前面复制好的公钥内容，您无需修改 Key type 下拉框，直接点击 Add SSH key 按钮即可。"
echo "完成后按任意键继续..."
read -n 1 -s

# 测试连接
echo ""
echo "测试SSH连接..."
echo "如果提示你需要继续连接，请输入yes！"

ssh -T git@github.com

echo ""
echo "如果提示中的用户名是您的，说明SSH key已经配置成功。"
