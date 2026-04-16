# Module Template

`ModuleTemplate` 是 `Scripts/generate_module.rb` 使用的模块脚手架模板。

生成器会基于这些模板产出一个新的 Objective-C 业务模块，默认目录结构如下：

```text
Sources/OCAppBox/Module/<ModuleName>
├── OCB<ModuleName>BootstrapTask.h
├── OCB<ModuleName>BootstrapTask.m
├── OCB<ModuleName>Module.h
├── OCB<ModuleName>Module.m
└── UI
    ├── OCB<ModuleName>ViewController.h
    └── OCB<ModuleName>ViewController.m
```

默认生成结果遵循当前仓库的约定：

- 类名前缀使用 `OCB`
- 模块实现 `OCBModuleProtocol`
- 页面默认继承 `OCBBaseViewController`
- 路由通过 `OCBRouter` 暴露
- 启动日志通过 `OCBLogging` 输出
- 自动追加 `OCB_EXPORT_MODULE(...)`，参与编译后可被 `autoRegisterModules` 自动接入
