/*===========================================
* Class Name: LeadTriggerTest
* Description: Test Class for LeadTrigger [S-553690]
* Created Date: 4 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class LeadTriggerTest{
    static testMethod void myUnitTest(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Company = 'Test';
        l.CurrencyIsoCode = 'USD';
        l.Group__c = 'G100';
        l.LeadSource = 'Other';
        l.Status = 'Open';
        l.Rating = 'Warm';
        insert l;
        
        ActionPlan__c acPlan = new ActionPlan__c();
        acPlan.Name='Test Account Plan';
        acPlan.Account__c = acc.id;
        acPlan.StartDate__c = System.today();
        acPlan.Lead__c = l.id;
        insert acPlan;
        
        Test.startTest();
        delete l;
        delete acPlan;
        undelete acPlan;
        undelete l;
        Test.stopTest();
        
        System.assertEquals(l.LeadSource,'Other');
        System.assertEquals(acPlan.Name,'Test Account Plan');
    }
}