/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Schedulable class for CountTaskForConatct
*********************************************************************************/
global class CountTaskForConatctSchedulable implements Schedulable{
    global void execute(SchedulableContext SC) {
        CountTaskForConatct ctc = new CountTaskForConatct();
        Database.executeBatch(ctc);
    } 
}