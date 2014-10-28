var app = angular.module('main', ['ngTable']).controller('DemoCtrl', function($scope, $http, $filter, ngTableParams) {
  $http.get('matrix.json').success(function(data, status, headers, config){
    $scope.tableParams = new ngTableParams({
        page: 1,            // show first page
        count: data.length  // count per page
    }, {
        counts: [],
        groupBy: 'suite',
        filter: {
            scenario: ''       // initial filter
        },
        total: data.length,
        getData: function($defer, params) {
          var filteredData = params.filter() ?
              $filter('filter')(data, params.filter()) :
              data;
          var orderedData = params.sorting() ?
              $filter('orderBy')(filteredData, params.orderBy()) :
              data;

            params.total(orderedData.length);
            $defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
        }
    });
  });
})
