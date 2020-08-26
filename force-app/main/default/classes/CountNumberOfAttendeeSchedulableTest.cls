/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Test Class for  CountNumberOfAttendeeSchedulable
*********************************************************************************/
@isTest
private class CountNumberOfAttendeeSchedulableTest {
    
    @isTest
    static void testMethod2() {
        Test.startTest();
        CountNumberOfAttendeeSchedulable cna = new CountNumberOfAttendeeSchedulable();
        String cex = '0 0 2 * * ?';
        system.schedule('Count number of attendee', cex, cna);
        Test.stopTest();
    }
    
}