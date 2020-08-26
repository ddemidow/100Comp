/*****************************************************
Author  : Appirio [Hitesh - Dec 05, 2014]
Purpose : Trigger on pse__Expense_Report__c.
*****************************************************/
trigger ExpenseReportApproverTrigger on pse__Expense_Report__c (before update) {
    if(Trigger.isBefore && Trigger.isUpdate)
        ExpenseReportApproverTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);  
}