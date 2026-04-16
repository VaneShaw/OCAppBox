# App Template

`AppTemplate` 是 `Scripts/generate_app.rb` 使用的宿主工程模板。

生成器默认会在 `Example/<AppName>` 下产出一个可运行的 Objective-C 宿主工程，包含：

- `AppDelegate + main`
- `Host` 启动装配层
- `Demo` 根模块和首页
- `Podfile`
- `README.md`

目标是让新项目不再从 `Example` 手动复制，而是通过脚本快速起一个带首页、路由和基础服务联调入口的宿主 App。
