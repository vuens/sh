# BASH 我的脚本仓库
<img src="bg-triangles.svg" alt="svg" width="300" >   <img src="bg-triangles.4gxfwd3v1880[1].webp" alt="webp" width="300" >


[一键换源](https://linuxmirrors.cn/use/)

## 1. gg2fa：linux系统ssh登录添加谷歌双重验证
[特别鸣谢](https://www.infvie.com/ops-notes/google-authenticator-sshd.html)

包含`dg2fa.sh`和`gg2fa.sh`两个脚本。
详细内容：
- 更改主机名，方便记忆
- 更新系统时间为上海
- 安装配置Google Authenticator
- 修改ssh相关配置
- 卸载功能

### 1.1 dg2fa.sh
其中`dg2fa.sh`在Debian系统上运行经过测试，理论Ubuntu系统也没问题。
使用方法：
```
curl -sSL https://raw.githubusercontent.com/vuens/sh/main/dg2fa.sh -o dg2fa.sh; chmod +x dg2fa.sh; ./dg2fa.sh
```
### 1.2 gg2fa.sh
另外`gg2fa.sh`脚本理论兼容debian、ubuntu、centos等大部分常用 Linux 发行版，未经测试。
使用方法：
```
curl -sSL https://raw.githubusercontent.com/vuens/sh/main/gg2fa.sh -o gg2fa.sh; chmod +x gg2fa.sh; ./gg2fa.sh
```
## 2. bt512：小内存VPS宝塔面板安装mysql5.6+
使用方法：
```
curl -sSL https://github.com/vuens/sh/raw/main/bt512.sh > bt512.sh; bash bt512.sh
```
###gitssh.sh<br/>
####脚本功能#
- 设置 Git 用户名和邮箱<br/>
脚本会提示用户输入 Git 用户名和邮箱,并将其设置为全局配置。

- 生成新的 SSH 密钥<br/>
脚本会自动生成新的 SSH 密钥对(私钥和公钥),用于与 GitHub 建立安全连接。在生成过程中,用户可以持续按回车键使用默认设置。

- 将 SSH 私钥添加到 ssh-agent<br/>
脚本会自动将生成的 SSH 私钥添加到 ssh-agent 中,以便在后续推送或拉取代码时无需每次手动输入密钥。

- 将 SSH 公钥复制到剪贴板(可选)<br/>
如果用户的系统安装了 xclip 工具,脚本会尝试自动将 SSH 公钥内容复制到剪贴板,方便用户在 GitHub 上配置。如果系统未安装 xclip,脚本会输出公钥内容,提示用户手动复制。

- 提供 GitHub 配置指引<br/>
脚本会给出在 GitHub 上添加 SSH 公钥的详细步骤,引导用户完成配置。

- 测试 SSH 连接<br/>
最后,脚本会尝试通过 SSH 连接到 GitHub,验证配置是否成功。如果连接成功,将输出相应的提示信息。
