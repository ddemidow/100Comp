/***********************************************************
Created by - Jyoti Singh
Use - Deleting Unpaid Invoices records.
Created Date - July 07, 2014
************************************************************/
global class BatchToDeleteUnpaidInvoices implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date currentDate = Date.today();        
        return Database.getQueryLocator([Select Id, CreatedDate From Unpaid_Invoices__c where CreatedDate < : currentDate ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<Unpaid_Invoices__c> unpaidInvoices = (list<Unpaid_Invoices__c>) scope;
        
        if(unpaidInvoices.size()>0){
            delete unpaidInvoices;
        }
   }
   
   global void finish(Database.BatchableContext BC){
   }
}