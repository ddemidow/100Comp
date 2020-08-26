/**
 *  Purpose			:	This class is used to create or delete the Reporting Balances on Deal Sheets.
 *
 *  Created By		:	Padmesh Soni (Appirio Offshore)
 *
 *  Created Date	:   11/05/2015
 *
 *  Current Version	:   V_1.1
 *
 *  Revision Log	:   V_1.0 - Created - S-361837
 						V_1.1 - Modified - Shubham Paboowal (Appirio Offshore - 12/16/2015) - Case #: 00143977
 **/
global class Batch_DelReportBalanceWithoutDealSheet implements Database.Batchable<sObject> {
	
	//Start method definition of Batchable interface abstract method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #Start
        //Getting query result from Deal Sheet sobject
        return Database.getQueryLocator([Select Id From c2g__ReportingBalance__c WHERE Deal_Sheet__c = null OR (Deal_Sheet__c != null AND Deal_Sheet__r.Prevailing_Version__c = false)]);
        //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #End
    }
    //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #Start
    //Execute method definition of Batchable interface abstract method
    global void execute(Database.BatchableContext BC, List<c2g__ReportingBalance__c> scope) {
    //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #End
		//Perform DML Operation on list of Deal Sheet
		delete scope;
    }
    
    //Finish method definition of Batchable interface abstract method
    global void finish(Database.BatchableContext BC) {
		
    }
}