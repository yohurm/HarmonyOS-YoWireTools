# product/tablet（预留）

平板独立产品入口预留位。当前**未**注册到 `build-profile.json5`，不参与默认构建。

## 为何预留

官方分层允许产品定制层按设备拆多个 Entry HAP。Notes1 现阶段用单 Entry + `deviceTypes: [phone,tablet,2in1]`；当平板信息架构 / 导航 / 布局与手机分叉后，再启用本模块。

## 启用清单（日后）

1. 复制 `product/phone` 为起点，或从零建 Entry。
2. `module.json5`：
   - `"name": "tablet"`
   - `"type": "entry"`
   - `"deviceTypes": ["tablet"]`
3. `product/phone` 的 `deviceTypes` 收窄为 `["phone","2in1"]`（按实际上架策略调整）。
4. 在根 `build-profile.json5` 登记 `srcPath: "./product/tablet"`，并配置多目标产物。
5. 平板专属壳 / 分栏布局放本模块；业务仍依赖 `features/*` + `common/*`。

## 当前平板体验

由 `product/phone` 通过响应式断点（`common_platform` / `youi_kit`）覆盖，无需本模块即可在平板安装运行。
