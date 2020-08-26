/*******************************************************************************
* @Class       : AW_AdvanceWorkflowHTTPHandlerTest
* @author      : Rohit Sharma
* @description : Test Class of AW_AdvanceWorkflowHTTPHandler (S-635394)
*******************************************************************************/
 
@isTest
private class AW_AdvanceWorkflowHTTPHandlerTest {
    static testMethod void setHTTPCalloutTest() {
        
        User u = new User(
                 ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                 LastName = 'last',
                 Email = 'test@test321.com',
                 Username = 'test@test321.com' + System.currentTimeMillis(),
                 CompanyName = 'TEST',
                 Title = 'title',
                 Alias = 'alias',
                 TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US'
            );
        
        insert u;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='FirstName',Type__c='Update Field',Value__c='TestUpdate',endpoint_url__c='www.google.com',callout_method__c='GET',Callout_Timeout__c='200',Notified_User__c = u.Id);
    
        insert a1;
        
        
        
        Test.startTest();
        AW_AdvanceWorkflowHTTPHandler.setHTTPCallout(a1.Id,rule.Id);
        Map<String,String> input = new Map<String,String>();
        AW_AdvanceWorkflowHTTPHandler handl = new AW_AdvanceWorkflowHTTPHandler();
		Map<String,STring> mapString = handl.doHTTPCallout(a1, input);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
		response.setBody('{"foo":"bar"}');
        response.setStatusCode(404);
        handl.httpErrorLog(a1,response);
        Test.stopTest();
    }
}