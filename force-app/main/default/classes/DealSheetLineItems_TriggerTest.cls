/************************************************************************************************************************
Name            :  DealSheetLineItems_TriggerTest
Created by      :  Shivani Jain [Appirio JDC] 
Related Story   :  S-637724
Description     :  Test class for the trigger "DealSheetLineItems_Trigger"
*************************************************************************************************************************/
@isTest
private class DealSheetLineItems_TriggerTest {
    static testMethod void testRecalculate() {
        Test.startTest();
        
        Deal_Sheet__c ds = new Deal_Sheet__c();
        ds.Project_Name__c = 'testproj';
        insert ds;
        
        Deal_Sheet_Line_Item__c dlsi = new Deal_Sheet_Line_Item__c();
        dlsi.Line_Type__c = 'Resource';
        dlsi.Role__c = 'Independent Contractor';
        dlsi.Start_Date__c = Date.today();
        dlsi.End_Date__c = Date.today().addMonths(1);
        dlsi.Billable_Days__c = 1;
        dlsi.Daily_Cost_Rate__c = 12;
        dlsi.Daily_Bill_Rate__c = 12;
        dlsi.Fixed_Revenue__c = 12;
        dlsi.Deal_Sheet__c = ds.id;
        insert dlsi;
        delete dlsi;
        undelete dlsi;

        Test.stopTest();
    }
}