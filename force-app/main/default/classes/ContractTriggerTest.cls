/*===========================================
* Class Name: ContractTriggerTest
* Description: Test Class for ContractTrigger [S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class ContractTriggerTest{
    static testMethod void myUnitTest(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        
        Contract c = new Contract();
        c.AccountId= acc.Id;
        c.Status = 'Draft';
        c.currencyIsoCode= 'USD';
        c.StartDate= System.today();
        c.ContractTerm = 4;
        insert c;
        
        ActionPlan__c acPlan = new ActionPlan__c();
        acPlan.Name='Test Account Plan';
        acPlan.Account__c = acc.id;
        acPlan.StartDate__c = System.today();
        acPlan.Contract__c= c.id;
        insert acPlan;
        
        Test.startTest();
        delete c;
        delete acPlan;
        undelete acPlan;
        undelete c;
        Test.stopTest();
        
        System.assertEquals(c.StartDate,System.today());
        System.assertEquals(acPlan.Name,'Test Account Plan');
    }
}