/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 6 Jan. 2016
Purpose : Renewal Oppty Batch test class
*********************************************************************************/
@IsTest
private with sharing class OpportunityRenewalsBatchTestClass {
    static testMethod void renewalOpportunityMethod (){
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
        
        Account a = new Account();
        a.Name = 'New Test Account';
        insert a;
        
        Contact con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'Contact';
        con.AccountId = a.Id;
        //Start Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
        con.pse__Is_Resource__c = TRUE;
        con.pse__Is_Resource_Active__c = TRUE;
        con.pse__Resource_Role__c = 'AMEX';
        //END Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
        insert con;
        
        Opportunity opp = New Opportunity();
        opp.accountId = a.id;
        opp.name = 'Test oppty';
        opp.Membership_Begins__c = date.today();
        opp.Membership_Expires__c = opp.Membership_Begins__c + 365;
        opp.Invoice_Date__c = date.today();
        opp.Payment_Date__c = date.today();
        opp.amount = 100.00;
        //Start- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        opp.StageName = '100 - Closed/Won';
        //End- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        //Start Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
        opp.Group2__c = 'The Miles Group';
        opp.TMG_Primary__c=con.id;
        //Start- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        opp.Project_Start_Date__c = date.today().AddMonths(-3);
        //End- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        opp.IsRenewableFromBatch__c=TRUE;
        //Start Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage
        opp.Engagement_Type__c = 'Coaching';
        opp.Lead_Contact_Source__c = con.id;
        opp.Participant_Contact__c = con.id;
        opp.Parent_Account_Contact__c = con.id;
        opp.recordTypeID = rt.id;
        opp.Project_Name__c = 'Test';
        opp.Engagement_Type__c = 'Coaching';
        opp.CloseDate = date.today() + 365;
        opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
        insert opp;
        
        OpportunityRenewalBatchClass bc = new OpportunityRenewalBatchClass();
        Test.startTest();
        Database.executeBatch(bc);
        Test.stopTest();
    }
    
    
}