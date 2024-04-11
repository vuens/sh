# BASH 我的脚本仓库
## 1. gg2fa：linux系统ssh登录添加谷歌双重验证
包含`dg2fa.sh`和`gg2fa.sh`两个脚本。
详细内容：
- 更改主机名，方便记忆
- 更新系统时间为上海
- 安装配置Google Authenticator
- 修改ssh相关配置
- 卸载功能
###1.1 dg2fa.sh
其中`dg2fa.sh`在Debian系统上运行经过测试，理论Ubuntu系统也没问题。
使用方法：
```
wget -O - https://github.com/gitcomy/bash/raw/main/dg2fa.sh | bash
```
###1.2 gg2fa.sh
另外`gg2fa.sh`脚本莅临兼容debian、ubuntu、centos，未经测试。
使用方法：
```
wget -O - https://github.com/gitcomy/bash/raw/main/gg2fa.sh | bash
```
