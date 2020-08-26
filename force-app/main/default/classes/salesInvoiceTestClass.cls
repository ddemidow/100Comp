@isTest(SeeAllData=true) 
// Since Salesinvoice is part of financialforce manage packgage , its not possible to create a test data for this object without using seeAllaData, so we have used it for deployement purpose
private class salesInvoiceTestClass
{
 static testMethod void salesInvoiceTest() 
 {
  Boolean isSandbox;
  isSandbox = URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
  if(isSandbox==true)
   { 
     system.debug('test1');
   //  return; // only for production deployment

   } 
   c2g__codaCompany__c cc = [Select id from c2g__codaCompany__c where name = 'High Lantern Group, LLC' limit 1];
   
   c2g__codaUserCompany__c cuc = new c2g__codaUserCompany__c();
   cuc.c2g__Company__c = cc.Id;
   cuc.c2g__User__c = UserInfo.getUserId() ;
   cuc.CurrencyIsoCode = 'USD';
   insert cuc;
     
  c2g__codaInvoice__c  saIn = [Select Id, Invoice_Notes__c from c2g__codaInvoice__c where c2g__PaymentStatus__c = 'Paid' and c2g__Account__r.Name = 'EY' and c2g__OwnerCompany__c  =: cc.id limit 1];
  saIn.Invoice_Notes__c = 'test';
  update saIn;
}
}