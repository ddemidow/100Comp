/*
 * Appirio, Inc
 * Name: BatchToUpdateOpportunityTeamTes
 * Description: [S-601362] Test class of batch class BatchToUpdateOpportunityTeam
 * Created Date: 15 Feb 2019
 * Created By: Vikrant Nathawat (Appirio Inc.)
 * 
 * 
 */
@isTest
private class BatchToUpdateOpportunityTeamTest {
  
  static Opportunity opp ;
  @isTest static void testMethodOne() {
    createTestData();

    Test.startTest();

      BatchToUpdateOpportunityTeam obj = new BatchToUpdateOpportunityTeam();
     // obj.query = 'Select Id,Opportunity_Team_Members__c from Opportunity where Group2__c=\'SSA & Company\' AND Id = \''+ opp.Id +'\'';
      Database.executeBatch(obj);
    Test.stopTest();

    opp = [Select Id,Opportunity_Team_Members__c from Opportunity where Id = :opp.Id] ;

   //system.assertEquals('CEO Works Primary - Andie Yamate',opp.Opportunity_Team_Members__c);
  }
  
  @isTest static void testMethodOne1() {
    createTestData();

    Test.startTest();

      string query = 'Select Id,Opportunity_Team_Members__c from Opportunity where Group2__c=\'SSA & Company\' AND Id = \''+ opp.Id +'\'';
      BatchToUpdateOpportunityTeam obj = new BatchToUpdateOpportunityTeam(query);
      Database.executeBatch(obj);
    Test.stopTest();

    //opp = [Select Id,Opportunity_Team_Members__c from Opportunity where Id = :opp.Id] ;

   //system.assertEquals('CEO Works Primary - Andie Yamate',opp.Opportunity_Team_Members__c);
  }
  
  private static void createTestData() {
    Account a = new Account();
    a.Name = 'New Test Account';
    insert a;
    
    Contact con = new Contact();
    Con.FirstName = 'Test';
    Con.LastName = 'Contact';
    con.AccountId = a.Id;
    insert con;
    
    List<opportunity> opplist = new List<opportunity>();
    opp = New Opportunity();
    opp.accountId = a.id;
    opp.name = 'Test oppty';
    opp.Membership_Begins__c = date.today();
    opp.Membership_Expires__c = opp.Membership_Begins__c + 365;
    opp.Invoice_Date__c = date.today();
    opp.Payment_Date__c = date.today();
    opp.amount = 100.00;
    opp.StageName = '100 - Signed Contract';
    opp.Group2__c = 'SSA & Company';
    opp.Engagement_Type__c = 'Advisory';
    opp.Lead_Contact_Source__c = con.id;
    opp.Participant_Contact__c = con.id;
    opp.Parent_Account_Contact__c = con.id;
    opp.Project_Name__c = 'Test';
    opp.CloseDate = date.today() + 365;
    opp.Project_Start_Date__c = date.today();
    opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
    opp.Revenue_Recognition_Begins__c = date.today().addDays(20);
    opp.Revenue_Recognition_Ends__c = date.today().addDays(25);
    opp.Revenue_Recognition_3__c = date.today().addDays(15);
    opp.Description__c = 'Testing Oppty' ;
    
    opplist.add(opp);
    
    Opportunity opp1 = New Opportunity();
    opp1.accountId = a.id;
    opp1.name = 'Test oppty';
    opp1.Membership_Begins__c = date.today();
    opp1.Membership_Expires__c = opp.Membership_Begins__c + 365;
    opp1.Invoice_Date__c = date.today();
    opp1.Payment_Date__c = date.today();
    opp1.amount = 100.00;
    opp1.StageName = '100 - Signed Contract';
    opp1.Group2__c = 'SSA & Company';
    opp1.Engagement_Type__c = 'Advisory';
    opp1.Lead_Contact_Source__c = con.id;
    opp1.Participant_Contact__c = con.id;
    opp1.Parent_Account_Contact__c = con.id;
    opp1.Project_Name__c = 'Test';
    opp1.CloseDate = date.today() + 365;
    opp1.Project_Start_Date__c = date.today();
    opp1.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
    opp1.Revenue_Recognition_Begins__c = date.today().addDays(20);
    opp1.Revenue_Recognition_Ends__c = date.today().addDays(25);
    opp1.Revenue_Recognition_3__c = date.today().addDays(15);
    opp1.Description__c = 'Testing Oppty' ;
    
    opplist.add(opp1);
    
    Opportunity opp2 = New Opportunity();
    opp2.accountId = a.id;
    opp2.name = 'Test oppty';
    opp2.Membership_Begins__c = date.today();
    opp2.Membership_Expires__c = opp.Membership_Begins__c + 365;
    opp2.Invoice_Date__c = date.today();
    opp2.Payment_Date__c = date.today();
    opp2.amount = 100.00;
    opp2.StageName = '100 - Signed Contract';
    opp2.Group2__c = 'SSA & Company';
    opp2.Engagement_Type__c = 'Advisory';
    opp2.Lead_Contact_Source__c = con.id;
    opp2.Participant_Contact__c = con.id;
    opp2.Parent_Account_Contact__c = con.id;
    opp2.Project_Name__c = 'Test';
    opp2.CloseDate = date.today() + 365;
    opp2.Project_Start_Date__c = date.today();
    opp2.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
    opp2.Revenue_Recognition_Begins__c = date.today().addDays(20);
    opp2.Revenue_Recognition_Ends__c = date.today().addDays(25);
    opp2.Revenue_Recognition_3__c = date.today().addDays(15);
    opp2.Description__c = 'Testing Oppty' ;
    
    opplist.add(opp2);
    
    insert opplist;
    
    User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
     FirstName = 'Andie',
     LastName = 'Yamate',
     Email = 'viki@amamama.com',
     Username = 'viki@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US');
     
