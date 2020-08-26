/************************************************
* Name           : DealSheet_Test
* Creaetd By     : Alka Taneja
* Created Date   : 24 Sep, 2015
* Story          : S-320861 
************************************************/
@isTest(seeAllData=true)
public class DealSheet_Test {
/*
    public static testMethod void TestDealSheet() {
    
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
        
        List<c2g__ReportingBalance__c> lstRB = new List<c2g__ReportingBalance__c>([select id from c2g__ReportingBalance__c where Deal_Sheet__c = :ds.id]);
        //system.assertNotEquals(lstRB.size(), 0 );
        
        Deal_Sheet_Line_Item__c dlsi2 = new Deal_Sheet_Line_Item__c();
        dlsi2.Line_Type__c = 'Resource';
        dlsi2.Role__c = 'Director';
        dlsi2.Start_Date__c = Date.today();
        dlsi2.End_Date__c = Date.today().addMonths(1);
        dlsi2.Billable_Days__c = 1;
        dlsi2.Daily_Cost_Rate__c = 12;
        dlsi2.Daily_Bill_Rate__c = 12;
        dlsi2.Fixed_Revenue__c = 12;
        dlsi2.Deal_Sheet__c = ds.id;
        insert dlsi2;
        
        List<c2g__ReportingBalance__c> lstRB1 = new List<c2g__ReportingBalance__c>([select id from c2g__ReportingBalance__c where Deal_Sheet__c = :ds.id and c2g__GeneralLedgerAccount__c = 'a1dF0000000BXfm']);
        //system.assertEquals(lstRB1.size(), 2);
        
        dlsi2.End_Date__c = dlsi2.End_Date__c.addDays(-1);
        update dlsi2;
        
        delete dlsi2;
        
        Test.stopTest();
    }*/
    
    //Method to test the functionality of onBeforeInsertUpdate method of Trigger on Deal Sheet
    private static testMethod void testOnBeforeInsertUpdate() {
        
        List<Deal_Sheet__c> dealSheets = new List<Deal_Sheet__c>();
        dealSheets.add(new Deal_Sheet__c(Project_Name__c = 'testproj'));
        
        //Test start here
        Test.startTest();
        
        insert dealSheets;
        
        //Update End Date on record
        update dealSheets;
        
        delete dealSheets;
        
        //Test stop here
        Test.stopTest();
    }
    
    //Code modified - Padmesh Soni (02/15/2016 - Appirio Offshore) - S-374088
    /*** Code Changes Start here ***/
    //Method to test the functionality of onBeforeInsertUpdate method of Trigger on Deal Sheet
    private static testMethod void testPopulateDefautlDSLIonDealsSheet() {
        
        List<Deal_Sheet__c> dealSheets = new List<Deal_Sheet__c>();
        dealSheets.add(new Deal_Sheet__c(Project_Name__c = 'testproj1'));
        dealSheets.add(new Deal_Sheet__c(Project_Name__c = 'testproj2'));
        dealSheets.add(new Deal_Sheet__c(Project_Name__c = 'testproj3'));
        
        //Test start here
        Test.startTest();
        
        //perform DML operation on Deal Sheet
        insert dealSheets;
        
        //Query result of Deal Sheet Line Items
        List<Deal_Sheet_Line_Item__c> dealSheetLineItems = [SELECT Id FROM Deal_Sheet_Line_Item__c WHERE Deal_Sheet__c IN: dealSheets];
        
        //assert statement
        System.assertEquals(15, dealSheetLineItems.size());
        
        //Perform delete operation on Deal Sheets
        delete dealSheets;
        
        //Query result of Deal Sheet
        //Code Modified by Gunjan Sharma for case - 00268047
        dealSheets = [SELECT Id FROM Deal_Sheet__c WHERE Project_Name__c Like 'testproj%' AND isDeleted = true ALL ROWS];
        //Perform Undelete operation on list of Deal Sheet
		 undelete dealSheets;
        
        //Test stop here
        Test.stopTest();
    }
    /*** Code Changes Stop here ***/
    //Code modified - Padmesh Soni (02/15/2016 - Appirio Offshore) - S-374088
}