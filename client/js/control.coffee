window.primus = new Primus()

primus.on 'open', ->
	primus.write
		message: "This is a new client connecting"

primus.on 'reload', ->
	console.log 'reloading'
	location.reload()

window.last_heartbeat = -1
primus.on 'rpt_heartbeat', (ts) ->
	# Want to do anything?
	window.last_heartbeat = new Date()
	

primus.on 'data', (data) ->
	console.log 'data', data

send_action = (action, data) ->
	primus.emit 'timer', {"action": action, "data": data}

parseTime = (t) ->
	t = "0#{t}".split(':')
	if t.length == 2
		parseInt(t[0])*60 + parseInt(t[1])
	else
		parseInt(t[0])

timepad = (n) ->
	if n < 10 then "0#{n}" else "#{n}"
formattime = (d) ->
	timepad(d.getHours()) + ":" + timepad(d.getMinutes()) + ":" +  timepad(d.getSeconds())

$ ->
	setInterval ->
			ts = new Date()
			$('#timedisplay').html formattime ts
			if window.last_heartbeat == -1
				$('#connection').html "Not connected yet!"
			else
				s = (ts.getTime() - window.last_heartbeat.getTime()) / 1000
				if s > 2
					$('#connection').html "Last server contact: #{s} s ago"
				else
					$('#connection').html "Connected to server."
		,1000
	
	$('#start').click ->
		send_action 'start', {}
	$('#stop').click ->
		send_action 'stop', {}
	$('#set_time').click ->
		send_action 'set_time', parseTime $('#timeleft').val()
	$('#reset_time').click ->
		$('#timeleft').val $('#T').val()
		$('#stop').click()
		$('#set_period').click()
		$('#set_time').click()
	$('#set_period').click ->
		send_action 'set_period', parseTime $('#T').val()
	$('#msc').click ->
		$('#T').val '30:00'
		$('#reset_time').click()
	$('#bsc').click ->
		$('#T').val '20:00'
		$('#reset_time').click()
	
	$('#advanced').change ->
		$('.advanced').toggle(this.checked)
	
	$('#T,#timeleft').keydown (event) ->
		if event.which == 13
			if $(this).attr('id') == 'T'
				$('#set_period').click()
			else
				$('#set_time').click()