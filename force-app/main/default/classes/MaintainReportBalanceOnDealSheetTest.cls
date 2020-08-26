/*******************************************************************************
* @Class       : MaintainReportBalanceOnDealSheetTest
* @author      : Rohit
* @description : Test Class of Batch_MaintainReportBalanceOnDealSheet (S-635394)
*******************************************************************************/
@isTest
public class MaintainReportBalanceOnDealSheetTest {
    public static testMethod void testBatchUpdatePaidDateSI() {
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

        Deal_Sheet_Line_Item__c dlsi2 = new Deal_Sheet_Line_Item__c();
        dlsi2.Line_Type__c = 'Resource';
        dlsi2.Role__c = 'Director';
        dlsi2.Start_Date__c = Date.today();
        dlsi2.End_Date__c = Date.today().addMonths(10);
        dlsi2.Billable_Days__c = 6;
        dlsi2.Daily_Cost_Rate__c = 12;
        dlsi2.Daily_Bill_Rate__c = 12;
        dlsi2.Fixed_Revenue__c = 12;
        dlsi2.Deal_Sheet__c = ds.id;
        insert dlsi2;
        
        List<c2g__ReportingBalance__c> lstRB1 = new List<c2g__ReportingBalance__c>([select id from c2g__ReportingBalance__c where Deal_Sheet__c = :ds.id and c2g__GeneralLedgerAccount__c = 'a1dF0000000BXfm']);
        
        Test.startTest();
        Batch_MaintainReportBalanceOnDealSheet btch = new Batch_MaintainReportBalanceOnDealSheet();
        Database.executeBatch(btch);
        Test.stopTest();
    }
}