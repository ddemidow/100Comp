/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Milestone1_TaskTest
{
    @IsTest
    private static void testTrigger()
    {
        //Start Added by Himanshu Baghmar for Case #00269061
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        //End Added by Himanshu Baghmar for Case #00269061
        // Force the dlrs_Milestone1_TaskTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(ms1); //Modified by Himanshu Baghmar for Case #00269061
    }
}