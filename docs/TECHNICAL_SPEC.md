# OCAppBox Starter App 技术规格说明

## 1. 文档目的

这份文档用于约束 `OCAppBox` 这个仓库到底应该是什么，不再按“可复用 SDK / Pod / 示例工程”思路描述，而是按“下载下来直接作为新 App 起步工程”来定义。

判断标准只有一句话：

“把仓库拉下来，执行 `pod install`，打开工程，改一个 `Bundle Identifier`，配一下 `TabBar`，就能直接开始写页面。”

后续所有能力补充，都必须服务这条主线。

## 2. 核心定位

`OCAppBox` 的定位是：

- 一个可直接运行的 Objective-C starter app 仓库
- 一个新项目的基础工程骨架
- 一个已经内置必要公共能力的 App 宿主

`OCAppBox` 不是：

- 需要再通过 `pod 'OCAppBox'` 接入自己的框架
- 外层包一层 `Example`、里层再套 `Sources/Framework` 的演示工程
- 必须先跑复杂初始化流程才能开始开发的半成品

## 3. 标准使用路径

拿到仓库后的标准路径应该固定为：

1. `git clone`
2. `cd OCAppBox`
3. `pod install`
4. 打开 `OCAppBox.xcworkspace`
5. 修改 `Bundle Identifier / Team / App 名称`
6. 修改 `App/Host/OCBStarterAppConfiguration.m`
7. 配置 `starterTabs`
8. 直接改现有页面或新增页面开始业务开发

这里的关键原则是：

- “直接写页面”必须成立
- “使用脚手架生成模块 / 页面 / 服务”只是提效方式，不是开始开发的前置条件

## 4. 硬性验收标准

### 4.1 工程形态

- 根目录必须直接是可开发、可运行的 iOS 工程
- 根目录必须存在 `OCAppBox.xcodeproj / OCAppBox.xcworkspace / Podfile`
- 业务代码必须集中在 `App` 目录
- 不允许再出现 `Example -> Sources -> Framework` 这类多层壳结构
- 下载仓库后，开发者不需要再额外生成宿主工程

### 4.2 第一天可用性

- 新开发者第一次打开仓库，就能直接运行宿主工程
- 修改 `Bundle Identifier` 后即可作为自己的 App 壳子继续开发
- 首页启动必须是正常全屏，不允许再出现非全屏或启动配置异常
- 默认必须带一个可工作的 `TabBar` 宿主
- 默认必须带若干 starter 页面，方便直接替换内容而不是从空白工程起步

### 4.3 启动配置收口

- 启动相关配置必须集中维护，不能分散在多个入口
- 至少必须有一处统一维护下列项目：
  - 默认环境
  - `starterTabs`
  - 网络环境 `baseURL`
  - 通用请求头
  - 业务响应解析规则
  - 默认远程配置

当前统一入口应为：

- `App/Host/OCBStarterAppConfiguration`

### 4.4 直接开发入口

- 开发者不应被迫先理解全部框架细节才能写页面
- 至少要支持下面两条路径：
  - 直接修改现有 starter 页面继续开发
  - 新建页面后挂到 `starterTabs` 中快速接入
- 业务开发的最低门槛应当是“会改一个 ViewController”

### 4.5 基础能力基线

仓库必须自带一套足以支撑新项目起步的公共能力，至少包括：

- 常用宏定义
  - 线程切换
  - `weakify / strongify`
  - 屏幕尺寸
  - 像素线
  - 安全类型转换
- 常用分类扩展
  - `NSString`
  - `NSArray`
  - `NSDictionary`
  - `UIColor`
  - `UIView`
- 页面基类
  - `OCBBaseViewController`
  - `OCBBaseTableViewController`
  - `OCBBaseCollectionViewController`
- 页面状态能力
  - loading
  - empty
  - error
  - toast
- 页面安全区容器
  - 业务页面应优先往 `contentView` 放内容，而不是每页重复处理安全区

### 4.6 TabBar 快速装配

- 必须存在一处直接配置 `TabBar` 的 API
- 每个 tab 至少可以声明：
  - 标题
  - 路由或页面入口
  - 图标
- 增加一个 tab 的复杂度应控制在“新增页面 + 配一条 tab 描述”

### 4.7 网络与服务

