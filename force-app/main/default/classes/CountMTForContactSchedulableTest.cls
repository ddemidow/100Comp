/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Test Class for  CountMeetingTaskForContactSchedulable
*********************************************************************************/
@isTest
public class CountMTForContactSchedulableTest {
    @isTest
    static void testMethod2() {
        Test.startTest();
        CountMeetingTaskForContactSchedulable ctc = new CountMeetingTaskForContactSchedulable();
        String cex = '0 0 2 * * ?';
        system.schedule('Count number of Meeting Task', cex, ctc);
        Test.stopTest();
    }
}