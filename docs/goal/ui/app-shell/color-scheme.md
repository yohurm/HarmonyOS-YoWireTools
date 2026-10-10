# 浅色与深色

来源：D2「同名 Token，浅色与深色数值可以不同」；ibest-ui-v2 用 `resources/dark/element/color.json` 覆盖同名颜色，不在组件里写死 `#fff` / `#000`。BluetoothLowEnergy 把卡片写成 `Color.White`、把页面写成 `#F1F3F5`，本文只保留 `#F1F3F5` 作为浅色 `background_secondary`，卡片改 `comp_background_primary`。

跟随系统 `ColorMode`。设置里可以选浅色、深色、跟随系统，三个选项都只切换资源限定符，不复制一套组件。

深色画布是 `background_secondary` `#191A1C`。主按钮仍是 `brand`，深色为 `#317AF7`，字保持 `font_on_primary`。`warning` / `alert` / `confirm` 换深色表中的对应值，色相不变。

按下叠 `interactive_pressed`。禁用把文字降到 `font_fourth`，主按钮改为 `comp_emphasize_tertiary`，不另画灰色 Material 按钮。

分割线只用 `comp_divider`。不在深色里把分割线改成纯白实线。
