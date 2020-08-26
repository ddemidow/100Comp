/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PSA_Exp_Approval_Request_con_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
     /*  FFA_TestUtility testUtil = new FFA_TestUtility();
		User usr = testUtil.newUserSysAdmin(true);
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);
        c2g__codaGeneralLedgerAccount__c gl = testUtil.newGLAccount();
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr) {
	        expReport = testUtil.newExpenseReport(true, proj.Id, milestone.Id, resource.Id);
	        exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'Auto Mileage', 100);
	        exp.pse__Status__c = 'Approved';
	        exp.pse__Distance__c = 200;
	        exp.pse__Tax_Type__c = 'GST';
	        exp.pse__Incurred_Tax__c = 100;
	        exp.pse__Milestone__c = milestone.Id;
	        exp.pse__Include_In_Financials__c = true;
	        exp.pse__Approved__c = true;
	        exp.pse__Billing_Amount__c = 200;
	        exp.ffpsai__ExpenseGLACode__c = gl.Id;
	        insert exp;
        }*/
        PSA_Exp_Approval_Request_con controllerObj = new PSA_Exp_Approval_Request_con();
        /*if(expReport!=null){
        	controllerObj.expenseReportObj.Id = expReport.Id;
 	        System.assertNotEquals(controllerObj.recordlink, '');
        }*/
    }
}