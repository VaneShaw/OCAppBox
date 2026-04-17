# OCAppBox 架构计划

## 1. 定位

`OCAppBox` 不只是一个工具类集合，而是一套面向 iOS Objective-C App 的“基础框架 + 业务接入规范”。

目标是让新 App 在立项后能直接复用下面这些能力：

- 应用启动骨架
- 模块化组织方式
- 基础设施接入规范
- 通用 UI 基座
- 业务服务抽象
- Starter App 工程和模板

## 2. 架构原则

### 2.1 分层清晰

底层能力向上提供服务，上层业务不反向侵入底层。

依赖方向建议如下：

`Foundation -> Core -> Infra / UI / Service -> Module -> App Host`

### 2.2 Objective-C 友好

- 所有公开类统一前缀，建议使用 `OCB`
- 优先使用 `Protocol + Registry` 方式解耦模块
- 尽量减少全局单例扩散，把单例收敛到受控中心
- 分类只补充安全和高复用能力，避免大范围方法污染

### 2.3 直接可用

仓库当前优先保证“clone 后直接开发”，而不是先做额外的发布拆包流程。

## 3. 目录规划

```text
App
├── Core
├── Foundation
├── Infra
├── Module
├── Service
├── Support
└── UI
```

各目录职责如下。

### 3.1 Core

负责应用主干能力，是整个框架的核心层。

建议包含：

- `OCBAppContext`：全局运行时上下文
- `OCBModuleManager`：模块注册、启动阶段分发
- `OCBRouter`：页面路由和 URL/Path 映射
- `OCBServiceRegistry`：协议到实现的服务注册中心
- `OCBLaunchTask`：启动任务协议和优先级编排

### 3.2 Foundation

负责最基础的公共能力。

建议包含：

- `Macro`：日志、线程、弱引用、颜色、尺寸等常用宏
- `Category`：`NSString`、`NSArray`、`NSDictionary`、`UIView` 等安全扩展
- `Util`：时间、加解密、校验、设备信息、文件处理
- `BaseModel`：统一模型基类和序列化约定

当前仓库已经补齐一版 `Foundation` 起步能力：

- `OCBFoundationMacros`
- `NSArray+OCBAdditions`
- `NSString+OCBAdditions`
- `NSDictionary+OCBAdditions`
- `UIColor+OCBAdditions`
- `OCBAppMetadata`

### 3.3 Infra

负责和外部系统、系统能力打交道的基础设施层。

建议拆为：

- `Network`
- `Storage`
- `Log`
- `Analytics`
- `Config`
- `Security`

核心对象建议：

- `OCBNetworkClient`
- `OCBRequest`
- `OCBNetworkResponse`
- `OCBNetworkError`
- `OCBCacheCenter`
- `OCBLogger`
- `OCBConfigCenter`
- `OCBKeychainStore`

当前仓库中的 `Infra/Network` 已切到 `AFNetworking` 封装，但 `AFNetworking` 只停留在框架内部：

- 对外继续暴露 `OCBNetworking`
- 业务模块直接使用 `OCBRequest`
- 返回统一的 `OCBNetworkResponse / OCBNetworkError`
- 支持按环境管理 `baseURL`

### 3.4 UI

负责通用 UI 基座，目标是减少每个业务页面从头搭建的成本。

建议包含：

- `OCBThemeManager`
- `OCBBaseViewController`
- `OCBBaseTableViewController`
- `OCBBaseCollectionViewController`
- `OCBNavController`
- `OCBLoadingView`
- `OCBEmptyStateView`
- `OCBToast`
- 通用表单、列表、分页、刷新组件

### 3.5 Service

负责偏业务公共域的横向服务。

建议包含：

- `UserService`
- `AuthService`
- `PermissionService`
- `RemoteConfigService`
- `FeatureFlagService`
- `UploadService`

这一层通过协议向业务模块暴露，不直接写死页面逻辑。

### 3.6 Module

负责业务模块接入规范和业务组件容器。

建议约束：

- 每个业务模块独立目录
- 每个模块实现 `OCBModuleProtocol`
- 模块只通过 `Router` 和 `ServiceRegistry` 与外部通信
- 模块对外暴露 `public interface`，隐藏内部实现

业务模块示例：

- `Home`
- `Account`
- `Message`
- `Settings`

当前仓库已经内置 `Home`、`Profile` 和 `Account` 三个自动注册演示模块：

- `Home`：负责首页、路由入口、权限状态和空态能力演示
- `Profile`：负责业务模块生成后的默认页面演示
- `Account`：负责账号登录态、用户会话和远程配置联动演示

### 3.7 Support

负责研发和排障辅助能力。

建议包含：

- 环境切换
- 调试面板
- 网络日志查看
- 埋点调试
- 崩溃采集接入层
- 性能埋点开关

