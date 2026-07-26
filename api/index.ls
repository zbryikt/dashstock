{default: YF} = require \yahoo-finance2
yf = new YF {suppressNotices: [\yahooSurvey, \ripHistorical]}
fs   = require \fs
path = require \path

cache-dir = \data
try fs.mkdirSync cache-dir, {recursive: true} catch

read-cache = (file) ->
  try JSON.parse fs.readFileSync (path.join cache-dir, file), \utf8
  catch then null

write-cache = (file, data) ->
  try fs.writeFileSync (path.join cache-dir, file), JSON.stringify(data) catch

days-ago = (n) ->
  d = new Date; d.setDate d.getDate! - n; d

# intervals that need Unix timestamp (multiple bars per day)
sub-daily = [\5m, \15m, \30m, \1h]

chunk-days = (interval) -> switch interval
  | \1wk => 730
  | \5m  => 7
  | \15m => 14
  | otherwise => 180

# Taiwan stock list — in-memory + disk cache, 24h TTL
tw-cache = null
tw-cache-ts = 0
TW-CACHE-FILE = \tw-stocks.json

get-tw-stocks = ->
  now = Date.now!
  if tw-cache and (now - tw-cache-ts) < 86400000
    return Promise.resolve tw-cache
  disk = read-cache TW-CACHE-FILE
  if disk and (now - disk.ts) < 86400000
    tw-cache := disk.data
    tw-cache-ts := disk.ts
    return Promise.resolve tw-cache
  urls = [
    \https://openapi.twse.com.tw/v1/opendata/t187ap03_L
    \https://openapi.twse.com.tw/v1/opendata/t187ap03_2
  ]
  suffixes = [\TW \TWO]
  Promise.all urls.map (url, i) ->
    fetch url
      .then (r) -> r.json!
      .then (list) ->
        list.map (s) ->
          code = s[\公司代號] or s[\SecuritiesCompanyCode] or ''
          name = s[\公司簡稱] or s[\Name] or ''
          full = s[\公司名稱] or s[\CompanyName] or name
          {symbol: code + '.' + suffixes[i], name, fullname: full}
      .catch -> []
  .then (lists) ->
    tw-cache := [].concat ...lists
    tw-cache-ts := Date.now!
    write-cache TW-CACHE-FILE, {ts: tw-cache-ts, data: tw-cache}
    tw-cache
  .catch -> tw-cache or []

module.exports = ({app}) ->
  get-tw-stocks!.catch ->

  app.get \/api/search, (req, res) ->
    q = (req.query.q or '').trim!
    if not q => return res.json {ok: true, data: []}
    has-chinese = /[一-鿿]/.test q
    get-tw-stocks!
      .then (tw) ->
        q-lower = q.toLowerCase!
        local = tw.filter (s) ->
          s.name.indexOf(q) >= 0 or s.fullname.indexOf(q) >= 0 or
          s.symbol.toLowerCase!.indexOf(q-lower) >= 0
        if has-chinese
          return res.json {ok: true, data: local.slice(0, 8)}
        yf.search q
          .then (result) ->
            yf-res = (result.quotes or [])
              .filter (r) -> r.quoteType in [\EQUITY, \ETF, \MUTUALFUND]
              .map (r) -> {symbol: r.symbol, name: r.shortname or r.longname or ''}
            seen = {}
            local.forEach (s) -> seen[s.symbol] = true
            merged = local.concat yf-res.filter (r) -> not seen[r.symbol]
            res.json {ok: true, data: merged.slice(0, 8)}
          .catch -> res.json {ok: true, data: local.slice(0, 8)}
      .catch (e) -> res.status(500).json {ok: false, error: e.message}

  app.get \/api/quote/:symbol, (req, res) ->
    yf.quote req.params.symbol
      .then (data) ->
        if !data => return res.json {ok: false, error: 'symbol not found'}
        res.json {ok: true, data}
      .catch (e) -> res.status(500).json {ok: false, error: e.message}

  app.get \/api/chart/:symbol, (req, res) ->
    symbol = req.params.symbol
    intraday = false      # filter result to last trading day only
    ts-before = false     # before param is a Unix timestamp
    cache-key = null

    if req.query.before and req.query.interval
      interval = req.query.interval
      before-raw = req.query.before
      # Unix timestamp (sub-daily) vs ISO date string (daily/weekly)
      ts-before = /^\d{9,}$/.test before-raw
      if ts-before
        period2 = new Date (Number(before-raw) * 1000)
        period1 = new Date period2
        period1.setDate period1.getDate! - chunk-days interval
      else
        period2 = new Date before-raw
        period2.setDate period2.getDate! - 1
        period1 = new Date period2
        period1.setDate period1.getDate! - chunk-days interval
      safe-sym = symbol.replace /\//g, '_'
      cache-key = "#{safe-sym}_#{interval}_#{period1.toISOString!slice 0,10}_#{period2.toISOString!slice 0,10}.json"
      cached = read-cache cache-key
      if cached => return res.json {ok: true, data: cached, interval}
    else
      range = req.query.range or \3mo
      [period1, interval, intraday] = switch range
      | \1d  => [days-ago(7),   \5m,  true ]
      | \5d  => [days-ago(8),   \15m, false]
      | \1mo => [days-ago(31),  \1d,  false]
      | \6mo => [days-ago(183), \1d,  false]
      | \1y  => [days-ago(366), \1d,  false]
      | \2y  => [days-ago(731), \1wk, false]
      | \5y  => [days-ago(1827),\1wk, false]
      | otherwise => [days-ago(92), \1d, false]

    yf.chart symbol, {period1, interval}
      .then (result) ->
        quotes = (result.quotes or []).filter (r) -> r.open? and r.high? and r.low? and r.close?

        # 1D: only show the most recent trading day
        if intraday and quotes.length
          last-date = new Date(quotes[quotes.length - 1].date).toDateString!
          quotes = quotes.filter (r) -> new Date(r.date).toDateString! == last-date

        # lazy load: filter to data strictly before the before boundary
        if period2
          if ts-before
            quotes = quotes.filter (r) -> new Date(r.date) < period2
          else
            quotes = quotes.filter (r) -> new Date(r.date) <= period2

        use-ts = interval in sub-daily
        rows = quotes.map (r) ->
          t = new Date r.date
          if use-ts
            {time: Math.floor(t.getTime! / 1000), open: r.open, high: r.high, low: r.low, close: r.close}
          else
            {time: t.toISOString!slice(0, 10), open: r.open, high: r.high, low: r.low, close: r.close}

        if cache-key and rows.length => write-cache cache-key, rows
        res.json {ok: true, data: rows, interval}
      .catch (e) -> res.status(500).json {ok: false, error: e.message}
