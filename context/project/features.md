# dashstock — 功能清單

> 最後更新：v0.3.0（2026-07-21）

---

## 圖表核心

| 功能 | 說明 |
|------|------|
| K 線圖 | `lightweight-charts` v5 CandlestickSeries，`yahoo-finance2` 資料來源 |
| Range 切換 | 1D / 5D / 1M / 3M / 6M / 1Y / 2Y / 5Y |
| 往左拉 lazy load | 向左捲動自動載入更多歷史資料（chunk 磁碟 cache，永久） |
| Intraday 支援 | 1D 使用 5m、5D 使用 15m interval；改用 Unix timestamp，支援往左拉 |


## 多股比較模式（compare mode）

2 檔以上股票時自動切換至 compare mode（LineSeries）。

| 功能 | 說明 |
|------|------|
| 正規化顯示 | `%`（漲跌%）或 `100 base`（以起始點為 100）模式 |
| 各股 lazy load | 向左捲動時各股獨立補載，`isLoadingMoreCmp` flag + auto-retry |
| Chip click dim | 點擊股票 chip label 切換 dim（淡化）/active；`dimMap` 追蹤狀態 |
| Shift+hover 虛線 | Shift + 滑鼠移動，各 series 顯示跟隨滑鼠的水平虛線 |
| Shift+hover tooltip | 同上，浮動 tooltip 顯示各股當下的**實際收盤價**（非正規化值） |
| Shift+drag 漲跌 | Shift + 拖曳選取時間區間，顯示各股漲跌幅（含時間區間 header） |
| Dblclick 重設基準 | 雙擊圖表，以點擊處 x 座標為新的比較原點，重繪所有 series |


## 股票管理

| 功能 | 說明 |
|------|------|
| 搜尋 autocomplete | 輸入框打字顯示下拉（代號 + 中文名），debounce 250ms，鍵盤可操作 |
| 中文名稱搜尋 | TWSE / TPEx 本地清單，24h cache；含中文 query 走本地，英數合併 Yahoo |
| Chip hover 報價 | 滑鼠移入股票 chip，topbar 右側報價切換為該股（session cache） |
| 選股集管理 | 多組選股集（`dashstock-groups`）：新增、改名、刪除、切換 |
| 持久化 | localStorage 儲存選股集，重開頁面自動還原；migrate 舊 `dashstock-syms` |


## Bug fix 記錄（已修）

| Bug | 修法 | 版本 |
|-----|------|------|
| 5D 無資料 | 改用 Unix timestamp format | v0.1.0 |
| 1D 無法往回拉 | 移除 isIntraday guard，後端支援 Unix before 參數 | v0.1.0 |
| compare lazy load 只更新一股 | capture fromTime 快照，isLoadingMoreCmp 移到 forEach 之後 | v0.1.0 |
| 多股 localStorage 還原只顯示一組 | batch push → 單次 reload() | v0.2.0 |
| 頁面載入圖表空白（defer issue） | initChart() 移入 Promise.all.then()（非同步） | v0.2.0 |
| 刪除後新增顏色重複 | `pickColor()` 找第一個未使用的顏色 | v0.3.0 |
| CPER 往左拉缺值 | loadMoreCompare 完成後 50ms auto-retry | v0.3.0 |
| CPER 快速切 range 變垂直線 | generation counter + sort dedup + null-safe concat | v0.3.0 |


## 後端 API

| Endpoint | 說明 |
|----------|------|
| `GET /api/chart/:sym` | 歷史 K 線，支援 `range` / `before` + `interval` 參數；chunk 磁碟 cache |
| `GET /api/quote/:sym` | 即時報價（session cache） |
| `GET /api/search?q=` | 股票搜尋，中文走本地 TWSE/TPEx 清單，英數合併 Yahoo Finance |


## Tech Stack

| 層 | 技術 |
|----|------|
| 後端 | Node.js + Express + LiveScript |
| 前端 | Pug + 原生 JS（無框架） |
| 圖表 | `lightweight-charts` v5 |
| 資料來源 | `yahoo-finance2` v3 |
| 編譯 | `@plotdb/srcbuild`（pug watch → static HTML） |
