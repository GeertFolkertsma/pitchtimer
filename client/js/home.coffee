window.primus = new Primus()
window.timer = 
	timeleft: 1*60 #5 minutes
	T: 5*60
	is_running: false
	is_active: true
	
	size: 400

primus.on 'open', ->
	primus.write
		message: "This is a new client connecting"

primus.on 'reload', ->
	console.log 'reloading'
	location.reload()

primus.on 'rpt_heartbeat', (ts) ->
	# do something with this heartbeat?
	_ts = ts

primus.on 'timer', (data) ->
	console.log data
	switch data.action
		when 'start'
			timer.is_running = true
		when 'stop'
			timer.is_running = false
		when 'set_period'
			timer.T = data.data
		when 'set_time'
			timer.timeleft = data.data
	update()

primus.on 'data', (data) ->
	console.log 'data', data

secs2duration = (secs) ->
	m = Math.floor secs / 60
	s = secs % 60
	s = "0"+s unless s >= 10
	s = "0"+s if s == "0"
	"#{m}:#{s}"


message = {"t": Date.now(), "message": 'message here'}
error = 'This is an example error'

resize = () ->
	# sizes the svg and all container divs etc such that it nicely fills the screen
	# want to fill about 70% of the window
	w = $(window).width()*0.7
	h = $(window).height()*0.7
	s = Math.min w,h
	timer.size = s
	$('#clockface').width(s).height(s)
	$('#timeleftdisplay').css
		'font-size': Math.round(s/ 10) + 'px'
		'margin-top': Math.round(-s/ 2 - s/ 20 ) + 'px'

update = () ->
	redraw(timer.timeleft)
	if timer.timeleft < 0
		$('#timeleftdisplay').addClass 'overtime'
		$('#timeleftdisplay').html "+" + secs2duration(-timer.timeleft)
	else
		$('#timeleftdisplay').removeClass 'overtime'
		$('#timeleftdisplay').html secs2duration(timer.timeleft)

redraw = (t) ->
	# Redraw the svg timer thingy
	frac = t / (timer.T) #runs from 1 to 0
	if frac < 0 then frac = 0 #do not go below 0
	w = timer.size
	r = w / 2 * Math.sqrt(2)
	
	pc = {x: w / 2, y: w / 2 }
	polypoints = "#{pc.x},#{pc.y}"
	# we need to obscure from 1 to 0 -> all to nothing
	# generate 10 points around the circle
	angles = (Math.PI / 2 + i*frac*Math.PI*2 for i in [0..1] by 0.1)
	circle_points = ({x: w / 2 + r*Math.cos(a), y: w / 2 - r*Math.sin(a)} for a in angles)
	for p in circle_points
		polypoints += " #{p.x},#{p.y}"
	
	
	$('#clockface polygon').attr('points',polypoints)
	$('#clockface circle').attr('stroke',"hsl(#{Math.round(frac*120)},100%,50%)")
		
$ ->
	$('#startbutton').on 'click', start
	$('#stopbutton').on 'click', stop
	resize()
	setInterval ->
			if(timer.is_running)
				timer.timeleft -= 1
				update()
			ts = new Date()
			# TODO print timestamp on object somewhere
			timestr = ts.toLocaleTimeString()
			$('#timedisplay').html timestr.substr(0,timestr.length-6)
		,1000
	
start = ->
	timer.is_running = true
stop = ->
	timer.is_running = false
