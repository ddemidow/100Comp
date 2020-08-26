/*===========================================
* Class Name: CaseTriggerTest
* Description: Test Class for CaseTrigger [S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class CaseTriggerTest{
    static testMethod void myUnitTest(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        
        Case c = new Case();
        c.CurrencyIsoCode = 'USD';
        c.Status = 'New';
        c.Origin = 'Phone';
        insert c;
        
        ActionPlan__c acPlan = new ActionPlan__c();
        acPlan.Name='Test Account Plan';
        acPlan.Account__c = acc.id;
        acPlan.StartDate__c = System.today();
        acPlan.Case__c = c.id;
        insert acPlan;
        
        Test.startTest();
        delete c;
        delete acPlan;
        undelete acPlan;
        undelete c;
        Test.stopTest();
        
        System.assertEquals(c.Origin,'Phone');
        System.assertEquals(acPlan.Name,'Test Account Plan');
    }
}