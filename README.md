# OCAppBox

`OCAppBox` 是一个面向 iOS Objective-C 项目的基础框架仓库，目标是把一个 App 从零到一时反复搭建的公共能力先沉淀下来，让后续项目能围绕统一的架构快速启动。

详细规格说明见 [TECHNICAL_SPEC.md](/Users/ios01/OCAppBox/docs/TECHNICAL_SPEC.md)。

## 3 分钟快速开始

如果你的目标是“下载仓库后，直接把它当成 App 框架基座开始开发”，按下面这条链路走就够了。

### 0. 环境要求

- Xcode 15+
- Ruby
- CocoaPods

当前仓库根目录就是 starter app，本仓库不需要再通过 `pod 'OCAppBox'` 的方式接入自己。

### 1. 安装第三方依赖并打开工程

```bash
pod install
open OCAppBox.xcworkspace
```

如果你只是想快速验证当前仓库是否能跑，也可以直接打开 `OCAppBox.xcodeproj`。当前网络层内置了 `NSURLSession` 回退实现，没有安装 Pods 也能编译；但日常开发建议走 `xcworkspace`，这样 `AFNetworking` 会直接可用。

打开后直接运行 `OCAppBox`，你拿到的是一套已经接好这些能力的宿主骨架：

- `AppDelegate + main`
- `Host` 启动装配层
- `TabBar` 根容器和默认业务模块
- 路由、服务注册、模块自动装配
- 通用宏、分类、基类和 UI 基座
- `Podfile` 中的第三方依赖入口
- 调试面板
- 内置 `Home / Profile / Account` starter tab

### 2. 改 Bundle ID

在 Xcode 中选中：

- `OCAppBox`

然后修改：

- `Signing & Capabilities -> Bundle Identifier`

这一步做完，当前仓库就已经是你的 App 壳子了。

### 3. 配置你的启动骨架

直接改这里：

- `App/Host/OCBStarterAppConfiguration.m`

当前 starter app 已经把最常改的项目级配置收口到了一个文件里，你通常只需要维护这几处：

- `starterTabs`
- `defaultEnvironment`
- `networkBaseURLsByEnvironment`
- `networkCommonHeaders`
- `configureAPIResponseMapper`
- `bootstrapRemoteConfig`

比如最常见的是直接维护 `starterTabs`：

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

后面你的业务接入路径就是：

- 生成模块
- 注册路由
- 往 `starterTabs` 里补一个 tab

### 4. 生成你自己的业务模块和页面

```bash
cd /Users/ios01/OCAppBox
ruby Scripts/generate_module.rb Profile
ruby Scripts/generate_page.rb Profile Detail --type plain
ruby Scripts/generate_service.rb UserProfile --domain User
ruby Scripts/generate_service.rb Feed --domain API --kind api
```

默认会生成：

- `App/Module/Profile`
- `App/Module/Profile/UI/OCBProfileDetailViewController.*`
- `App/Service/User/OCBUserProfileService.*`

脚本执行后会自动刷新 `OCAppBox.xcodeproj`，所以你回到 Xcode 就能直接看到新文件。

### 5. 开始改页面

你通常最先改的是新模块页面：

- `App/Module/Profile/UI/OCBProfileViewController.m`

也就是从这里开始写你的第一个真实业务页面。

### 6. 想确认当前仓库可用，直接跑校验

```bash
bash Scripts/validate_project.sh
```

这会验证：

- 宿主工程能否构建
- 单元测试能否通过
- 宿主/模块/页面/服务生成器能否正常工作

## 快速判断

如果你现在问“这个仓库能不能下载下来直接作为一个新 App 的起步框架”，当前答案是：可以。

它已经具备：

- 当前仓库自身就是 starter app
- `Podfile` 已预留必要第三方库入口
- 可直接运行的宿主工程
- 一处配置 `TabBar` 的根容器 API
- 模块 / 页面 / 服务脚手架
- 路由、服务注册、启动装配
- 通用宏、分类、基类和 UI 基座
- 宿主工程和调试面板

## 设计目标

