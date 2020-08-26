// 
// (c) 2015 Appirio, Inc.
//
// Test class for the PaymentDateOnOpportunity batch
//
// 19 Aug 2015     Nick Sharp      Original    S-339373
//
//Added seeAllData = true by Shivani for S-637724 on 092/09/2019
@isTest(SeeAllData = true)
private class PaymentDateOnOpportunityBatchTest {

    @isTest static void PaymentDateOnOpportunityBatchTest() {
            
            Test.startTest();
            PaymentDateOnOpportunityBatch batch = new PaymentDateOnOpportunityBatch();
            database.executebatch(batch);
            
            //Added for the case #00138614 #START
            
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new PaymentDateOnOpportunity());
            
            //Added for the case #00138614 #END 
            Test.stopTest(); 
    }
    
}