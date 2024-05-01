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
curl -sSL https://github.com/vuens/sh/raw/main/dg2fa.sh > dg2fa.sh; bash dg2fa.sh
```
### 1.2 gg2fa.sh
另外`gg2fa.sh`脚本理论兼容debian、ubuntu、centos，未经测试。
使用方法：
```
curl -sSL https://github.com/vuens/sh/raw/main/gg2fa.sh > gg2fa.sh; bash gg2fa.sh
```
## 2. bt512：小内存VPS宝塔面板安装mysql5.6+
使用方法：
```
curl -sSL https://github.com/vuens/sh/raw/main/bt512.sh > bt512.sh; bash bt512.sh
```
