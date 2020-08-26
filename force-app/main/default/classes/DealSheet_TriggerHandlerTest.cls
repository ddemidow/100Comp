/*===========================================
* Class Name: DealSheet_TriggerHandlerTest
* Description: Test Class for DealSheet_TriggerHandler[S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class DealSheet_TriggerHandlerTest{
    
    public static List<Deal_Sheet__c> dealSheetList;
    public static Map<Id,Deal_Sheet__c> mapDealSheet;
    
    static void testSetup(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        
        Deal_Sheet__c dealSheet = new Deal_Sheet__c();
        dealSheet.Project_Name__c='Test Deal Sheet';
        dealSheet.currencyIsoCode='USD';
        insert dealSheet;
        dealSheetList = new List<Deal_Sheet__c>();
        dealSheetList.add(dealSheet);
        mapDealSheet = new Map<Id,Deal_Sheet__c>();
        mapDealSheet.put(dealSheet.Id, dealSheetList[0]);
    }
    
    @isTest
    static void testMethod1(){
        testSetup();
        Test.startTest();
        DealSheet_TriggerHandler.onBeforeInsertUpdate(dealsheetList,mapDealSheet);
        DealSheet_TriggerHandler.onAfterInsert(dealsheetList,mapDealSheet);
        DealSheet_TriggerHandler.onAfterUnDelete(dealsheetList);
        DealSheet_TriggerHandler.populateDefautlDSLIonDealsSheet(dealsheetList);
        Test.stopTest();
        System.assertNotEquals(dealSheetList,null);
        System.assertNotEquals(mapDealSheet,null);
    }
}