- 统一 App 启动、模块注册、路由和服务治理
- 沉淀网络、缓存、日志、配置、权限、账号等基础设施
- 提供可复用的 UI 基座和业务模块接入规范
- 通过模板和示例工程降低新项目初始化成本

## 建议模块

- `Core`：应用内核，负责启动、模块注册、路由、协议服务发现
- `Foundation`：宏、分类、工具类、基类和公共数据结构
- `Infra`：网络、缓存、日志、埋点、配置等基础设施
- `UI`：主题、导航容器、基类控制器、通用组件
- `Service`：账号、权限、远程配置、业务公共服务
- `Module`：业务模块接入层和业务组件规范
- `Support`：调试能力、环境切换、监控埋点接入

## 当前仓库结构

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
│   ├── APIServiceTemplate
│   ├── ModuleTemplate
│   ├── PageTemplate
│   └── ServiceTemplate
└── docs
```

## 内置演示模块

当前框架已经内置三个自动注册的 starter 模块，宿主工程只需要调用 `autoRegisterModules` 即可接入：

- `Home`：展示路由、权限、远程配置和空态能力
- `Profile`：作为业务模块生成后的默认页面示例
- `Account`：展示登录态、用户会话和远程配置联动

## 宿主模板

仓库根目录现在就是推荐直接开发的 starter app，你日常只需要关注这一层宿主结构：

- `App/Host/OCBDemoAppLauncher`：封装窗口初始化、`appContext` 创建、模块自动装配、`TabBar` 安装
- `App/Host/OCBStarterAppConfiguration`：集中维护默认环境、TabBar、baseURL、公共请求头和启动配置
- `App/Host/OCBDemoRouteCatalog`：集中管理宿主入口、Home、Account、Debug 的路由常量
- `OCBDemoAppLauncher` 内部会准备示例环境、远程配置和开发调试默认值

## Foundation 基座

`Foundation` 层已经提供一套可直接复用的基础能力：

- `OCBFoundationMacros`：弱强引用、主线程派发、屏幕尺寸、像素线和安全转换
- `NSString+OCBAdditions`：字符串清洗和空白判断
- `NSArray+OCBAdditions`：数组越界保护和 typed 安全读取
- `NSDictionary+OCBAdditions`：typed 安全读取
- `UIColor+OCBAdditions`：十六进制颜色值 / 颜色字符串转换
- `UIView+OCBAdditions`：常用 frame 读写、安全区读取和子视图清理
- `OCBAppMetadata`：App 名称、Bundle ID、版本号读取

## 网络基座

`Infra/Network` 现在基于 `AFNetworking` 做了一层框架内封装，业务侧仍然只依赖 `OCBRequest / OCBNetworking / OCBNetworkResponse`：

- `OCBAPIResponseMapper`：统一解析 `code / message / data / success`，并支持在宿主层改成你自己的返回协议
- `OCBRequest`：统一请求方法、参数、超时和序列化方式
- `OCBRequest`：支持 `GET / POST / PUT / DELETE` 快捷构造，减少接口层样板代码
- `OCBNetworkClient`：统一环境化 `baseURL`、公共请求头和请求发送
- `OCBNetworkResponse`：统一状态码、响应头、原始响应以及业务码 / message / data 解析结果
- `OCBNetworkError`：统一网络错误域、HTTP 错误和业务错误

当前调试面板已经支持查看和切换 `development / staging / production` 网络环境。

## Support 调试层

`Support` 层已经接入一个自动注册的开发调试面板：

- 路由：`ocb://support/debug`
- 入口：`Home` 页面上的“开发调试面板”按钮
- 能力：查看模块、路由、服务、登录态、权限状态、远程配置，并可切换首页空态开关

## UI 基座

`UI` 层现在除了基础页面和导航容器，还补上了更适合直接开写业务页面的起步基座：

- `OCBBaseViewController`：统一 `contentView + loading / empty / error / retry` 状态容器
- `OCBBaseTableViewController`：自带 `UITableView` 和下拉刷新入口
- `OCBBaseCollectionViewController`：自带 `UICollectionView` 和下拉刷新入口
- `OCBTabBarController`：一处描述即可快速装配根 `TabBar`
- `OCBTabBarItemDescriptor`：统一 tab 标题、路由和图标声明
- `OCBToast`：轻量页面提示
- `OCBThemeManager`：主题色统一入口