     insert u;
    
    User u1 = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
     FirstName = 'Andie1',
     LastName = 'Yamate1',
     Email = 'viki1@amamama.com',
     Username = 'viki1@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title1',
     Alias = 'alias1',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US');
     
     insert u1;
     
     User u2 = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
     FirstName = 'Andie2',
     LastName = 'Yamate2',
     Email = 'viki2@amamama.com',
     Username = 'viki2@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title2',
     Alias = 'alias2',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US');
     
     insert u2;
     
    //Start code modified by Saurabh S-640524
    List<OpportunityTeamMember> oppTeamlist = new List<OpportunityTeamMember>();
    OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u.id,TeamMemberRole = 'CEO Works Primary');
    OpportunityTeamMember otm1 = new OpportunityTeamMember (OpportunityId = opp1.id,UserId = u1.id,TeamMemberRole = 'HLG Secondary');
    OpportunityTeamMember otm2 = new OpportunityTeamMember (OpportunityId = opp2.id,UserId = u2.id,TeamMemberRole = 'TMG Tertiary');
    OpportunityTeamMember otm3 = new OpportunityTeamMember (OpportunityId = opp.id,UserId = u1.id,TeamMemberRole = 'CEO Works Primary');
    OpportunityTeamMember otm4 = new OpportunityTeamMember (OpportunityId = opp1.id,UserId = u2.id,TeamMemberRole = 'HLG Secondary');
    OpportunityTeamMember otm5 = new OpportunityTeamMember (OpportunityId = opp2.id,UserId = u.id,TeamMemberRole = 'TMG Tertiary');
      oppTeamlist.add(otm);
    oppTeamlist.add(otm1);
    oppTeamlist.add(otm2);
    oppTeamlist.add(otm3);
    oppTeamlist.add(otm4);
    oppTeamlist.add(otm5);
    //End Saurabh S-640524
  insert oppTeamlist;
  }
  
}