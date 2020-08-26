/****************************************
Author			: Appirio India - [Hitesh Pareek]
Date Original	: Dec 30, 2016
Purpose			: S-449232
****************************************/
 
@isTest
private class UploadProjectCloseoutExtTest {
	
	@testSetup
 	private static void createTestData() {
 		
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        //Insert Account
        Account testAccount = new Account(Name = 'Test', CurrencyIsoCode = 'USD');
        insert testAccount;
        
         //Insert region 
        pse__Region__c pse_region = new pse__Region__c(Name = 'test region', CurrencyIsoCode = 'USD', ffpsai__OwnerCompany__c = comp.id);
        insert pse_region;
        
        //Insert Practice
        pse__Practice__c pse_practice = new pse__Practice__c(Name = 'test practice', CurrencyIsoCode = 'USD');
        insert pse_practice;
        
        //Insert Group
        pse__Grp__c  pse_group = new pse__Grp__c(name='test Group', CurrencyIsoCode = 'USD');
        insert pse_group;
        
        List<contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', pse__Is_Resource_Active__c = true, pse__Is_Resource__c = true,
        							pse__Resource_Role__c ='Consultant', pse__Default_Cost_Rate__c = 25.0, pse__Region__c = pse_region.Id, 
        							pse__Salesforce_User__c = Userinfo.getUserId(), Email = 'a@b.com'));
        insert contacts;
         
        List<pse__Proj__c> projects = new List<pse__Proj__c>();
        projects.Add(new pse__Proj__c(Name='test_project 1', pse__Is_Billable__c = true, pse__Is_Active__c = true, pse__Project_Status__c = 'Green',
											pse__Allow_Timecards_Without_Assignment__c = false, pse__Start_Date__c = Date.today().addMonths(-1),
											pse__End_Date__c = Date.today().addMonths(4), pse__Region__c = pse_region.Id, pse__Practice__c = pse_practice.Id,
											pse__Group__c = pse_group.Id, CurrencyIsoCode ='USD', pse__Billing_Type__c = 'Administrative',
											pse__Project_Type__c = 'Sales'));
        projects.Add(new pse__Proj__c(Name='test_project 2', pse__Is_Billable__c = true, pse__Is_Active__c = true, pse__Project_Status__c = 'Green',
											pse__Allow_Timecards_Without_Assignment__c = false, pse__Start_Date__c = Date.today().addMonths(-1),
											pse__End_Date__c = Date.today().addMonths(4), pse__Region__c = pse_region.Id, pse__Practice__c = pse_practice.Id,
											pse__Group__c = pse_group.Id, CurrencyIsoCode ='USD', pse__Billing_Type__c = 'Administrative',
											pse__Project_Type__c = 'Sales'));
        
        insert projects;
 	}
 	
    static testMethod void testUpload() {
       List<pse__Proj__c> projects = [SELECT Id FROM pse__Proj__c];
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        //Test start here
        Test.startTest();
        PageReference pref = Page.UploadProjectCloseout;
        Test.setCurrentPage(pref);
        ApexPages.currentPage().getParameters().put('id',projects[0].id);
        //Standard Controller instance
        Apexpages.StandardController SC = new Apexpages.StandardController(projects[0]);
        
        //Class instance
        UploadProjectCloseoutExt controller = new UploadProjectCloseoutExt(SC);
        
        //Test no file body or name errors
        controller.processUpload();
        
        //Call method
        controller.fileBody = bodyBlob;
        controller.fileName = 'testAttchmnt';
        controller.Project_Benefits = 'testbenefit';
        
       controller.processUpload();
        controller.back();
        
        //Query result of Attachments
        List<Attachment> attachments = [SELECT Id FROM Attachment];
        
        //Assert statement
        System.assert(attachments.size() > 0);              
        
        //Test stop here
        Test.stopTest();
        
    }
}