## 模块脚手架

已经内置模块生成器，可以直接产出符合当前框架约定的 Objective-C 模块骨架。

```bash
ruby Scripts/generate_module.rb Home
ruby Scripts/generate_module.rb AccountCenter --route ocb://account-center --title "Account Center"
```

默认生成到 `App/Module/<ModuleName>`，包含：

- `OCB<ModuleName>Module`
- `OCB<ModuleName>BootstrapTask`
- `UI/OCB<ModuleName>ViewController`

生成出的模块默认带 `OCB_EXPORT_MODULE(...)`，调用 `moduleManager autoRegisterModules` 后会自动接入。

## 服务脚手架

已经内置服务生成器，可以快速产出一个可编译的“状态型服务”骨架。

```bash
ruby Scripts/generate_service.rb FeatureFlag --domain Config
ruby Scripts/generate_service.rb HomePreference --domain User
ruby Scripts/generate_service.rb Feed --domain API --kind api
```

默认生成到 `App/Service/<Domain>`，包含：

- `OCB<ServiceName>Providing`
- `OCB<ServiceName>DidChangeNotification`
- `OCB<ServiceName>Service`

生成出的服务默认带 `OCB_EXPORT_SERVICE(...)`，创建 `OCBAppContext` 时会自动注册到 `serviceRegistry`。

当前支持两类服务：

- `state`：默认值，生成状态型服务，适合配置、本地状态和开关中心
- `api`：生成继承 `OCBBaseAPIService` 的接口型服务，适合直接封装网络请求

## 接口服务基座

如果你的服务主要职责是调接口，不建议从零开始写。当前仓库已经提供了 `OCBBaseAPIService`：

- 自动注入 `appContext`
- 自动拿到 `networking / logger / remoteConfig`
- 直接支持 `GET / POST / PUT / DELETE`
- 回调默认直接返回 `response.businessData`
- 统一保留 `response + error`
- 子类可通过重写 `responseDataForResponse:` 做二次封装

典型写法：

```objc
@interface OCBFeedAPIService : OCBBaseAPIService

- (void)fetchFeedWithCompletion:(OCBAPIServiceCompletion)completion;

@end

@implementation OCBFeedAPIService

- (void)fetchFeedWithCompletion:(OCBAPIServiceCompletion)completion
{
    [self GET:@"/feed" parameters:@{@"page": @1} completion:completion];
}

@end
```

## 页面脚手架

现在已经补上页面生成器，用来在模块内部快速新增页面，而不是每次手写空控制器。

```bash
ruby Scripts/generate_page.rb Home Feed --type table
ruby Scripts/generate_page.rb Account Profile --type collection
```

支持页面类型：

- `plain`
- `table`
- `collection`

默认生成到 `App/Module/<ModuleName>/UI`，并自动产出可编译的 `ViewController` 骨架。

## 一键校验

已经内置一套最小回归校验脚本，用于验证当前仓库的依赖安装、宿主工程构建和脚手架生成链路。

```bash
bash Scripts/validate_project.sh
```

脚本会执行：

- 根目录工程重建
- `OCAppBox.xcodeproj` 的 `clean build`
- `OCAppBoxTests` 的单元测试
- 根目录下 `pod install`
- `OCAppBox.xcworkspace` 的构建
- 页面生成器的 smoke test
- 模块 / 服务生成器的 smoke test

当前 starter app 已补上一组最小单元测试，覆盖：

- `OCBAppContext`
- `OCBDemoAppLauncher`
- `OCBModuleManager`
- `OCBRouter`
- `OCBServiceRegistry`
- `OCBCacheCenter`

## 下一步建议

1. 先把当前仓库当成真实 starter app 用起来，直接改 `Bundle ID + starterTabs + 模块页面`。
2. 再继续补你项目里真正常用的第三方库、业务基类、网络封装和组件库。
3. 等这套骨架在一个真实 App 中跑顺了，再决定要不要额外做发布复用和拆包。
