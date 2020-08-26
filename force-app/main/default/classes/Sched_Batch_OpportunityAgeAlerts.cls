/**
 *  Purpose         :   This scheduler is used to schedule Batch_OpportunityAgeAlerts class.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   02/23/2016
 *
 *  Current Version :   V1.0
 *
 *  Revision Log    :   V1.0 - Created - S-374199
 **/
global class Sched_Batch_OpportunityAgeAlerts implements Schedulable {
    
    //execute method to execute the logic of batch processing 
    global void execute(SchedulableContext ctx) {
        
        //Batch executes here
        Database.executeBatch(new Batch_OpportunityAgeAlerts(1), 200);
    }
}