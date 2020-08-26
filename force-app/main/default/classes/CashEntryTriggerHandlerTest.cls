/*
// (c) 2017 Appirio (A Wipro company), Inc.
//
// CashEntryTriggerHandlerTest: 
//
// 15 Dec 2017      Jai Gupta       Original (S-524906) Test class for CashEntryTrigger
// 25 Sept 2018     Jessica Schilling       C-00240137      Fixing test class failures
//
*/
@isTest(SeeAllData=true)
private class CashEntryTriggerHandlerTest {

    static testMethod void myUnitTest1() {
        List<String> companies;
        c2g__codaCompany__c comp;
        
        //START JSCHILLING 9/27/2018 C-00240137 Adding test data
        c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__User__c = UserInfo.getUserId();
        userCompany.c2g__Company__c = [Select Id from c2g__codaCompany__c WHERE OwnerId IN (SELECT GroupId FROM GroupMember where userorgroupid = :UserInfo.getUserId()) LIMIT 1][0].Id;
        insert userCompany;
        //END JSCHILLING 9/27/2018 C-00240137
    
        try {
            companies = c2g.CODAAPICompany_2_0.getCurrentCompanies(null);
            comp = [Select Id from c2g__codaCompany__c where name = :companies[0] limit 1];
        } catch (Exception e) {
        }
            
        List<c2g__codaAccountingCurrency__c> listCurrency = [Select Id,Name from c2g__codaAccountingCurrency__c where c2g__OwnerCompany__c = :comp.id and Name = 'USD' limit 1 ] ;
        
        c2g__codaAccountingCurrency__c ac ;
        if(listCurrency.size() > 0) {
            ac = listCurrency[0];
        } else {
        
            ac = new c2g__codaAccountingCurrency__c();
            ac.Name = 'HUF';  
            ac.c2g__DecimalPlaces__c  = 2 ;
            ac.CurrencyISOCode = 'HUF' ;
            ac.c2g__OwnerCompany__c = comp.id ;
            insert ac ;
        }
        c2g__codaGeneralLedgerAccount__c a = new c2g__codaGeneralLedgerAccount__c ();
        a.c2g__ReportingCode__c  = '122121212';
        a.c2g__Type__c  = 'Profit and Loss' ; // Modified by Himanshu Matharu C-00240137 [14 Oct 2018]
        insert a ;
        c2g__codaBankAccount__c b = new c2g__codaBankAccount__c();
        b.c2g__AccountName__c = 'testingname' ;
        b.c2g__AccountNumber__c = 'testnumber';
        b.c2g__BankName__c = 'testingbankname';
        b.c2g__ReportingCode__c = '122121212';
        b.c2g__GeneralLedgerAccount__c = a.id ;
        b.c2g__BankAccountCurrency__c = ac.id;
        insert b ;
        
        Account acct = new Account(
            Name='testingname',
            c2g__CODAAccountTradingCurrency__c='USD',
            CurrencyIsoCode='USD'
        );
        insert acct;
        
        //c2g__codaAccountingCurrency__c curr = [SELECT ID, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c=:comp.Id LIMIT 1][0];
        c2g__codaPeriod__c per = [SELECT ID, c2g__StartDate__c, c2g__EndDate__c FROM c2g__codaPeriod__c WHERE c2g__EndDate__c > TODAY AND c2g__StartDate__c <= TODAY LIMIT 1][0];
        
        User u = [SELECT Id from User WHERE Username LIKE 'mcox@g100companies.com%'][0];
        
       // System.runAs(u) { // Modified by Himanshu Matharu C-00240137 [14 Oct 2018]
        c2g__codaPayment__c p = new c2g__codaPayment__c(
            c2g__GeneralLedgerAccount__c=a.id,
            c2g__PaymentDate__c=System.Today(),
            c2g__PaymentMethod__c='Check',
            c2g__DueDate__c=System.Today(),
            c2g__BankAccount__c=b.Id,
            c2g__PaymentCurrency__c=ac.Id,
            c2g__CurrencyWriteOff__c=a.id,
            c2g__SettlementDiscountReceived__c=a.id,
            c2g__Period__c=per.Id);
        //Modified below 2 lines JSCHILLING 9/25/2018 C-00240137 Querying for payment instead of creating one
        //insert p;
        c2g__codaPayment__c payment = [SELECT Id FROM c2g__codaPayment__c LIMIT 1][0];
        
        /*
        List<c2g__codaPaymentAccountLineItem__c> pali = [Select Id, c2g__Account__c , c2g__Payment__c , Payment_Reference__c  from c2g__codaPaymentAccountLineItem__c where c2g__Payment__c = :p.id];
        System.debug(pali);
        
           */   
        /*c2g__codaPaymentAccountLineItem__c pali = new c2g__codaPaymentAccountLineItem__c(
            c2g__Account__c=acct.id,
            c2g__Payment__c=p.id);
        insert pali;*/
        
        
        c2g__codaPaymentLineItem__c pli = new c2g__codaPaymentLineItem__c(
            c2g__Account__c = acct.id,
            //Modified below 1 line JSCHILLING 9/25/2018 C-00240137 Using queried payment instead
            c2g__Payment__c = payment.id
        );
        
        c2g__codaCashEntry__c ce = new c2g__codaCashEntry__c();
        ce.c2g__BankAccount__c = b.id ;
        //Modified below 1 line JSCHILLING 9/25/2018 C-00240137 Using queried payment instead
        ce.c2g__PaymentNumber__c = payment.id;
        ce.c2g__Account__c = acct.id;
        insert ce ;
        
        Test.startTest();
                BatchToUpdatePaymentReference obj = new BatchToUpdatePaymentReference();
                Database.executeBatch(obj);
        Test.stopTest();
       // } // Modified by Himanshu Matharu C-00240137 [14 Oct 2018]
    }
}