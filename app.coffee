'use strict'

Primus = require 'primus'
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

primus = new Primus server,
	transformer: 'engine.io'
primus.use 'emit', require('primus-emit')
primus.save "#{__dirname}/client/lib/primus.js"

setTimeout ->
		primus.forEach (spark) ->
			console.log 'Sending out reload message'
			spark.emit 'reload'
	, 1500

primus.on 'connection', (spark) ->
	console.log 'Client connected'
	spark.write 'Primus-server says hi'
	spark.on 'data', (data) ->
		console.log 'received plain data: ', data
	
	spark.on 'testing', (data) ->
		console.log 'testing data: ', data

setInterval ->
		primus.forEach (spark) ->
			spark.emit 'rpt_heartbeat', "#{Date.now()}"
	, 2000

server.listen 3000, ->
	console.log 'Listening on port 3000'