vkontakte 	= require "vkontakte"
async 		= require "async"
fs 			= require "fs"
http 		= require "http"
request 	= require "request"
_ 			= require "lodash"
Canvas  	= require "canvas"
util 		= require "util"

data = require "./data-flatten.json"


drawGrid = (friends) ->
	friends = _.first friends, 10000
	dim = Math.floor Math.sqrt friends.length
	w = 16

	console.log dim, dim*w


	canvas = new Canvas dim * w, dim * w
	ctx = canvas.getContext '2d'	

	i = 0
	async.mapSeries friends, (user, cb) ->
		fs.readFile user.photo_path, (err, squid) ->
			img = new Canvas.Image
			img.onload = ->

				ctx.drawImage img, w * (i % dim),w * Math.floor((i / dim)), w, w

				console.log i, user.uid
				++i
				cb null, user
			img.src = squid

	, (err, res) ->
		console.log "done"
		canvas.pngStream().pipe( fs.createWriteStream( "2.png" ) )

drawGrid data
