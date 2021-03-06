"use strict";
'use strict';
angular.module('slatwalladmin').controller('pageDialog', ['$scope', '$location', '$log', '$anchorScroll', '$slatwall', 'dialogService', function($scope, $location, $log, $anchorScroll, $slatwall, dialogService) {
  $scope.$id = 'pageDialogController';
  $scope.pageDialogs = dialogService.getPageDialogs();
  $scope.scrollToTopOfDialog = function() {
    $location.hash('/#topOfPageDialog');
    $anchorScroll();
  };
  $scope.pageDialogStyle = {"z-index": 3000};
}]);

//# sourceMappingURL=../controllers/pagedialog.js.map