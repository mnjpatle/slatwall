"use strict";
'use strict';
angular.module('slatwalladmin').controller('alertController', ['$scope', 'alertService', function($scope, alertService) {
  $scope.$id = "alertController";
  $scope.alerts = alertService.getAlerts();
}]);

//# sourceMappingURL=../controllers/alertcontroller.js.map