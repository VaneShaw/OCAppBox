# __APP_NAME__

这个目录由 `ruby Scripts/generate_app.rb __APP_NAME__` 生成。

## 启动方式

1. 进入当前目录执行 `pod install`
2. 打开 `__APP_NAME__.xcworkspace`
3. 运行 `__APP_NAME__` Scheme

## 当前宿主结构

- `__APP_PREFIX__AppLauncher`：创建 `OCBAppContext`，装配模块并安装根控制器
- `__APP_PREFIX__RouteCatalog`：集中管理宿主根路由和框架快捷入口
- `__APP_PREFIX__Module`：宿主根模块，负责注册首页路由
- `__APP_PREFIX__HomeViewController`：生成后的首页，直接可继续开发页面

## 默认路由

- 宿主根路由：`__ROOT_ROUTE_PATH__`
- Framework Home：`ocb://home`
- Account：`ocb://account`
- Debug：`ocb://support/debug`
