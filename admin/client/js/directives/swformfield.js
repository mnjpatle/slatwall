angular.module('slatwalladmin')
.directive('swFormField', 
[
'$log',
'$templateCache',
'$http',
'$compile',
'formService',
'partialsPath',
function(
$log,
$templateCache,
$http,
$compile,
formService,
partialsPath
){
	var getTemplate = function(templateType){
		var templatePath = '';
		switch(templateType){
			case 'text':
				templatePath = partialsPath + 'formfields/text.html';
				break;
			case 'select':
				templatePath = partialsPath + 'formfields/select.html';
				break;
		};
		
		var templateLoader = $http.get(templatePath,{cache:$templateCache});
		
        return templateLoader;
	};
	
	return {
		require:"^form",
		restrict: 'A',
		scope:{
			propertyDisplay:"="
		},
		replace:true,
		link: function(scope, element,attrs, formController){
		
		//revert values when they are set to pristine
		/*scope.registerWatch = function(){
			scope.$watch('formController.$pristine',function(){
				console.log('form is pristine!');
				console.log(scope.propertyDisplay);
				if(angular.isDefined(scope.propertyDisplay)){
					
					if(angular.isDefined(scope.revertValue.value)){
						
						scope.propertyDisplay.value = scope.revertValue.value;
					}else{
						if(scope.revertValue.type === 'text'){
							scope.propertyDisplay.value = '';
						}
						if(scope.revertValue.type === 'select'){
							scope.propertyDisplay.value = scope.propertyDisplay.object[scope.propertyDisplay.valueOptions].value[0];
						}
						
					}
					console.log(scope.propertyDisplay);
				}
			});
		};*/
			//as soon as we get data compile the web componenet
			var unBindWatch = scope.$watch('propertyDisplay',function(newValue,oldValue){
				if(newValue !== oldValue){
					scope.revertValue = angular.copy(newValue);
					
					var templateLoader = getTemplate(newValue.type);
			    	var promise = templateLoader.success(function(html){
			    		var formfield = angular.element(html);
			    		//dynamic formfield name mapping
			    		formfield.attr('name',scope.propertyDisplay.property);
			    		if(angular.isDefined(scope.propertyDisplay.object.validation.properties[scope.propertyDisplay.property.split('.').pop()])){
			    			var validationProperties = scope.propertyDisplay.object.validation.properties[scope.propertyDisplay.property.split('.').pop()];
			    			for(i in validationProperties){
			    				for(key in validationProperties[i]){
			    					var validationProperty = validationProperties[i];
			    					if(key === 'required'){
			    						formfield.attr(key,validationProperty[key]);
			    					}
			    				}
			    			}
			    		}
			    		element.html(formfield);
						$compile(element.contents())(scope);
						if(scope.propertyDisplay.type === 'select'){
				        	scope.propertyDisplay.value = scope.propertyDisplay.object[scope.propertyDisplay.valueOptions].value[0];
				        	formService.setPristinePropertyValue(scope.propertyDisplay.property,scope.propertyDisplay.object[scope.propertyDisplay.valueOptions].value[0]);
				        }
						if(scope.propertyDisplay.type === 'text'){
							formService.setPristinePropertyValue(scope.propertyDisplay.property,scope.propertyDisplay.value);
						}
						
						scope.propertyDisplay.errors = formController[scope.propertyDisplay.property].$error;
						scope.propertyDisplay.form = formController;
				        
						
						//scope.registerWatch();
						unBindWatch();
					});
			    	
			    	
				}
			});
		}
	};
}]);
	