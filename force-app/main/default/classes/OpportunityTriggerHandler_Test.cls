/*********************************************************************************
Name : Connor Flynn 
Created By : Appirio  
Created Date : 03 May 2016
Purpose : Test for Opportunity Trigger Handler

*********************************************************************************/

@isTest
private class OpportunityTriggerHandler_Test {
/*
 * 10/31/2019 - Anmol Khanna 
 * Commenting class since we already have a test class for Opportunity Trigger Handler and 
 * that is OpportunityTriggerHandlerTest
 * 
    static testMethod void testOppContactRoleInsert() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);

        testOpp.Participant_Contact__c = testContact2.Id;
        insert testOpp;

        List<OpportunityContactRole> testOppContactRole = new List<OpportunityContactRole>([Select Id, ContactId From OpportunityContactRole Where OpportunityId = :testOpp.Id And isPrimary = true limit 1]);
        System.assert(testOppContactRole != null && testOppContactRole.size() == 1, 'Could not find an opportunity contact role');
        System.assertEquals(testContact2.id, testOppContactRole.get(0).ContactId, 'Wrong contact id on the opportunity contact role');

        testOpp.Participant_Contact__c = testContact1.Id;
        update testOpp;

        testOppContactRole = new List<OpportunityContactRole>([Select Id, ContactId From OpportunityContactRole Where OpportunityId = :testOpp.Id And isPrimary = true limit 1]);

        System.assert(testOppContactRole != null && testOppContactRole.size() == 1, 'Could not find an opportunity contact role');
        System.assertEquals(testContact1.id, testOppContactRole.get(0).ContactId, 'Wrong contact id on the opportunity contact role');
    }

    //START -- Added by Shivani for S-637724 on 02/09/2019
    private static testMethod void testOppContactRoleInsert1() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        Opportunity testOpp1 = testUtil.newOpportunity(true, testAccount.Id, testContact1.Id);
        Opportunity testOpp2 = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        testOpp2.Description__c = 'Testing';
        insert testOpp2;


        testOpp.IsRenewalOpportunity__c = true;
        testOpp.Group2__c = 'The Miles Group';
        testOpp.TMG_Primary__c = testContact2.Id;
		insert testOpp;
        
        testOpp.Participant_Contact__c = testContact1.Id;
        testOpp.Amount = 123;
        insert testOpp;

        testOpp.Parent_Opportunity__c = testOpp2.Id;
        testOpp.Amount = 124;
        update testOpp;
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;

        pse__Region__c region = new pse__Region__c();
        region.Name = 'test region';
        region.CurrencyIsoCode = 'USD';
        region.ffpsai__OwnerCompany__c = comp.id;
        insert region ;

		Test.startTest();//00271014 - AKhanna - 10/29/2019 - Test class failure 
        pse__Proj__c project = new pse__Proj__c();
        project.Name = 'Testing';
        project.pse__Account__c = testAccount.id;
        project.CurrencyIsoCode = 'USD';
        project.pse__Start_Date__c = date.today().addYears(-1);
        project.pse__Region__c = region.id;
        project.pse__Project_Type__c = 'Customer Project';
        project.pse__Project_Status__c = 'Green';
        project.pse__Is_Billable__c = true;
        project.pse__Is_Active__c = true;
        project.pse__Invoiced__c = 50000;
        project.pse__End_Date__c = date.today().addYears(1);
        project.pse__Closed_for_Time_Entry__c = false; 
        project.pse__Closed_for_Expense_Entry__c = false;
        project.pse__Billing_Type__c = 'Time and Materials';
        project.pse__Billed__c = 40000;
        project.pse__Allow_Timecards_Without_Assignment__c = true;
        project.pse__Allow_Expenses_Without_Assignment__c = true;
        project.pse__Opportunity__c = testOpp.id;
        insert project;
		Test.stopTest();//00271014 - AKhanna - 10/29/2019 - Test class failure
        
        testOpp2.StageName = '100 - Signed Contract';
        update testOpp2;
    }

    private static testMethod void onAfterUpdate() {
    	FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp1 = testUtil.newOpportunity(true, testAccount.Id, testContact1.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        testOpp.StageName  = '100 - Signed Contract';
        testOpp.Group2__c = 'The Miles Group';
        testOpp.Engagement_Type__c  = 'Coaching';
        testOpp.CloseDate = Date.today();
        testOpp.TMG_Primary__c = testContact2.Id;
        testOpp.IsRenewalOpportunity__c = true;
        testOpp.Participant_Contact__c = testContact1.Id;
        testOpp.OwnerId = UserInfo.getUserId();
        insert testOpp;
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(testOpp.Id, testOpp1);
		OpportunityTriggerHandler.onAfterUpdate(new List<Opportunity>{testOpp}, oldMap);

		testOpp.Parent_Opportunity__c = testOpp1.Id;
		update testOpp;
		testOpp1.SubGroup__c  = 'G100 Network Enterprise';
		testOpp1.Description = 'TestDescription';
		update testOpp1;
    }
    //END -- Added by Shivani for S-637724 on 02/09/2019
*/
}