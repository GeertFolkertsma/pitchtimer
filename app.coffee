
http = require 'http'
express = require 'express'

# Initiate app
app = express()
# Config
app.set 'views', './client/views'
app.set 'view engine', 'pug'
app.use express.static('client')

app.get '/', (req,res) ->
	res.render 'home'

server = http.createServer app

server.listen 3000, ->
	console.log 'Listening on port 3000'