// 
// (c) 2012 Appirio, Inc.
//
// AW_trgr_RuleManager                                                     
//
// Trigger is used to populate the count of rule in an Advance Workflow    
//
//  
// 26 Jan 2013     Processing regarding Active, Draft and Archive Rule Status
public with sharing class AW_trgr_RuleManager {
 
  //Variable to make sure that the Rule insert, update  delete  is happening only once.
  public static Boolean RULE_FLOW_CONTROLLER = true;
 
  public static void afterInsertRule( List<Rule__c> newList){
  Set<Id> executionWorkflowIds = new Set<Id>();  
     for(Rule__c rule : newList){
            if(rule.Advance_Workflow__c != null){
                executionWorkflowIds.add(rule.Advance_Workflow__c);
			     
            }
    }       	
    if (executionWorkflowIds.size()>0  ) CountRulesassociatedtoAdvanceWorkflow(executionWorkflowIds);
    RULE_FLOW_CONTROLLER = false;
}

 // public static void afterUpdateRule(List<Rule__c> newList, Map<Id, Rule__c> oldMap ){
  public static void afterUpdateRule(List<Rule__c> newList,List<Rule__c> oldList  ){
    Set<Id> executionWorkflowIds = new Set<Id>();
    Set<Id> ruleIds = new Set<Id>();
    Set<Id> activedraftruleIds = new Set<Id>();
   
	 
    for(Integer i = 0; i < oldList.size(); i++){
    	system.debug('-- for(Integer i: ' +  i );
	    Rule__c newRule = newlist[i];
	    Rule__c oldRule = oldlist[i];
	    
	    system.debug('-- NEW RULE ' +newRule +'  -- OLD RULE ' + oldRule );
	     
	    system.debug('-- NEW Status ' +newRule.Status__c + '-- OLD Status ' + oldRule.Status__c);
	     
	//     NOT POSSIBLE ONLY ONE ADVANCE WORKFLOW PER OBJECT
	    if(newRule.Advance_Workflow__c != oldRule.Advance_Workflow__c){
            if(newRule.Advance_Workflow__c != null ){
                     executionWorkflowIds.add(newRule.Advance_Workflow__c);
             } else{
                     executionWorkflowIds.add(oldRule.Advance_Workflow__c);
             }
             if (executionWorkflowIds.size()>0  ) CountRulesassociatedtoAdvanceWorkflow(executionWorkflowIds);
        }
		 
		//if(newRule.Status__c != oldRule.Status__c && newRule.Id != null){
        if(newRule.Status__c != oldRule.Status__c  ){
      	
        	   	/* If status change from Active to Draft  update status to archive, reset  order & asscociate to advance workflow  */
				
        	    if( oldRule.Status__c == 'Active' &&  newRule.Status__c == 'Draft'   ){
						   activedraftruleIds.add(newRule.Id);
						   system.debug('--- from Active to Draft draftarchiveruleIds '+ activedraftruleIds); 
						   if (activedraftruleIds.size()>0   ) updateRuleActive_To_Draft(activedraftruleIds);
		       }
		       	/* If status change from Active to Archive insert a record Rule_Archive object and Delete Rule */
				  else  if(( oldRule.Status__c == 'Active' ) && (  newRule.Status__c == 'Archived' && oldRule.Total_Actions__c > 0 && oldRule.Total_Criteria__c > 0)){
				 	   		ruleIds.add(newRule.Id);
						   	system.debug('--- from Active to Archive draftarchiveruleIds '+ ruleIds); 
						    if (ruleIds.size()>0  ) {
						    	  updateRuleActiveDraft_To_Archive(ruleIds,newList,oldRule.Status__c);
							 }
				/* If status change from Draft to Archive insert a record Rule_Archive object and Delete Rule */
				 } else  if (   oldRule.Status__c == 'Draft' && newRule.Status__c == 'Archived'   && oldRule.Total_Actions__c > 0 && oldRule.Total_Criteria__c > 0 ) {
				  		   ruleIds.add(newRule.Id);
						   system.debug('--- from Draft to Archive draftarchiveruleIds '+ ruleIds); 
						     if (ruleIds.size()>0  ) {
						    	  updateRuleActiveDraft_To_Archive(ruleIds,newList,oldRule.Status__c);
						        //  afterInsertDeleteRule(newList);
						    }
        	           }  
			   }   
          }
     RULE_FLOW_CONTROLLER = false;	
   }

 
  public static void afterDeleteRule(List<Rule__c> oldList){
    system.debug('-- AW_trgr_RuleManafer afterDeleteRule OLD LIST SIZE  ' +oldList.size() );
     Set<Id> executionWorkflowIds = new Set<Id>();
     
     for(Rule__c rule : oldList){
     system.debug('--AW_trgr_RuleManafer afterDeleteRule RULE STATUS   ' +rule.Status__c );
    	 
     	if ( rule.Status__c=='Active') {
    	// || ( rule.Status__c=='Draft' && rule.Total_Actions__c  >0 && rule.Total_Criteria__c>0 ) ) 
        	executionWorkflowIds.add(rule.Advance_Workflow__c);
      	}
      }
     if (executionWorkflowIds.size()>0  ) CountRulesassociatedtoAdvanceWorkflow(executionWorkflowIds);
     RULE_FLOW_CONTROLLER = false;  
    	
    }
   
  public static void CountRulesassociatedtoAdvanceWorkflow( Set<Id> Ids){
  /* 
  * Get all the childs of Advance Workflow and then update
  * CountRulesassociatedtoAdvanceWorkflow__c  field
  */ 
  system.debug('-- CountRulesassociatedtoAdvanceWorkflow   ' +Ids );
    
    Map<id,Advance_Workflow__c> executionWorkflowMap = new Map<id,Advance_Workflow__c>([select id,(select id from Rules__r where Status__c='Active' ) from Advance_Workflow__c where id IN :Ids]);
    for(Id flowId: executionWorkflowMap.keyset()){
        Advance_Workflow__c workflow = executionWorkflowMap.get(flowId);
        workflow.CountRulesassociatedtoAdvanceWorkflow__c = workflow.Rules__r.size();
    }
    update executionWorkflowMap.values();      
   }   

/**
    * If status change from Active to Draft Update Rule fields :
     Blank Order, Advance orkflow, 
     Set Status to Draft
     Increase Version
  */  
public static void updateRuleActive_To_Draft( Set<Id> Ids){  

 system.debug('-- updateRuleActive_To_Draft   ' +Ids );
  
  if (Ids.size()>0  ) {
         Map<id,Rule__c> ruleMap = new Map<id,Rule__c>([SELECT id,
                                                           Status__c,
                                                            Version__c 
                                                     FROM Rule__c 
                                                     WHERE id IN :Ids]);
        for(Id ruleId: ruleMap.keyset()){
              Rule__c rule = ruleMap.get(ruleId);
              rule.Advance_Workflow__c =null;
              rule.Order__c =null;
              rule.Execution_Behavior__c =null;
              rule.Status__c ='Draft';
              if (rule.Version__c != null ) rule.Version__c =rule.Version__c+1;else rule.Version__c=1;
              update ruleMap.values();    
        	
       } 
    }
}

/**
* If status change from Active or Draft to Archive insert a record 
* Rule_Archive object and Delete Rule  
*/  
public static void updateRuleActiveDraft_To_Archive( Set<Id> Ids,List<Rule__c> newList,String PriorStatus){ 
	system.debug('-- updateRuleActiveDraft_To_Archive   ' +Ids );
	
    String result='' ;
	if (Ids.size()>0  ) {
     	 List<Rule_Archive__c>  insertArchiveRuleList = new List<Rule_Archive__c>();
    	 List<Rule__c> lstRulesToDelete = new List<Rule__c>();
    	 for(Rule__c rl : newList) {
			 Rule__c rlDel = new Rule__c(Id=rl.Id);
			 if(PriorStatus=='Active' || ( PriorStatus=='Draft' && rl.Total_Actions__c>0 && rl.Total_Criteria__c >0))  {
			 	 lstRulesToDelete.add(rlDel);
			 }
	         Rule_Archive__c   rulearchiveList = new Rule_Archive__c();
	               
	        // rulearchiveList.Rule__c= rl.Id; 
	         rulearchiveList.Rule_Reference_Id__c=rl.Id; 
	         rulearchiveList.Rule_Name__c =rl.Name;
	         rulearchiveList.Description__c= rl.Description__c; 
	         rulearchiveList.Status__c= rl.Status__c; 
	         rulearchiveList.Object__c= rl.Object__c; 
	         rulearchiveList.Status__c= rl.Status__c; 
	         rulearchiveList.Order__c= rl.Order__c; 
	         rulearchiveList.Evaluation_Rule__c= rl.Evaluation_Rule__c; 
	         rulearchiveList.Version__c= rl.Version__c; 
	         if(PriorStatus=='Active') {
	         	rulearchiveList.Prior_Status__c='Active';
	            rulearchiveList.Body__c='Body for Rule ( From Active to Archive   ) is generated ...';  
	            insertArchiveRuleList.add(rulearchiveList);
              }
	         if(PriorStatus=='Draft' && rl.Total_Actions__c>0  && rl.Total_Criteria__c >0) {
	           rulearchiveList.Prior_Status__c='Draft';
	          
	          // result=XMLWriteDemo.getXml();
	          // rulearchiveList.Body__c=result;
	           rulearchiveList.Body__c='Body for Rule ( From Draft to Archive   ) is generated ...';  
	         insertArchiveRuleList.add(rulearchiveList);
	       }
	         
	        // insertArchiveRuleList.add(rulearchiveList);
       }
       if (insertarchiveruleList.size() >0 ) insert insertarchiveruleList;
       //convert the data of rule actions and criteria into XML format 
      // system.debug('lstRulesToDelete.size() ' + lstRulesToDelete.size()) ;
      // if (lstRulesToDelete.size() >0 ) delete lstRulesToDelete;
      }
}

  
}