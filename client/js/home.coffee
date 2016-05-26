


ng = angular.module 'rpt', []

ng.run ['$rootScope', ($rootScope) ->
	console.log 'ng.run executing'
]

ng.controller 'HomeCtrl', ['$scope', ($scope) ->
	$scope.message = {"t": Date.now(), "message": 'message here'}
	$scope.error = 'This is an example error'
]