## iOS 运行项目

确保您已经安装完成 [iOS 所需环境](https://eeui.app/guide/env.html#%E5%BC%80%E5%8F%91-ios)。

`cd`到此目录下的`eeuiApp` 执行`pod install`命令来拉取iOS工程的依赖
```
pod install
```

首次执行时间会稍长，命令执行完毕后找到当前目录下 `eeuiApp.xcworkspace` 文件，双击即可唤起XCode打开 iOS 工程；

然后在XCode选择相应的模拟器（比如iPhone xs），点击`▶`按钮来运行项目。
