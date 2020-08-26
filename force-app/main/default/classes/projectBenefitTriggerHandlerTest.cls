@isTest(seeAllData=false)
private class projectBenefitTriggerHandlerTest{

    static testMethod void myUnitTest() {
       Account testAccount = new Account();
       testAccount.Name = 'TestAccount';
       testAccount.logo__c = 'test.com';
       insert testAccount;
       
       c2g__codaCompany__c testcompany = new c2g__codaCompany__c();
       testcompany.Name = 'Test Company';
       insert testcompany;
       
       pse__Region__c testRegion = new pse__Region__c();
       testRegion.Name = 'Test Region';
       testRegion.ffpsai__OwnerCompany__c = testcompany.id;
       insert testRegion;
       
       pse__Proj__c testProject = new pse__Proj__c();
       testProject.Name = 'Test Project';
       testProject.pse__Account__c = testAccount.id;
       testProject.pse__Region__c = testRegion.id;
       insert testProject;
       
       Project_Closeout__c testpc = new Project_Closeout__c();
       testpc.Name = 'Test Project Closeout';
       testpc.Project__c =  testProject.id;
       insert testpc;
       
       Project_Benefit__c pb1 = new Project_Benefit__c();
       pb1.Name = 'Project Benefit';
       pb1.Project_Closeout__c = testpc.id;
       insert pb1;
       
       update pb1;
       
    }
       
}