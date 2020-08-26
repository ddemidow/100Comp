// 
// (c) 2012 Appirio, Inc.
//
//  AW_Advance_WorkflowController                                                     
//
// This class is used to define Execution Plan 
//
// 18 Nov 2012     Peter Babalis     Original
//  
//  
public with sharing class AW_Advance_WorkflowController {
     
    public Advance_Workflow__c newruleexecutionplan {get;set;} 
    public String obj {get;set;}
    public List<SelectOption> objOptions {get;set;}
    public boolean edit {get;set;}
    public boolean ruleAssigned {get;set;}
    
    /**
    * Constructor
    */    
    public AW_Advance_WorkflowController(Apexpages.StandardController stdcon){
        String ruleexecutionplanId;
        ruleexecutionplanId = stdcon.getId();
        newruleexecutionplan = new Advance_Workflow__c();
        objOptions = new List<SelectOption>();
        edit=false;
        ruleAssigned = false;
        
      /* Start */
      /* Modified by Gaurav Dudani on 4th December 2015 for case # 00142114  */
      
        If(Advance_Workflow_Available_objects__c.getAll() != null) {
        List<Advance_Workflow_Available_objects__c> advWorkFlowRules = new  List<Advance_Workflow_Available_objects__c>();
        advWorkFlowRules =  Advance_Workflow_Available_objects__c.getAll().values();
        if(advWorkFlowRules.size() > 0) {
        Set<String> objAPI = new Set<String>();
        for(Advance_Workflow_Available_objects__c obj:Advance_Workflow_Available_objects__c.getAll().values()){
            if(obj.Available__c){
                objAPI.add(obj.API_Name__c); // to add the api names to the set.
            }
        } 
        
        
        if(objAPI.size()>0){
        /* End */
         
        Map<String, Schema.SObjectType> mapObj = Schema.getGlobalDescribe();
        for(String objname:mapObj.keySet()){
            Schema.SObjectType sobj = mapObj.get(objname);
            Schema.DescribeSObjectResult descRes = sobj.getDescribe();
            if(!descRes.isCustomSetting() && descRes.isAccessible() && (descRes.isCreateable() || descRes.isUpdateable())){
             //if(!descRes.isCustomSetting() && descRes.isCustom()){
                String objLabel = descRes.getLabel();
        /* Start */
        /* Modified by Gaurav Dudani on 4th December 2015 for case # 00142114  */
                if(objAPI.contains(descRes.getName())){
        /* End */
                objOptions.add(new SelectOption(descRes.getName(),objLabel + ' (' + descRes.getName() + ')'));
               }
             }
           }
         }
        }
       }
        for(SelectOption op: objOptions){           
                system.debug('---------> List of Objects' + op);
        }
        objOptions.sort();
        if(ruleexecutionplanId != null){
            edit = true;
            newruleexecutionplan = [SELECT name,object__c,
                                           Description__c ,
                                           Enabled__c,
                                           CountRulesassociatedtoAdvanceWorkflow__c 
                                   FROM Advance_Workflow__c 
                                   WHERE id =: ruleexecutionplanId];
            if(newruleexecutionplan != null){
                obj = newruleexecutionplan.object__c;
                ruleAssigned = (newruleexecutionplan.CountRulesassociatedtoAdvanceWorkflow__c == null || newruleexecutionplan.CountRulesassociatedtoAdvanceWorkflow__c > 0) ?true:false;
            }
        }
    }
     
    
    /**
    * Save and New Action
    */
    public PageReference saveAndNewRule(){
        newruleexecutionplan.object__c = obj;
        edit = false;
        try{
            upsert newruleexecutionplan;
            newruleexecutionplan = new Advance_Workflow__c();
            return(new PageReference('/apex/AW_Advance_Workflow_VF'));
        }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,e.getDMLMessage(0));
            ApexPages.addMessage(msg);
            return null;
        }
    }
        
    /**
    * Save Action
    */
    public PageReference saveRule(){
        newruleexecutionplan.object__c = obj;
        try{
            upsert newruleexecutionplan;
            return(new PageReference('/'+newruleexecutionplan.id));
        }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,e.getDMLMessage(0));
            ApexPages.addMessage(msg);
            return null;
        }
    }
}