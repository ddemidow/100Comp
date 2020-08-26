/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Milestone1_MilestoneTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Milestone1_MilestoneTrigger to be invoked, fails the test if org config or other Apex code prevents this.
       // Start code added by Gunjan for case - 00268047
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        dlrs.RollupService.testHandler(ms1);
        
        // End code added by Gunjan for case - 00268047
    }
}