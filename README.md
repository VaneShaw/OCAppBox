# OCAppBox

`OCAppBox` 是一个可直接运行的 iOS Objective-C starter app 仓库。

它的目标不是让你先搭一层框架，再去创建宿主工程，而是让你把仓库拉下来之后，安装依赖、改一下 `Bundle Identifier`、配一下 `TabBar`，就能直接开始写业务页面。

详细技术规格见 [docs/TECHNICAL_SPEC.md](docs/TECHNICAL_SPEC.md)。

## 仓库定位

这个仓库是：

- 一个新 App 的起步工程
- 一个已经接好基础能力的宿主工程
- 一个可以直接在上面继续开发页面的 starter app

这个仓库不是：

- 需要再通过 `pod 'OCAppBox'` 接入自己的框架
- `Example + Sources + Framework` 这种多层演示结构
- 还得先生成宿主工程才能开始开发的半成品

## 3 分钟开始

### 0. 环境要求

- Xcode 15+
- Ruby
- CocoaPods

### 1. 安装依赖并打开工程

```bash
git clone git@github.com:VaneShaw/OCAppBox.git
cd OCAppBox
pod install
open OCAppBox.xcworkspace
```

日常开发以 `OCAppBox.xcworkspace` 为准。

### 2. 改成你自己的 App

打开 Xcode 后，修改：

- `Signing & Capabilities -> Bundle Identifier`
- `Signing & Capabilities -> Team`
- `General -> Display Name`

改完这一步，当前仓库就已经是你的 App 壳子。

### 3. 配置启动骨架

启动配置统一收口在：

- `App/Host/OCBStarterAppConfiguration.m`

这里通常是你最先改的文件，主要维护：

- `starterTabs`
- `defaultEnvironment`
- `networkBaseURLsByEnvironment`
- `networkCommonHeaders`
- `configureAPIResponseMapper`
- `bootstrapRemoteConfig`

最常见的动作是直接改 `starterTabs`：

```objc
+ (NSArray<OCBTabBarItemDescriptor *> *)starterTabs
{
    return @[
        [OCBTabBarItemDescriptor itemWithTitle:@"Home"
                                     routePath:OCBDemoRouteHome
                               systemImageName:@"house"
                       selectedSystemImageName:@"house.fill"],
        [OCBTabBarItemDescriptor itemWithTitle:@"Profile"
                                     routePath:OCBDemoRouteProfile
                               systemImageName:@"person.crop.circle"
                       selectedSystemImageName:@"person.crop.circle.fill"],
        [OCBTabBarItemDescriptor itemWithTitle:@"Account"
                                     routePath:OCBDemoRouteAccount
                               systemImageName:@"gearshape"
                       selectedSystemImageName:@"gearshape.fill"]
    ];
}
```

### 4. 直接开始开发页面

这个仓库默认已经带了可运行的 starter 页面，你可以直接从这些文件开始改：

- `App/Module/Home/UI/OCBHomeViewController.m`
- `App/Module/Profile/UI/OCBProfileViewController.m`
- `App/Module/Account/UI/OCBAccountViewController.m`

如果你的目标只是尽快开始业务开发，这一步就够了，不需要先理解全部架构细节。

## 可选脚手架

脚手架是提效工具，不是使用前置条件。

如果你不想手写重复骨架，可以使用：

```bash
ruby Scripts/generate_module.rb Profile
ruby Scripts/generate_page.rb Profile Detail --type plain
ruby Scripts/generate_route.rb Profile Detail
ruby Scripts/generate_service.rb UserProfile --domain User
ruby Scripts/generate_service.rb Feed --domain API --kind api
```

作用分别是：

- `generate_module.rb`
  - 生成业务模块骨架
- `generate_page.rb`
  - 在指定模块下生成页面骨架
- `generate_service.rb`
  - 生成状态型服务或接口型服务骨架
- `generate_route.rb`
  - 在 `App/Host/OCBDemoRouteCatalog` 中补齐页面路由常量，并输出可直接粘贴的路由注册代码片段

但即使完全不用这些脚本，仓库也必须仍然可以直接开发。

### 典型新增页面流程（5 分钟）

