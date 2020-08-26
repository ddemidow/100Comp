/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 18 Dec 2015
Purpose : Schedule class for create the renewal Opportunity (Run At 6 AM EST)
*********************************************************************************/
global class OpportunityRenewalBatchScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        id batchId = Database.executeBatch(new OpportunityRenewalBatchClass(),200);
        
    }  
    
}