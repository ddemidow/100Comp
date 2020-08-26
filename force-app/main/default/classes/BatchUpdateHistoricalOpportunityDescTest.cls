/*
 * Appirio, Inc
 * Name: BatchUpdateHistoricalOpportunityDescTest
 * Description: [S-589952]
 * Created Date: 15 Nov 2018
 * Created By: Jai Gupta (Appirio)
 * Coverage: 98%
 * 
 */
@isTest
private class BatchUpdateHistoricalOpportunityDescTest {
	
	static Opportunity opp ;
	@isTest static void test_method_one() {
		createTestData();

		Test.startTest();
			opp.Description__c = 'Testing with 2' ;
			update opp ;

			BatchUpdateHistoricalOpportunityDesc obj = new BatchUpdateHistoricalOpportunityDesc();
			obj.query = 'Select Id,Opportunity_History_c__c,History_Data_Created__c from Opportunity where Id = \''+ opp.Id +'\'';
			Database.executeBatch(obj);
		Test.stopTest();

		opp = [Select Id, History_Data_Created__c from Opportunity where Id = :opp.Id] ;

		system.assertEquals(true,opp.History_Data_Created__c);
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
		
		opp = New Opportunity();
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
		opp.Project_Name__c = 'Test';
		opp.CloseDate = date.today() + 365;
		opp.Project_Start_Date__c = date.today();
		opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
		opp.Revenue_Recognition_Begins__c = date.today().addDays(20);
		opp.Revenue_Recognition_Ends__c = date.today().addDays(25);
		opp.Revenue_Recognition_3__c = date.today().addDays(15);
		opp.Description__c = 'Testing Oppty' ;
		insert opp;
	}
	
}