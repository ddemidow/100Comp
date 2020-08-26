/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 12 Jan 2016
Purpose : test class of scheduler
*********************************************************************************/
@istest
private class OpportunityRenewalBatchSchedulerTest{
	public static testmethod void  testschedule() {
	Test.StartTest();
	OpportunityRenewalBatchScheduler sh1 = new OpportunityRenewalBatchScheduler();      
	 String sch = '0 0 23 * * ?';
	        system.schedule('Scheduler', sch, sh1);
	Test.stopTest();
	}
}