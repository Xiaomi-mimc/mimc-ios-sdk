# 更新日志

## [MMCSDK_2_2_3] - 2020-04-28

### 变更

* 优化sdk

## [MMCSDK_2_2_2] - 2020-03-09

### 变更

* parseProxyServiceToken从后台获取的数据原样返回，可参考demo<font color=red>注意！获取token返回的数据必须原样返回，否则程序无法照常运行</font>
* 消息回调加上返回类型，具体用法可参考demo
* 增加单点登录功能
* sdk中所有Boolean调整为BOOL

## [MMCSDK_2_2_0] - 2019-12-23

### 变更

* 增加发送在线消息接口
* 增加Conversation字段

## [MMCSDK_2_1_9] - 2019-12-12

### 变更

* 用户状态回调的参数统一

## [MMCSDK_2_1_8] - 2019-11-11

### 变更

* 优化sdk(优化fe/socket重连)

## [MMCSDK_2_1_7] - 2019-10-16

### 变更

* 优化sdk(敏感信息加密)

## [MMCSDK_2_1_6] - 2019-09-24

### 变更

* 优化sdk

## [MMCSDK_2_1_5] - 2019-09-11

### 变更

* 修复无限大群无法收到bizType的bug

## [MMCSDK_2_1_4] - 2019-08-22

### 变更

* 优化sdk

## [MMCSDK_2_1_3] - 2019-08-05

### 变更

* fix bug

## [MMCSDK_2_1_2] - 2019-07-10

### 变更

* 消息体`payload`大小限制从10k调整为15k。
* `MIMCServerAck`新增`code`值。

## [MMCSDK_2_1_1] - 2019-06-05

### 变更

* `user`初始化`initWithAppId`去掉`request`。
* 改变获取token方式，由开发者获取token返回给sdk。`parseProxyServiceToken:(void(^)(NSString *data))callback；`具体实现方式可参考demo。


## [MMCSDK_2_1_0] - 2019-05-21

### 变更

* fix bug

## [MMCSDK_2_0_9] - 2019-05-7

### 变更

* 新增信令群聊功能，具体用法参考文档

## [MMCSDK_2_0_8] - 2019-04-16

### 变更

* 修复登录用户信息不缓存时第一次发送消息失败问题
* 信令`sendRtsData`方法成功返回`dataId`，失败返回`-1`
* 信令单聊接口`rTsCallEventDelegate`更名为`handleRtsCallDelegate`
* 信令单聊回调`handleData`更名为`onData`，新增`frmoAccount`和`resource`参数
* 信令中参数`context`的类型由`void *`改为`id`
* 信令单聊回调`handleSendDataSuccess`更名为`onSendDataSuccess`
* 信令单聊回调`handleSendDataFail`更名为`onSendDataFailure`
* 接收消息回调`handleUnlimitedGroupMessage:(NSArray<MIMCGroupMessage*> *)packets`
* 接收消息回调`handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage`
* 无限大群回调部分部分参数名变更，具体可参考文档

## [MMCSDK_2_0_7] - 2019-04-02

### 变更

* 修复APP登录成功后，锁屏再解锁进行语音通话时APP闪退问题
* 修复关闭网络连接后，APP点击语音通话按钮闪退问题

## [MMCSDK_2_0_6] - 2019-02-28

### 变更

* 普通群和无限大群的`groupId`统一更名为`topicId`
* 信令回调中的`groupId`统一更名为`dataId`
* 修复login不缓存第一条消息无法发送问题

## [MMCSDK_2_0_5] - 2019-01-17

### 变更

* 音视频的`chatId`统一更名为`callId`

## [MMCSDK_2_0_4] - 2019-01-15

### 变更

* 初始化用户时加入`appId`
* 接收消息回调中的`serverAck`回调参数封装起来
* 单聊群聊和无限大群中`msg`更名为`payload`
* 登录状态回调`statusChange`中，`errType`更名为`type`，`errReason`更名为`reason`，`errDescription`更名为`desc`
* 无限大群回调`errMsg`更名为`desc`
* 信令回调`errMsg`更名为`desc`
* `LaunchedResponse.errMsg`更名为`desc`



