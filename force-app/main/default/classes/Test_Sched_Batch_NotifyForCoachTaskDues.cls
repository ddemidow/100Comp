/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class Test_Sched_Batch_NotifyForCoachTaskDues {
/**
 *  Purpose         :   This test class is for scheduler which is used to schedule Batch_NotifyForCoachingTaskDues class.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   11/10/2015
 *
 *  Current Version :   V1.0
 *
 *  Revision Log    :   V1.0 - Created - S-358685
 *
 *  Coverage        :   V1.0 - 100%
 **/
 
    //Test method added
    static testmethod void myUnitTest(){
        
        //create a cron expression test obj
        string CRON_EXP = '0 0 0 * * ? *';
        
        //start the test
        Test.startTest();
        
        //create a string of the jobId for a new schedule instance of the Sched_Batch_NotifyForCoachingTaskDues class
        string jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Sched_Batch_NotifyForCoachingTaskDues());
        
        //query the CronTrigger table selecting in CronTrigger fields where the Id = jobId
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: jobId];
        system.assertEquals(CRON_EXP, ct.CronExpression);
        
        //assert that the job has not been triggered
        system.assertEquals(0, ct.TimesTriggered);
        
        //assert when the next fire time will be
        system.assert(ct.NextFireTime != null);
        
        //Test stops here
        Test.stopTest();
    }
}