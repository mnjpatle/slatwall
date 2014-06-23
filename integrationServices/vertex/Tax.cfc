/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) ten24, LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
	
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this program statically or dynamically with other modules is
    making a combined work based on this program.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
	
    As a special exception, the copyright holders of this program give you
    permission to combine this program with independent modules and your 
    custom code, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting program under terms 
    of your choice, provided that you follow these specific guidelines: 

	- You also meet the terms and conditions of the license of each 
	  independent module 
	- You must not alter the default display of the Slatwall name or logo from  
	  any part of the application 
	- Your custom code must not alter or create any files inside Slatwall, 
	  except in the following directories:
		/integrationServices/

	You may copy and distribute the modified version of this program that meets 
	the above guidelines as a combined work under the terms of GPL for this program, 
	provided that you include the source code of that other code when and as the 
	GNU GPL requires distribution of source code.
    
    If you modify this program, you may extend this exception to your version 
    of the program, but you are not obligated to do so.

Notes:

*/
component accessors="true" output="false" displayname="Vertex" implements="Slatwall.integrationServices.TaxInterface" extends="Slatwall.integrationServices.BaseTax" {
	
	public any function init() {
		return this;
	}
	
	public any function getTaxRates(required any requestBean) {
		
		// Create new TaxRatesResponseBean to be populated with XML Data retrieved from Quotation Resquest
		var responseBean = new Slatwall.model.transient.tax.TaxRatesResponseBean();
		
		// Loop over each unique tax address
		for(var taxAddressID in arguments.requestBean.getTaxRateItemRequestBeansByAddressID()) {
			
			var addressTaxRequestItems = arguments.requestBean.getTaxRateItemRequestBeansByAddressID()[ taxAddressID ];

			// Build Request XML
			var xmlPacket = "";
				
			savecontent variable="xmlPacket" {
				include "QuotationRequest.cfm";
			}
			
			// Setup Request to push to Vertex
	        var httpRequest = new http();
	        httpRequest.setMethod("POST");
			httpRequest.setUrl("#setting('webServicesURL')#/CalculateTax60?wsdl");
			httpRequest.addParam(type="XML", name="name",value=xmlPacket);
	
			// Parse response and set to struct
			var xmlResponse = XmlParse(REReplace(httpRequest.send().getPrefix().fileContent, "^[^<]*", "", "one"));
			
			
			
			// Searches for the totalTax in xmlChild
			for(var n1 in xmlResponse.xmlRoot.xmlChildren[1].xmlChildren[1].xmlChildren) {
				
				if(n1.xmlName == "QuotationResponse") {
						
					for(var n2 in n1.xmlChildren) {
						
						if(n2.xmlName == "LineItem") {
							
							var orderItemID = n2.xmlAttributes.materialCode;
							var taxAmount = 0;
							
							for(var n3 in n2.xmlChildren) {
								if(n3.xmlName == "TotalTax") {
									taxAmount = n3.xmlText;
								}
							}
							responseBean.addTaxRateItem(orderItemID=orderItemID, taxAmount=taxAmount);
							
						}
						
					}
					
				}
				
			}
			
		}
			
		return responseBean;
	}
	
	public any function postInvoiceRequestToVertex(required any requestBean){

		// Loop over each unique tax address
		for(var taxAddressID in arguments.requestBean.getTaxRateItemRequestBeansByAddressID()) {
			
			var addressTaxRequestItems = arguments.requestBean.getTaxRateItemRequestBeansByAddressID()[ taxAddressID ];

			// Build Request XML
			var xmlPacket = "";
				
			savecontent variable="xmlPacket" {
				include "InvoiceRequest.cfm";
			}
			
			// Setup Request to push to Vertex
	        var httpRequest = new http();
	        httpRequest.setMethod("POST");
			httpRequest.setUrl("#setting('webServicesURL')#/CalculateTax60?wsdl");
			httpRequest.addParam(type="XML", name="name",value=xmlPacket);
	
			// Parse response and set to struct
			var xmlResponse = XmlParse(REReplace(httpRequest.send().getPrefix().fileContent, "^[^<]*", "", "one"));

		}
	}


}