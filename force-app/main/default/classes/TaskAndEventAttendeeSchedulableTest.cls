/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Test Class for  TaskAndEventAttendeeSchedulable
*********************************************************************************/
@isTest
public class TaskAndEventAttendeeSchedulableTest {
	@isTest
    static void testMethod2() {
        Test.startTest();
        TaskAndEventAttendeeSchedulable cc = new TaskAndEventAttendeeSchedulable();
        String cex = '0 0 2 * * ?';
        system.schedule('Count number of task for Attendee', cex, cc);
        Test.stopTest();
    }
}