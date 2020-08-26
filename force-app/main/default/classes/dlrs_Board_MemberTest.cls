/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Board_MemberTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Board_MemberTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Board_Member__c());
    }
}