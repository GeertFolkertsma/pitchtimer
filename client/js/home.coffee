window.primus = new Primus()


ng = angular.module 'rpt', []

ng.run ['$rootScope', ($rootScope) ->
	console.log 'ng.run executing'
	
	primus.on 'open', ->
		primus.write
			message: "This is a new client connecting"
	
	primus.on 'reload', ->
		console.log 'reloading'
		location.reload()
	
	primus.on 'rpt_heartbeat', (ts) ->
		$rootScope.$apply => $rootScope.$broadcast 'heartbeat', ts
	
	primus.on 'timer', (data) ->
		$rootScope.$apply => $rootScope.$broadcast 'timer', data
	
	primus.on 'start_timer', ->
		$rootScope.$apply => $rootScope.$broadcast 'start_timer'
	primus.on 'stop_timer', ->
		$rootScope.$apply => $rootScope.$broadcast 'stop_timer'
	primus.on 'set_timer', (T) ->
		$rootScope.$apply => $rootScope.$broadcast 'set_timer', T
	
	primus.on 'data', (data) ->
		console.log 'data', data
		$rootScope.$apply => $rootScope.$broadcast 'data', data
]

ng.filter 'duration', ->
	(secs) ->
		m = Math.floor secs / 60
		s = secs % 60
		s = "0"+s unless s >= 10
		s = "0"+s if s == "0"
		"#{m}:#{s}"

ng.controller 'HomeCtrl', ['$scope', 'durationFilter', ($scope,duration) ->
	$scope.message = {"t": Date.now(), "message": 'message here'}
	$scope.error = 'This is an example error'
	
	$scope.timeleft = 1*60 #5 minutes
	$scope.T = 5*60
	$scope.is_running = false
	$scope.is_active = true
	
	$scope.polypoints = "200,200 200,-600 600,200"
	$scope.colour = "hsl(120,100%,50%)"
	$scope.width = 400
	
	$scope.$watch 'timeleft', (oldt,t) ->
		redraw(t)
	
	redraw = (t) ->
		# Redraw the svg timer thingy
		frac = t / ($scope.T) #runs from 1 to 0
		w = $scope.width
		r = w / 2 * Math.sqrt(2)
		
		pc = {x: w / 2, y: w / 2 }
		polypoints = "#{pc.x},#{pc.y}"
		# we need to obscure from 1 to 0 -> all to nothing
		# generate 10 points around the circle
		angles = (Math.PI / 2 + i*frac*Math.PI*2 for i in [0..1] by 0.1)
		circle_points = ({x: w / 2 + r*Math.cos(a), y: w / 2 - r*Math.sin(a)} for a in angles)
		for p in circle_points
			polypoints += " #{p.x},#{p.y}"
		
		$scope.polypoints = polypoints
		$scope.colour = "hsl(#{Math.round(frac*120)},100%,50%)"
	
	setInterval ->
			if($scope.is_running)
				$scope.$apply => $scope.timeleft -= 1
			$scope.$apply => $scope.ts = Date.now()
		,1000
	
	$scope.start = ->
		$scope.is_running = true
	$scope.stop = ->
		$scope.is_running = false
	
	$scope.$on 'timer', (event, data) ->
		console.log data
		switch data.action
			when 'start' then $scope.is_running = true
			when 'stop' then $scope.is_running = false
			when 'set_period' then $scope.T = data.data
			when 'set_time'
				$scope.timeleft = data.data
				redraw(data.data)
	
	$scope.$on 'heartbeat', (event, ts) ->
		$scope.hbts = ts
	
	$scope.$on 'data', (event, data) ->
		$scope.message = 
			t: Date.now()
			message: data
]