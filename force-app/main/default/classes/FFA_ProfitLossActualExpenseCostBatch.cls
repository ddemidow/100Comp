/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossActualExpenseCostBatch
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Created data for the Profit Loss reporting object.  This job processes records
* - in the Project Forecast object.
----------------------------------------------------------------------------------------------------- */
global without sharing class FFA_ProfitLossActualExpenseCostBatch extends FFA_ProfitLossReportingBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    public boolean testException = false;  
    public boolean exceptionThrown = false;
    public String jobMessage;
    public class FFA_ProfitLossActualExpenseCostBatchException extends Exception {}
    
    global FFA_ProfitLossActualExpenseCostBatch() 
    {
    }      
    global void execute(SchedulableContext sc) 
    {
        database.executeBatch(new FFA_ProfitLossActualExpenseCostBatch());
    }  
         
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	setLastRunDate('FFA_ProfitLossActualExpenseCostBatch');		
    	  
        if (Test.isRunningTest()) 
        {
            return Database.getQueryLocator([SELECT pse__Billing_Amount__c, pse__Billable__c, pse__Billing_Currency__c, CurrencyIsoCode, pse__Include_In_Financials__c, pse__Project__c,pse__Resource__c, pse__Bill_Date__c, pse__Project__r.pse__Account__c,pse__Expense_Date__c,  Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r) FROM pse__Expense__c WHERE pse__Include_In_Financials__c = true AND pse__Billable__c = false AND (Report_Data_Capture_Date__c = null OR LastModifiedDate >= :lastRunDate) order by CreatedDate desc limit 2]);
        } else 
        {            
            return Database.getQueryLocator([SELECT pse__Billing_Amount__c, pse__Billable__c, pse__Billing_Currency__c, CurrencyIsoCode, pse__Include_In_Financials__c, pse__Project__c, pse__Resource__c, pse__Bill_Date__c, pse__Project__r.pse__Account__c, pse__Expense_Date__c,  Report_Data_Capture_Date__c,
            (SELECT Id FROM Profit_Loss_Reporting_Data__r) FROM pse__Expense__c WHERE pse__Include_In_Financials__c = true AND pse__Billable__c = false AND (Report_Data_Capture_Date__c = null OR LastModifiedDate >= :lastRunDate) order by CreatedDate desc]);
        }
    }     
             
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        Savepoint dbSave = Database.setSavepoint();
        List<pse__Expense__c> transList = scope;
        Integer transCount = scope.size();
        try 
        {  
            if (testException) 
            {
                throw new FFA_ProfitLossActualExpenseCostBatchException();  //MODIFIED by Rohit for S-635394
            }
            FFA_ProfitLossReportingDataActions.processExpenseCostActuals(transList); 
            for (pse__Expense__c transRow : transList) 
            {
            	transRow.Report_Data_Capture_Date__c = System.now();
            }
            update transList;
            jobMessage = 'Successfully processed '+ transCount +' expense cost actual objects.';   
        } 
        catch (Exception e) 
        {  
            System.debug('exception='+e);
            Database.rollback(dbSave);
            jobMessage = e.getMessage();  
            jobMessage += ' AND Scope='+scope;
            exceptionThrown = true;   
        }
    }     
    
    global void finish(Database.BatchableContext BC)
    {       
        if (exceptionThrown) 
        { 
            FFA_Admin_Setting__c configData = FFA_Admin_Setting__c.getInstance('Default'); 
            
            String email = configData.Alert_Email__c;
            String[] toAddresses = email.split(','); 
            //system.debug('Job Id - @@'+BC.getJobId());
          	system.debug('Emails : - '+toAddresses);
            
            AsyncApexJob a ;
            if (!Test.isRunningTest()) 
        	{
            	a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            	system.debug('@@@ '+a);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            String msg;
            if (!Test.isRunningTest()) 
        	{
            	mail.setSubject('FFA_ProfitLossActualExpenseCostBatch ' + a.Status);
            	msg = 'The batch Apex job processed ' + a.TotalJobItems + ' items.';
            }
            else
            {
                mail.setSubject('FFA_ProfitLossActualExpenseCostBatch ' + 'Custom Status');
            	msg = 'The batch Apex job processed ' + 'job items' + ' items.';
            }
            msg += '\n ' + jobMessage;
            mail.setPlainTextBody(msg);
            // Start code added by Gunjan for case - 00268047
            if (!Test.isRunningTest()) 
        	{
                if (a.TotalJobItems > 0) 
                {      
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }  
            }
            else
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            // End code added by Gunjan for case - 00268047
        }    
    }

}