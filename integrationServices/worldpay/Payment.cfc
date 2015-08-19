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

component accessors="true" output="false" implements="Slatwall.integrationServices.PaymentInterface" extends="Slatwall.integrationServices.BasePayment" {

	variables.sandboxURL = "https://secure-test.worldpay.com/wcc/purchase";
	variables.productionURL = "https://secure.worldpay.com/wcc/purchase";

	public string function getPaymentMethodTypes() {
		return "external";
	}

	public string function getExternalPaymentHTML( required any paymentMethod ) {
		var returnHTML = "";

		savecontent variable="returnHTML" {
			include "views/main/externalpayment.cfm";
		}

		return returnHTML;
	}

	public any function processExternal( required any requestBean ){

		var orderPayment = getService("orderService").getOrderPayment( requestBean.getOrderPaymentID() );
		writedump(orderPayment);
		var paymentMethod = orderPayment.getPaymentMethod();

		var response = getTransient("externalTransactionResponseBean");
				/*var requestBean = rc.$.slatwall.cart().GETORDERPAYMENTS()[1];
				var paymentCFC = paymentMethod.getIntegration().getIntegrationCFC( 'payment' );
				var response = paymentCFC.processExternal(requestBean);*/
				response.setStatusCode( 'success' );
				response.setAmountReceived(orderPayment.getAmountReceived());
				response.setTransactionID(orderPayment.getTransactionID());
				response.setAuthorizationCode(orderPayment.getTransactionID());
				response.setSecurityCodeMatchFlag( true );
				response.setAVSCode( "Y" );
		writedump(response);
		abort;
			return response;
	}

	public string function getInitiatePaymentData( required any paymentMethod, required any order ) {
		var queryString = '';
		var returnURL = paymentMethod.getIntegration().setting('externalPaymentReturnURL');

		if(findNoCase("?", returnURL)) {
			 returnURL &= "&slatAction=worldpay:main.processResponse";
		} else {
			 returnURL &= "?slatAction=worldpay:main.processResponse";
		}

		queryString = "MC_callback=#returnURL#&MC_paymentMethodID=#arguments.paymentMethod.getPaymentMethodID()#";
		var instId = '';

		if( arguments.paymentMethod.getIntegration().setting('ACCOUNTSANDBOXFLAG') ) {
			instId = arguments.paymentMethod.getIntegration().setting('testinstallationID') ;
		} else {
			instId = arguments.paymentMethod.getIntegration().setting('liveinstallationID');
		}
		queryString &= "&instId=#instId#";
		var testMode = arguments.paymentMethod.getIntegration().setting('testMode');
		queryString &= "&testMode=#testMode#";
		queryString &= "&currency=#arguments.order.getCurrencyCode()#";
		queryString &= "&cartId=0";
		queryString &= "&amount=#arguments.order.getTotal()#";

		/*httpRequest.addParam(type="formfield", name="method", value="setExpressCheckout");
		httpRequest.addParam(type="formfield", name="user", value=arguments.paymentMethod.getIntegration().setting('paypalAccountUser'));
		httpRequest.addParam(type="formfield", name="pwd", value=arguments.paymentMethod.getIntegration().setting('paypalAccountPassword'));
		httpRequest.addParam(type="formfield", name="signature", value=arguments.paymentMethod.getIntegration().setting('paypalAccountSignature'));
		httpRequest.addParam(type="formfield", name="version", value="98.0");*/

		// line items
		for( var i=1; i <= arrayLen(arguments.order.getOrderItems()); ++i){
			var orderItem = arguments.order.getOrderItems()[i];
			queryString &= "&MC_L_PAYMENTREQUEST_0_NAME#i-1#=#orderItem.getSku().getProduct().getTitle()#";
			queryString &= "&MC_L_PAYMENTREQUEST_0_NUMBER#i-1#=#orderItem.getSku().getSkuCode()#";
			queryString &= "&MC_L_PAYMENTREQUEST_0_AMT#i-1#=#orderItem.getItemTotal()#";
			queryString &= "&MC_L_PAYMENTREQUEST_0_QTY#i-1#=#orderItem.getQuantity()#";

			/*httpRequest.addParam(type="formfield", name="L_PAYMENTREQUEST_0_NAME#i-1#", value="#orderItem.getSku().getProduct().getTitle()#");
			httpRequest.addParam(type="formfield", name="L_PAYMENTREQUEST_0_NUMBER#i-1#", value="#orderItem.getSku().getSkuCode()#");
			httpRequest.addParam(type="formfield", name="L_PAYMENTREQUEST_0_AMT#i-1#", value="#orderItem.getItemTotal()#");
			httpRequest.addParam(type="formfield", name="L_PAYMENTREQUEST_0_QTY#i-1#", value="#orderItem.getQuantity()#");*/
		}

		queryString &= "&MC_PAYMENTREQUEST_0_PAYMENTACTION=SALE";
		queryString &= "&MC_PAYMENTREQUEST_0_ITEMAMT=#arguments.order.getSubTotalAfterItemDiscounts()#";
		queryString &= "&MC_PAYMENTREQUEST_0_TAXAMT=#arguments.order.getTaxTotal()#";
		queryString &= "&MC_PAYMENTREQUEST_0_SHIPPINGAMT=#arguments.order.getFulfillmentChargeTotal()#";
		queryString &= "&MC_PAYMENTREQUEST_0_AMT=#arguments.order.getTotal()#";
		queryString &= "&MC_PAYMENTREQUEST_0_CURRENCYCODE=#arguments.order.getCurrencyCode()#";

		// cart totals
		/*httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_PAYMENTACTION", value="SALE");
		httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_ITEMAMT", value="#arguments.order.getSubTotalAfterItemDiscounts()#");
		httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_TAXAMT", value="#arguments.order.getTaxTotal()#");
		httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_SHIPPINGAMT", value="#arguments.order.getFulfillmentChargeTotal()#");
		httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_AMT", value="#arguments.order.getTotal()#");
		httpRequest.addParam(type="formfield", name="PAYMENTREQUEST_0_CURRENCYCODE", value="#arguments.order.getCurrencyCode()#");*/

		//httpRequest.addParam(type="formfield", name="noShipping", value="0");

		queryString &= "&MC_allowNote=0";
		queryString &= "&MC_SOLUTIONTYPE=Sole";
		queryString &= "&MC_LANDINGPAGE=Billing";
		queryString &= "&email=#arguments.order.getAccount().getPrimaryEmailAddress().getEmailAddress()#";

		/*
		httpRequest.addParam(type="formfield", name="allowNote", value="0");
		httpRequest.addParam(type="formfield", name="SOLUTIONTYPE", value="Sole");
		httpRequest.addParam(type="formfield", name="LANDINGPAGE", value="Billing");
		httpRequest.addParam(type="formfield", name="hdrImg", value=arguments.paymentMethod.getIntegration().setting('WORLDPAYIMAGE'));
		httpRequest.addParam(type="formfield", name="email", value=arguments.order.getAccount().getPrimaryEmailAddress().getEmailAddress());
*/

		return queryString;
	}
}