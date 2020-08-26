/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossActualRevenueBatch
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Created data for the Profit Loss reporting object.  This job processes records
* - in the Project Forecast object.
----------------------------------------------------------------------------------------------------- */
global without sharing class FFA_ProfitLossActualRevenueBatch extends FFA_ProfitLossReportingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public boolean testException = false;  
    public boolean exceptionThrown = false;
    public String jobMessage;
    public class FFA_ProfitLossActualRevenueBatchException extends Exception {}
    
    global FFA_ProfitLossActualRevenueBatch() {
    }      
    global void execute(SchedulableContext sc) {
        database.executeBatch(new FFA_ProfitLossActualRevenueBatch());
    }  
         
    global Database.QueryLocator start(Database.BatchableContext BC){
    	setLastRunDate('FFA_ProfitLossActualRevenueBatch');	
    	    	
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([   
            SELECT ffrr__Account__c, ffrr__AmountRecognized__c, 
            CreatedDate, ffrr__Currency__c, CurrencyIsoCode, LastModifiedDate, 
            Opportunity__c, ffrr__Period__c, ffrr_exp__Project__c, 
            ffrr_exp__Project__r.pse__Account__c, ffrr__AccountType__c,
            ffrr__RecognizedDate__c, ffrr__RecognizedRecordID__c, Name,
            Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r)
            FROM ffrr__RevenueRecognitionTransactionLine__c
            WHERE ffrr__AccountType__c = 'Income Statement'
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            order by LastModifiedDate desc
            limit 2]);  
        } else {            
            return Database.getQueryLocator([ 
            SELECT ffrr__Account__c, ffrr__AmountRecognized__c, 
            CreatedDate, ffrr__Currency__c, CurrencyIsoCode, LastModifiedDate, 
            Opportunity__c, ffrr__Period__c, ffrr_exp__Project__c, 
            ffrr_exp__Project__r.pse__Account__c,ffrr__AccountType__c,
            ffrr__RecognizedDate__c, ffrr__RecognizedRecordID__c, Name,
            Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r) 
            FROM ffrr__RevenueRecognitionTransactionLine__c
            WHERE ffrr__AccountType__c = 'Income Statement'
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            Order by CreatedDate
            ]);
        }
    }     
             
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Savepoint dbSave = Database.setSavepoint();
        List<ffrr__RevenueRecognitionTransactionLine__c> transList = scope;
        Integer transCount = scope.size();
        try {  
            if (testException) {
                throw new FFA_ProfitLossActualRevenueBatchException('test');
            }
            FFA_ProfitLossReportingDataActions.processRevenueActuals(transList); 
            jobMessage = 'Successfully processed '+ transCount +' revenue actual (transaction line) objects.';   
        } catch (Exception e) {  
            System.debug('exception='+e);
            Database.rollback(dbSave);
            jobMessage = e.getMessage();  
            jobMessage += ' AND Scope='+scope;
            exceptionThrown = true;   
        }
    }     
    
    global void finish(Database.BatchableContext BC){       
        if (exceptionThrown) { 
            FFA_Admin_Setting__c configData = FFA_Admin_Setting__c.getInstance('Default'); 
            
            String email = configData.Alert_Email__c;
            String[] toAddresses = email.split(','); 
          
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob WHERE Id =
                                  :BC.getJobId()];
          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);  
            mail.setSubject('FFA_ProfitLossActualRevenueBatch ' + a.Status);
            String msg = 'The batch Apex job processed ' + a.TotalJobItems + ' items.';
            msg += '\n ' + jobMessage;
            mail.setPlainTextBody(msg);
            if (a.TotalJobItems > 0) {      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }    
    }

}