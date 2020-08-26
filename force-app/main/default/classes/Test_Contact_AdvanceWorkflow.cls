/************************************************
Name : Test_Contact_AdvanceWorkflow
Created By : Reena Acharya(Appirio JDC)
Created Date : 9/4/2014
Description : Test coverage of trigger Contact_AdvanceWorkflow
************************************************/
@isTest
private class Test_Contact_AdvanceWorkflow {
    
    static testMethod void triggerAdvanceWorkflow() {
        Contact cont = new Contact(LastName = 'test');
        insert cont;
        
        skipTriggers__c st = new SkipTriggers__c(Name = userinfo.getUserId());
        insert st;
        
        update cont;
    
    }
}