// 
// (c) 2012 Appirio, Inc.
//
//  AW_RuleController	                                                  
//
// This class is used for creating and editing Rule
//
// 31 Aug 2012     Peter Babalis     Original
//  
//
/*
If active---> RO (object, evaluation rule,rule name ,Description,  ), Status can go to archive or Draft  

If Status = Draft (edit=false )---> Status, object, evaluation, Description , rule name  Status can go to  Archive …to activate the rule use the “add rule to workflow”

If Archive ---> RO (object, evaluation rule,rule name  Description,) Status Status can go to Draft  if there is a rule on Draft override the existing rule from archive 

*/
public with sharing class AW_RuleController{
    public Rule__c newrule     {get;set;}  
    public String objType   {get;set;}
    public string SearchEvalRule {get;set;}
    public string SearchStatusRule {get;set;}
    public Integer Version {get;set;}
 //   public string StatusRule {get;set;}
    public string Descr {get;set;}
    public List<SelectOption> objOptions    {get;set;}
   
    public boolean edit {get;set;}
    
    public boolean editrule {get;set;}
    public boolean edistatus {get;set;}
    public boolean editdescr {get;set;}
    public boolean editobject {get;set;}
    public boolean editevalrule {get;set;}
    
     		
    
     
    String ruleId;
    
    public AW_RuleController(Apexpages.StandardController stdcon){
        ruleId = stdcon.getId();
        newrule = new Rule__c();
        objOptions = new List<SelectOption>();
        
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
                 String objLabel = descRes.getLabel();
         /* Start */
        /* Modified by Gaurav Dudani on 9th December 2015 for case # 00142114  */
                if(objAPI.contains(descRes.getName())){
        /* End */
                 objOptions.add(new SelectOption(descRes.getName(),objLabel + ' (' + descRes.getName() + ')'));
               // proposed String objName = descRes.getName();
               // proposed    objOptions.add(new SelectOption(descRes.getLabel(),objLabel + ' (' + descRes.getName() + ')'));
                }
               }
         /* Start */
        /* Modified by Gaurav Dudani on 9th December 2015 for case # 00142114  */
              }
             }
        	} 	
           }
        /* End */
         objOptions.sort();
  
         /* Edit Rule */
       if(ruleId!=null){
            edit=true;
            newrule = [SELECT  name,
                               Object__c,
                               Advance_Workflow__c,
                               Status__c,
                               Version__c,
                               Evaluation_Rule__c,
                               Description__c ,
                               Total_Actions__c,
                               Total_Criteria__c
                       FROM    Rule__c
                       WHERE   id=:ruleId];
            if(newrule!=null){
                objtype=newrule.Object__c;
                Descr =newrule.Description__c;
                Version=integer.valueOf(newrule.Version__c);
                SearchEvalRule =newrule.Evaluation_Rule__c ;
                SearchStatusRule=newrule.Status__c ;
                /*
              If active or archive ---> RO (object, evaluation rule,rule name ,Description,  ), Status can go to archive or Draft  
              
              */ 
               if (SearchStatusRule =='Active' || SearchStatusRule =='Archived') { 
               	    editrule =false; 
                    editdescr=false; 
                    editobject =false;
                    editevalrule=false;
                    edistatus=true;
              }
               
               if (SearchStatusRule =='Draft' && newrule.Total_Criteria__c >0   && newrule.Total_Actions__c >0) { 
               	    editrule =true; 
                    editdescr=true; 
                    editobject =true;
                    editevalrule=true;
                    edistatus=true;
              } else if (SearchStatusRule =='Draft' && ( newrule.Total_Criteria__c ==0  ||  newrule.Total_Actions__c == 0)) { 
               	    editrule =true; 
                    editdescr=true; 
                    editobject =true;
                    editevalrule=true;
                    edistatus=false;
              
              }
              
              }
        } 
        else {
     
              editrule =true; 
              editdescr=true; 
              editobject =true;
              editevalrule=true;
              SearchStatusRule='Draft';
         	  Version=1;
        	   	   
         }
    }
   
   Public List<SelectOption> getStatusRule()  {
  
         List<selectOption> options = new List<selectOption>();
         Schema.DescribeFieldResult field = Rule__c.Status__c.getDescribe();
           /*
            for (Schema.Picklistentry picklistEntry : field.getPicklistValues())
               {
                    options.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
               }    
           */
            // options.add(new selectOption('Draft', 'Draft'));
            //  options.add(new selectOption('Archive', 'Archive'));
            if (SearchStatusRule =='Draft' ) {
            	  options.add(new selectOption('Draft', 'Draft'));
                  options.add(new selectOption('Archived', 'Archived'));
            }
            if (SearchStatusRule =='Active') {
                 options.add(new selectOption('Active', 'Active'));
                 options.add(new selectOption('Draft', 'Draft'));
                 options.add(new selectOption('Archived', 'Archived'));
            }
            if (SearchStatusRule =='Archived') {
            	options.add(new selectOption('Archived', 'Archived'));
                options.add(new selectOption('Draft', 'Draft'));
            }
             return options;  
   }  
  
  Public List<SelectOption> getEvalRule()  {
  
         List<selectOption> options = new List<selectOption>();
            options.add(new selectOption('', '- None -'));
            Schema.DescribeFieldResult field = Rule__c.Evaluation_Rule__c.getDescribe();
            for (Schema.Picklistentry picklistEntry : field.getPicklistValues())
               {
                    options.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
               }
           return options;  
   }  
   
    public PageReference saveRule(){
        newrule.object__c = objtype;
        newrule.Status__c =SearchStatusRule;
        newrule.Evaluation_Rule__c=SearchEvalRule;
        newrule.Description__c= Descr;
        newrule.Version__c= Version;
 
        try{
            Database.upsert(newrule);
          
           if (newrule.Status__c =='Archived' && newrule.Total_Criteria__c> 0 && newrule.Total_Actions__c >0 ) { 
              //Get a reference to the Custom Object and gets its Key
               Schema.DescribeSObjectResult result = Rule__c.sObjectType.getDescribe();
               //system.debug( 'result.getKeyPrefix() '+result.getKeyPrefix());
               PageReference pageRef = New PageReference('/' + result.getKeyPrefix() + '/o');
               pageRef.setRedirect(true);
               return pageRef;        
           }
           else  return(new PageReference('/'+newrule.id ));
          }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,e.getDMLMessage(0));
            ApexPages.addMessage(msg);
            return null;
        }
        
    }
    
    public PageReference saveAndNewRule(){
         newrule.object__c = objtype;
         newrule.Evaluation_Rule__c=SearchEvalRule;
         newrule.Description__c= Descr;
         newrule.status__c ='Draft';
         newrule.Version__c= 1;
         //editrule =false; 
         //editdescr=false; 
        // editobject =false;
        // editevalrule=false;
         edit=true;
        try{
            Database.upsert(newrule);
            newrule = new Rule__c();
            return(new PageReference('/apex/AW_Rule_VF'));
        }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.Error,e.getDMLMessage(0));
            ApexPages.addMessage(msg);
            return null;
        }
        
    }    
    
    
}