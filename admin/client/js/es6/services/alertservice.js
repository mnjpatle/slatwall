/// <reference path='../../../../client/typings/slatwallTypescript.d.ts' />
/// <reference path='../../../../client/typings/tsd.d.ts' />
/*services return promises which can be handled uniquely based on success or failure by the controller*/
var slatwalladmin;
(function (slatwalladmin) {
    class AlertService {
        constructor($timeout, alerts) {
            this.$timeout = $timeout;
            this.alerts = alerts;
            this.get = () => {
                return this.alerts || [];
            };
            this.addAlert = (alert) => {
                this.alerts.push(alert);
                this.$timeout((alert) => {
                    this.removeAlert(alert);
                }, 3500);
            };
            this.addAlerts = (alerts) => {
                alerts.forEach(alert => {
                    this.addAlert(alert);
                });
            };
            this.removeAlert = (alert) => {
                var index = this.alerts.indexOf(alert, 0);
                if (index != undefined) {
                    this.alerts.splice(index, 1);
                }
            };
            this.getAlerts = () => {
                return this.alerts;
            };
            this.formatMessagesToAlerts = (messages) => {
                var alerts = [];
                for (var message in messages) {
                    var alert = new slatwalladmin.Alert();
                    alert.msg = messages[message].message;
                    alert.type = messages[message].messageType;
                    alerts.push(alert);
                    if (alert.type === 'success' || alert.type === 'error') {
                        $timeout(function () {
                            alert.fade = true;
                        }, 3500);
                        alert.dismissable = false;
                    }
                    else {
                        alert.fade = false;
                        alert.dismissable = true;
                    }
                }
                return alerts;
            };
            this.removeOldestAlert = () => {
                this.alerts.splice(0, 1);
            };
            this.alerts = [];
        }
    }
    AlertService.$inject = [
        '$timeout'
    ];
    slatwalladmin.AlertService = AlertService;
})(slatwalladmin || (slatwalladmin = {}));
var slatwalladmin;
(function (slatwalladmin) {
    angular.module('slatwalladmin')
        .service('alertService', slatwalladmin.AlertService);
})(slatwalladmin || (slatwalladmin = {}));

//# sourceMappingURL=../services/alertservice.js.map