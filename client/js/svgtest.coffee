w = 400
h = 400
drawArc = (frac) ->
	# change the svg's arc to run from N, by E-S-W, to sweep (1-<frac>)*360 deg
	# starting point is always N, but have to subtract stroke width
	
	#bit of an ugly hack, but: arc will never be a full circle
	if Math.round(1000*frac) == 0 then frac = 0.0001
	stroke = 40
	r = 180
	start = "#{w/ 2},#{0+stroke/ 2}"
	# end is something with cos and sin
	end = "#{w/ 2 + r*Math.sin(2*Math.PI*(1-frac))},#{h/ 2 - r*Math.cos(2*Math.PI*(1-frac))}"
	# we need small arc for frac <= 0.5 and large arc for frac > 0.5
	large_arc = if frac < 0.5 then 1 else 0
	sweep = 1 #always go clockwise
	
	# construct the svg path (the magic 0 is axis rotation)
	d = "M#{start} A#{r},#{r} 0 #{large_arc},#{sweep} #{end}"
	$('#peek').html("frac: #{frac}; d: #{d}")
	$('#arc').attr('d',d)

f = 1
$ ->
	$a = $('#arc')
	# $a.attr('d','M200,20 A180,180 0 0,1 380,200')
	setInterval ->
			f = 1*f - 0.05
			if f < -0.001 then f = 1
			drawArc(f)
		,500