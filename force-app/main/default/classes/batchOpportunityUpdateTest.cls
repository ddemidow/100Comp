/************************************************
* Name           : batchOpportunityUpdateTest
* Creaetd By     : Lokesh Korani
* Created Date   : 25th march 2020
* Story          : S-654715
************************************************/

@isTest
public class batchOpportunityUpdateTest {
    public static String CRON_EXP = '0 0 22 * * ? *';
    
    public TestMethod static void batchOpportunityUpdate_Method() {
        //Insert Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        //Insert contact
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        con.Email = 'a@b.com'; 
        insert con; 
        
        Opportunity opp = new Opportunity(accountid = acc.id);
        opp.Name = 'Test Opportunity';
        opp.CloseDate = System.today() + 5;
        opp.StageName = '100 - Closed/Won';
        opp.Group2__c = 'G100 Network';
        opp.SubGroup__c = 'G100';
        opp.Amount = 200;        
        opp.Membership_Begins__c = System.today() - 1;
        opp.Membership_Expires__c = System.today() + 1;
        opp.Participant_Contact__c = con.Id; 
        opp.Parent_Account_Contact__c = con.Id;
        opp.G100N_Opp_Type__c = 'New Business';
        opp.Membership_Type__c = 'G100 Network ($200K)';
        opp.Type = 'Membership Management';
        opp.Invoicing_Status__c = 'To Send';
        opp.Invoice_Date__c = System.today();
        insert opp;
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new batchOpportunityUpdate());
        Test.stopTest();
    }
     public TestMethod static void batchOpportunityUpdate_Method1() {
        //Insert Account
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        insert acc1;
        
        //Insert contact
        Contact con1 = new Contact();
        con1.LastName = 'Test';
        con1.AccountId = acc1.Id;
        con1.Email = 'a@b.com'; 
        insert con1; 
        
        Opportunity opp1 = new Opportunity(accountid = acc1.id);
        opp1.Name = 'Test Opportunity';
        opp1.CloseDate = System.today() + 5;
        opp1.StageName = '100 - Closed/Won';
        opp1.Group2__c = 'G100 Network';
        opp1.SubGroup__c = 'Mentore';
        opp1.Amount = 200;        
        opp1.Membership_Begins__c = System.today() + 1;
        opp1.Membership_Expires__c = System.today() + 1;
        opp1.Participant_Contact__c = con1.Id; 
        opp1.Parent_Account_Contact__c = con1.Id;
        opp1.G100N_Opp_Type__c = 'New Business';
        opp1.Membership_Type__c = 'G100 Network ($200K)';
        opp1.Type = 'Membership Management';
        opp1.Invoicing_Status__c = 'To Send';
        opp1.opp12__C = 1;
        opp1.Invoice_Date__c = System.today();
        insert opp1;
         Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new batchOpportunityUpdate());
        Test.stopTest();
	}
}