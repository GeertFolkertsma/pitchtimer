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

ng.controller 'ControlCtrl', ['$scope', 'durationFilter', ($scope,duration) ->
	$scope.message = {"t": Date.now(), "message": 'message here'}
	$scope.error = 'This is an example error'
	
	$scope.T = 5*60 #5 minutes
	$scope.timeleft = 4*60
	
	send_action = (action, data) ->
		primus.emit 'timer', {"action": action, "data": data}
	
	$scope.start = ->
		send_action 'start', {}
	$scope.stop = ->
		send_action 'stop', {}
	$scope.set_time = ->
		send_action 'set_time', $scope.timeleft
	$scope.reset_time = ->
		$scope.timeleft = $scope.T
		$scope.set_time()
	$scope.set_period = ->
		send_action 'set_period', $scope.T
	
	$scope.$on 'heartbeat', (event, ts) ->
		$scope.hbts = ts
	
	$scope.$on 'data', (event, data) ->
		$scope.message = 
			t: Date.now()
			message: data
]