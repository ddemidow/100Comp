/*********************************************************************************
Name : Jyotirmaya Rath
Created By : Appirio  
Created Date : 03 Nov 2015
Purpose : Schedule class to send an email of due Tasks (Run At 6 AM EST)
*********************************************************************************/
global class DueDateTaskDetailsBatchScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        id batchId = Database.executeBatch(new DueDateTaskDetailsBatch(),200); 
        
    }  
    
}