global with sharing class AW_Advance_WorkflowBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private string query = '';
    private string sobjType = '';
    private DateTime dtnew = null;
    private DateTime dt = null;
    
    public AW_Advance_WorkflowBatch (DateTime dt1,String sobjType){
        this.sobjType = sobjType;
        this.dt = dt1;       
        query = 'Select Id,Action__c,Value__c,Record_Id__c FROM ' + sobjType ;//where CreatedDate >=:dt 
       
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        dtnew = system.now();
        return Database.getQueryLocator(query);
        /**
         * Setting the date context for next execute
         */     
    }
    
    global void execute(Database.BatchableContext BC, List<Object_Action_Execution__c> scope){
        Set<Id> actionIds = new Set<Id>();
        Set<Id> recordIds = new Set<Id>();
        Map<String,String> actionValue = new Map<String,String>();      
        for(Object_Action_Execution__c o: scope){
            actionIds.add(o.Action__c);
            recordIds.add(o.Record_Id__c);
            actionValue.put(o.Action__c,o.Value__c);
        }
       
      // List<RuleAction__c> actions =[Select Id,Type__c, Rule__c,Rule__r.Object__c,Lookup_Object__c,Lookup_Field_Api_Name__c,Lookup_Condition__c,Field_API_Name__c  ,Field_Name__c FROM RuleAction__c WHERE Id IN:actionIds];
       List<RuleAction__c> actions =[Select Id,Type__c, Rule__c,Rule__r.Object__c,Field_API_Name__c  ,Field_Name__c FROM RuleAction__c WHERE Id IN:actionIds];
       
       Set<Id> ruleIds = new Set<Id>();
       Set<Id> evaluateActions = new Set<Id>();
       String sobjectName;  
       
       for(RuleAction__c a:actions){
            //if(a.Type__c=='Update Field' && a.Field_Name__c=='LookupObject')
            //    continue;
                
            ruleIds.add(a.Rule__c);
            evaluateActions.add(a.Id);
            sobjectName =a.Rule__r.Object__c; 
       }
       
       AW_AdvanceWorkflowExecutionEngine.bulkOperation=true;     
       AW_AdvanceWorkflowExecutionEngine.bulkactionIds=evaluateActions;   
       AW_AdvanceWorkflowExecutionEngine.evaluateRules(ruleIds,recordIds,sobjectName );
       
       
       
       delete scope;
       
    }
    
    global void finish(Database.BatchableContext BC) {
        //schedule for next run after some time
        //string query = 'Select id from ' + sobjType + ' where CreatedDate >=:dtnew ' + ' limit 1';
        
        string query = 'Select id from ' + sobjType + ' limit 1';
        
        List<SObject> lstObj = Database.query(query);
        if(lstObj != null && lstObj.size() > 0){
            AW_AdvanceWorkflowExecutionHelper.StartAWSchedular(system.now(),sobjType);
        }else{
            AdvanceWorkflowBatchStatus__c awBatchStatus = AdvanceWorkflowBatchStatus__c.getInstance(sobjType);
            if(awBatchStatus != null){
                delete awBatchStatus;
            }
        }
    }

}