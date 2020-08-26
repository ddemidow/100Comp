/************************************************
Name : Test_Campaign_AdvanceWorkflow 
Created By : Reena Acharya(Appirio JDC)
Created Date : 9/4/2014
Description : Test coverage of trigger Campaign_AdvanceWorkflow 
************************************************/
@isTest
private class Test_Campaign_AdvanceWorkflow {
    @isTest
    static void myUnitTest() {
     
     Campaign cc = new Campaign(Name='test');
     insert cc;
     
     Skiptriggers__c st = new SkipTriggers__c(Name = 'test');
     insert st;
     
     update cc;
     
    }
}