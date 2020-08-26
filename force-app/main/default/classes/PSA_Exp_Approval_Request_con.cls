global class PSA_Exp_Approval_Request_con {
	public pse__Expense_Report__c expenseReportObj{get;set;}
	public String recordlink{get
		{
		if(expenseReportObj!=null){
			recordlink = URL.getSalesforceBaseUrl().toExternalForm() +'/' + expenseReportObj.id;
		}
		return recordlink;
		}set;}
	public PSA_Exp_Approval_Request_con(){
		
	}

}