/**************************************************************************************
Name        : TestResourcePlannerReminderBatch
Created By  : Appirio India (Nimisha Prashant)
Date        : 12th May,2016
Purpose     : Test Class for Batch S-408902
****************************************************************************************/
@isTest
private class TestResourcePlannerReminderBatch {
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	static testMethod void testReminderBatch() {
        Test.startTest();
	        FFA_TestUtility testUtil = new FFA_TestUtility();
		    User usr = testUtil.newUserFFAdmin(true);
		    createTestData(testUtil, usr);
		        
	    	ResourcePlannerReminderBatch b = new ResourcePlannerReminderBatch();
	   		Database.executeBatch(b);
	   		
	   		// Schedule the test job
	   		String jobId = System.schedule('ScheduleApexClassTest',
	                    CRON_EXP, 
	                    new ResourcePlannerReminderBatch());
        Test.stopTest();
    }
    
    static void createTestData(FFA_TestUtility testUtil, User usr) {
    	System.runAs(usr) {  
	    	Account acct = testUtil.newAccount(true);
	        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
	        c2g__codaCompany__c comp = new c2g__codaCompany__c(name =  'SSA & Company GmbH1');
	        insert Comp;
	        
	        pse__Region__c reg = new pse__Region__c(
	        Name = 'Region1',
	        ffpsai__OwnerCompany__c = comp.Id,
	        Timecard_Approval__c = 'One Step',
	        Expense_Approval__c = 'One Step');
	        insert reg;
	        
	        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
	        ffrr__Settings__c settingObj = new ffrr__Settings__c();
	        settingObj.ffrr__ActiveField__c = 'pse__Is_Active__c'; 
	        settingObj.ffrr__ActiveValue__c = 'TRUE';
	        settingObj.ffrr__Description__c = 'Name';
	        settingObj.ffrr__Object__c = 'pse__Proj__c';
	        settingObj.ffrr__TotalRevenue__c = 'test';
	        settingObj.ffrr__Currency__c = 'CurrencyIsoCode';
	        settingObj.ffrr__SettingsType__c = 'Forecast';
	        settingObj.ffrr__IncludeActiveValue__c = 'Include';
	        settingObj.ffrr__ForecastTransactionLineRelationship__c = 'Project__c';
	        settingObj.ffrr__EndDate__c = 'pse__End_Date__c';
	        settingObj.ffrr__StartDate__c = 'pse__Start_Date__c';
	        settingObj.ffrr__TotalRevenue__c = 'Total_Projected_Revenue__c';
	        settingObj.ffrr__SettingsLevel__c = 'Primary';
	        settingObj.ffrr__ForecastHeaderPrimaryRelationship__c = 'Project__c';
	        settingObj.ffrr__AccountName__c = 'pse__Account__c';
	        insert settingObj;
	        
	        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
	        pse__Practice__c practice = new pse__Practice__c(Name='G100 Companies');
	        insert practice;
	        
	        Id practId = [select Id from pse__Practice__c limit 1].Id;
	        ffrr__Template__c tempObj = new ffrr__Template__c();
	        tempObj.Name = 'EVA - Equal Split1';
	        tempObj.ffrr__Settings__c = settingObj.Id;
	        tempObj.ffrr__RevenueSource__c = 'pse__Est_Vs_Actuals__c';
	        tempObj.ffrr__CalculationType__c = 'Months';
	        tempObj.ffrr__RevenueBasis__c = 'Total Revenue';
	        tempObj.ffrr__RevRecType__c = 'Equal Split';
	        insert tempObj;
	        
	        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);
	        proj.EVA_Forecast_Template__c = tempObj.Id;
	        update proj;
	        
	        User usr2 = testUtil.newUserSysAdmin(true);
	        Contact res = testUtil.newResource(true,acct.Id,usr2.Id,reg.Id, cal.Id);
	        system.assertEquals(false, res.pse__Exclude_from_Resource_Planner__c);
	        
	        pse__Schedule__c sched = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
	        pse__Assignment__c ass = testUtil.newAssignment(true,proj.Id,res.Id,sched.Id);
	        system.assertEquals(false, ass.pse__Exclude_from_Planners__c);
	        
	        pse__Est_Vs_Actuals__c estObj = new pse__Est_Vs_Actuals__c();
	        estObj.Name = 'test';
	        estObj.pse__Project__c = proj.Id;
	        estObj.pse__Resource__c = res.Id;
	        estObj.pse__Assignment__c = ass.Id;
	        estObj.pse__Actual_Hours__c = 10;
	        estObj.pse__End_Date__c = System.today().addDays(6);
	        estObj.pse__Estimated_Hours__c = 0;
	        estObj.pse__Start_Date__c = System.today();
	        insert estObj;
	        system.assert(estObj.Id != null);
	    }
    }
}