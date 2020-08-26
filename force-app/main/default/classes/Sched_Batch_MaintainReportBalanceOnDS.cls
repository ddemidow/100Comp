/**
 *  Purpose         :   This scheduler is used to schedule Batch_MaintainReportBalanceOnDealSheet class.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   11/06/2015
 *
 *  Current Version :   V1.0
 *
 *  Revision Log    :   V1.0 - Created - S-361837
 **/
global class Sched_Batch_MaintainReportBalanceOnDS implements Schedulable {
    
    //execute method to execute the logic of batch processing 
    global void execute(SchedulableContext ctx) {
        
        //Batch executes here
        Database.executeBatch(new Batch_MaintainReportBalanceOnDealSheet(), 200);
    }
}