- 网络层必须有统一抽象，业务层不能直接依赖第三方网络库
- 必须支持环境化 `baseURL`
- 必须支持公共请求头
- 必须支持业务响应统一映射
- 服务层必须至少满足：
  - 状态型服务
  - 接口型服务

### 4.8 第三方库策略

- `Podfile` 中应预置 starter app 必要的第三方库
- 这些库应该是“多数项目都会立刻用到”的基础依赖，而不是大而全堆砌
- 与依赖相关的兼容性修正应尽量沉淀在仓库自身的 `Podfile / post_install` 中
- 新项目使用这个仓库时，不应再重复手写这些基础依赖配置

当前基线：

- `AFNetworking`

### 4.9 调试与校验

- 至少应内置一个调试入口
- 必须存在一条可重复执行的校验脚本
- 校验脚本至少应覆盖：
  - 依赖安装
  - 工程构建
  - 单元测试
  - 模块 / 页面 / 服务脚手架 smoke test

## 5. 目录与分层约束

当前仓库推荐目录应保持清晰、直观，不再引入“框架包裹感”。

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

分层要求如下：

- `Host`
  - 负责 App 启动、根控制器安装、启动配置注入
- `Core`
  - 负责 `AppContext`、模块管理、路由、服务注册
- `Foundation`
  - 负责宏、分类、工具类
- `Infra`
  - 负责网络、存储、日志等底层能力
- `UI`
  - 负责页面基类、容器、主题、通用状态视图
- `Service`
  - 负责横向公共服务与接口封装
- `Module`
  - 负责业务模块组织与路由接入
- `Support`
  - 负责调试、开发辅助能力

## 6. 脚手架定位

仓库可以提供脚手架，但脚手架的定位必须明确：

- 是提效工具
- 不是使用门槛
- 不应该让用户误以为必须先“生成一个 App”才能开始开发

因此：

- `generate_module.rb` 用于快速生成业务模块骨架
- `generate_page.rb` 用于快速生成页面骨架
- `generate_service.rb` 用于快速生成服务骨架

但即使完全不使用这些脚本，仓库也必须仍然可以直接开发。

## 7. 当前仓库应满足的实际开发体验

对使用者来说，仓库需要提供的体验应该是：

1. 打开工程能直接跑起来
2. 改 `Bundle Identifier` 后就是自己的 App
3. 改 `starterTabs` 就能得到自己的底部导航结构
4. 直接改 `Home / Profile / Account` 之类的 starter 页面就能开始做业务
5. 如果嫌手写重复，再选择用脚手架提效

这意味着文档、代码和目录都要围绕“直接开工”设计，而不是围绕“展示框架概念”设计。

## 8. 当前仓库完成度对照

### 8.1 已满足

- 根目录已是 starter app 结构
- `App` 已作为主业务目录
- `Podfile` 已内置基础依赖入口
- `Bundle Identifier` 可直接修改
- `LaunchScreen` 已接入，启动为全屏形态
- `OCBStarterAppConfiguration` 已作为启动配置收口
- `starterTabs` 已可直接配置
- 已内置 starter 模块与页面
- 已具备宏、分类、页面基类、网络基座、调试面板
- 已提供模块 / 页面 / 服务脚手架
- 已提供 `validate_project.sh`

### 8.2 后续补齐建议

后续继续补能力时，优先补“多数 App 起步就会遇到的共性能力”，而不是继续扩概念。

优先级建议：

- Keychain / 安全存储封装
- 埋点 / tracking 抽象
- 路由常量与业务路由组织规范
- 主题 token 进一步结构化
- 一条完整的业务示例链路
  - 页面
  - service
  - network
  - loading / empty / error

## 9. 开发约定

- 页面开发优先继承基类，不建议直接从裸 `UIViewController` 起步
- 页面布局优先放到 `contentView`
- 网络请求优先通过统一服务层封装
- 能直接写页面时，不要为了“符合架构”而强行增加中间层
- 新增模块、页面、服务后，优先执行 `bash Scripts/validate_project.sh`

## 10. 结论

从现在开始，`OCAppBox` 的技术规格以“starter app 可直接落地”为唯一主线。

如果某项设计不能让下面这句话更成立，它就不是优先项：

“下载仓库，安装依赖，改一个 Bundle ID，配一下 TabBar，直接开始开发页面。”
