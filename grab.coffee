vkontakte 	= require "vkontakte"
async 		= require "async"
fs 			= require "fs"
http 		= require "http"
request 	= require "request"
_ 			= require "lodash"
Canvas  	= require "canvas"
util 		= require "util"
progress 	= require "progress"


vk = vkontakte (require "./config.json").access_token
global = []


download = (uri, filename, cb) ->
        r = request(uri).pipe(fs.createWriteStream(filename))
        r.on "close", cb

downloadPhoto = (user, cb) ->
	photoPath = "download/#{user.uid}.jpg"

	fs.exists photoPath, (exists) ->
		if exists
			return cb null, _.extend user,
				photo_path : photoPath

		download user.photo_max, photoPath, ->
			util.print user.uid + "\r"
			cb null, _.extend user,
				photo_path : photoPath

getUserFriends = (user, cb) ->
	console.log "#{user.first_name} #{user.last_name}"

	vk "friends.get",
		"user_id" : user.uid 
		"fields" : "photo_max"
	,(err, fr) ->
		if not fr?
			return cb null, []

		realLen = fr.length 

		friends = [ user ]
		if fr.length < 1500
			friends = _.union fr, friends

		friends = _.filter friends, (user) ->
			user.photo_max != "http://vk.com/images/camera_b.gif" and not _.has(user, "deactivated") and not _.contains global, user.uid

		his = async.mapLimit friends, 40, downloadPhoto, (err, result) ->
			uids = _.map friends, (f) -> f.uid
			global = _.union uids, global

			cb err, result
			

# Execution starts here
vk "friends.get", 
	"fields" : "photo_max"
,(err, friends) ->		
	async.mapSeries friends, getUserFriends, (err, result) ->
		fs.writeFileSync "data.json", JSON.stringify result

		result = _.flatten result
		fs.writeFileSync "data-flatten.json", JSON.stringify result


