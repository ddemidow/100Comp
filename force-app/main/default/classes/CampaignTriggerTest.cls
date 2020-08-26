/*===========================================
* Class Name: CampaignTriggerTest
* Description: Test Class for CampaignTrigger [S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class CampaignTriggerTest{
    static testMethod void myUnitTest(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        
        Campaign c = new Campaign();
        c.Name='Test Campaign';
        c.Group__c='G100';
        c.Status = 'In Progress';
        c.Type = 'Other';
        c.StartDate= System.today();
        insert c;
        
        ActionPlan__c acPlan = new ActionPlan__c();
        acPlan.Name='Test Account Plan';
        acPlan.Account__c = acc.id;
        acPlan.StartDate__c = System.today();
        acPlan.Campaign__c = c.id;
        insert acPlan;
        
        Test.startTest();
        delete c;
        delete acPlan;
        undelete acPlan;
        undelete c;
        Test.stopTest();
        System.assertEquals(c.Status,'In Progress');
        System.assertEquals(acPlan.Name,'Test Account Plan');
    }
}