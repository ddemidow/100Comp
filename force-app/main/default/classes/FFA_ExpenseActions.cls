/**************************************************************************************************
Description:      This class contains methods that are called from FFA_ExpenseTrigger on before 
				  update.  This method assigns the GL account to Expenses based on
				  the expense type and project type and billable flag.
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
01/09/2014              Liz Ichihashi              		Created new class.
01/14/2014              Liz Ichihashi                   Changed to execute on before update only,
                                                        Check for null gl code to execute assignment logic.
**************************************************************************************************/
public with sharing class FFA_ExpenseActions {

	public static void setGLAcct(List<pse__Expense__c> oldList, List<pse__Expense__c> newList) {
		Map<Id, pse__Expense__c> oldMap;
		if (oldList != null) {
			oldMap = new Map<Id, pse__Expense__c>(oldList);
		}	    
		Set<Id> expenseReportIds = new Set<Id>();
        List<pse__Expense__c> expensesToUpdate = new List<pse__Expense__c>();
        for (pse__Expense__c expRow : newList) {
        	System.debug('expRow='+expRow);
        	if (expRow.pse__Expense_Report__c != null && expRow.pse__Project__c != null && 
        		expRow.pse__Status__c != oldMap.get(expRow.Id).pse__Status__c) {  
        		expensesToUpdate.add(expRow);  
        		expenseReportIds.add(expRow.pse__Expense_Report__c);
        	}		  
        }	
        
        if (expensesToUpdate.size() > 0) {
        	/* get data from reference table and make a map with the expense type as the key */
        	List<ffpsai__ExpenseTypeGLAMapping__c> expTypeList = [Select ffpsai__ExpenseType__c, ffpsai__GLACodeBillable__c,
					 						GLACodeInternal__c, ffpsai__GLACodeNonBillable__c, GLACodeSales__c
											from ffpsai__ExpenseTypeGLAMapping__c];
	        Map<String, ffpsai__ExpenseTypeGLAMapping__c> expenseTypeMap = new Map<String, ffpsai__ExpenseTypeGLAMapping__c>();
	        for (ffpsai__ExpenseTypeGLAMapping__c expTypeRow : expTypeList) {
				expenseTypeMap.put(expTypeRow.ffpsai__ExpenseType__c, expTypeRow);
	        }
	        /* get additional data from expense report records to use in GL assignment logic */
        	Map<Id, pse__Expense_Report__c> headerMap = new Map<Id, pse__Expense_Report__c>([select Id, pse__Project__r.pse__Project_Type__c
        									 from pse__Expense_Report__c where id in :expenseReportIds]);	
        	/* loop through expenses and assign GL account from mapping based on Expense Type, Project Type and Billable flag. */									
	        for (pse__Expense__c expRow : expensesToUpdate) {	
	        	pse__Expense_Report__c header = headerMap.get(expRow.pse__Expense_Report__c);
	        	System.debug('header='+header);
	    		ffpsai__ExpenseTypeGLAMapping__c expMapping = expenseTypeMap.get(expRow.pse__Type__c);
	    		if (expMapping != null && header != null && header.pse__Project__r != null) {  
	    			if (header.pse__Project__r.pse__Project_Type__c == 'Customer') {
		        		if (expRow.pse__Billable__c) {	
			     			expRow.ffpsai__ExpenseGLACode__c = expMapping.ffpsai__GLACodeBillable__c;
			        	} else {
			        		expRow.ffpsai__ExpenseGLACode__c = expMapping.ffpsai__GLACodeNonBillable__c;		
		        		}
	    			} else if (header.pse__Project__r.pse__Project_Type__c == 'Internal') {
	    				expRow.ffpsai__ExpenseGLACode__c = expMapping.GLACodeInternal__c;
	    			} else if (header.pse__Project__r.pse__Project_Type__c == 'Sales') {
	    				expRow.ffpsai__ExpenseGLACode__c = expMapping.GLACodeSales__c;
	    			}
	        	}    
	        	if (expRow.ffpsai__ExpenseGLACode__c == null) {
	        		expRow.addError('The Expense Type cannot be mapped to a GL Account.  Please contact the Finance department for more info. Expense='+expRow);
	        	}
	        }
		}   
	}
}