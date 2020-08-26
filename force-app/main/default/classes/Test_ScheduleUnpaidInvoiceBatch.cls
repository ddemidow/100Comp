@isTest

private class Test_ScheduleUnpaidInvoiceBatch {
    static testMethod void myUnitTest() {
        //Start Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
      	Unpaid_Invoices__c Un = new Unpaid_Invoices__c();
        Un.CreatedDate = system.today().AddMonths(-4);
        insert Un;
        //END Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
        test.startTest();

        ScheduleUnpaidInvoiceBatch unpaidInvoicebatch = new ScheduleUnpaidInvoiceBatch();

        String schedule = '0 0 23 * * ?';

        system.schedule('Unpaid Invoice Delete', schedule, unpaidInvoicebatch);

        test.stopTest();

    }

}