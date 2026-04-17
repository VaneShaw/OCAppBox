# OCAppBox 技术规格说明

## 1. 文档目的

这份文档不是架构畅想，而是面向当前仓库的可执行技术规格。

主旨只有一个：

`OCAppBox` 必须是一套可以直接拿来起新 App 的 Objective-C starter app，而不是一个还需要二次封装才能落地的半成品框架。

拿到仓库后的标准路径应该是：

1. `git clone`
2. `pod install`
3. 打开 `OCAppBox.xcworkspace`
4. 改 `Bundle Identifier`
5. 改 `starterTabs`
6. 生成模块 / 页面 / 服务
7. 直接开始写业务页面

## 2. 目标与非目标

### 2.1 目标

- 根目录直接可运行，是一个完整 starter app
- 统一启动装配、模块接入、服务注册、路由跳转
- 内置常用宏、分类、基类和基础设施
- 内置 TabBar 宿主配置入口
- 内置模块 / 页面 / 服务生成脚手架
- 业务页面默认具备 loading / empty / error / toast 能力
- 网络层对业务暴露稳定抽象，不把第三方库泄漏到业务层
- 研发拿到仓库后，不需要先研究框架拆包流程就能开始开发

### 2.2 非目标

- 当前阶段不追求发布成可复用 Pod
- 当前阶段不追求一次性塞入大量第三方库
- 当前阶段不追求把所有业务场景都预置到仓库里

## 3. 启动型仓库验收标准

### 3.1 宿主工程

- 根目录必须存在 `OCAppBox.xcodeproj / OCAppBox.xcworkspace / Podfile`
- `App` 目录即业务源码目录，不允许再套 `Example -> Sources -> Framework`
- 直接修改 `Bundle Identifier` 后即可运行

### 3.2 启动配置

- 必须存在单一入口集中维护启动配置
- 至少可配置：
  - 默认环境
  - TabBar
  - 网络环境 `baseURL`
  - 公共请求头
  - API 返回协议映射
  - 默认远程配置

### 3.3 通用基础能力

- 宏定义：线程切换、weakify/strongify、屏幕尺寸、像素线、安全类型转换
- 分类扩展：`NSString / NSArray / NSDictionary / UIColor / UIView`
- 页面基类：`BaseViewController / BaseTableViewController / BaseCollectionViewController`
- 页面容器必须提供安全区内容视图，避免业务页面反复处理安全区

### 3.4 网络与服务

- 网络层统一暴露 `OCBRequest / OCBNetworking / OCBNetworkResponse / OCBNetworkError`
- 必须支持环境化 `baseURL`
- 必须支持通用业务响应解析
- 必须同时支持：
  - 状态型服务生成
  - 接口型服务生成

### 3.5 业务接入效率

- 必须可以一键生成模块
- 必须可以一键生成页面
- 必须可以一键生成服务
- 新生成页面应默认建立在统一基座上，而不是裸控制器

### 3.6 调试与回归

- 至少具备一个调试入口
- 必须有一条可重复执行的校验脚本
- 校验脚本必须覆盖构建、测试、依赖安装和脚手架 smoke test

## 4. 分层规格

### 4.1 Host

职责：

- App 启动装配
- 根控制器安装
- 启动默认配置注入

当前关键对象：

- `OCBDemoAppLauncher`
- `OCBDemoRouteCatalog`
- `OCBStarterAppConfiguration`

### 4.2 Core

职责：

- `OCBAppContext`
- `OCBModuleManager`
- `OCBRouter`
- `OCBServiceRegistry`
- `OCBAutoRegister`

要求：

- 模块与服务必须通过协议和注册中心解耦
- 宿主只依赖 `AppContext`、路由和模块自动装配能力

### 4.3 Foundation

职责：

- 宏
- 分类
- 工具类

要求：

- 只放高复用、低业务耦合能力
- 不放页面逻辑
- 分类命名统一 `OCBAdditions`

### 4.4 Infra

职责：

- 网络
- 存储
- 日志

要求：

- 对业务暴露稳定抽象
- 第三方库只能封装在内部

### 4.5 UI

职责：

- 页面基类
- 通用容器
- 主题
- 空态 / Loading / Toast

要求：

- `BaseViewController` 必须提供安全区内容容器
- 列表基类默认带下拉刷新能力

### 4.6 Service

职责：

- 横向业务公共服务

要求：

- 状态型服务面向配置、状态中心
- 接口型服务面向网络请求封装

### 4.7 Module

职责：

- 业务模块容器
- 模块启动任务
- 页面路由注册

要求：

- 每个模块目录独立
- 对外通过 `Module + BootstrapTask + Route` 接入

## 5. 第三方库策略

当前仓库目标不是“预装越多越好”，而是“保证 starter app 最小可用并且不臃肿”。

当前基线：

- `AFNetworking`

使用原则：

- 框架层只内聚少量、稳定、通用的底层库
- 不预置强业务倾向的组件库
- 新库进入前必须满足：
  - 多项目高频复用
  - 与 starter app 目标直接相关
  - 不引入明显的升级/维护负担

## 6. 当前仓库对照结果

### 6.1 已完成

- 根目录 starter app 结构
- `Bundle ID` 可直接修改
- `OCBStarterAppConfiguration` 启动配置收口
- `TabBar` 快速配置
- 模块 / 页面 / 服务生成器
- `state / api` 两类服务脚手架
- 网络环境与业务响应映射
- `UIView` 通用扩展
- `BaseViewController.contentView`
- 新页面模板接入 `contentView`
- 调试面板
- `validate_project.sh`

### 6.2 本轮已补能力

- 新建正式技术规格文档
- 补 `UIView` 通用扩展
- 补 `BaseViewController.contentView`
- 把新页面模板切到 `contentView`

### 6.3 后续仍建议继续补

- 埋点基础抽象
- Keychain / 安全存储
- 路由常量生成辅助
- 主题 token 进一步结构化
- 更明确的业务模块示例链路

## 7. 开发约定

- 页面开发优先使用 `contentView`
- 业务请求优先继承 `OCBBaseAPIService`
- 业务状态服务优先使用 `generate_service.rb --kind state`
- 接口服务优先使用 `generate_service.rb --kind api`
- 新页面、新模块、新服务落地后优先跑 `bash Scripts/validate_project.sh`

## 8. 结论

判断这个仓库是否达标，不看它有多少概念，而看它能不能满足下面这句话：

“下载下来，改一个 Bundle ID，配一下 TabBar，就能直接开始开发业务页面。”

后续所有补充，都应该围绕这句话做增量建设。
