/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Milestone1_ProjectTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Milestone1_ProjectTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Milestone1_Project__c());
    }
}