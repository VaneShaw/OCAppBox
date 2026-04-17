# API Service Template

`APIServiceTemplate` 是 `Scripts/generate_service.rb --kind api` 使用的接口服务脚手架模板。

生成器默认产出一个“接口型服务”骨架，适合以下场景：

- 列表接口
- 详情接口
- 登录注册
- 用户资料
- 需要统一走网络层的业务服务

默认生成结果包含：

- `OCB<ServiceName>Providing` 协议
- `OCB<ServiceName>Completion` 回调类型
- `OCB<ServiceName>Service` 默认实现
- 继承 `OCBBaseAPIService`
- 自动追加 `OCB_EXPORT_SERVICE(...)`

推荐示例：

```bash
ruby Scripts/generate_service.rb Feed --domain API --kind api
ruby Scripts/generate_service.rb UserProfile --domain User --kind api
```
