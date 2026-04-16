# OCAppBox

`OCAppBox` 是一个面向 iOS Objective-C 项目的基础框架仓库，目标是把一个 App 从零到一时反复搭建的公共能力先沉淀下来，让后续项目能围绕统一的架构快速启动。

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
├── Example
├── Scripts
├── Sources
│   └── OCAppBox
│       ├── Core
│       ├── Foundation
│       ├── Infra
│       ├── Module
│       ├── Service
│       ├── Support
│       └── UI
├── Templates
│   ├── ModuleTemplate
│   └── ServiceTemplate
└── docs
```

## 内置演示模块

当前框架已经内置两个自动注册的示例模块，`Example` 宿主只需要调用 `autoRegisterModules` 即可接入：

- `Home`：展示路由、权限、远程配置和空态能力
- `Account`：展示登录态、用户会话和远程配置联动

## Example 宿主模板

`Example` 目录现在额外提供一层宿主模板，用来演示一个 App 如何在不改框架源码的前提下接入 `OCAppBox`：

- `Host/OCBDemoAppLauncher`：封装窗口初始化、`appContext` 创建、模块自动装配和根控制器安装
- `Host/OCBDemoRouteCatalog`：集中管理 Example 宿主入口、Framework Home、Account、Debug 的路由常量
- `Demo/OCBDemoHomeViewController`：作为宿主首页，直接提供 Framework Home / Account / Debug 的跳转入口

Example 宿主根路由使用 `ocb://demo/home`，不再和框架 `Home` 模块争抢 `ocb://home`。

## Foundation 基座

`Foundation` 层已经提供一套可直接复用的基础能力：

- `OCBFoundationMacros`：弱强引用、主线程派发、block 安全调用
- `NSString+OCBAdditions`：字符串清洗和空白判断
- `NSDictionary+OCBAdditions`：typed 安全读取
- `OCBAppMetadata`：App 名称、Bundle ID、版本号读取

## Support 调试层

`Support` 层已经接入一个自动注册的开发调试面板：

- 路由：`ocb://support/debug`
- 入口：`Home` 页面上的“开发调试面板”按钮
- 能力：查看模块、路由、服务、登录态、权限状态、远程配置，并可切换首页空态开关

## CocoaPods Subspec

当前 `podspec` 已经拆成可裁剪 subspec，默认安装 `Umbrella` 聚合层。

```ruby
pod 'OCAppBox', :path => '..'
pod 'OCAppBox/Foundation', :path => '..'
pod 'OCAppBox/Core', :path => '..'
pod 'OCAppBox/Service', :path => '..'
pod 'OCAppBox/Support', :path => '..'
```

可用 subspec：

- `Foundation`
- `Core`
- `Infra`
- `UI`
- `Service`
- `Module`
- `Support`
- `Umbrella`

## 模块脚手架

已经内置模块生成器，可以直接产出符合当前框架约定的 Objective-C 模块骨架。

```bash
ruby Scripts/generate_module.rb Home
ruby Scripts/generate_module.rb AccountCenter --route ocb://account-center --title "Account Center"
```

默认生成到 `Sources/OCAppBox/Module/<ModuleName>`，包含：

- `OCB<ModuleName>Module`
- `OCB<ModuleName>BootstrapTask`
- `UI/OCB<ModuleName>ViewController`

生成出的模块默认带 `OCB_EXPORT_MODULE(...)`，调用 `moduleManager autoRegisterModules` 后会自动接入。

## 服务脚手架

已经内置服务生成器，可以快速产出一个可编译的“状态型服务”骨架。

```bash
ruby Scripts/generate_service.rb FeatureFlag --domain Config
ruby Scripts/generate_service.rb HomePreference --domain User
```

默认生成到 `Sources/OCAppBox/Service/<Domain>`，包含：

- `OCB<ServiceName>Providing`
- `OCB<ServiceName>DidChangeNotification`
- `OCB<ServiceName>Service`

生成出的服务默认带 `OCB_EXPORT_SERVICE(...)`，创建 `OCBAppContext` 时会自动注册到 `serviceRegistry`。

## 一键校验

已经内置一套最小回归校验脚本，用于验证当前仓库的依赖安装、示例工程构建和脚手架生成链路。

```bash
bash Scripts/validate_example.sh
```

脚本会执行：

- `Example` 下 `pod install`
- `OCAppBoxExample` 的 `clean build`
- `OCAppBoxExampleTests` 的单元测试
- 模块 / 服务生成器的 smoke test

当前 Example 已补上一组最小单元测试，覆盖：

- `OCBAppContext`
- `OCBDemoAppLauncher`
- `OCBModuleManager`
- `OCBRouter`
- `OCBServiceRegistry`
- `OCBCacheCenter`

## 下一步建议

1. 先搭 `Core + Infra`，把启动流程、路由、服务注册、网络和日志打通。
2. 再补 `UI` 基座，统一导航、主题、空态、列表页、表单页。
3. 用 `Example` 工程接入两个演示业务模块，验证框架分层是否顺手。
4. 最后再抽成 `CocoaPods subspec` 或 `XCFramework` 形式对外复用。
