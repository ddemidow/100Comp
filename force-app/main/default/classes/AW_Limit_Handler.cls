// This class is used to validate rule limits 

public with sharing class AW_Limit_Handler {
  
  	static string TOTAL_ADVANCE_WORKFLOW = 'NumAdvanceWorkflowperObject';
  	static string TOTAL_APEX_JOBS = 'NumApexJobsperRule';
  	static string TOTAL_CRITERIA_CROSSFORMULA = 'NumCriteriaCrossFormulaFieldsperRule';
  	static string TOTAL_CRITERIA = 'NumCriteriaperRule';
  	static string TOTAL_EMAIL_ACTION = 'NumEmailActionsperRule';
  	static string TOTAL_INSERT_ACTION = 'NumInsertActionsperRule';
  	static string TOTAL_RULES = 'NumRulesperObject';
  	static string TOTAL_UPDATE_ACTION = 'NumUpdateActionsperRule';
  	static string TOTAL_UPDATE_CROSSREFERENCE_ACTION = 'NumUpdateCrossReferenceFieldsperRule';
  	static string TOTAL_UPDATE_LOOKUPREFERENCE_ACTION = 'NumUpdateLookupReferenceFieldsperRule';
  	static string TOTAL_UPDATE_MERGE_ACTION = 'NumUpdateMergeFieldsperRule';
    
    static string TOTAL_ADVANCE_WORKFLOW_MESSAGE = 'Advance Workflow Limit Exceeded. Unable to create Advance Workflow because it exceeds the maximum allowed: ';
    static string TOTAL_APEX_JOBS_MESSAGE = 'Apex Job Action Limit Exceeded. Unable to create Apex Job Action because it exceeds the maximum allowed: ';
    static string TOTAL_CRITERIA_CROSSFORMULA_MESSAGE = 'Cross Formula Criteria Limit Exceeded. Unable to create Cross Formula Criteria because it exceeds the maximum allowed: ';
    static string TOTAL_CRITERIA_MESSAGE = 'Criteria Limit Exceeded. Unable to create Criteria because it exceeds the maximum allowed: ';
    static string TOTAL_UPDATE_ACTION_MESSAGE = 'Update Action Limit Exceeded. Unable to create Update Action because it exceeds the maximum allowed: ';
    static string TOTAL_INSERT_ACTION_MESSAGE = 'Insert Action Limit Exceeded. Unable to create Insert Action because it exceeds the maximum allowed: ';
    static string TOTAL_EMAIL_ACTION_MESSAGE = 'Email Action Limit Exceeded. Unable to create Email Action because it exceeds the maximum allowed: ';
    static string TOTAL_UPDATE_CROSSREFERENCE_ACTION_MESSAGE = 'Update Cross Reference Action Limit Exceeded. Unable to create Update Cross Reference Action because it exceeds the maximum allowed: ';
    static string TOTAL_UPDATE_LOOKUPREFERENCE_ACTION_MESSAGE = 'Update Lookup Reference Action Limit Exceeded. Unable to create Update Lookup Reference Action because it exceeds the maximum allowed: ';
    static string TOTAL_UPDATE_MERGE_ACTION_MESSAGE = 'Update Merge Action Limit Exceeded. Unable to create Update Merge Action because it exceeds the maximum allowed: ';
    static string TOTAL_RULE_MESSAGE = 'Rule Limit Exceeded. Unable to create Rule because it exceeds the maximum allowed: ';
   
    /**
    * This method validates rule limit
    */
	public void validateRule(List<Rule__c> newRuleList){
    
    	Advance_Workflow_Limits__c criteriaLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_CRITERIA);
    	Advance_Workflow_Limits__c crossFormulaCriteriaLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_CRITERIA_CROSSFORMULA);
    	Advance_Workflow_Limits__c apexJobActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_APEX_JOBS);
    	Advance_Workflow_Limits__c ruleLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_RULES);
    	Advance_Workflow_Limits__c updateActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_UPDATE_ACTION);
    	Advance_Workflow_Limits__c emailActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_EMAIL_ACTION);
    	Advance_Workflow_Limits__c insertActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_INSERT_ACTION);
    	
    	Advance_Workflow_Limits__c updateCrossRefActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_UPDATE_CROSSREFERENCE_ACTION);
    	Advance_Workflow_Limits__c updateLookupRefActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_UPDATE_LOOKUPREFERENCE_ACTION);
    	Advance_Workflow_Limits__c udateMergeActionLimit = Advance_Workflow_Limits__c.getInstance(TOTAL_UPDATE_MERGE_ACTION);
    	
		Set<String> objectSet = new Set<String>();
		for(Rule__c rule: newRuleList){
			objectSet.add(rule.Object__c);
		}  	  
		List<AggregateResult> ruleCountPerObject = [select count(Id) cnt,object__c obj from Rule__c where Object__c in: objectSet group by Object__c];
		objectSet.clear();
		
		Map<String,Integer> objectRuleCount = new Map<String,Integer>();
				
		for(AggregateResult rule: ruleCountPerObject){
			objectRuleCount.put((String)rule.get('obj'),(Integer)rule.get('cnt'));
		}
		
  	  	for(Rule__c rule: newRuleList){
	  		if(criteriaLimit != null && rule.Total_Criteria__c > criteriaLimit.Value__c){
	  			rule.addError(TOTAL_CRITERIA_MESSAGE + String.valueof(criteriaLimit.Value__c).replace('.0',''));
	  		}
	  		if(crossFormulaCriteriaLimit != null && rule.Total_Cross_Formula_Criteria__c > crossFormulaCriteriaLimit.Value__c){
	  			rule.addError(TOTAL_CRITERIA_CROSSFORMULA_MESSAGE + String.valueof(crossFormulaCriteriaLimit.Value__c).replace('.0',''));
	  		}
	  		if(updateActionLimit != null && rule.Total_Update_Action__c > updateActionLimit.Value__c){
	  			rule.addError(TOTAL_UPDATE_ACTION_MESSAGE + String.valueof(updateActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(apexJobActionLimit != null && rule.Total_Apex_Jobs_Action__c > apexJobActionLimit.Value__c){
	  			rule.addError(TOTAL_APEX_JOBS_MESSAGE + String.valueof(apexJobActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(emailActionLimit != null && rule.Total_Email_Action__c > emailActionLimit.Value__c){
	  			rule.addError(TOTAL_EMAIL_ACTION_MESSAGE + String.valueof(emailActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(insertActionLimit != null && rule.Total_Insert_Action__c > insertActionLimit.Value__c){
	  			rule.addError(TOTAL_INSERT_ACTION_MESSAGE + String.valueof(insertActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(updateLookupRefActionLimit != null && rule.Total_Update_Lookup_Reference_Action__c > updateLookupRefActionLimit.Value__c){
	  			rule.addError(TOTAL_UPDATE_LOOKUPREFERENCE_ACTION_MESSAGE + String.valueof(updateLookupRefActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(updateCrossRefActionLimit != null && rule.Total_Cross_Reference_Field_Action__c > updateCrossRefActionLimit.Value__c){
	  			rule.addError(TOTAL_UPDATE_CROSSREFERENCE_ACTION_MESSAGE + String.valueof(updateCrossRefActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(udateMergeActionLimit != null && rule.Total_Update_Merge_Action__c > udateMergeActionLimit.Value__c){
	  			rule.addError(TOTAL_UPDATE_MERGE_ACTION_MESSAGE + String.valueof(udateMergeActionLimit.Value__c).replace('.0',''));
	  		}
	  		if(objectRuleCount.containsKey(rule.Object__c)){
	  			Integer cnt = objectRuleCount.get(rule.Object__c);
	  			if(ruleLimit != null && cnt > ruleLimit.Value__c){
	  				rule.addError(TOTAL_RULE_MESSAGE + String.valueof(ruleLimit.Value__c).replace('.0',''));
	  			}
	  			else{
	  				objectRuleCount.put(rule.Object__c,++cnt);
	  			}
	  		}
	  		else{
	  			objectRuleCount.put(rule.Object__c,1);
	  		}	  	
 	    }
	}
    
    /**
    * This method creates limit custom setting records
    */
    public static void createLimitSettings(){
    	List<Advance_Workflow_Limits__c> limitList = new List<Advance_Workflow_Limits__c>(); 
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_ADVANCE_WORKFLOW, value__c = 1));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_APEX_JOBS, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_CRITERIA_CROSSFORMULA, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_CRITERIA, value__c = 99));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_EMAIL_ACTION, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_RULES, value__c = 1000));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_INSERT_ACTION, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_UPDATE_ACTION, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_UPDATE_CROSSREFERENCE_ACTION, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_UPDATE_LOOKUPREFERENCE_ACTION, value__c = 25));
    	limitList.add(new Advance_Workflow_Limits__c(Name = TOTAL_UPDATE_MERGE_ACTION, value__c = 25));
    	DataBase.insert(limitList,false);
    }

}