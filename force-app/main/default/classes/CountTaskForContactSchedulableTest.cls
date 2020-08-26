/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : Test Class for  CountTaskForConatctSchedulable
*********************************************************************************/
@isTest
public class CountTaskForContactSchedulableTest {
    
    @isTest
    static void testMethod2() {
        Test.startTest();
        CountTaskForConatctSchedulable cc = new CountTaskForConatctSchedulable();
        String cex = '0 0 2 * * ?';
        system.schedule('Count number of task for Contact', cex, cc);
        Test.stopTest();
    }
}