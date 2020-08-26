// 
// (c) 2017 Appirio (A Wipro company), Inc.
//
// Test class
//
// 26 Dec 2017     Jai Gupta       Original (S-534162) Test class for customclone controller
//                                    CustomClone: 100%
//
//
@isTest
private class CustomCloneTest {
	
	@testSetup
	private static void createTestData() {
		FFA_TestUtility ftu = new FFA_TestUtility();
		Account acc = ftu.newAccount(true);
		c2g__codaCompany__c comp = createCompany();
		pse__Region__c reg = createRegion(comp);
		pse__Proj__c proj = createProject('Vacation',acc,reg);
		pse__Milestone__c m = ftu.newMilestone(true,proj.id,100.0,date.today());
		
	}
	static testMethod void clone() {
		pse__Milestone__c m = [Select Id from pse__Milestone__c];
		ApexPages.StandardController sc = new ApexPages.StandardController(m);
		ApexPages.currentPage().getParameters().put('id',m.id);
		Test.startTest();
			CustomClone c = new CustomClone(sc);
			c.redirect();
			system.assertEquals(false,c.clearClone);
		Test.stopTest();
	}
	
	static testMethod void clearClone() {
		pse__Milestone__c m = [Select Id from pse__Milestone__c];
		ApexPages.StandardController sc = new ApexPages.StandardController(m);
		ApexPages.currentPage().getParameters().put('id',m.id);
		ApexPages.currentPage().getParameters().put('clearclone','1');
		Test.startTest();
			CustomClone c = new CustomClone(sc);
			c.redirect(); 
			system.assertEquals(true,c.clearClone);
		Test.stopTest();
	}
	
	static testMethod void invalidId() {
		pse__Milestone__c m = [Select Id from pse__Milestone__c];
		ApexPages.StandardController sc = new ApexPages.StandardController(m);
		ApexPages.currentPage().getParameters().put('id','4567898765e');
		Test.startTest();
			CustomClone c = new CustomClone(sc);
			c.redirect();
			system.assertEquals(false,c.clearClone);
		Test.stopTest();
	}
	
	private static pse__Proj__c createProject(String name, Account acc,pse__Region__c region) {
        pse__Proj__c project = new pse__Proj__c();
        project.Name = name;
        project.pse__Account__c = acc.id;
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
        insert project;
        return project;
    }
    
    private static c2g__codaCompany__c createCompany() {
    		c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        return comp ;
    }
	
	private static pse__Region__c createRegion(c2g__codaCompany__c comp) {
		//Insert region 
        pse__Region__c region = new pse__Region__c();
        region.Name = 'test region';
        region.CurrencyIsoCode = 'USD';
        region.ffpsai__OwnerCompany__c = comp.id;
        insert region ;
        return region ;
	}
}