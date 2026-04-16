# OCAppBox Example

这个目录提供一个最小可接入的示例宿主工程。

## 当前内容

- `OCAppBoxExample.xcodeproj`：由脚本生成的最小 iOS App 工程
- `OCAppBoxExample/`：AppDelegate、主页控制器、演示模块
- `Podfile`：本地集成上层 `OCAppBox` pod

## 使用方式

1. 在仓库根目录执行脚本生成示例工程后，进入 `Example` 目录。
2. 执行 `pod install`。
3. 打开 `OCAppBoxExample.xcworkspace`。
4. 运行 `OCAppBoxExample` Scheme。
