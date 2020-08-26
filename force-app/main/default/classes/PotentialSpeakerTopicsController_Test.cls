/**********************************************
/* Name : ContactNewOverrideController_Test
/* Created By : Shubham
/* Case : 00138614
/*********************************************/
@isTest
private class PotentialSpeakerTopicsController_Test {

    static testMethod void myUnitTest() {
    	Contact c = new Contact();
        c.LastName = 'Test';
        insert c ;
        
        Account acc = new Account();
        acc.Name = 'AccTest';
        insert acc;
        
        c.AccountId = acc.id;
        update c;
        
        Potential_Speaker_Topic__c topic = new Potential_Speaker_Topic__c();
        topic.Name = 'TestTopic';
        topic.CurrencyIsoCode = 'USD';
        insert topic;
        
        PotentialSpeakerTopicsController controller = new PotentialSpeakerTopicsController(new Apexpages.Standardcontroller(c));
        controller.selectedTopics = 'TestTopic, Test, Test1, Test2, Test3';
        controller.doSave();
        Integer count = controller.getCountOfTags();
        
    }
}