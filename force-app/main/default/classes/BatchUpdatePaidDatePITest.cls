@isTest
private class BatchUpdatePaidDatePITest {
	
	@isTest static void test_method_one() {
        //Method modified by Saurabh S-640524
        /*c2g__codaTransaction__c cdTransaction = new c2g__codaTransaction__c();
        cdTransaction.c2g__TransactionType__c = 'Purchase Invoice';
        insert cdTransaction;*/
        
        c2g__codaTransaction__c cdTransaction2 = new c2g__codaTransaction__c();
        cdTransaction2.c2g__TransactionType__c = 'Cash Matching Journal';
        
        c2g__codaPurchaseInvoice__c cdPurchase = new c2g__codaPurchaseInvoice__c();
        cdPurchase.c2g__Transaction__c = cdTransaction2.Id;
        
        c2g__codaPurchaseInvoice__c cdPurchase2 = new c2g__codaPurchaseInvoice__c();
        cdPurchase2.c2g__Transaction__c = cdTransaction2.Id;
        
        List<c2g__codaPurchaseInvoice__c>  cPurchaselist =  new List<c2g__codaPurchaseInvoice__c>(); 
        cPurchaselist.add(cdPurchase);
        cPurchaselist.add(cdPurchase2);
        
		Test.startTest();
        BatchUpdatePaidDatePI bupdSI = new BatchUpdatePaidDatePI();
        //Database.executeBatch(bupdSI);
        Database.QueryLocator ql = bupdSI.start(null); //Added by Saurabh S-640524
        bupdSI.execute(null,cPurchaselist);
        Test.stopTest(); 
	}
	
}