当前仓库已经落地一版 `Support/Debug`：

- `OCBDebugPanelModule`
- `OCBDebugPanelViewController`
- `ocb://support/debug` 调试路由

当前 `UI` 层也已经补上第一版页面起步基座：

- `OCBBaseViewController`
- `OCBBaseTableViewController`
- `OCBBaseCollectionViewController`
- `OCBToast`
- `OCBLoadingView`
- `OCBEmptyStateView`

## 4. 技术路线建议

### 4.1 第一阶段：单仓库基础版

先在一个仓库里完成以下闭环：

- 一个根目录直开的宿主 App
- 一套 `App` 源码
- 三个演示业务模块
- 本地可运行、可调试、可验证

当前 starter app 已经收敛成根目录直接可开的宿主工程：

- `App/Host/OCBDemoAppLauncher` 负责启动装配
- `App/Host/OCBDemoRouteCatalog` 负责宿主路由常量
- `starterTabs` 负责根 `TabBar` 配置

你直接改 `Bundle Identifier + starterTabs + 业务模块页面` 就能开始开发。

这个阶段先不追求过度拆包，重点是验证架构是否顺手。

### 4.2 第二阶段：模板化提效

如果你的目标是“快速开发 App”，模板化能力非常关键。

建议补齐：

- 新模块生成脚本
- 新页面模板
- Service 协议模板
- 路由注册模板
- 示例模块脚手架

当前仓库已提供模块生成脚本：

```bash
ruby Scripts/generate_module.rb Home
```

默认会生成一个带 `Module / BootstrapTask / ViewController` 的模块骨架，后续可以继续补 Service 和页面子组件模板。
生成后的模块实现默认带自动导出宏，可通过 `autoRegisterModules` 自动装配。

当前仓库也已提供服务生成脚本：

```bash
ruby Scripts/generate_service.rb FeatureFlag --domain Config
```

默认会生成一个带 `Providing 协议 + 默认实现 + storage/logger 注入点` 的服务骨架，适合作为远程配置、功能开关和业务公共状态中心的起点。
生成后的服务实现默认带自动导出宏，`OCBAppContext` 初始化时会自动注册。

当前仓库也已提供页面生成脚本：

```bash
ruby Scripts/generate_page.rb Home Feed --type table
```

默认会根据页面类型生成 `plain / table / collection` 三类 `ViewController` 骨架，并落到对应模块的 `UI` 目录。

当前仓库也已提供最小回归校验脚本：

```bash
bash Scripts/validate_project.sh
```

会覆盖：

- CocoaPods 依赖安装
- 根目录宿主工程编译
- `AppContext / ModuleManager / Router / ServiceRegistry / CacheCenter` 最小单测
- 模块 / 服务脚手架 smoke test

## 5. 编码规范建议

### 5.1 命名规范

- 类名前缀统一使用 `OCB`
- 协议使用 `OCB...Protocol`
- 路由常量统一集中管理
- 禁止业务模块直接依赖别的业务模块具体类

### 5.2 依赖规范

- `Foundation` 不依赖业务层
- `Core` 不依赖具体业务模块
- `Infra` 不直接操作页面跳转
- `UI` 不持有复杂业务状态
- `Module` 通过协议使用 `Service`

### 5.3 错误边界

建议所有基础能力统一输出：

- 错误码
- 错误域
- 调试日志
- 可观测埋点

这样后续定位线上问题会轻松很多。

## 6. 推荐里程碑

### M1：仓库初始化

- 建目录
- 建示例工程
- 建命名规范
- 建基础文档

### M2：内核打底

- 启动任务编排
- 模块注册
- 服务注册中心
- 路由中心

### M3：基础设施

- 网络层
- 本地缓存
- 日志中心
- 配置中心
- 账号和权限服务

### M4：UI 基座

- 基类控制器
- 通用导航容器
- 主题系统
- 列表页模板
- 空态、加载、提示组件

### M5：业务验证

- 接入三个真实业务模块
- 跑通登录、列表、详情、设置等典型流程
- 修正模块边界和依赖关系

当前基础版已经完成 `Home + Profile + Account` 三个演示模块接入，示例工程通过 `autoRegisterModules` 即可完成业务层验证。

### M6：复用整理

- 接入文档
- 模块模板工具
- 目录和发布方式再评估

## 7. 我建议你优先做的最小闭环

如果你要尽快把这个框架做出来，优先顺序建议是：

1. `Core`：启动、路由、服务注册
2. `Infra`：网络、缓存、日志
3. `UI`：基类控制器、导航、加载和空态
4. `Service`：账号、权限、远程配置
5. `Module`：先做 `Home` 和 `Account` 两个示例模块
6. `Templates`：补模块脚手架，真正把“快速开发”落下来

只有模板、规范和示例一起到位，这个框架才真的能提升 App 开发速度。
