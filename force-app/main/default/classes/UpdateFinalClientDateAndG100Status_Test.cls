/*********************************************************************************
Name : Arihant Jain (CASE#00223036)
Created By : Appirio  
Created Date : 21/3/18
Purpose : UpdateFinalClientDateAndG100Status Test Class
*********************************************************************************/
@istest
private with sharing class UpdateFinalClientDateAndG100Status_Test {
    static testMethod void testUpdateBatch (){
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
        Account a = new Account();
        a.Name = 'New Test Account';
        a.G100_Companies_Status__c='High Lantern Group - Client'; //Added by bhagya for case -
        
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
        opp.recordTypeID = rt.id;
        opp.Project_Name__c = 'Test';
        opp.CloseDate = date.today() + 365;
        opp.Project_Start_Date__c = date.today();
        opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
        opp.Revenue_Recognition_Begins__c = date.today().addDays(20);
        opp.Revenue_Recognition_Ends__c = date.today().addDays(25);
        opp.Revenue_Recognition_3__c = date.today().addDays(15);
        insert opp;
        
        Opportunity opp2 = New Opportunity();
        opp2.accountId = a.id;
        opp2.name = 'Test oppty 2';
        opp2.Membership_Begins__c = date.today();
        opp2.Membership_Expires__c = opp.Membership_Begins__c + 365;
        opp2.Invoice_Date__c = date.today();
        opp2.Payment_Date__c = date.today();
        opp2.amount = 100.00;
        opp2.Participant_Contact__c = con.id;
        opp2.Parent_Account_Contact__c = con.id;
        opp2.StageName = '95 - Booked Not Yet Scheduled';
        opp2.Group2__c = 'CEO Works';
        opp2.Engagement_Type__c = 'Advisory';
        opp2.recordTypeID = rt.id;
        opp2.Project_Name__c = 'Test 2';
        opp2.CloseDate = date.today() + 365;
        opp2.Project_Start_Date__c = date.today();
        opp2.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
        opp2.Revenue_Recognition_Begins__c = date.today().addDays(20);
        opp2.Revenue_Recognition_Ends__c = date.today().addDays(25);
        opp2.Revenue_Recognition_3__c = date.today().addDays(15);
        insert opp2;
        
        Test.startTest();
            UpdateFinalClientDateAndG100Status obj = new UpdateFinalClientDateAndG100Status();
            DataBase.executeBatch(obj);
        Test.stopTest();
        
        Opportunity opp_updated = [select  Final_Client_Date__c, Membership_Expires__c from Opportunity where id =:opp.id limit 1];
        Account parentAccount = [Select Id, G100_Companies_Status__c From Account Where Id = :a.Id limit 1];
        system.assertEquals(parentAccount.G100_Companies_Status__c, 'High Lantern Group - Client, CEO Works - Prospect');
        system.assertEquals(opp_updated.Final_Client_Date__c, opp_updated.Membership_Expires__c);
        
    }
}