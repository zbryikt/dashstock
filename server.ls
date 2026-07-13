require! <[express path @plotdb/srcbuild]>

app = express!
app.use express.json!
app.use express.urlencoded {extended: true}

(require \./api) {app}

app.use \/, express.static \web/static

port = process.env.PORT or 3000

Promise.resolve!
  .then ->
    new Promise (res, rej) ->
      s = app.listen port, (e) ->
        if e => return rej e
        console.log "listening on port #{s.address!port}"
        res s
  .then ->
    srcbuild.lsp {base: \web}
