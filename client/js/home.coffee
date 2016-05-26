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

ng.controller 'HomeCtrl', ['$scope', ($scope) ->
	$scope.message = {"t": Date.now(), "message": 'message here'}
	$scope.error = 'This is an example error'
	
	$scope.timeleft = 5*50 #5 minutes
	
	$scope.$on 'heartbeat', (event, ts) ->
		$scope.ts = ts
	
	$scope.$on 'data', (event, data) ->
		$scope.message = 
			t: Date.now()
			message: data
]