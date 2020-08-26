@isTest(SeeAllData=false)
/**************************************************************************************************
Description:      This class contains methods that test FFA_ExpenseActions
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
01/09/2014              Liz Ichihashi                   Created new class.
**************************************************************************************************/
public with sharing class FFA_ExpenseActions_Test {

	public static testMethod void testInternalProjGL() {
		FFA_TestUtility testUtil = new FFA_TestUtility();
	              
        User usr = testUtil.newUserSysAdmin(true); 
        User usr2 = testUtil.newUserSysAdmin(true);
       
        usr2.ManagerId = usr.Id;    
        update usr2; 
        User usr3 = testUtil.newUserSysAdmin(true);     
        Account acct = testUtil.newAccount(true);
        User partUsr = testUtil.newUserSysAdmin(true);
       // Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
       // START-- Code Added By Parag Bhatt For Case #00253117
        Contact participant = new Contact();
        participant.FirstName = 'Test';
        participant.LastName = 'Contact';
        participant.AccountId = acct.Id;
        insert participant; 
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        //pse__Region__c reg = testUtil.newRegionMaster(true);
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        pse__Region__c reg = new pse__Region__c();
        reg.Name = 'test region';
        reg.CurrencyIsoCode = 'USD';
        reg.ffpsai__OwnerCompany__c = comp.id;
        insert reg ;
        // END-- Code Added By Parag Bhatt For Case #00253117
        Contact resource = testUtil.newResource(true, acct.Id, usr2.Id, reg.Id, cal.Id);
        c2g__codaGeneralLedgerAccount__c gl1 = testUtil.newGLA(true,'00000','00000');
        c2g__codaGeneralLedgerAccount__c gl2 = testUtil.newGLA(true,'11111','11111');
        c2g__codaGeneralLedgerAccount__c gl3 = testUtil.newGLA(true,'33333','33333');
        c2g__codaGeneralLedgerAccount__c gl4 = testUtil.newGLA(true,'44444','44444');
        ffpsai__ExpenseTypeGLAMapping__c mapping = new ffpsai__ExpenseTypeGLAMapping__c();
        mapping.ffpsai__ExpenseType__c = 'test';
        mapping.ffpsai__GLACodeBillable__c = gl1.Id;
        mapping.GLACodeInternal__c = gl2.Id;
        mapping.ffpsai__GLACodeNonBillable__c = gl3.Id;   
        mapping.GLACodeSales__c = gl4.Id;
        insert mapping;
        
        Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
        insert opp;
        
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr2.Id,reg.Id);
        // START-- Code Added By Parag Bhatt For Case #00253117
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Demo Test';
        proj.pse__Account__c = acct.id;
        proj.CurrencyIsoCode = 'USD';
        proj.pse__Start_Date__c = date.today().addYears(-1);
        proj.pse__Region__c = reg.id;
        proj.pse__Project_Status__c = 'Green';
        proj.pse__Is_Active__c = true;
        proj.pse__Invoiced__c = 50000;
        proj.pse__End_Date__c = date.today().addYears(1);
        proj.pse__Closed_for_Time_Entry__c = false; 
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.pse__Billed__c = 40000;
        proj.pse__Opportunity__c = opp.Id;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Project_Type__c = 'Internal';
        proj.pse__Is_Billable__c = false;
        proj.Billing_Resource_Rate_Type__c = 'All';
        insert proj;
        // END-- Code Added By Parag Bhatt For Case #00253117
      //  proj = [select Id, pse__Project_Type__c from pse__Proj__c where id = :proj.Id];
       // System.assert(proj.pse__Project_Type__c == 'Internal');
       pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr2) {  
            
            expReport = testUtil.newExpenseReport(false, proj.Id, milestone.Id, resource.Id);
            expReport.pse__Billable__c = false;
            insert expReport;
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'test', 444);
            exp.pse__Billable__c = false;
            insert exp;
            exp.pse__Status__c = 'Submitted';
            update exp;  
        }
        
    }
    
    public static testMethod void testSalesProjGL() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
                  
        User usr = testUtil.newUserSysAdmin(true); 
        User usr2 = testUtil.newUserSysAdmin(true);
       
        usr2.ManagerId = usr.Id;    
        update usr2; 
        User usr3 = testUtil.newUserSysAdmin(true);     
        Account acct = testUtil.newAccount(true);
        User partUsr = testUtil.newUserSysAdmin(true);
       // Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
       // START-- Code Added By Parag Bhatt For Case #00253117
        Contact participant = new Contact();
        participant.FirstName = 'Test';
        participant.LastName = 'Contact';
        participant.AccountId = acct.Id;
        insert participant;
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        pse__Region__c reg = new pse__Region__c();
        reg.Name = 'test region';
        reg.CurrencyIsoCode = 'USD';
        reg.ffpsai__OwnerCompany__c = comp.id;
        insert reg ;
        // END-- Code Added By Parag Bhatt For Case #00253117
        
        Contact resource = testUtil.newResource(true, acct.Id, usr2.Id, reg.Id, cal.Id);
        c2g__codaGeneralLedgerAccount__c gl1 = testUtil.newGLA(true,'00000','00000');
        c2g__codaGeneralLedgerAccount__c gl2 = testUtil.newGLA(true,'11111','11111');
        c2g__codaGeneralLedgerAccount__c gl3 = testUtil.newGLA(true,'33333','33333');
        c2g__codaGeneralLedgerAccount__c gl4 = testUtil.newGLA(true,'44444','44444');
        ffpsai__ExpenseTypeGLAMapping__c mapping = new ffpsai__ExpenseTypeGLAMapping__c();
        mapping.ffpsai__ExpenseType__c = 'test';
        mapping.ffpsai__GLACodeBillable__c = gl1.Id;
        mapping.GLACodeInternal__c = gl2.Id;
        mapping.ffpsai__GLACodeNonBillable__c = gl3.Id;   
        mapping.GLACodeSales__c = gl4.Id;
        insert mapping;  
        
        Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
        insert opp;
        
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr2.Id,reg.Id);
        // START-- Code Added By Parag Bhatt For Case #00253117
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Demo Test';
        proj.pse__Account__c = acct.id;
        proj.CurrencyIsoCode = 'USD';
        proj.pse__Start_Date__c = date.today().addYears(-1);
        proj.pse__Region__c = reg.id;
        proj.pse__Project_Status__c = 'Green';
        proj.pse__Is_Active__c = true;
        proj.pse__Invoiced__c = 50000;
        proj.pse__End_Date__c = date.today().addYears(1);
        proj.pse__Closed_for_Time_Entry__c = false; 
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.pse__Billed__c = 40000;
        proj.pse__Opportunity__c = opp.Id;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Project_Type__c = 'Sales';
        proj.pse__Is_Billable__c = false;
        proj.Billing_Resource_Rate_Type__c = 'All';
        insert proj;
        // END-- Code Added By Parag Bhatt For Case #00253117
        //proj = [select Id, pse__Project_Type__c from pse__Proj__c where id = :proj.Id];
        //System.assert(proj.pse__Project_Type__c == 'Sales');
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr2) {  
            
            expReport = testUtil.newExpenseReport(false, proj.Id, milestone.Id, resource.Id);
            expReport.pse__Billable__c = false;
            insert expReport;
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'test', 444);
            exp.pse__Billable__c = false;
            insert exp;
            exp.pse__Status__c = 'Submitted';
            update exp;  
        }
       // exp = [select Id, ffpsai__ExpenseGLACode__c,ffpsai__ExpenseGLACode__r.c2g__ReportingCode__c  from pse__Expense__c order by createddate desc limit 1];
       // System.debug('exp='+exp);
       // System.debug('exp.ffpsai__ExpenseGLACode__r.c2g__ReportingCode__c='+exp.ffpsai__ExpenseGLACode__r.c2g__ReportingCode__c);
       //System.assert(exp.ffpsai__ExpenseGLACode__c == gl4.Id); 
    }
    
    public static testMethod void testCustomerProjGL() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
                
        User usr = testUtil.newUserSysAdmin(true); 
        User usr2 = testUtil.newUserSysAdmin(true);
        usr2.ManagerId = usr.Id;    
        update usr2; 
        User usr3 = testUtil.newUserSysAdmin(true);     
        Account acct = testUtil.newAccount(true);
        User partUsr = testUtil.newUserSysAdmin(true);
        //Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
        // START-- Code Added By Parag Bhatt For Case #00253117
        Contact participant = new Contact();
        participant.FirstName = 'Test';
        participant.LastName = 'Contact';
        participant.AccountId = acct.Id;
        insert participant;
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        pse__Region__c reg = new pse__Region__c();
        reg.Name = 'test region';
        reg.CurrencyIsoCode = 'USD';
        reg.ffpsai__OwnerCompany__c = comp.id;
        insert reg ;
        // END-- Code Added By Parag Bhatt For Case #00253117
        Contact resource = testUtil.newResource(true, acct.Id, usr2.Id, reg.Id, cal.Id);
        c2g__codaGeneralLedgerAccount__c gl1 = testUtil.newGLA(true,'00000','00000');
        c2g__codaGeneralLedgerAccount__c gl2 = testUtil.newGLA(true,'11111','11111');
        c2g__codaGeneralLedgerAccount__c gl3 = testUtil.newGLA(true,'33333','33333');
        c2g__codaGeneralLedgerAccount__c gl4 = testUtil.newGLA(true,'44444','44444');
        ffpsai__ExpenseTypeGLAMapping__c mapping = new ffpsai__ExpenseTypeGLAMapping__c();
        mapping.ffpsai__ExpenseType__c = 'test';
        mapping.ffpsai__GLACodeBillable__c = gl1.Id;
        mapping.GLACodeInternal__c = gl2.Id;
        mapping.ffpsai__GLACodeNonBillable__c = gl3.Id;
        mapping.GLACodeSales__c = gl4.Id;
        insert mapping;
        
        Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
        insert opp;
        
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr2.Id,reg.Id);
     // START-- Code Added By Parag Bhatt For Case #00253117
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Demo Test';
        proj.pse__Account__c = acct.id;
        proj.CurrencyIsoCode = 'USD';
        proj.pse__Start_Date__c = date.today().addYears(-1);
        proj.pse__Region__c = reg.id;
        proj.pse__Project_Status__c = 'Green';
        proj.pse__Is_Active__c = true;
        proj.pse__Invoiced__c = 50000;
        proj.pse__End_Date__c = date.today().addYears(1);
        proj.pse__Closed_for_Time_Entry__c = false; 
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.pse__Billed__c = 40000;
        proj.pse__Opportunity__c = opp.Id;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Project_Type__c = 'Customer';
        insert proj;
        // END-- Code Added By Parag Bhatt For Case #00253117
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        boolean expThrown = false;
        System.runAs(usr2) {  
            
            expReport = testUtil.newExpenseReport(false, proj.Id, milestone.Id, resource.Id);
            expReport.pse__Billable__c = false;
            insert expReport;
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'test', 444);
            exp.pse__Billable__c = true;
            
            try {
             insert exp;
             exp.pse__Status__c = 'Submitted';
             update exp;  
            } catch (Exception e) {
                expThrown = true;
            }   
        }
        //exp = [select Id, ffpsai__ExpenseGLACode__c from pse__Expense__c order by createddate desc limit 1];
        //System.assert(exp.ffpsai__ExpenseGLACode__c == gl1.Id); 
        //exp.pse__Billable__c = false;
       // update exp;
        //exp = [select Id, ffpsai__ExpenseGLACode__c from pse__Expense__c order by createddate desc limit 1];
       // System.assert(exp.ffpsai__ExpenseGLACode__c == gl3.Id); 
    }
    
    public static testMethod void testExceptionBadExpenseType() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
                  
        User usr = testUtil.newUserSysAdmin(true); 
        User usr2 = testUtil.newUserSysAdmin(true);
       
        usr2.ManagerId = usr.Id;    
        update usr2; 
        User usr3 = testUtil.newUserSysAdmin(true);     
        Account acct = testUtil.newAccount(true);
        User partUsr = testUtil.newUserSysAdmin(true);
       // Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
       // START-- Code Added By Parag Bhatt For Case #00253117
        Contact participant = new Contact();
        participant.FirstName = 'Test';
        participant.LastName = 'Contact';
        participant.AccountId = acct.Id;
        insert participant;
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        pse__Region__c reg = new pse__Region__c();
        reg.Name = 'test region';
        reg.CurrencyIsoCode = 'USD';
        reg.ffpsai__OwnerCompany__c = comp.id;
        insert reg ;
        // END-- Code Added By Parag Bhatt For Case #00253117
        Contact resource = testUtil.newResource(true, acct.Id, usr2.Id, reg.Id, cal.Id);
        c2g__codaGeneralLedgerAccount__c gl1 = testUtil.newGLA(true,'00000','00000');
        c2g__codaGeneralLedgerAccount__c gl2 = testUtil.newGLA(true,'11111','11111');
        c2g__codaGeneralLedgerAccount__c gl3 = testUtil.newGLA(true,'33333','33333');
        c2g__codaGeneralLedgerAccount__c gl4 = testUtil.newGLA(true,'44444','44444');
        ffpsai__ExpenseTypeGLAMapping__c mapping = new ffpsai__ExpenseTypeGLAMapping__c();
        mapping.ffpsai__ExpenseType__c = 'test';
        mapping.ffpsai__GLACodeBillable__c = gl1.Id;
        mapping.GLACodeInternal__c = gl2.Id;
        mapping.ffpsai__GLACodeNonBillable__c = gl3.Id;   
        mapping.GLACodeSales__c = gl4.Id;
        insert mapping;
        
        Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
        insert opp;
        
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr2.Id,reg.Id);
        // START-- Code Added By Parag Bhatt For Case #00253117
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Demo Test';
        proj.pse__Account__c = acct.id;
        proj.CurrencyIsoCode = 'USD';
        proj.pse__Start_Date__c = date.today().addYears(-1);
        proj.pse__Region__c = reg.id;
        proj.pse__Project_Status__c = 'Green';
        proj.pse__Is_Active__c = true;
        proj.pse__Invoiced__c = 50000;
        proj.pse__End_Date__c = date.today().addYears(1);
        proj.pse__Closed_for_Time_Entry__c = false; 
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.pse__Billed__c = 40000;
        proj.pse__Opportunity__c = opp.Id;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Project_Type__c = 'Internal';  
        proj.pse__Is_Billable__c = false;
        proj.Billing_Resource_Rate_Type__c = 'All';
        insert proj;
        // END Code Added By Parag Bhatt For Case #00253117
       // proj = [select Id, pse__Project_Type__c from pse__Proj__c where id = :proj.Id];
       // System.assert(proj.pse__Project_Type__c == 'Internal');
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        boolean expThrown = false;
        System.runAs(usr2) {  
            
            expReport = testUtil.newExpenseReport(false, proj.Id, milestone.Id, resource.Id);
            expReport.pse__Billable__c = false;
            insert expReport;
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'DOH', 444);
            exp.pse__Billable__c = false;
            try {
             insert exp;
             exp.pse__Status__c = 'Submitted';
             update exp;  
            } catch (Exception e) {
                expThrown = true;
            } 
        }
       // System.assert(expThrown); 
    }
}