/**
Author		:Appirio India [Hitesh Pareek]
Date 		:Sept 14, 2016
Purpose		:S-429731
 */
@isTest
private class ClickLinkProjectTriggerHandlerTest {

    static testMethod void testProjectInsertUpdate() {
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
        
        Account a = new Account();
    a.Name = 'New Test Account';
    insert a;
    
    Contact con = new Contact();
    Con.FirstName = 'Test';
    Con.LastName = 'Contact';
    con.AccountId = a.Id;
    insert con;
    
    Opportunity opp = New Opportunity();
    opp.accountId = a.id;
    opp.name = 'Test oppty';
    opp.Membership_Begins__c = date.today();
    opp.Membership_Expires__c = opp.Membership_Begins__c + 365;
    opp.Invoice_Date__c = date.today();
    opp.Payment_Date__c = date.today();
    opp.amount = 100.00;
    opp.StageName = '100 - Signed Contract';
    opp.Group2__c = 'High Lantern Group';
    opp.Engagement_Type__c = 'Advisory';
    opp.Lead_Contact_Source__c = con.id;
    opp.Participant_Contact__c = con.id;
    opp.Parent_Account_Contact__c = con.id;
    opp.recordTypeID = rt.id;
    opp.Project_Name__c = 'Test';
    opp.CloseDate = date.today() + 365;
    opp.Project_Start_Date__c = date.today();
    opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);       
    opp.Revenue_Recognition_Begins__c = date.today().addDays(20);
    opp.Revenue_Recognition_Ends__c = date.today().addDays(25);
    opp.Revenue_Recognition_3__c = date.today().addDays(15);
    
    insert opp;
    
    c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
    
	//Insert region 
    pse__Region__c pse_region = new pse__Region__c();
    pse_region.Name = 'test region';
    pse_region.CurrencyIsoCode = 'USD';
    pse_region.ffpsai__OwnerCompany__c = comp.id;
    insert pse_region;
    system.assert(pse_region.Id != null);
    
    pse__Proj__c proj = new pse__Proj__c();
    proj.Name = 'Test Project';
    proj.pse__Region__c =  pse_region.id;
    proj.pse__Opportunity__c = opp.id;   
    proj.pse__Start_Date__c = Date.Today();
    proj.pse__End_Date__c = Date.Today().addDays(30);
    
    insert proj;
    }
}