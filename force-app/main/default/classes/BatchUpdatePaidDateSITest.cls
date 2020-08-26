/************************************************************************************************************************
Name            :  BatchUpdatePaidDateSITest
Created by      :  Shivani Jain [Appirio JDC] 
Related Story   :  S-637724
Description     :  Test class for BatchUpdatePaidDateSI
*************************************************************************************************************************/
@isTest(SeeAllData = True)
private class BatchUpdatePaidDateSITest {

    private static testMethod void BatchUpdatePaidDateSItest() {
        
        Test.startTest();
        BatchUpdatePaidDateSI bupdSI = new BatchUpdatePaidDateSI();
        Database.executeBatch(bupdSI);
        Test.stopTest();    

    }

    private static testMethod void mapNegativeToPositiveInvoicesTest() {
        Test.startTest();
        c2g__codaInvoice__c ctrans = [select Id from c2g__codaInvoice__c limit 1];
        Map<Id,c2g__codaInvoice__c> mapInv = new Map<Id,c2g__codaInvoice__c>();
        Map<Id,c2g__codaInvoice__c> mapInv1 = new Map<Id,c2g__codaInvoice__c>();
        mapInv.put(ctrans.Id, ctrans);
        BatchUpdatePaidDateSI bupdSI = new BatchUpdatePaidDateSI();
        bupdSI.mapNegativeToPositiveInvoices(mapInv1, mapInv);
        Test.stopTest(); 
    }

}