```bash
# 1) 生成页面骨架
ruby Scripts/generate_page.rb Profile Settings --type plain

# 2) 生成路由常量（自动更新 RouteCatalog）
ruby Scripts/generate_route.rb Profile Settings
```

然后做两件事即可：

1. 在 `Profile` 模块的 `BootstrapTask` 里注册路由（脚本会打印可粘贴代码）。
2. 在 `App/Host/OCBStarterAppConfiguration.m` 的 `starterTabs` 增加一个 tab 项（或从已有页面入口跳转）。

## 当前已经内置的基础能力

当前仓库已经具备一套可直接起步的基础能力：

- 启动装配
  - `AppDelegate + Host + AppContext`
- 根容器
  - 已接好 `Navigation + TabBar`
- 路由与模块注册
  - 模块自动装配、路由跳转、服务注册
- 通用宏
  - 线程切换、`weakify / strongify`、屏幕尺寸、像素线、安全类型转换
- 常用分类
  - `NSString / NSArray / NSDictionary / UIColor / UIView / UIImage`
- 页面基类
  - `OCBBaseViewController`
  - `OCBBaseTableViewController`
  - `OCBBaseCollectionViewController`
- 页面状态
  - loading / empty / error / toast
  - `OCBListStateContainerView`（列表页 loading / 空态 / 错误 + 重试，Masonry 布局）
- 页面安全区容器
  - 统一 `contentView`
- 网络基座
  - `OCBRequest / OCBNetworking / OCBNetworkResponse / OCBNetworkError`
- 服务基座
  - 状态型服务
  - 接口型服务
- 调试入口
  - 已内置开发调试面板

## 第三方依赖策略

这个 starter app 的目标不是一次性塞满所有库，而是先提供最常用、最基础、最稳定的依赖入口。

当前 `Podfile` 内置的基线依赖是：

- `AFNetworking`（网络）
- `Masonry`（布局）
- `SDWebImage`（图片加载与缓存）
- `MJRefresh`（列表下拉/上拉刷新）

同时仓库已经把与该依赖相关的兼容处理沉淀在 `post_install` 中，新项目使用这个仓库时不需要每次重复补这一层基础配置。

## 推荐开发方式

最推荐的日常开发路径是：

1. 打开 `OCAppBox.xcworkspace`
2. 改 `Bundle Identifier / Team / Display Name`
3. 改 `App/Host/OCBStarterAppConfiguration.m`
4. 先直接改已有 starter 页面
5. 需要拆分业务时，再生成模块 / 页面 / 服务

一句话总结就是：

“先开工，再按需要补结构”，不要为了开始写一个页面，先做一轮无效搭架子。

## 目录结构

```text
OCAppBox
├── App
│   ├── Host
│   ├── Core
│   ├── Foundation
│   ├── Infra
│   ├── Module
│   ├── Service
│   ├── Support
│   └── UI
├── Tests
├── Podfile
├── OCAppBox.xcodeproj
├── OCAppBox.xcworkspace
├── Scripts
├── Templates
└── docs
```

各层职责：

- `Host`
  - App 启动、根控制器安装、启动配置注入
- `Core`
  - `AppContext`、模块管理、路由、服务注册
- `Foundation`
  - 宏、分类、工具类
- `Infra`
  - 网络、存储、日志等基础设施
- `UI`
  - 页面基类、容器、主题、通用状态视图
- `Service`
  - 横向公共服务与接口封装
- `Module`
  - 业务模块组织与路由接入
- `Support`
  - 调试和开发辅助能力

## 校验命令

如果你想确认当前仓库依然处于可直接开发状态，执行：

```bash
bash Scripts/validate_project.sh
```

这条脚本会覆盖：

- 依赖安装
- 工程构建
- 单元测试
- 模块 / 页面 / 服务脚手架 smoke test

## 文档

- [技术规格说明](docs/TECHNICAL_SPEC.md)
- [架构说明](docs/ARCHITECTURE.md)

## 结论

`OCAppBox` 的使用原则已经固定：

- 仓库本身就是 App
- `pod install` 后直接开发
- 改一个 `Bundle Identifier`
- 配一下 `starterTabs`
- 直接开始写页面

如果某项设计不能让这条链路更顺，它就不是当前优先项。
