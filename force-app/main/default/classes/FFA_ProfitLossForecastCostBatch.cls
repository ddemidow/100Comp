/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossForecastCostBatch
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Created data for the Profit Loss reporting object.  This job processes records
* - in the Project Forecast object.
----------------------------------------------------------------------------------------------------- */
global without sharing class FFA_ProfitLossForecastCostBatch extends FFA_ProfitLossReportingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public boolean testException = false;  
    public boolean exceptionThrown = false;  
    public String jobMessage;
    public class FFA_ProfitLossForecastCostBatchException extends Exception {}
    
    global FFA_ProfitLossForecastCostBatch() {
    }      
    global void execute(SchedulableContext sc) {
        database.executeBatch(new FFA_ProfitLossForecastCostBatch());
    }   
         
    global Database.QueryLocator start(Database.BatchableContext BC){
    	setLastRunDate('FFA_ProfitLossForecastCostBatch');	
    	
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([   
            SELECT Id, pse__Actual_Billable_Amount__c, pse__Actual_Days__c, 
            pse__Actual_Hours__c, pse__Assignment__c, CurrencyIsoCode, 
            pse__End_Date__c, pse__Estimated_Days__c, pse__Estimated_Hours__c, 
            pse__Project__c, pse__Resource__c, pse__Scheduled_Bill_Rate__c, 
            pse__Scheduled_Bill_Rate_is_Daily_Rate__c, pse__Start_Date__c, 
            pse__Assignment__r.pse__Cost_Rate_Amount__c, 
            pse__Assignment__r.pse__Suggested_Bill_Rate_Number__c, 
            pse__Assignment__r.pse__Is_Billable__c,
            pse__Resource__r.pse__External_Resource__c, 
            pse__Time_Period__c, pse__Project__r.pse__Account__c,
        	 pse__Project__r.pse__Billing_Type__c,
            (SELECT Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
			  Est_Vs_Actual__c,CurrencyISOCode, Account__c, Category__c, 
			  Subcategory__c, Type__c, Time_Period__c, Project__c,
			  Reference_Id__c, Reference_Type__c, RecordTypeId FROM Profit_Loss_Reporting_Data__r) 
            FROM pse__Est_Vs_Actuals__c
            WHERE pse__Estimated_Hours__c > 0
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            order by CreatedDate desc
            limit 2]);
        } else {            
            return Database.getQueryLocator([ 
            SELECT Id, pse__Actual_Billable_Amount__c, pse__Actual_Days__c, 
            pse__Actual_Hours__c, pse__Assignment__c, CurrencyIsoCode, 
            pse__End_Date__c, pse__Estimated_Days__c, pse__Estimated_Hours__c, 
            pse__Project__c, pse__Resource__c, pse__Scheduled_Bill_Rate__c, 
            pse__Scheduled_Bill_Rate_is_Daily_Rate__c, pse__Start_Date__c, 
            pse__Assignment__r.pse__Cost_Rate_Amount__c, 
            pse__Assignment__r.pse__Suggested_Bill_Rate_Number__c, 
            pse__Assignment__r.pse__Is_Billable__c,
            pse__Resource__r.pse__External_Resource__c, 
            pse__Time_Period__c, pse__Project__r.pse__Account__c,
            pse__Project__r.pse__Billing_Type__c,
            (SELECT Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
			  Est_Vs_Actual__c,CurrencyISOCode, Account__c, Category__c, 
			  Subcategory__c, Type__c, Time_Period__c, Project__c,
			  Reference_Id__c, Reference_Type__c, RecordTypeId FROM Profit_Loss_Reporting_Data__r) 
            FROM pse__Est_Vs_Actuals__c
            WHERE pse__Assignment__r.pse__Suggested_Bill_Rate_Number__c > 0
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            Order by CreatedDate
            ]);  
        }
    }     
             
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Savepoint dbSave = Database.setSavepoint();
        List<pse__Est_Vs_Actuals__c> transList = scope;
        Integer transCount = scope.size();
        try {    
            if (testException) {  
                throw new FFA_ProfitLossForecastCostBatchException('test');
            }
            FFA_ProfitLossReportingDataActions.processLaborCostForecasts(transList); 
            for (pse__Est_Vs_Actuals__c transRow : transList) {
            	transRow.Report_Data_Capture_Date__c = System.now();
            }
            update transList;
            jobMessage = 'Successfully processed '+ transCount +' cost forecast (est. vs. actuals) objects.';   
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
            mail.setSubject('FFA_ProfitLossForecastCostBatch ' + a.Status);
            String msg = 'The batch Apex job processed ' + a.TotalJobItems + ' items.';
            msg += '\n ' + jobMessage;
            mail.setPlainTextBody(msg);
            if (a.TotalJobItems > 0) {      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }    
    }

}