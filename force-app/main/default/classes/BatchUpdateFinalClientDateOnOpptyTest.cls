/*******************************
Author      :Appirio India [Hitesh Pareek]
Date        :Sept 15, 2016
Purpose     :S-438975
*******************************/
@isTest
private class BatchUpdateFinalClientDateOnOpptyTest {
    @testsetup
    static void createTestData(){
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Membership Management' Limit 1];
        Account a = new Account();
        a.Name = 'New Test Account';
        insert a;
        
        Contact con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'Contact';
        con.AccountId = a.Id;
        insert con;
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        //Insert region 
        pse__Region__c pse_region = new pse__Region__c();
        pse_region.Name = 'test region';
        pse_region.CurrencyIsoCode = 'USD';
        pse_region.ffpsai__OwnerCompany__c = comp.id;
        insert pse_region;
        
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList.add(createOppty('Test opp1', a, '15 - Campaign Target', con, rt, Date.today().addDays(100), Date.today().addDays(10), Date.today().addDays(20),Date.today().addDays(30)));
        opptyList.add(createOppty('Test opp2', a, '100 - Signed Contract', con, rt, Date.today().addDays(100), Date.today().addDays(15), Date.today().addDays(25),Date.today().addDays(35)));
        opptyList.add(createOppty('Test opp3', a, '100 - Signed Contract', con, rt, Date.today().addDays(100), Date.today().addDays(40), Date.today().addDays(65),Date.today().addDays(85)));
        
        insert opptyList;
        
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        
        projList.add(createProj(Date.today().addDays(30), 'Test Proj -1',pse_region, opptyList[0]));
        projList.add(createProj(Date.today().addDays(40), 'Test Proj -2',pse_region, opptyList[1]));
        
        insert projList;
        
    }
    
    static Opportunity createOppty(string name, Account a, string stageName, Contact con, RecordType rt, Date memberExpire, Date d1, Date d2, Date d3){
        Opportunity opp = New Opportunity();
        opp.accountId = a.id;
        opp.name = name;
        opp.Membership_Begins__c = date.today();
        opp.Membership_Expires__c = memberExpire;
        opp.Invoice_Date__c = date.today();
        opp.Payment_Date__c = date.today();
        opp.amount = 100.00;
        opp.StageName = stageName;
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
        
        //S-429731 ---START--- Hitesh[Sept 14, 2016]
        opp.Revenue_Recognition_Begins__c = d1;
        opp.Revenue_Recognition_Ends__c = d2;
        opp.Revenue_Recognition_3__c = d3;
        
        return opp;
    }
    
    static pse__Proj__c createProj(Date EndDate, string name, pse__Region__c region, opportunity opp){
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = name;
        proj.pse__Region__c =  region.id;
        proj.pse__Opportunity__c = opp.id;   
        proj.pse__Start_Date__c = Date.Today();
        proj.pse__End_Date__c = EndDate;
        
        return proj;
    }
    static testMethod void testFinalClientBatch() {           
        Test.startTest();
        Database.executeBatch(new BatchUpdateFinalClientDateOnOppty());                      
        Database.executeBatch(new BatchUpdateCompanyStatusOnAccount());
        Test.stopTest();
    }
}