/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Schedulable class for CountNumberOfAttendee
*********************************************************************************/
global class TaskAndEventAttendeeSchedulable implements Schedulable {
    global void execute(SchedulableContext SC) {
        CountNumberOfAttendee cna = new CountNumberOfAttendee();
        CountTaskForConatct ctc = new CountTaskForConatct();
        CountMeetingTaskForContact cmc = new CountMeetingTaskForContact();
    }
}