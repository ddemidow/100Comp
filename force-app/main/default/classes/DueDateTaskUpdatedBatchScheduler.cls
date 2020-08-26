/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 18 Dec 2015
Purpose : Schedule class to send an email of due Tasks (Run At 6 AM EST)
*********************************************************************************/
global class DueDateTaskUpdatedBatchScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        id batchId = Database.executeBatch(new DueDateTaskUpdatedBatch(),200); 
        
    }  
    
}