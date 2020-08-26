/*
Action Plans v3
Force.com Labs
http://appexchange.salesforce.com/listingDetail?listingId=a0N30000003HcINEA0

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
@isTest (seeAllData=false)  // Added by Ankit Sharma | C-00276831 | 14/04/2020
public with sharing class ActionPlansBatchBuilderTest {

    public static Boolean isTest = false;
    //Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701
    //Changes start here
    public static RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
    //Changes stop here
    //Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701
 
     //Start code added by bhagya-case-00254740
      private static User createTestUser(String username) {
      Profile userPrf= [select id from profile where name='G100 User'];       
      User testUser = new User();
      testUser.Email= 'test@test.com';
      testUser.Username= username +'@testuser12.com';
      testUser.LastName= 'test';
      testUser.Alias = 'test';
      testUser.ProfileId = userPrf.Id;
      testUser.LanguageLocaleKey   = 'en_US';
      testUser.LocaleSidKey= 'en_US';
      testUser.TimeZoneSidKey = 'America/Chicago';
      testUser.EmailEncodingKey= 'UTF-8';
      //insert testUser;
      return testUser;
    }
    //Stop bhagya-case-00254740

    private static testMethod void runBatchAccount(){
    
       //Start added by Bhagya case-00254740
       User testUser1=createTestUser('TestB1');
       insert testUser1;
       system.runAs(testUser1)
       { //Stop bhagya-case-00254740
       
            ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
            Test.startTest();
            ActionPlan__c ap = ge.createNewActionPlan( 'accounts' ,2);
            ap.Name= 'check_undelete';
            List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
            User u = ge.createTestUser();

			APTaskTemplate__c at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = u.Id;
	   		at.SendEmail__c		 = false;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

	   		at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = u.Id;
	   		at.SendEmail__c		 = true;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

			Account ac = new Account();
			ac.Name ='Doe';
			insert ac;

			Account ac1 = new Account();
			// START - Tommy Noe (S-409504)
			ac1.Name ='Doe1';
			// END - (S-409504)
			insert ac1;

			List<string> oIdsList = new List<String>();
			oIdsList.add(ac.Id);
			oIdsList.add(ac1.Id);

	   		ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Account',oIdsList);
	        ID batchID = Database.executeBatch(testBatch, 20);
		Test.stopTest();

		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
		System.AssertEquals('Completed', a.status);
		System.AssertEquals(0, a.NumberOfErrors);
		/*
		List<ActionPlan__c> l_ap = [Select Id from ActionPlan__c where name ='check_undelete'];

        if (l_ap.size()>0){
            delete l_ap;
            List <String> ids = new List <String>();
            ids.add(l_ap[0].Id);
            try{
                database.undelete (ids);
            }catch(Dmlexception e){
                //System.assert( e.getMessage().contains('Undelete failed.'),e.getMessage() );
            }
        }*/
    }
    }//Added by Bhagya case-00254740

    private static testMethod void runBatchContact(){
       //Start added by Bhagya case-00254740
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        Test.startTest();
            ActionPlan__c ap = ge.createNewActionPlan( 'contacts' ,2);
            List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
            User u = ge.createTestUser();
            
            APTaskTemplate__c at = new APTaskTemplate__c();
            at.Action_Plan__c    = ap.Id;
            at.Dependent__c      = 'None';
            at.DaysFromStart__c  = 2.0;
            at.User__c           = u.Id;
            at.SendEmail__c      = false;
            at.Subject__c        = 'Test ';
            at.Type__c           = 'Email';
            at.Priority__c       = 'Low';
            at.Comments__c       = 'Test';
            at.Reminder__c       = true;
            at.Minutes_Reminder__c = '510';
            insert at;
            apTasks.add(at);
            
            at = new APTaskTemplate__c();
            at.Action_Plan__c    = ap.Id;
            at.Dependent__c      = 'None';
            at.DaysFromStart__c  = 2.0;
            at.User__c           = u.Id;
            at.SendEmail__c      = true;
            at.Subject__c        = 'Test ';
            at.Type__c           = 'Email';
            at.Priority__c       = 'Low';
            at.Comments__c       = 'Test';
            at.Reminder__c       = true;
            at.Minutes_Reminder__c = '510';
            insert at;
            apTasks.add(at);
            
            Contact op = new Contact();
            op.LastName ='Doe';
            insert op;
            
            Contact op2 = new Contact();
            op2.LastName ='Doe';
            insert op2;
            
            List<string> oIdsList = new List<String>();
            oIdsList.add(op.Id);
            oIdsList.add(op2.Id);
            
            ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Contact',oIdsList);
            //START --Updated singleline by Ankit | C-00276831 | 10/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
            ID batchID = Database.executeBatch(testBatch, 200); 
            // ENd -- Updated by Ankit Sharma | C-00276831 | 10/04/2020
            Test.stopTest();
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
            System.AssertEquals('Completed', a.status);
            System.AssertEquals(0, a.NumberOfErrors);
        }//Added by Bhagya case-00254740
    }


    private static testMethod void runBatchOpportunity(){
       //Start added by Bhagya case-00254740
       User testUser3=createTestUser('TestB3');
       insert testUser3;
       system.runAs(testUser3)
       { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
         //Test.startTest(); //Commented by Bhagya case- 00254740
            ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys' ,2);
            List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();

			APTaskTemplate__c at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = false;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

	   		at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = true;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

			//Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701
			//Changes start here
			Account account = new Account();
		    account.Name = '123454321New Test Account123454321';
		    insert account;

            Contact con = new Contact();
            Con.FirstName = 'Test';
            Con.LastName = 'Contact';
            con.AccountId = account.Id;
            insert con;
            Test.startTest();//Added by Bhagya case- 00254740
            Opportunity op = New Opportunity(accountId = account.id, name = 'Op1', Membership_Begins__c = date.today(), Membership_Expires__c = date.today() + 365,
                                                    Invoice_Date__c = date.today(), Payment_Date__c = date.today(), amount = 100.00, StageName = 'Won',
                                                    Group2__c = 'High Lantern Group',  Lead_Contact_Source__c = con.id,
                                                    Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, recordTypeID = rt.id,
                                                    Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 365,
                                                    Project_Start_Date__c = date.today(), Project_End_Date__c = date.today().addmonths(9));

		    insert op;

		    Opportunity op2 = New Opportunity(accountId = account.id, name = 'Op2', Membership_Begins__c = date.today(), Membership_Expires__c = date.today() + 365,
		    										Invoice_Date__c = date.today(), Payment_Date__c = date.today(), amount = 100.00, StageName = 'Won',
		    										Group2__c = 'High Lantern Group', Lead_Contact_Source__c = con.id,
		    										Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, recordTypeID = rt.id,
		    										Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 365,
		    										Project_Start_Date__c = date.today(), Project_End_Date__c = date.today().addmonths(9));

		    insert op2;

			/**Opportunity op = new Opportunity();
			op.Name ='Op1';
			op.StageName = 'Won';
			op.CloseDate = Date.today();
			insert op;

			Opportunity op2 = new Opportunity();
			op2.Name ='Op2';
			op2.StageName = 'Won';
			op2.CloseDate = Date.today();
			insert op2;**/
			//Changes stop here
			//Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701

			List<string> oIdsList = new List<String>();
			oIdsList.add(op.Id);
			oIdsList.add(op2.Id);

	   		ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
	        ID batchID = Database.executeBatch(testBatch, 20);
		Test.stopTest();

        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);
    }//Added by Bhagya case-00254740
    }
    private static testMethod void runBatchException(){
    //Start added by Bhagya case-00254740
       User testUser4=createTestUser('TestB4');
       insert testUser4;
       system.runAs(testUser4)
       { //Stop bhagya-case-00254740
    
        ActionPlansBatchBuilderTest.isTest = true;
/*      ActionPlansTestUtilities ge = new ActionPlansTestUtilities();

		ActionPlan__c ap = ge.createNewActionPlan( 'leads' ,2);
		List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();
		List<string> oIdsList = new List<String>();

		Test.startTest();
	   		ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
	        ID batchID = Database.executeBatch(testBatch, 20);
		Test.stopTest();

		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
		System.AssertEquals('Completed', a.status);*/
		ActionPlansTestUtilities ge = new ActionPlansTestUtilities();

           //Test.startTest();//Commented by Bhagya case 00254740
            ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys' ,2);
            List<APTaskTemplate__c> apTasks = new List<APTaskTemplate__c>();

			APTaskTemplate__c at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = false;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

	   		at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.Dependent__c		 = 'None';
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = true;
	   		at.Subject__c		 = 'Test ';
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'Test';
	   		at.Reminder__c		 = true;
	   		at.Minutes_Reminder__c = '510';
	   		insert at;
	   		apTasks.add(at);

			//Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701
			//Changes start here
			Account account = new Account();
		    account.Name = 'New Test Account12345654321';
		    insert account;

            Contact con = new Contact();
            Con.FirstName = 'Test';
            Con.LastName = 'Contact';
            con.AccountId = account.Id;
            insert con;
             
            Test.startTest();//Added by Bhagya case- 00254740

            Opportunity op = New Opportunity(accountId = account.id, name = 'Op1', Membership_Begins__c = date.today(), Membership_Expires__c = date.today() + 365,
                                                    Invoice_Date__c = date.today(), Payment_Date__c = date.today(), amount = 100.00, StageName = 'Won',
                                                    Group2__c = 'High Lantern Group',  Lead_Contact_Source__c = con.id,
                                                    Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, recordTypeID = rt.id,
                                                    Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 365,
                                                    Project_Start_Date__c = date.today(), Project_End_Date__c = date.today().addmonths(9));

		    insert op;

		    Opportunity op2 = New Opportunity(accountId = account.id, name = 'Op2', Membership_Begins__c = date.today(), Membership_Expires__c = date.today() + 365,
		    										Invoice_Date__c = date.today(), Payment_Date__c = date.today(), amount = 100.00, StageName = 'Won',
		    										Group2__c = 'High Lantern Group', Lead_Contact_Source__c = con.id,
		    										Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, recordTypeID = rt.id,
		    										Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 365,
		    										Project_Start_Date__c = date.today(), Project_End_Date__c = date.today().addmonths(9));

		    insert op2;

			/**Opportunity op = new Opportunity();
			op.Name ='Op1';
			op.StageName = 'Won';
			op.CloseDate = Date.today();
			insert op;

			Opportunity op2 = new Opportunity();
			op2.Name ='Op2';
			op2.StageName = 'Won';
			op2.CloseDate = Date.today();
			insert op2;**/
			//Changes stop here
			//Code modified - Padmesh Soni (06/03/2015 - Appirio Offshore) - S-373701

			List<string> oIdsList = new List<String>();
			oIdsList.add(op.Id);
			oIdsList.add(op2.Id);

	   		ActionPlansBatchBuilder testBatch = new ActionPlansBatchBuilder( ap,apTasks,'Opportunity',oIdsList);
	        ID batchID = Database.executeBatch(testBatch, 20);
		Test.stopTest();

        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);
    }//Added by Bhagya case-00254740
    }

}