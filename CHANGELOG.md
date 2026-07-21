## v0.3.0

 - features:
   - 選股集（stock group）管理 UI：可新增、改名、刪除、切換，替代原本的單一 localStorage 清單
   - shift+drag 漲跌 panel 頂端顯示時間區間，位置由頁底改至圖表上緣
   - compare mode 往左拉自動連續補載歷史資料（loadMoreCompare 完成後 50ms 自動重觸）
 - bug fix:
   - 修正快速切換 range 時舊 loadMoreCompare fetch 回來後污染新資料（generation counter 機制）
   - 修正 loadMoreCompare merge 時可能有重複時間點造成 lightweight-charts 垂直線（sort + dedup）
   - 修正刪除後再新增股票顏色重複（改用 pickColor 找未使用顏色）
   - 修正 normalizeOne 傳入 close <= 0 或 NaN 的無效資料點


## v0.2.0

 - features:
   - localStorage 持久化股票清單，重開頁面自動還原
   - compare mode chip click 切換 dim / active，淡化不關注的 line
   - shift+drag 橫向選取區間，顯示各股漲跌幅
   - compare mode shift+hover 各 line 虛線跟隨滑鼠，tooltip 顯示實際收盤價
   - compare mode dblclick 重設比較基準點（以點擊處 x 座標為新原點）
 - bug fix:
   - 修正多股從 localStorage 還原時只顯示一組的問題（批次 init 改為一次 reload）
   - 修正 loadCompare 在初始化時同步呼叫 initChart 導致 LightweightCharts 尚未載入的問題


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
