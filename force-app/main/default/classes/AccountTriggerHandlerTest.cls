/*===========================================
* Class Name: AccountTriggerHandlerTest
* Description: Test Class for AccountTriggerHandler [S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class AccountTriggerHandlerTest{
    public static Account acc;
    public static Contact con;
    public static Map<Id,Account> accMapOld;
    public static Map<Id,Account> accMapNew;
    
    static void testSetup(){
        
        FFA_TestUtility testUtil = new FFA_TestUtility();
        acc = testUtil.newAccount(true);
        accMapOld = new Map<Id,Account>();
        accMapOld.put(acc.id,acc);
        
        con = testUtil.newResource(false,acc.id,UserInfo.getUserId());
        con.Account_Name__c = 'Test Acc Name';
        insert con;
        
        acc.Name='Test Account Update';
        acc.Type='Vendor';
        update acc;
        accMapNew = new Map<Id,Account>();
        accMapNew.put(acc.id,acc);
    }
    
    @isTest
    static void testMethod1(){
        testSetup();
        Test.startTest();
        AccountTriggerHandler.onAfterUpdateofAccount(accMapOld,accMapNew);
        AccountTriggerHandler.onAfterDeleteofAccount(accMapOld);
        Test.stopTest();
        System.assertNotEquals(accMapOld, null);
        System.assertNotEquals(accMapNew, null);
    }
}