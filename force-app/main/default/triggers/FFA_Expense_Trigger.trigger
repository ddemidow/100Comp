trigger FFA_Expense_Trigger on pse__Expense__c (before update) {
	FFA_ExpenseActions.setGLAcct(trigger.old, trigger.new);  
}