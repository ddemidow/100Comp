/************************************************
Name : Test_CampaignMember_AdvanceWorkflow
Created By : Reena Acharya(Appirio JDC)
Created Date : 9/4/2014
Description : Test coverage of trigger CampaignMember_AdvanceWorkflow
************************************************/
@isTest
private class Test_CampaignMember_AdvanceWorkflow {
    @isTest
    static void myUnitTest() {
     
     Campaign cc = new Campaign(Name='test');
     insert cc;
     
     Contact cont = new Contact(lastName = 'test');
     insert cont;
     
     CampaignMember cm = new CampaignMember(campaignID = cc.id , contactId = cont.id);
     insert cm;
     
     Skiptriggers__c st = new SkipTriggers__c(Name = 'test');
     insert st;
     
     update cm;
     
    }
}