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

window.last_heartbeat = -1
primus.on 'rpt_heartbeat', (ts) ->
	# do something with this heartbeat?
	window.last_heartbeat = new Date()

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
	"#{m}:#{s}"
timepad = (n) ->
	if n < 10 then "0#{n}" else "#{n}"
formattime = (d) ->
	timepad(d.getHours()) + ":" + timepad(d.getMinutes())# + ":" +  timepad(d.getSeconds())

message = {"t": Date.now(), "message": 'message here'}
error = 'This is an example error'

resize = () ->
	# sizes the svg and all container divs etc such that it nicely fills the screen
	# want to fill about 90% of the window
	w = $(window).width()*0.9
	h = $(window).height()*0.9
	s = Math.round Math.min w,h
	
	timer.size = s
	$('#clockface').width(s).height(s)
	$('#timeleftdisplay').css
		'font-size': Math.round(s/ 10) + 'px'
		'margin-top': Math.round(-s/ 2 - s/ 20 ) + 'px'
	$('#timedisplay').css('font-size', Math.round(s/ 20)+'px')
	$('#percentage').css('font-size', Math.round(s/ 20)+'px')

update = () ->
	redraw(timer.timeleft)
	frac = timer.timeleft / timer.T
	if timer.timeleft < 0
		$('#timeleftdisplay').addClass 'overtime'
		$('#timeleftdisplay').html "+" + secs2duration(-timer.timeleft)
		$('#percentage').html "+" + Math.round(-100*frac) + "%"
	else
		$('#timeleftdisplay').removeClass 'overtime'
		$('#timeleftdisplay').html secs2duration(timer.timeleft)
		$('#percentage').html Math.round(100*frac) + "%"

drawArc = (frac) ->
	# change the svg's arc to run from N, by E-S-W, to sweep (1-<frac>)*360 deg
	# starting point is always N, but have to subtract stroke width
	s = timer.size
	stroke = Math.round(s / 10)
	r = Math.floor(s / 2 - stroke / 2)
	
	#bit of an ugly hack, but: arc will never be a full circle
	if Math.round(1000*frac) == 0 then frac = 0.0001
	start = "#{s/ 2},#{0+stroke/ 2}"
	# end is something with cos and sin
	end = "#{s/ 2 + r*Math.sin(2*Math.PI*(1-frac))},#{s/ 2 - r*Math.cos(2*Math.PI*(1-frac))}"
	# we need small arc for frac <= 0.5 and large arc for frac > 0.5
	large_arc = if frac < 0.5 then 1 else 0
	sweep = 1 #always go clockwise
	
	# construct the svg path (the magic 0 is axis rotation)
	d = "M#{start} A#{r},#{r} 0 #{large_arc},#{sweep} #{end}"
	$('#arc').attr
		'd': d
		'stroke-width': stroke
	
	
redraw = (t) ->
	# Redraw the svg timer thingy
	frac = t / (timer.T) #runs from 1 to 0
	if frac < 0 then frac = 0 #do not go below 0
	
	drawArc frac
	
	$('#arc').attr('stroke',"hsl(#{Math.round(frac*120)},100%,50%)")
		
$ ->
	resize()
	setInterval ->
			if(timer.is_running)
				timer.timeleft -= 1
				update()
			
			ts = new Date()
			$('#timedisplay').html formattime ts
			
			# connection status
			if ts.getTime() - window.last_heartbeat > 2500
				$('#connection_status').attr('fill','rgba(255,0,0,0.5)')
			else
				$('#connection_status').attr('fill','rgba(0,127,0,0.5)')
		,1000
	
start = ->
	timer.is_running = true
stop = ->
	timer.is_running = false
