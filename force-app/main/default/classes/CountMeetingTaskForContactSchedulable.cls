/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Schedulable class for CountMeetingTaskForContact
*********************************************************************************/
global class CountMeetingTaskForContactSchedulable implements Schedulable{
    global void execute(SchedulableContext SC) {
        CountMeetingTaskForContact cmc = new CountMeetingTaskForContact();
        Database.executeBatch(cmc);
    }    
}