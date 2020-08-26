/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossForecastRevenueBatch
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Created data for the Profit Loss reporting object.  This job processes records
* - in the Project Forecast object.
----------------------------------------------------------------------------------------------------- */
global without sharing class FFA_ProfitLossForecastRevenueBatch extends FFA_ProfitLossReportingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
  
    public boolean testException = false;  
    public boolean exceptionThrown = false; 
    public String jobMessage;
    public class FFA_ProfitLossForecastRevenueBatchException extends Exception {}
    
    global FFA_ProfitLossForecastRevenueBatch() {
    }      
    global void execute(SchedulableContext sc) {
        database.executeBatch(new FFA_ProfitLossForecastRevenueBatch());
    }  
         
    global Database.QueryLocator start(Database.BatchableContext BC){
		setLastRunDate('FFA_ProfitLossForecastRevenueBatch');			
			
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([   
            SELECT Id, pse__Entered_Forecast__c, CurrencyISOCode,
            CreatedDate, LastModifiedDate, pse__Time_Period__c, 
            pse__Project__c, pse__Region__c, pse__Practice__c,
            pse__Region__r.ffpsai__OwnerCompany__c,
            pse__Project__r.pse__Account__c,   
            Report_Data_Capture_Date__c,
            Expense_Cost_Forecast__c,
            (SELECT  Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
					  Forecast__c,CurrencyISOCode, Account__c, Category__c, 
					  Subcategory__c, Type__c, Time_Period__c, Project__c,
					  Reference_Id__c, Reference_Type__c, RecordTypeId FROM Profit_Loss_Reporting_Data__r) 
            FROM pse__Forecast__c  
            WHERE Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate
            Order by CreatedDate desc
            limit 2]);
        } else {            
            return Database.getQueryLocator([ 
            SELECT Id, pse__Entered_Forecast__c, CurrencyISOCode,
            CreatedDate, LastModifiedDate, pse__Time_Period__c, 
            pse__Project__c, pse__Region__c, pse__Practice__c,
            pse__Region__r.ffpsai__OwnerCompany__c,
            pse__Project__r.pse__Account__c,
            Report_Data_Capture_Date__c,
            Expense_Cost_Forecast__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r)       
            FROM pse__Forecast__c  
            WHERE Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate
   			Order by CreatedDate desc 
            ]);
        }
    }     
             
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Savepoint dbSave = Database.setSavepoint();
        List<pse__Forecast__c> transList = scope;
        Integer transCount = scope.size();
        try {  
            if (testException) { 
                throw new FFA_ProfitLossForecastRevenueBatchException('test');
            }
            FFA_ProfitLossReportingDataActions.processRevenueForecasts(transList); 
            jobMessage = 'Successfully processed '+ transCount +' revenue forecast objects.';   
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
            mail.setSubject('FFA_ProfitLossForecastRevenueBatch ' + a.Status);
            String msg = 'The batch Apex job processed ' + a.TotalJobItems + ' items.';
            msg += '\n ' + jobMessage;
            mail.setPlainTextBody(msg);
            if (a.TotalJobItems > 0) {      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }    
    }

}