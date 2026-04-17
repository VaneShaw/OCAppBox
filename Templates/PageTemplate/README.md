# Page Template

`PageTemplate` 是 `Scripts/generate_page.rb` 使用的页面脚手架模板。

支持三种页面类型：

- `plain`：普通内容页，适合表单、详情、设置入口
- `table`：列表页，默认带 `UITableView` 和下拉刷新入口
- `collection`：卡片 / 宫格页，默认带 `UICollectionView` 和下拉刷新入口

推荐用法：

```bash
ruby Scripts/generate_page.rb Home Feed --type table
ruby Scripts/generate_page.rb Account Profile --type collection
```

默认会生成到 `App/Module/<ModuleName>/UI`。
