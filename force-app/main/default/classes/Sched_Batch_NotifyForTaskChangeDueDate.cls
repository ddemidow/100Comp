/**
 *  Purpose         :   This scheduler is used to schedule Batch_NotifyForCoachingTaskDues class only for second notification type.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   12/09/2015
 *
 *  Current Version :   V1.0
 *
 *  Revision Log    :   V1.0 - Created - S-358685
 **/
global class Sched_Batch_NotifyForTaskChangeDueDate implements Schedulable {
    
    //execute method to execute the logic of batch processing 
    global void execute(SchedulableContext ctx) {
        
        //Batch executes here
        Database.executeBatch(new Batch_NotifyForCoachingTaskDues(2), 200);
    }
}