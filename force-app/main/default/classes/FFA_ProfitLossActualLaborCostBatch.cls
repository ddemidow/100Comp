/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossActualLaborCostBatch
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Created data for the Profit Loss reporting object.  This job processes records
* - in the Project Forecast object.
----------------------------------------------------------------------------------------------------- */
global without sharing class FFA_ProfitLossActualLaborCostBatch extends FFA_ProfitLossReportingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public boolean testException = false;  
    public boolean exceptionThrown = false;
    public String jobMessage;
    public class FFA_ProfitLossActualLaborCostBatchException extends Exception {}
    
    global FFA_ProfitLossActualLaborCostBatch() {
    }      
    global void execute(SchedulableContext sc) {
        database.executeBatch(new FFA_ProfitLossActualLaborCostBatch());
    }  
         
    global Database.QueryLocator start(Database.BatchableContext BC){
    	setLastRunDate('FFA_ProfitLossActualLaborCostBatch');		
    	
        if (Test.isRunningTest()) {
            return Database.getQueryLocator([   
            SELECT pse__Approved__c, pse__Assignment__c, ffrr_exp__BillRate__c, 
            pse__Billable__c, CurrencyIsoCode, pse__End_Date__c, pse__External_Resource__c, 
            pse__Include_In_Financials__c, Is_Daily_Bill_Rate__c, pse__Project__c, 
            pse__Resource__c, pse__Project_Exchange_Rate__c, pse__Start_Date__c, 
            pse__Total_Billable_Amount__c, pse__Total_Cost__c, pse__Total_Hours__c,
            pse__Project__r.pse__Account__c, pse__Assignment__r.pse__Cost_Rate_Amount__c,
            pse__Resource__r.pse__External_Resource__c, Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r) 
            FROM pse__Timecard__c
            WHERE pse__Include_In_Financials__c = true
            AND pse__Total_Hours__c > 0
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            order by CreatedDate desc
            limit 2]);
        } else {            
            return Database.getQueryLocator([ 
            SELECT pse__Approved__c, pse__Assignment__c, ffrr_exp__BillRate__c, 
            pse__Billable__c, CurrencyIsoCode, pse__End_Date__c, pse__External_Resource__c, 
            pse__Include_In_Financials__c, Is_Daily_Bill_Rate__c, pse__Project__c, 
            pse__Resource__c, pse__Project_Exchange_Rate__c, pse__Start_Date__c, 
            pse__Total_Billable_Amount__c, pse__Total_Cost__c, pse__Total_Hours__c ,
            pse__Project__r.pse__Account__c, pse__Assignment__r.pse__Cost_Rate_Amount__c,
            pse__Resource__r.pse__External_Resource__c, Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r) 
            FROM pse__Timecard__c
            WHERE pse__Include_In_Financials__c = true
            AND pse__Total_Hours__c > 0
            AND (Report_Data_Capture_Date__c = null 
            OR LastModifiedDate >= :lastRunDate)
            order by CreatedDate desc
            ]);
        }
    }     
             
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Savepoint dbSave = Database.setSavepoint();
        List<pse__Timecard__c> transList = scope;
        Integer transCount = scope.size();
        try {  
            if (testException) {
                throw new FFA_ProfitLossActualLaborCostBatchException('test');  
            }
            FFA_ProfitLossReportingDataActions.processLaborCostActuals(transList); 
            for (pse__Timecard__c transRow : transList) {
            	transRow.Report_Data_Capture_Date__c = System.now();
            }
            update transList;
            jobMessage = 'Successfully processed '+ transCount +' cost actual objects.';   
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
            mail.setSubject('FFA_ProfitLossActualLaborCostBatch ' + a.Status);
            String msg = 'The batch Apex job processed ' + a.TotalJobItems + ' items.';
            msg += '\n ' + jobMessage;
            mail.setPlainTextBody(msg);
            if (a.TotalJobItems > 0) {      
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }    
    }

}