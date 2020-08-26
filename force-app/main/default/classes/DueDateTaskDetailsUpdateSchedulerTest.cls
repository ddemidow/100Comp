/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 12 Jan 2016
Purpose : test Class for Scheduler class DueDateTaskDetailsUpdateSchedulerTest
*********************************************************************************/
@istest
public class DueDateTaskDetailsUpdateSchedulerTest {
    
    static testmethod void testDueDateTaskDetailsBatchScheduler() {

        Test.startTest();
        String CRON_EXP = '0 0 6 * * ? ' ;
        String jobId = System.schedule('ScheduleApexClassTest3',CRON_EXP,new DueDateTaskUpdatedBatchScheduler());
        test.stopTest();
    }
}