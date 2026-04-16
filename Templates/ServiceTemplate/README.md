# Service Template

`ServiceTemplate` 是 `Scripts/generate_service.rb` 使用的服务脚手架模板。

生成器默认产出一个“状态型服务”骨架，适合以下场景：

- 远程配置
- 功能开关
- 实验分桶
- 页面级本地状态中心
- 业务公共配置服务

默认生成结果包含：

- `OCB<ServiceName>Providing` 协议
- `OCB<ServiceName>DidChangeNotification`
- `OCB<ServiceName>Service` 默认实现
- `storage + logger` 两个常见依赖注入点
- 自动追加 `OCB_EXPORT_SERVICE(...)`，创建 `OCBAppContext` 时会自动注册到 `serviceRegistry`

推荐示例：

```bash
ruby Scripts/generate_service.rb FeatureFlag --domain Config
ruby Scripts/generate_service.rb HomePreference --domain User
```
