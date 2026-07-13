## master

 - features:
   - localStorage 持久化股票清單，重開頁面自動還原
   - compare mode chip click 切換 dim / active，淡化不關注的 line
   - shift+drag 橫向選取區間，顯示各股漲跌幅
   - compare mode shift+hover 顯示各 line 虛線跟隨滑鼠位置


## v0.1.0

 - features:
   - compare mode（多股同時比較，% 或 100 基準模式）
   - 各股 lazy load（向左捲動自動載入更多歷史資料）
   - 修正 compare mode lazy load race condition（兩股同捲只更新一股的 bug）
   - 股票搜尋 autocomplete（含中文名稱，使用 TWSE Open API 本地清單）
   - 中文查詢本地搜尋，英文 / 數字合併 Yahoo Finance 結果
   - chip hover 切換右上角報價顯示
   - 歷史 K 線 chunk 磁碟 cache（`data/` 目錄，永久；TWSE 清單 24h TTL）
   - 修正 5D 無資料（15m interval 改用 Unix timestamp 格式）
   - 修正 1D 無法往回拉（移除 isIntraday guard；後端支援 Unix timestamp before 參數）
   - quote session cache（避免重複打 API）


## v0.0.1

 - init release
 - K 線圖基本功能：candlestick chart、range 切換（1D/5D/1M/3M/6M/1Y/2Y/5Y）
 - yahoo-finance2 資料來源（quote + chart API）
 - 多股 chip UI，可新增 / 移除
