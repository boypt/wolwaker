# WOL WEB Waker - 网络开机面版

通过路由器内运行的一段脚本`onlinewake_padavan.sh`把局域网内的设备信息注册到服务端，可随时从其他地方访问服务端发送唤醒特定设备的指令（ WOL - Wake on LAN ）。

![waker](https://raw.githubusercontent.com/pentie/wolwaker/master/doc/waker.png)

## 运行服务端

服务端是个简单的Node服务，基于Express。

```
git clone https://github.com/pentie/wolwaker.git
cd wolwaker/web
npm install
DEBUG=web:* npm start
```

## 运行唤醒端

唤醒端是运行在路由器内的一个脚本，目前只在padavan系统中测试。

* 修改onlinewake_padavan.sh文件内SERVER_URL的值为服务端的服务地址。
* 通过winscp发送onlinewake_padavan.sh到padavan中的/etc/storage/， 并设置可执行权限755
* 从web配置界面【自定义设置】- 【脚本】- 【在 WAN 上行/下行启动后执行】脚本中加入`/etc/storage/onlinewake_padavan.sh &`

![padavan](https://raw.githubusercontent.com/pentie/wolwaker/master/doc/padavan.png)

## 唤醒

通过手机等设备访问服务端，点对应设备的WAKE按钮，WOL开机指令会实时发送。


## 安全建议

部署服务端请务至少必配置HTTPS+Basic Auth （比如通过nginx代理实现），避免信息泄露。 
