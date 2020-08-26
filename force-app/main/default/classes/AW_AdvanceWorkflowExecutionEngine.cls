// 
// (c) 2012 Appirio, Inc.
// AW_AdvanceWorkflowExecutionEngine                                                     
// This class is used to process rules assigned to an execution plan 
// and performs the associated actions
//
// 18 Nov 2012     Peter Babalis     Original
// 07 Feb 2013     Peter Babalis     Executes Cross field Objects and Tasks and email Templates
// 10 May 2013     Peter Babalis     IsChangedFrom To
// 10 May 2013     Peter Babalis     IsChanged
// 25 May 2013     Peter Babalis     Http Call outs
// 25 May 2013     Peter Babalis     Apex Class Execution  
// 01 Jun 2013     Peter Babalis     String & Date Functions as Actions 
// 05 Jun 2013     Peter Babalis     Send Email To Distribution List
//
//  
global class AW_AdvanceWorkflowExecutionEngine{ 
    
    //required to stop the trigger to start
    global static Boolean EvaluationIsRunning=false;
    
    //stores the fields that needs to be quired
    private static Map<String,Set<String>> criteriaFields;  
    
    //field map of the object
    public static Map<String,Map<String,Schema.SObjectField>> fieldMap;
    
    //store the global describe result
    private static Map<String, Schema.SObjectType> gd = new Map<String, Schema.SObjectType>();
     
    //store all the relationships names
    private static Map<String,String> relationshipNames = new Map<String,String>();
    
    //store the valid relationship names in the object
    private static Map<String,Set<String>> validRelationShips= new Map<String,Set<String>>();
    
    //store the rule Id for Record is created or edited and did not previously meet the rule criteria
    static Map<Id,Set<Id>> rulesExecuted = new Map<Id,Set<Id>>();
        
    /**
    * Added Below variables by Cloud Challenger
    */
    // External salesforce url
    private static string sfURL = URL.getSalesforceBaseUrl().toExternalForm();    
    
    // Map of Object API Name and Label
    private static Map<String,String> objectLabels = new Map<String,String>();
    
    // Child object to be inserted
    private static List<SObject> childObjectList = new List<SObject>();
    
    // Map of Rule Action Id and Insert Related Record Info object as child 
    private static Map<Id,RuleAction__c> insertedRelatedRecordInfo = new Map<Id,RuleAction__c>();
    
    // Map of child relationship name and field in child for parent
    private static Map<String,String> childParentRelationshipField = new Map<string,String>();
    
    
    private static Map<Id,SObject> toUpdateSObject;
    private static List<Object_Action_Execution__c> bulkObjectUpdates= new List<Object_Action_Execution__c>();
    
    // Boolean to notify user 
    private static boolean notifyUser = false; 
    private static String concatop='&';
    private static String templateId;    
    
    
    /*this variable handles bulk operation for actions:- */
    public static Boolean bulkOperation;
    public static Set<Id> bulkactionIds;
    
    
    /** added this variable to hold the oldRecords in case of update **/
    //public static List<Sobject> oldSobjectList = new List<Sobject>();
    public static  Map<Id,SObject> oldListMap = new Map<Id,SObject>();
    public static Boolean isUpdate=false;
    
    
    //@added on 31 may
    static RuleAction__c actionInContext;
    Static user userInContext;
     //adding a new variable that will store all the rules that are valid for onclick event as they have to displayes     
    public static List<Rule__c> displayClickEventValidRules = new List<Rule__c>(); 
    
    /**
    * this method starts the processing engine for evaluation the rules
    * params : 
    * recordIds : ids of the object records that needs to be evaluated 
    * sobjectName : object(Account,Contact)
    * action : update/insert 
    
    **** Updating the method to fix the issue of evaluation rule criteria ***
     
  
    */
    //@future
    global static void startRulesProcessing(Set<Id> recordIds,String sobjectName,Boolean isInsert){
        bulkOperation =false;
        isUpdate = !isInsert;
        // get the rules get all types of rules
        String query ='Select Id,Evaluation_Rule__c,Object__c FROM Rule__c WHERE Object__c=\''+sobjectName+'\' AND Status__c=\'Active\' AND Evaluation_Rule__c!=\'On Click Event\'  ';
        
        if(!isInsert){
            query+=' AND Evaluation_Rule__c!=\'Record is created\'';
        }
        /**
        * CC: Added filter for execution plan
        */
        query += ' AND Advance_Workflow__c in (SELECT id from Advance_Workflow__c where object__c = \''+sobjectName+'\' and Enabled__c = true)';
        
        //list of rules
        List<Rule__c> rules = database.query(query);
        if(rules.size()==0) return;
        
        Set<String> executedIds = new Set<String>(); 
        //get the history need later to check whether the rule needs to be evaluated or not
        for(Rule_Execution_History__c h : [SELECT Rule_ID__c,Rule__c,
                                                  Record_ID__c 
                                           FROM   Rule_Execution_History__c 
                                           WHERE Record_ID__c IN:recordIds])
                                           {               
                                              
            Set<Id> ruleIds = rulesExecuted.get(h.Record_ID__c)!=null ? rulesExecuted.get(h.Record_ID__c): new Set<Id>();
            ruleIds.add(h.Rule__c);
            rulesExecuted.put(h.Record_ID__c,ruleIds);
        }
         
         Set<Id> processRules = new Set<Id>();
        //now there is a condition :-
        for(Rule__c r :rules ){
            processRules.add(r.Id); 
        }
        //start
        system.debug('Start of execution');
        evaluateRules(processRules,recordIds,sobjectName);
    }
    
    /**
    * this method starts the processing engine for evaluation the rules  for click events  
    */
    global static void startRulesProcessingOnClick(Set<Id> recordIds,String sobjectName){
        
        bulkOperation =false;
        
        // get the rules get all types of rules
        String query ='Select Id,Evaluation_Rule__c,Object__c FROM Rule__c WHERE Object__c=\''+sobjectName+'\' AND Status__c=\'Active\' ';                
        query+=' AND Evaluation_Rule__c=\'On Click Event\'';
        
        /**
        * CC: Added filter for execution plan
        */
        query += ' AND Advance_Workflow__c in (SELECT id from Advance_Workflow__c where object__c = \''+sobjectName+'\' and Enabled__c = true)';
        
        //list of rules
        List<Rule__c> rules = database.query(query);
        if(rules.size()==0) return;
        
        Set<Id> processRules = new Set<Id>();
        //now there is a condition :-
        for(Rule__c r :rules ){
            processRules.add(r.Id); 
        }
        //start
        system.debug('Start of execution On Click Event');
        evaluateRules(processRules,recordIds,sobjectName);
    }

    /**
    * this method given a set of rules ids will evaluate the object records for
    * criteria ,if the record matches the criteria then it will perform the associated action
    * with that rule
    
    *** Updated the method to fix issue of evalution rule ***
    
    */
    public static void evaluateRules(Set<Id> ruleIds,Set<Id> recordIds,String sobjectName){
          
        AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap = new Map<String,Map<String,List<RuleAction__c>>>();
          
        //first thing is to check if the rule ids exist (just a validation)
        
        if(ruleIds.size()==0) return; //nothing to process :) 
        userInContext =[Select Id,Name,Profile.Name,UserRole.Name FROM User WHERE Id=:UserInfo.getUserId()];
      
            try{
                //get the list of criteria for the given set of rule Ids:-
                List<Rule__c> rules = AW_AdvanceWorkflowExecutionHelper.getActiveCriteria(ruleIds,sobjectName);
                  
                EvaluationIsRunning = true; 
                                                              
                List<Rule__c> lstValidRules = getValidRules(rules,sobjectName);
                system.debug('---->lstValidRules:' + lstValidRules);
                system.debug('---->criteriaFields:' + criteriaFields);
                if(criteriaFields.size() == 0){
                    return;
                }
                
                //update : if bulk get subset of actions
                Map<Id,Rule__c> ruleActions = bulkOperation ? AW_AdvanceWorkflowExecutionHelper.getActiveRuleActionsSubset(ruleIds,sobjectName,bulkactionIds) : AW_AdvanceWorkflowExecutionHelper.getActiveRuleActions(ruleIds,sobjectName);  
                system.debug('---->ruleActions:' + ruleActions);
                /**
                * By Cloud Challenger
                * Get all the insert related record info of rule
                */
                insertedRelatedRecordInfo = bulkOperation ? AW_AdvanceWorkflowExecutionHelper.getInsertRelatedRecordInfoForActions(bulkactionIds): AW_AdvanceWorkflowExecutionHelper.getInsertRelatedRecordInfo(ruleIds);
              
                /** 
                * here the logic is now encapsulated in a method
                * the method first add the valid fields to be updated in the criteria field list
                * also check if the value is a valid object field/reference field so that you cann
                * add it to list to query
                */
                
                system.debug('---->ruleActions.values():' + ruleActions.values());
                system.debug('---->rsobjectName ' + sobjectName);
                
                getValidActions(ruleActions.values(),sobjectName);
             
                Set<String> parentFields = criteriaFields.get(sobjectName.toLowerCase());      
                system.debug('---->parentFields:' + parentFields);
                
                String fields = AW_AdvanceWorkflowExecutionHelper.joinSet(parentFields,',');
                 system.debug('---->from joinSet fields:' + fields);
                if(fields!=null && fields.trim()!='') fields= fields+',';
                String qrySOQL='SELECT ' + fields +' Id ';
                
                //now add the child queries also as they need to be evaluated in the query :)
                for(String obj:criteriaFields.keySet()){
                    if(obj.equalsIgnoreCase(sobjectName)) continue;
                    fields =AW_AdvanceWorkflowExecutionHelper.joinSet(criteriaFields.get(obj),',');
                    qrySOQL+=' , (SELECT ' + fields +',Id FROM '+relationshipNames.get(obj)+')';                        
                }
              
                qrySOQL+=' FROM '+sobjectName+' WHERE Id IN : recordIds';
                system.debug('--->qrySOQL:' + qrySOQL);
                system.debug('--->recordIds:' + recordIds);
                List<SObject> sobjectRecords = database.query(qrySOQL);     
                system.debug('--->sobjectRecords:' + sobjectRecords);
                
                toUpdateSObject= new Map<Id,SObject>();
                Map<String,List<SObject>> toUpdateChildObjects = new Map<String,List<SObject>>();
                Map<Id,List<SObject>> validRecords= new Map<Id,List<SObject>>();
                 
                /* defining variables to handle the send email action */
                //Map<String,Map<String,List<String>>> usersInSendEmailAction =new Map<String,Map<String,List<String>>> ();
                //Map<String,Map<String,List<String>>> grpsInSendEmailAction = new Map<String,Map<String,List<String>>> ();
                
                Map<String,Map<String,List<RuleAction__c>>> usersInSendEmailAction =new Map<String,Map<String,List<RuleAction__c>>> ();
                Map<String,Map<String,List<RuleAction__c>>> grpsInSendEmailAction = new Map<String,Map<String,List<RuleAction__c>>> ();
                
                
                //Map<String,Map<SObject,List<String>>> apexClasses = new Map<String,Map<SObject,List<String>>>();
                

                        
                /**
                * Instead of iterating to the map, iterate to the list just to maintain the order of rules
                */
                for(Rule__c rule : lstValidRules){
                    
                    
                    Rule__c r = ruleActions.get(rule.Id);
                    system.debug('r--->'+r);
                    if(r.Rule_Actions__r.size()==0) continue;
                  
                    //for every sobject record that matched the rule we need to apply the action
                    List<RuleAction__c> actions= r.Rule_Actions__r;
                    boolean isValidCriteria = false;
                    
                             
                    
                    for(SObject o:sobjectRecords) {
                         system.debug('o--->'+o);
                        //if(rule.Evaluation_Rule__c.equals('Record is created or edited and did not previously meet the rule criteria')){
                            //if(rulesExecuted.get(o.Id)!=null &&  rulesExecuted.get(o.Id).contains(rule.Id)){
                            //    continue;
                            //}
                            
                            //we will use thsi block later of new evaluation :Record created/edited rule triggered once when criteria met
                            
                        //}
                        system.debug('---Record---'+o);
                         system.debug('Have Criteria for Rule Met '+ isValidCriteria);

                        isValidCriteria = bulkOperation ? true : evaluateSingleRule(rule,o,sobjectName);
                        system.debug('Have Criteria for Rule Met '+ isValidCriteria);
                        
                      
                        if(isValidCriteria)
                        {                        	
                        	/* adding a block for click event handling */
                        	if(rule.Evaluation_Rule__c.equalsIgnoreCase('On Click Event')){
                        		displayClickEventValidRules.add(r);
                        		break;
                        	}
                        	
                            List<SObject> matched = validRecords.get(rule.Id)!=null ? validRecords.get(rule.Id) :new List<SObject>();
                            matched.add(o);
                            //store the objects that passed this rule -
                            validRecords.put(rule.Id,matched);
                            for(RuleAction__c action : actions){
                                String actionObject = action.Related_Object__c.toLowerCase();
                                notifyUser = action.Notify_User__c;
                                templateId=action.Email_Template__c;
                                system.debug('action obj-->'+actionObject);
                                actionInContext = action; 
                               if(action.Type__c == 'Send Email'){ 
                                    //sending email :-
                                    Id sendTo = action.User_Owner_Id__c !=null ? Id.valueof(action.User_Owner_Id__c):UserInfo.getUserId();
                                    //now that we have the user ids that need to be sent email:-
                                    
                                    if(sendTo.getSObjectType() == User.SobjectType ){
                                        //usersInSendEmailAction=AW_AdvanceWorkflowExecutionHelper.buildListForEmail(usersInSendEmailAction,sendTo,templateId,o.Id);
                                        usersInSendEmailAction=AW_AdvanceWorkflowExecutionHelper.buildListForEmail(usersInSendEmailAction,sendTo,action,o.Id);
                                    }else if(sendTo.getSObjectType() == Group.SobjectType){
                                        //grpsInSendEmailAction=AW_AdvanceWorkflowExecutionHelper.buildListForEmail(grpsInSendEmailAction,sendTo,templateId,o.Id);
                                        grpsInSendEmailAction=AW_AdvanceWorkflowExecutionHelper.buildListForEmail(grpsInSendEmailAction,sendTo,action,o.Id);
                                    }
                                    
                                    //If the action has additional emails that need to be sent
                                    
                                }else if(action.Type__c.equalsIgnoreCase('Execute an Apex Job')){
                                        //execute apex class:- instantiate a class
                                        Type t = Type.forName(action.Apex_job_Class__c);
                                        AW_RuleActionInterface job = (AW_RuleActionInterface)t.newInstance();
                                        
                                        //get the input parameter map:-
                                        Map<String,String> inputParams = apex_execution_params(action,action.input_parameters__c,o);
                                        Map<String,String> outputParams = job.runAction(inputParams);
                                         
                                        //here finally dump the result of execution :-
                                        apex_execution_outputupdate(action,outputParams,o);
                                        continue;
                                } 
                                else if(action.Type__c.equalsIgnoreCase('Apex Callout-HTTP') && !Test.isRunningTest()){                                  
                                    //set up http call out:
                                    if(bulkOperation ){ 
                                         Map<String,String> inputParams = AW_AdvanceWorkflowExecutionEngine.apex_execution_params(action,action.input_parameters__c,o);
                                          //call helper method to do the callout:-
                                         AW_AdvanceWorkflowHTTPHandler httpHandle = new AW_AdvanceWorkflowHTTPHandler();
                                         Map<String,String> outputParams = httpHandle.doHTTPCallout(action,inputParams); 
                                         AW_AdvanceWorkflowExecutionEngine.apex_execution_outputupdate(action,outputParams,o); 
                                    }else 
                                    AW_AdvanceWorkflowHTTPHandler.setHTTPCallout(action.id,o.Id);   
                                }                                
                                else if(relationshipNames.get(actionObject)!= null || action.Type__c == 'Insert Related Object'  ){
                                //if(relationshipNames.get(actionObject)!= null || (actionObject.equalsIgnoreCase('task') && action.Type__c == 'Insert Related Object' ) ){
                                // if(relationshipNames.get(actionObject)!= null && !actionObject.equalsIgnoreCase(sobjectName) ){
                                    // code is moved inside condition by cloud challenger
                                    if(action.Type__c == 'Update Field'){ 
                                        //itz a action on the child object:-
                                        SObject[] childRecordsFromParent = toUpdateChildObjects.get(actionObject)!=null? toUpdateChildObjects.get(actionObject):o.getSObjects(relationshipNames.get(actionObject)); //child object
                                        if(childRecordsFromParent!=null){                                       
                                            for (Integer i=0;i<childRecordsFromParent.size();i++){ 
                                                childRecordsFromParent[i] = applyActions(action,childRecordsFromParent[i]); 
                                                toUpdateSObject.put(childRecordsFromParent[i].Id,childRecordsFromParent[i]);                                
                                            }
                                             system.debug('-->childRecordsFromParent'+childRecordsFromParent);
                                             toUpdateChildObjects.put(actionObject,childRecordsFromParent);
                                             system.debug('-->toUpdateChildObjects '+toUpdateChildObjects);
                                             system.debug('-->toUpdateSObject '+toUpdateSObject);
                                            
                                        }
                                    } 
                                   
                                    /**
                                    * By Cloud Challenger
                                    * Below Code apply related record info on child
                                    */
                                    else if(action.Type__c == 'Insert Related Object' ){
                                        
                                        if(action.Bulk_Api__c && !bulkOperation){
                                            bulkObjectUpdates.add(new Object_Action_Execution__c(Action__c=action.Id,Status__c='New',Value__c='',Type__c='Bulk API'));
                                            continue;
                                        }
                                        
                                        system.debug(childParentRelationshipField+'--'+action.Related_Object__c.tolowerCase());
                                        String parentFieldName = childParentRelationshipField.get(action.Related_Object__c.tolowerCase());
                                        /**
                                        * Dynamically create child instance
                                        */
                                        Type t = Type.forName(action.Related_Object__c);
                                        SOBject newObj = (SObject)t.newInstance();
                                        system.debug(action.Related_Object__c+'--'+parentFieldName+' -- '+o.Id+' --- '+newObj);
                                        /**
                                        * Populate parentField on Child
                                        */
                                        if(action.Related_Object__c.tolowerCase()=='task'){
                                            if(o.Id.getSObjectType() == User.SobjectType){
                                                parentFieldName='OwnerId';
                                            }else  if(o.Id.getSObjectType() == Contact.SobjectType || o.Id.getSObjectType() == Lead.SobjectType){
                                                parentFieldName='WhoId';
                                            }
                                            if(o.Id.getSObjectType() == Contact.SobjectType || o.Id.getSObjectType() == Lead.SobjectType){
                                                parentFieldName='WhatId';
                                            }
                                        }
                                        if (parentFieldName!= null ) newObj = updateField(action.Related_Object__c,parentFieldName,o.Id,newObj);
                                        /**
                                        * Apply rest of the fields
                                        */
                                        childObjectList.add(applyInsertChildActions(action,newObj,o));
                                    }
                                   
                                }//end if                                
                                else{
                                    o = applyActions(action,o);
                                }
                             }//end for  
                            toUpdateSObject.put(o.Id,o);
                            system.debug('--> toUpdateSObject '+ toUpdateSObject);
                        }
                    }
                    /**
                    * CC: if execution behavour is exit then exit from loop
                    */  
                    if(rule.Execution_Behavior__c == 'Execute Rule and Exit'  && isValidCriteria){
                        break;
                    }
                }           


                          
               // update toUpdateSObject.values();
              
                // Start By Cloud Challenger
                /**
                * Insert child records
                */ 
                //insert childObjectList;
                 
                 /** Update Records and Insert child records */ 
               system.debug('-->before AW_AdvanceWorkflowTransactionProcessing toUpdateSObject'+toUpdateSObject);
                boolean processstatus= AW_AdvanceWorkflowTransactionProcessing.performDMLOperations(toUpdateSObject,childObjectList );
                
                /** Insert records for lookupObjectProcessing & bulk processing **/
                if(bulkObjectUpdates.size()>0 && !bulkOperation)
                     AW_AdvanceWorkflowTransactionProcessing.processLookupUpdatesAndBulkAPi(bulkObjectUpdates);
                
                //finally add that these records are processed in a history object
                processstatus= AW_AdvanceWorkflowTransactionProcessing.addRecordstoExecutionHistory(validRecords);
               
                if(AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap!=null && AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.size()>0){
                         Map<Id,User> userDetails = AW_AdvanceWorkflowExecutionHelper.getUserDetails(AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.keySet());
                         new AW_SendEmailUtil().sendEmail(userDetails ,AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap);
               }
                 
               if(grpsInSendEmailAction!=null & grpsInSendEmailAction.size()>0){
                    //get the list of users in that group:-
                    List<Group> grps =[Select Id,(Select UserOrGroupId FROM GroupMembers) FROM Group WHERE Id IN:grpsInSendEmailAction.keySet()];
                    
                    for(Group g:grps){
                         for(GroupMember gm:g.GroupMembers){
                                for( String objId : grpsInSendEmailAction.get(g.Id).keySet()){
                                        
                                       for(RuleAction__c template :  grpsInSendEmailAction.get(g.Id).get(objId)){
                                            usersInSendEmailAction= AW_AdvanceWorkflowExecutionHelper.buildListForEmail(usersInSendEmailAction, gm.UserOrGroupId, template,objId);
                                       }  
                                        
                                }
                         }
                    }
                    
               }
               
               //finally sending emails :-
               if(usersInSendEmailAction!=null &&   usersInSendEmailAction.size()>0){
                      Map<Id,User> userDetails = AW_AdvanceWorkflowExecutionHelper.getUserDetails(usersInSendEmailAction.keySet());
                      new AW_SendEmailUtil().sendEmail(userDetails ,usersInSendEmailAction);
               }                             
                
            }//end try
             catch(Exception e){
                system.debug(e);
                String msg = string.valueOf(e);
                List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
                AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowExecutionHelper.cls','isvalid','AW_AdvanceWorkflowExecutionEngine.cls','evaluateRules','Advance_Workflow__c');
                 
            } 
            EvaluationIsRunning=false;//once everything is done mark false          
        }        
        
        /**
        * this method checks that rules are valid before executing them
        */
        private static List<Rule__c> getValidRules(List<Rule__c> rules ,String sobjectName){
             
            gd = Schema.getGlobalDescribe(); 
             
            Schema.DescribeSObjectResult R =gd.get(sobjectName).getDescribe();
             
            objectLabels.put(sobjectName,R.getLabel());
             
            //check which of these criteria are valid which needs to be ignored
            fieldMap = new Map<String,Map<String,Schema.SObjectField>>();
            fieldMap.put(sobjectName.toLowerCase(),R.fields.getMap());
             
            /* Rules can have criteria from its related object also */
            Set<String> objectDefinedInCriteria = new Set<String>();
            for (Integer i=0;i<rules.size();i++){
                for(RuleCriteria__c criteria : rules[i].Rule_Criteria__r){
                    if(!objectDefinedInCriteria.contains(criteria.Related_Object__c.toLowerCase())){
                        objectDefinedInCriteria.add(criteria.Related_Object__c.toLowerCase());      
                    }
                } 
            }
           
            /* get all the related child objects for this object of the rule */
            for(Schema.ChildRelationship child: R.getChildRelationships()){
                Schema.DescribeSObjectResult descRes = child.getChildSObject().getDescribe();
                String objname =descRes.getName().toLowerCase();
                if(objname.equalsIgnoreCase(sobjectName))continue;
                if(objectDefinedInCriteria.contains(objname)){     
                    relationshipNames.put(objname,child.getRelationshipName());
                    fieldMap.put(objname,descRes.fields.getMap());
                }
            }
            criteriaFields = new Map<String,Set<String>>();
            Boolean isValid=true;
             
            //Map<Id,Rule__c> validRules = new Map<Id,Rule__c>();
            List<Rule__c> lstValidRules = new List<Rule__c>();
             
            /* ow starts the validation process*/
            for (Integer i=0;i<rules.size();i++){
                //under that rule check for criteria :-   
                isValid = true; 
                /**
                * all the field defined in the criteria are now checked that they
                * are valid fields either the field belongs to the parent field
                * or child objects
                * Also here we will then build the list of the fields 
                * that are involved
                */         
                for(RuleCriteria__c criteria : rules[i].Rule_Criteria__r){
                    /*Map<String,Schema.SObjectField> fieldList = fieldMap.get(criteria.Related_Object__c.toLowerCase());
                    if(fieldList!=null && (fieldList.containsKey(criteria.Field_API_Name__c)==true ||  fieldMap.containsKey(criteria.Field_API_Name__c.toLowerCase())==true)){
                        Set<String> fieldToAdd = criteriaFields.get(criteria.Related_Object__c.toLowerCase())!=null ? criteriaFields.get(criteria.Related_Object__c.toLowerCase()): new Set<String>(); 
                        fieldToAdd.add(criteria.Field_API_Name__c.toLowerCase());
                        criteriaFields.put(criteria.Related_Object__c.toLowerCase(),fieldToAdd);
                    }
                    else {                                                                     
                        isValid=false;//remove the rule if that field name isn't a valid field on sobject
                        break;
                    } */
                    
                    Map<String,Schema.SObjectField> fieldList = fieldMap.get(criteria.Related_Object__c.toLowerCase());
                     if(fieldList!=null){
                         Set<String> fieldToAdd = criteriaFields.get(criteria.Related_Object__c.toLowerCase())!=null ? criteriaFields.get(criteria.Related_Object__c.toLowerCase()): new Set<String>(); 
                         if(criteria.Field_API_Name__c.toLowerCase() =='crossformula') fieldToAdd.add(criteria.CrossFormula__c.toLowerCase());
                         else if(criteria.Field_API_Name__c.startsWithIgnoreCase('globalvariable-')){}                       
                         else if(fieldList.containsKey(criteria.Field_API_Name__c)==true ||  fieldMap.containsKey(criteria.Field_API_Name__c.toLowerCase())==true) fieldToAdd.add(criteria.Field_API_Name__c.toLowerCase());
                         else {
                             isValid=false;//remove the rule if that field name isn't a valid field on sobject
                             break;
                         }
                         criteriaFields.put(criteria.Related_Object__c.toLowerCase(),fieldToAdd);
                     }else {                                                                     
                        isValid=false;//remove the rule if that field name isn't a valid field on sobject
                        break;
                    }    
                                  
                }//end of criteria loop
                if (isValid){
                    lstValidRules.add(rules[i]);
                }
            }
            return  lstValidRules;
        }
        
        /**
        * @added by SH 1/10/2012
        * method that will initialize valid action fields so that we can add it
        * in field list that will be queried
        */
        public static void getValidActions(List<Rule__c> rules ,String sobjectName){
            Schema.DescribeSObjectResult R =gd.get(sobjectName).getDescribe();
              
            /**
            * set all the object on which the action has been defined
            */
            Set<String> objectDefinedInAction = new Set<String>();
            for (Integer i=0;i<rules.size();i++){
                for(RuleAction__c action : rules[i].Rule_Actions__r){
                    if(!objectDefinedInAction.contains(action.Related_Object__c.toLowerCase())){
                        objectDefinedInAction.add(action.Related_Object__c.toLowerCase());      
                    }                       
                } 
            }
            
            /**
            * the objects that are defined in the criteria a valid child relation ships
            */
            for(Schema.ChildRelationship child: R.getChildRelationships()){
                Schema.DescribeSObjectResult descRes = child.getChildSObject().getDescribe();
                String objname =descRes.getName().toLowerCase();
                /**
                * Below line by Cloud Challenger
                * This populated parent field name in childParentRelationshipField Map
                */                  
                childParentRelationshipField.put(objname,child.getField().getDescribe().getName());
                /**
                * if the object is object defined in action process the next steps
                */
                if(objectDefinedInAction.contains(objname) && fieldMap.get(objname)==null){     
                    
                    //add the field in relationship map
                    relationshipNames.put(objname,child.getRelationshipName());   

                    //get the fields in the list
                    Map<String,Schema.SObjectField> fieldList = descRes.fields.getMap();            
                    fieldMap.put(objname,fieldList);

                    /**
                    * for all the valid fields in the child object
                    * check if it has a relation ship name if yes then add it for future use
                    */
                    for(String f: fieldList.keySet()){
                        Schema.DescribeFieldResult FR =fieldList.get(f).getDescribe();
                        system.debug('getRelationshipName-->'+FR.getRelationshipName());
                        if(FR.getRelationshipName()!=null){
                            Set<String> validRN = validRelationShips.get(objname.toLowerCase())!=null ? validRelationShips.get(objname.toLowerCase()): new Set<String>();
                            validRN.add(FR.getRelationshipName());
                            validRelationShips.put(objname.toLowerCase(),validRN);
                        }
                    }
                }
            }
            //add this rule fields also to criteria field set as they need to be updated
            for(Rule__c rule : rules){
                System.debug('rules>>> '+rules);
               
                for(RuleAction__c action : rule.Rule_Actions__r){
                    if(action.Type__c=='Update Field'){
                        configureUpdateFieldAction(action);                     
                    }//end  action.Type__c=='Update Field'
                    else if(action.Type__c == 'Insert Related Object'){
                        /**
                        * By Cloud Challenger
                        * Below code iterate to Values_for_Action_Insert_Record__c records to get reference field for query
                        */
                        configureInsertRelatedObjectAction(rule,action);
                    }// end action.Type__c == 'Insert Related Object'
                    if(action.Type__c=='Execute An Apex Job' || action.Type__c=='Apex Callout-HTTP'){
                        configureJobAction(action);                     
                    }//end  action.Type__c=='Execute An Apex Job'
                }//end action
            }//end rule
            
        }//end method
        
        private static String getValueForUpdateAction(RuleAction__c action){
            /**
              * For Long Text Area
              */
              String value=null;
              if(action.Field_Type__c == 'REFERENCE' && action.Reference_Id__c != null && action.Reference_Id__c != ''){
                  value = action.Reference_Id__c;
              }
              else if(action.Value__c == null && action.Long_Value__c != null){
                  value = action.Long_Value__c;
              }
              else{
                  value = action.value__c;
              }
              
              return value ;
        }
          
        /* 
          helper method added to get the field from value
        */  
        
        private static String fetchFieldFromString(RuleAction__c action,String value){
                if(value!=null){
                    String value1= value.toLowerCase();
                    if(value1.startswith('left(')){
                        //return value1.substringBetween('left(',',');
                        return fetchFieldFromString(action,value1.substringBetween('left(',','));
                    }
                    else if(value1.startswith('right(')){
                        //return value1.substringBetween('right(',',');
                        return fetchFieldFromString(action,value1.substringBetween('right(',','));
                    }else if(value1.startswith('mid(')){
                        //return value1.substringBetween('mid(',',');
                        return fetchFieldFromString(action,value1.substringBetween('mid(',','));
                    }
                }
                
                if(value!=null && (value.contains(concatop) || value.startsWith('{!'))){
                    List<String> splitVaue = value.split(concatop);
                    List<String>  mergeFields = new List<STring>();
                    for(String s:splitVaue){
                        s=s.trim();
                        if(s.startsWith('{!')){
                            String mergeField= s.substringBetween('{!','}');
                            mergeFields.add( mergeField.toLowerCase());
                        }
                    }
                    return String.join(mergeFields,',');
                }else
                //that means we are trying to reference
                if(value != null && value.contains('.')){
                    //then validate:- as we can have . in value field as well for www.koncero.com could be a value
                    List<String> splitReference = value.split('\\.');
                    Set<String> validRN = validRelationShips.get(action.Related_Object__c.toLowerCase())!=null ? validRelationShips.get(action.Related_Object__c.toLowerCase()): new Set<String>();
                    if(validRN.contains(splitReference[0])){
                        return value.toLowerCase();
                    }
                } 
                
                return null;
        }
        
        private static void configureUpdateFieldAction(RuleAction__c action){
                Set<String> fieldToAdd = criteriaFields.get(action.Related_Object__c.toLowerCase())!=null ? criteriaFields.get(action.Related_Object__c.toLowerCase()): new Set<String>(); 
                
                system.debug('-->1 configureUpdateFieldAction.fieldToAdd -->'+fieldToAdd );
                              
                //modifying for crossobject
                if(action.Field_Name__c!='LookupObjectField'){
                    String fieldToUpdate = action.Field_Name__c=='CrossObject' ? action.CrossObjectField__c: action.Field_Name__c.toLowerCase();
                
                     system.debug('-->2 configureUpdateFieldAction.fieldToUpdate -->'+fieldToUpdate );
                   
                     system.debug('-->3 configureUpdateFieldAction.fieldToUpdate -->'+fieldToUpdate.toLowerCase() );
                   
                    if(!fieldToAdd.contains(fieldToUpdate.toLowerCase())){
                        fieldToAdd.add(fieldToUpdate);
                    }
                   system.debug('-->4 configureUpdateFieldAction.fieldToAdd -->'+fieldToAdd );
                
                }    
                // now modify the section of code here:-
                String value = getValueForUpdateAction(action);
                
                  
                Map<String,Schema.SObjectField> fieldList = fieldMap.get(action.Related_Object__c.toLowerCase());
                
                if(value != null && fieldList!= null && (fieldList.containsKey(value)==true ||  fieldMap.containsKey(value.toLowerCase())==true)){
                    fieldToAdd.add(value.toLowerCase());        
                }else{
                    String field = fetchFieldFromString(action,value);
                    
                  
                    //adding an additional line to avaoid errors                    
                    if(field!=null){
                    		List<String> fieldelements = field.split('\\.'); 
                   //          system.debug('-->configureUpdateFieldAction.fieldelements -->'+fieldelements );
                   //         system.debug('-->configureUpdateFieldAction.fieldelements[0] -->'+fieldelements[0] );
                   //         system.debug('-->configureUpdateFieldAction.fieldelements[1] -->'+fieldelements[1] );
                              
                    	 for(String fld : field.split(','))
                    	   		if(!fieldToAdd.contains(fld.toLowerCase()))
                    	   			fieldToAdd.add(fld.toLowerCase());
                    }
                }
                
                //finally add the fields back
                criteriaFields.put(action.Related_Object__c.toLowerCase(),fieldToAdd);   
        }
        
   
        private static void configureJobAction(RuleAction__c action){
            Set<String> fieldToAdd = criteriaFields.get(action.Related_Object__c.toLowerCase())!=null ? criteriaFields.get(action.Related_Object__c.toLowerCase()): new Set<String>(); 
            
            if(action.Input_Parameters__c!=null){
                List<String> input = action.Input_Parameters__c!=null? action.Input_Parameters__c.split(','):new List<String>();
                for(String pair : input){
                    List<String> keyValue = pair.split(':');
                    if(!fieldToAdd.contains(keyValue[1]) && !fieldToAdd.contains(keyValue[1].toLowerCase()))
                        fieldToAdd.add(keyValue[1].toLowerCase());
                }
            }
            
            if(action.output_Parameters__c!=null){
                List<String> output = action.output_Parameters__c!=null? action.output_Parameters__c.split(','):new List<String>();
                for(String pair : output){
                    List<String> keyValue = pair.split(':');
                    if(!fieldToAdd.contains(keyValue[1]) && !fieldToAdd.contains(keyValue[1].toLowerCase()))
                        fieldToAdd.add(keyValue[1].toLowerCase());
                }
            }
            //finally add the fields back
            criteriaFields.put(action.Related_Object__c.toLowerCase(),fieldToAdd);   
                    
        }
        
    
        
         private static void configureInsertRelatedObjectAction(Rule__c rule,RuleAction__c action){
                if(insertedRelatedRecordInfo.containsKey(action.Id)){
                  for(Values_for_Action_Insert_Record__c info: insertedRelatedRecordInfo.get(action.Id).Values_for_Action_Insert_Record__r){
                      
                      /**
                      * if reference then add field to parent object
                      */
                      Set<String> fieldToAdd = criteriaFields.get(rule.Object__c.toLowerCase())!=null ? criteriaFields.get(rule.Object__c.toLowerCase()): new Set<String>();
                      
                        //  system.debug('--> configureInsertRelatedObjectAction fieldToAdd   '+fieldToAdd);
                       
                        //adding merge fields in value evaluation
                       String field = fetchFieldFromString(action,info.Value__c); 
	                       system.debug('--> field from fetchFieldFromString '+field);
                        if(field!=null){
                        	 
                        	List<String> fieldelements = field.split('\\.'); 
                          /*  system.debug('fieldelements -->'+fieldelements );
                            system.debug('fieldelements[0] -->'+fieldelements[0] );
                            system.debug('fieldelements[1] -->'+fieldelements[1] );
                            system.debug('rule.Object__c.toLowerCase() -->'+rule.Object__c.toLowerCase() );
                            */ 
                                  
                      	     for(String fld : field.split(',')){
                    	     	if  (fieldelements.size()>1 ){
                    	   	         if ( (fieldToAdd.contains(fieldelements[1])) &&(rule.Object__c.toLowerCase()== fieldelements[0]) )
                                      fieldToAdd.remove(fieldelements[1]);
                    	     	 }
                                if(!fieldToAdd.contains(fld.toLowerCase()))
                    	   			fieldToAdd.add(fld.toLowerCase());
                    	   	      
                    	     }
                    	  //    system.debug('fieldToAdd -->'+fieldToAdd );
                              	
                    	     
                         }
                  }
              }
        }
                
        /*
          this method evaluates a single rule on the object
        */
        private static Boolean evaluateSingleRule(Rule__c rule,SObject obj,string sobjectName){
             
            //IN MAP STORE THE BOOLEAN RESULT
            Map<Integer,Integer> evaluationResult= new Map<Integer,Integer>();
            Integer i=1;
            //system.debug('--->'+obj);
            Boolean evaluateRule = true;
            
            if(isUpdate  && rule.Evaluation_Rule__c.equals('Record is created or edited and did not previously meet the rule criteria')){
                evaluateRule =false;
                if(oldListMap != null && oldListMap .size()>0 && oldListMap.get(obj.Id)!=null){
                   SOBject so= oldListMap.get(obj.Id);
                   for(RuleCriteria__c criteria: rule.Rule_Criteria__r){
                        if(so.get(criteria.Field_API_Name__c) != obj.get(criteria.Field_API_Name__c)){
                            evaluateRule = true;
                            break;
                        }
                   } 
                }           
            }
            
            if(!evaluateRule ) return false; 
            
            for(RuleCriteria__c cr :rule.Rule_Criteria__r){
                String fieldname=cr.Field_API_Name__c; 
                String fieldtype=cr.Field_Type__c.toLowerCase();
                String comparisonValue = cr.Matching_Value__c;
                //criteria is on object
                String cobj = cr.Related_Object__c.toLowerCase();
                //system.debug('--->'+cobj);
                 
                Boolean result=false;
                
                /*
                    if the criteria object is the child object the evaluate the criteria 
                    against all the child records and if all the child records
                    match the criteria then criteria is evaluated as true
                */ 
                 SOBject so= oldListMap.get(obj.Id);
                 if(relationshipNames.get(cobj)!=null && !cobj.equalsIgnoreCase(sobjectName)){
                    //then we need to evaluate the child object in the criteria
                    SObject[] childRecordsFromParent = obj.getSObjects(relationshipNames.get(cobj)); //child object
                    if(childRecordsFromParent!=null){
                        for (SObject childRecord : childRecordsFromParent){                           
                             //adding cross formula
                            String recordFieldValue = fieldname=='CrossFormula' ? AW_AdvanceWorkflowExecutionHelper.getCrossFormulaValue(childRecord,cr.CrossFormula__c):string.valueOf(childRecord.get(fieldname));
                            //AW_AdvanceWorkflowExecutionHelper.oldvalue =null;//recordFieldValue ;//fieldname=='CrossFormula' ?recordFieldValue :string.valueOf(so.get(fieldname));
                            
                            //for child records we do not consider IsChanged & IsChangedFromTo
                            
                            result = AW_AdvanceWorkflowExecutionHelper.doComparison(recordFieldValue,comparisonValue,fieldtype,cr);
                            if(result==false)break; //if any record does not match
                        }
                    }
                 
                 }else{             
                    String recordFieldValue;
                    if(!fieldname.startsWithIgnoreCase('GlobalVariable'))
                    	recordFieldValue =  fieldname=='CrossFormula' ? AW_AdvanceWorkflowExecutionHelper.getCrossFormulaValue(obj,cr.CrossFormula__c): string.valueOf(obj.get(fieldname));                   
                    else if(fieldname.startsWithIgnoreCase('GlobalVariable')){
                    	String var = fieldname.split('-')[1];
                    	if(var=='User')
                    		recordFieldValue = userInContext.Name;
                    	if(var=='Profile')
                    		recordFieldValue=userInContext.profile.name;
                    	else if(var=='UserRole')
                    		recordFieldValue=userInContext.UserRole.Name;
                    	else if(var=='Organization'){
                    		recordFieldValue = 	UserInfo.getOrganizationName();
                    	}
                   }
                   system.debug('recordFieldValue-->'+recordFieldValue);
                   //AW_AdvanceWorkflowExecutionHelper.oldvalue = fieldname=='CrossFormula' ? null :string.valueOf(so.get(fieldname));
                   result = AW_AdvanceWorkflowExecutionHelper.doComparison(recordFieldValue,comparisonValue,fieldtype,cr);
                   
                   // Cloud Challenger
                   /*if(cr.Matching_Type__c == 'IsChanged'){
                    	result = isChanged(obj.Id,fieldname);
                    }
                    else if(cr.Matching_Type__c == 'ChangedFromTo'){
                    	result = isChangedFromTo(obj.Id,cr);	
                    }
                    else{ 
                        result = AW_AdvanceWorkflowExecutionHelper.doComparison(recordFieldValue,comparisonValue,fieldtype,cr);
					}*/
					        
	           }                                                              
                 Integer res = result ? 1:0;
                 evaluationResult.put(i,res); i++;   //dump the result for later stage                           
             }
             
            //finally apply the filter logic:-
             
            /*
               if the user has not defined the filter logic then we need to
               add all the criteria
            */
            if(rule.Filter_Logic__c==null){
                Set<String> criteriaLogic = new Set<String>();
                for(Integer j=1;j<=rule.Total_Criteria__c;j++)
                    criteriaLogic.add(string.valueof(j));
                
                rule.Filter_Logic__c = AW_AdvanceWorkflowExecutionHelper.joinSet(criteriaLogic,'and') ;                       
            }
            AW_ExpressionEvaluation_Helper evaluate = new AW_ExpressionEvaluation_Helper();
            return evaluate.evaluateExpression(rule.Filter_Logic__c,evaluationResult);
        } 
     
                
    /* apply a action - helper */
    private static SObject applyActions(RuleAction__c action,SObject o){
        SObject o1 =  action.Field_Name__c=='CrossObject' ? o.getSObject(action.CrossObjectField__c.split('\\.')[0]): o;
        
        if(o1!=null && action.Type__c == 'Update Field'){
            system.debug('action-->'+action);
            
            //SH bug fix - to use most recent instance of the object for update
            o1= toUpdateSObject.get(String.valueof(o1.get('id'))) ==null?
            o1 : toUpdateSObject.get(String.valueof(o1.get('id')));
            
         
            String value = getValueForUpdateAction(action);
            String fieldToUpdate = action.Field_Name__c=='CrossObject' ? action.CrossObjectField__c.split('\\.')[1] :action.Field_Name__c;
                         
            if(value!=null){
                /*if(value.contains(concatop) || value.startsWith('{!')){
                            value=doMerge(action,value,o);
                             //o1 = updateField(action.Related_Object__c,fieldToUpdate,value,o1);
                }
                else if(value.contains('.')){
                            //String valuetosave = fetchCrossformulaValue(action,value,o);
                            value = fetchCrossformulaValue(action,value,o);
                            //o1 = updateField(action.Related_Object__c,fieldToUpdate,valuetosave,o1);    
                 }else{
                    Map<String,Schema.SObjectField> fieldList = fieldMap.get(action.Related_Object__c.toLowerCase());
                    String valueToUpdate =value;
                    if(fieldList!=null && (fieldList.containsKey(value)==true ||  fieldMap.containsKey(value.toLowerCase())==true)){
                        value = string.valueof(o.get(valueToUpdate));
                    }
                      //o1 = updateField(action.Related_Object__c,fieldToUpdate,valueToUpdate,o1); 
                 }//end else
                 */       
                 value =   resolveValueFetched (action,value,o);       
           }
           
           if(fieldToUpdate!='LookupObjectField' && (action.Bulk_api__c==false || bulkOperation))
                    o1 = updateField(action.Related_Object__c,fieldToUpdate,value,o1);
           else if(action.Bulk_api__c && !bulkOperation) {
                    bulkObjectUpdates.add(new Object_Action_Execution__c(Action__c=action.Id,Status__c='New',Value__c=value,Record_Id__c=o.Id,Type__c='Bulk API'));
           }else if(fieldToUpdate=='LookupObjectField' && (action.Bulk_api__c==false || bulkOperation)){
                    //process the lookup object action                  
                    value = executeLookupObjectAction(action);
                    o1.put(action.Lookup_Field_Name__c,value );
           }     
            
        }
        
        //SH @bug fix : allowing multiple cross object in same rule
        if(action.Field_Name__c=='CrossObject' && o1!=null)
           
            toUpdateSObject.put(String.valueof(o1.get('id')),o1);
            
           // toUpdateSObject.put(UserInfo.getUserId(),o1);
             system.debug('-->CrossObject.action.Field_Name__c  toUpdateSObject ' + toUpdateSObject);
             system.debug('-->CrossObject.action.Field_Name__c  o1 ' + o1);
              //action.Field_Name__c=='CrossObject' ? o :o1;
             //system.debug.('-->action.Field_Name__c ' +action.Field_Name__c);
            // return action.Field_Name__c ;
          return action.Field_Name__c=='CrossObject' ? o :o1;
    
    }  
    
    //helper method that will fetch the value resolvinf merge fields
    private static String resolveValueFetched(RuleAction__c action,String value,SObject o){
        String value1 = value.toLowerCase();
        
        if(value1.startswith('left(')){
                String fieldValue = resolveValueFetched(action,value1.substringBetween('left(',','),o);
                Integer numChars = Integer.valueof(value1.substringBetween(',',')'));
                value = fieldValue.left(numChars);
        }
       else if(value1.startswith('right(')){
                String fieldValue = resolveValueFetched(action,value1.substringBetween('right(',','),o);
                Integer numChars = Integer.valueof(value1.substringBetween(',',')'));
                value = fieldValue.right(numChars);
       }else if(value1.startswith('mid(')){
                String fieldValue = resolveValueFetched(action,value1.substringBetween('mid(',','),o);
                value1 = value1.replace('mid(','');
                value1 = value1.replace(')','');
                List<String> params = value1.split(',');
                value = fieldValue.mid(Integer.valueof(params[1]),Integer.valueof(params[2]));
       }
       else if(value1.startswith('now(') || value1.startswith('today(')){
                Datetime myDateTime = resolveDateTimeFunctions(value1);
                value = value1.startswith('today(') ? String.valueof(myDateTime.date()) : String.valueof(myDateTime); 
       }

        if(value.contains(concatop) || value.startsWith('{!')){
                value=doMerge(action,value,o);
                             //o1 = updateField(action.Related_Object__c,fieldToUpdate,value,o1);
        }
        else if(value.contains('.')){
                            //String valuetosave = fetchCrossformulaValue(action,value,o);
                            value = fetchCrossformulaValue(action,value,o);
                            //o1 = updateField(action.Related_Object__c,fieldToUpdate,valuetosave,o1);    
        }
        else{
            Map<String,Schema.SObjectField> fieldList = fieldMap.get(action.Related_Object__c.toLowerCase());
            String valueToUpdate =value;
            if(fieldList!=null && (fieldList.containsKey(value)==true ||  fieldMap.containsKey(value.toLowerCase())==true)){
                 value = string.valueof(o.get(valueToUpdate));
            }
            
                      //o1 = updateField(action.Related_Object__c,fieldToUpdate,valueToUpdate,o1); 
         }//end else
         
         return value;
         
    } 
    
    
    private static datetime resolveDateTimeFunctions(String value1){
        //then it is today funstionality
                datetime myDateTime = datetime.now();
                if(value1.contains('+')){
                    //then add value
                    List<String> splitparam = value1.split('\\+');
                    //we assume the format to add day /month/year h:m:s would be 7d/7m/7y 1h:m2m:40s
                    List<String> datetimeparts = splitparam[1].split(' ');
                    
                    if(datetimeparts[0].contains('/')) 
                        splitparam = datetimeparts[0].split('/');
                    else if(datetimeparts[0].contains(':')) 
                        splitparam = datetimeparts[0].split(':');
                    else
                        splitparam = datetimeparts[0].split(' ');
                    system.debug('splitparam>>>'+splitparam);   
                    for(String s:splitparam){
                        myDateTime = dateFuntionality(myDateTime,s);                    
                    }
                    
                    if(datetimeparts.size()>1){
                        splitparam = datetimeparts[1].split(':');
                        for(String s:splitparam){
                            myDateTime = dateFuntionality(myDateTime,s);                    
                        }
                    }//end if(datetimeparts.size()>1)
                    
                }//end if('+')  
           system.debug('myDateTime>>>'+myDateTime);    
           return myDateTime;
    }
    
    private static Datetime dateFuntionality(Datetime dt, String s){
        system.debug('s>>>'+Integer.valueof(s.replace('d','')));  
        if(s.contains('d')) {
            dt=dt.addDays(Integer.valueof(s.replace('d','')));
        }else if(s.contains('m')) {
            dt=dt.addMonths(Integer.valueof(s.replace('m','')));
        }else if(s.contains('y')) {
            dt=dt.addYears(Integer.valueof(s.replace('y','')));
        }
        else if(s.contains('h')) {
            dt=dt.addHours(Integer.valueof(s.replace('h','')));
        }
        else if(s.contains('i')) {
            dt=dt.addMinutes(Integer.valueof(s.replace('i','')));
        }
        else if(s.contains('s')) {
            dt=dt.addSeconds(Integer.valueof(s.replace('s','')));
        }
        system.debug('myDateTime>>>'+dt);         
        return dt;
    }
    
    public static Map<String,String> apex_execution_params(RuleAction__c action,String params,SOBject o){
        Map<String,String> param_map= new Map<String,String>();
        if(params==null) return param_map;
        List<String> input = params.split(',');
        
        for(String s:input){
            List<String> keyValue = s.split(':');
            String value=keyValue[1]!=null ? resolveValueFetched(action,keyValue[1],o):'';
            param_map.put(keyValue[0],value);
        }
        
        return param_map;
    }
    
    public static void apex_execution_outputupdate(RuleAction__c action,Map<String,String> params,SOBject o){
        if(action.output_parameters__c==null) return;
        
        List<String> input = action.output_parameters__c.split(',');
        
        for(String s:input){
            SObject o1 =  toUpdateSObject.get(o.Id)!=null?toUpdateSObject.get(o.Id):o;
            List<String> keyValue = s.split(':');
            String value=params.get(keyValue[0]);
            if(value==null) continue;
            
            //otherwise start the processing
            String fieldToUpdate = keyValue[1];
            
            if(fieldToUpdate==null || fieldToUpdate.trim()=='') continue;
            
            if(fieldToUpdate.contains('.')){
                List<String> reference = value.split('\\.'); 
                fieldToUpdate = reference[reference.size()-1];
                o1 = o.getSObject( reference[0]);   
                o1 =  toUpdateSObject.get(o1.Id)!=null?toUpdateSObject.get(o1.Id):o;    
                continue ;              
            }
            o1 = updateField(action.Related_Object__c,fieldToUpdate,value,o1);
            toUpdateSObject.put(o1.Id,o1);      
        }
    }
    
     private static boolean isChanged(Id recordId, string fieldAPIName){
    	if(Trigger.isExecuting && Trigger.isUpdate){
    		if(Trigger.oldMap.get(recordId).get(fieldAPIName) != Trigger.newMap.get(recordId).get(fieldAPIName)){
    			return true;
    		}
    	}
    	return false;
    }
    
    private static boolean isChangedFromTo(Id recordId, RuleCriteria__c cr){
    	if(Trigger.isExecuting && Trigger.isUpdate){
    		String value = cr.Matching_value__c;
    		String fieldAPIName = cr.Field_API_Name__c;
    		if(value != null && value.contains(',')){
    			String[] result = value.split(',');
    			String oldValue = result[0];
    			String newValue = result[1];
    			system.debug('oldValue: '+oldValue);
    			system.debug('newValue: '+newValue);
 	    		if( AW_AdvanceWorkflowExecutionHelper.doComparison(String.Valueof(Trigger.oldMap.get(recordId).get(fieldAPIName)),oldValue, cr.Field_Type__c, new RuleCriteria__c(Matching_Type__c = 'equals')) && 
	    			AW_AdvanceWorkflowExecutionHelper.doComparison(String.valueOf(Trigger.newMap.get(recordId).get(fieldAPIName)), newValue, cr.Field_Type__c, new RuleCriteria__c(Matching_Type__c ='equals'))){
    				return true;
    			}
    			/*if(String.Valueof(Trigger.oldMap.get(recordId).get(fieldAPIName)).equalsIgnoreCase(oldValue) && 
    			   String.valueOf(Trigger.newMap.get(recordId).get(fieldAPIName)).equalsIgnoreCase(newValue)){
    				return true;
    			}*/
    		} 
    	}
    	return false;
    }
     
      
    private static String executeLookupObjectAction(RuleAction__c action){
        
        String query ='Select Id,'+action.Lookup_Field_Api_Name__c+' FROM '+action.lookup_object__c;
        
        if(action.Lookup_Where_fields__c!=null)
            query+=' WHERE '+action.Lookup_Where_fields__c;
                            
       
        List<SObject> sobjList = Database.query(query+' limit 1');
        if(sobjList != null && sobjList.size() > 0 && sobjList[0].get(action.Lookup_Field_API_Name__c)!=null){
               return String.valueof(sobjList[0].get(action.Lookup_Field_API_Name__c));
        }
        return null;
    }  
    
    private static String doMerge(RuleAction__c action,String value,SObject o){
       system.debug('----in merge fields--- action '+action);
         system.debug('----in merge fields--- value '+value);
        system.debug('----in merge fields--- o '+o);
         
        value=value.replaceAll('\'','');
        List<String> splitVaue = value.split(concatop);
       
        system.debug('----in merge fields--- splitVaue '+splitVaue);
        
        try{
        for(String s:splitVaue){
            system.debug('----> before trim  s '+s);
            s=s.trim();
            system.debug('----> after trim  s '+s);
            if(s.startsWith('{!')){
                String mergeField= s.substringBetween('{!','}');
                List<String> reference = mergeField.split('\\.');                    
                SObject fetchedChild ;
                    
                 system.debug('----> fetchedChild  '+fetchedChild);
                               
                String fieldToFetch = reference[reference.size()-1];
                
                 system.debug('----> fieldToFetch  '+fieldToFetch);
                
                for(Integer i=0;i<reference.size()-1;i++){
                    if(reference[i]=='.' || reference[i].trim()=='' ) continue;
                    
                     //second condition :- @any point the reference returns null we cannot evaluate further
                    if(i>=1 && fetchedChild ==null) break;
                    
                     /* system.debug('--->reference['+i+'] '+ reference[i]);
                       system.debug('--->reference['+i+1+'] '+ reference[i+1]);
                       system.debug('----in merge fields--- o '+o);
      
                        system.debug('--->o.getsobject[1] '+o.getSObject(reference[i]));
                      */
                          fetchedChild = fetchedChild==null ?  o.getSObject(reference[i]):fetchedChild.getSObject(reference[i]);              
                 
                    
                }
                
                //we need to update this line for multiple reference :it will throw an error fetched child is null
                String replacewithval =  fetchedChild==null ? '':string.valueof(fetchedChild.get(fieldToFetch)) ;               
                if(fetchedChild==null && !s.contains('.')) replacewithval = string.valueof(o.get(fieldToFetch));
                
                replacewithval = replacewithval ==null ? '':replacewithval ;
                value=value.replace(s,replacewithval);       
            }
        }
        	value=value.replaceAll('&',' ');
       
        	return value;
        }catch(Exception e){
                String msg = string.valueOf(e);
                   
                 List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
                 AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowExecution.cls','domerge','AW_AdvanceWorkflowExecution.cls','LogEmail','RuleAction__c');
                 //other wise it is an invlaid operator on this datatype:-                   
              return null;
       } 
    }       
     
    /*       
    private static String doMerge_production(RuleAction__c action,String value,SObject o){
        system.debug('----in merge fields---');
        value=value.replaceAll('\'','');
        List<String> splitVaue = value.split(concatop);
        
        try{
        for(String s:splitVaue){
            s=s.trim();
            if(s.startsWith('{!')){
                String mergeField= s.substringBetween('{!','}');
                system.debug('----in merge fields---'+mergeField);
                List<String> reference = mergeField.split('\\.'); 
                SObject fetchedChild ;
                
                String fieldToFetch = reference[reference.size()-1];
                system.debug('----in merge fields---'+fieldToFetch);
                
                system.debug('----in merge fields--- reference.size() '+reference.size());
               
                for(Integer i=0;i<reference.size()-1;i++){
               
                    system.debug('----in merge fields--- i '+i);
               
                    if(reference[i]=='.' || reference[i].trim()=='' ) continue;
                    
                     //second condition :- @any point the reference returns null we cannot evaluate further
                    if(i>=1 && fetchedChild ==null) break;
                    
                    fetchedChild = fetchedChild==null ?  o.getSObject(reference[i]):fetchedChild.getSObject(reference[i]);
                    system.debug('fetched child-->'+fetchedChild);
                }
                String replacewithval = fetchedChild==null?string.valueof(o.get(fieldToFetch)):string.valueof(fetchedChild.get(fieldToFetch));
                system.debug('----in merge fields replacewithval ---'+replacewithval );
                replacewithval = replacewithval ==null ? '':replacewithval ;
                value=value.replace(s,replacewithval);
            }
        }
        value=value.replaceAll('&',' ');
        return value;
        }catch(Exception e){
               AW_AdvanceWorkflowExecutionHelper.handleError(e);                  //other wise it is an invlaid operator on this datatype:-                   
              return null;
            } 
    }       
    */     
    private static String fetchCrossformulaValue(RuleAction__c action,String value,SObject o){
        //validate again else could result an error
          List<String> reference = value.split('\\.'); 
          system.debug('reference -->'+reference );
          
          if(reference[0].isNumeric())return value;
          
          SObject fetchedChild ;
          Set<String> validRN = validRelationShips.get(action.Related_Object__c.toLowerCase())!=null ? validRelationShips.get(action.Related_Object__c.toLowerCase()): new Set<String>();
          //if(!validRN.contains(reference[0])){
           //   return value;
          //}
          String fieldToFetch = reference[reference.size()-1];
          system.debug('fieldToFetch-->'+fieldToFetch );
        
          //SObject fetchedChild  ;
          for(Integer i=0;i<reference.size()-1;i++){
              if(reference[i]=='.' || reference[i].trim()=='' ) continue;
              if(i>=1 && fetchedChild ==null) break;
              fetchedChild = fetchedChild==null ?  o.getSObject(reference[i]):fetchedChild.getSObject(reference[i]);
              system.debug('fetched child-->'+fetchedChild);
          }
            system.debug('fetchedChild -->'+fetchedChild );
          return fetchedChild!=null?string.valueof(fetchedChild.get(fieldToFetch)):'';
    }       
            
    /**
    * By Cloud Challenger
    * Required one more parameter parent 
    */
    private static SObject applyInsertChildActions(RuleAction__c action,SObject sobj,Sobject parent){  
        /**
        * By Cloud Challenger
        * Below code apply Insert Related Record Info record  and create sobject for insertion
        */
        try{
        if(action.Type__c == 'Insert Related Object'){
            if(insertedRelatedRecordInfo.containsKey(action.Id)){
                for(Values_for_Action_Insert_Record__c info: insertedRelatedRecordInfo.get(action.Id).Values_for_Action_Insert_Record__r){
                    //bug fix : when the field is type of reference it is passing record name instead of the id
                    String toupdatevalue= info.Reference_Id__c!=null? info.Reference_Id__c : info.Value__c;
                    //adding merge field logic here
                     if(toupdatevalue!=null && (toupdatevalue.contains(concatop) ||  toupdatevalue.startsWith('{!'))){
                            String valuetosave=doMerge(action,toupdatevalue,parent);
                            sobj = updateField(action.Related_Object__c,info.Name.tolowercase(),valuetosave,sobj);
                    }
                    else if(toupdatevalue!=null && toupdatevalue.contains('.')){
                        String valuetosave = fetchCrossformulaValue(action,toupdatevalue,parent);
                        system.debug('valuetosave-->'+valuetosave);
                        sobj = updateField(action.Related_Object__c.tolowercase(),info.Name.tolowercase(),valuetosave,sobj);  
                    }
                    else{
                        sobj = updateField(action.Related_Object__c.tolowercase(),info.Name.tolowercase(),toupdatevalue,sobj);
                    }
                }
            }
        }  
        return sobj;
      }
      catch(Exception e){
         AW_AdvanceWorkflowExecutionHelper.handleError(e);                     
         return null;
      }       
       
    }
    
    
        

    /* update a field - helper */
    private static Sobject updateField(String obj,String fieldname ,String value,SObject toUpdate){
        system.debug('--fieldmap--'+fieldmap);
        system.debug('--fieldmap for obj--'+fieldmap.get(obj.toLowerCase()));
 //       system.debug('--fieldmap for fieldname --'+fieldname );
        
        if(fieldmap.get(String.valueof(toUpdate.getSObjectType()).toLowerCase())==null)
            fieldmap.put(String.valueof(toUpdate.getSObjectType()).toLowerCase(),gd.get(String.valueof(toUpdate.getSObjectType())).getDescribe().fields.getMap());
        Schema.Sobjectfield field = fieldmap.get(String.valueof(toUpdate.getSObjectType()).toLowerCase()).get(fieldname); 
        Schema.Describefieldresult fieldDesc = field.getDescribe();

       
         
        String fldType = fieldDesc.getType().name();
        //value = String.escapeSingleQuotes(value);     
        if(value!=null)value = value.replaceAll('\'','');
        /**
        * Start
        * By Cloud Challenger
        * Below code will add reference id to map and the mail body to be sent only if the reference type is user
        * and  NotifyUser is true
        */
        if(fldType.equalsIgnoreCase('reference')){
            try{
                 //updating to use the tempalte id
               // Id referenceId = Id.valueof(value);
                Id referenceId;
                if(value!=null)referenceId = Id.valueof(value);
                if(referenceId.getSObjectType() == User.SobjectType && notifyUser){
                      //String mailBody = 'You are assigned as '+ fieldDesc.getLabel() + ' for '+objectLabels.get(obj) +' <a href="'+sfURL+'/'+toUpdate.Id+'">Record</a>';
                    if(!AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.containsKey(referenceId)){
                        //if no                       
                        List<RuleAction__c> temp = new List<RuleAction__c>{actionInContext};
                        Map<String ,List<RuleAction__c>> objTemp=  new Map<String ,List<RuleAction__c>>();
                        objTemp.put(toUpdate.Id,temp);
                        AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.put(referenceId,objTemp); 
                    }
                    else{
                        Map<String ,List<RuleAction__c>> objTemp = AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.get(referenceId);
                        if(!objTemp.containsKey(toUpdate.Id))
                            objTemp.put(toUpdate.Id,new List<RuleAction__c>{actionInContext});
                        else
                            objTemp.get(toUpdate.Id).add(actionInContext);
                            
                        AW_AdvanceWorkflowExecutionHelper.userIdMailContentMap.put(referenceId,objTemp);
                    }
                }
            }
            catch(Exception ex){
            }
            toUpdate.put(fieldname,value);
            /**
            * End 
            */
        }else if(fldType.equalsIgnoreCase('string') || fldType.equalsIgnoreCase('picklist')|| fldType.equalsIgnoreCase('email') || fldType.equalsIgnoreCase('url')|| fldType.equalsIgnoreCase('multipicklist')|| fldType.equalsIgnoreCase('phone')){       
            toUpdate.put(fieldname,value);
        }else if(fldType.equalsIgnoreCase('boolean')){   
            toUpdate.put(fieldname,Boolean.valueOf(value));
        }else if(fldType.equalsIgnoreCase('double') || fldType.equalsIgnoreCase('currency')|| fldType.equalsIgnoreCase('percent')){   
            toUpdate.put(fieldname,Decimal.valueOf(value));
        }else if(fldType.equalsIgnoreCase('integer')|| fldType.equalsIgnoreCase('number')){   
            toUpdate.put(fieldname,Integer.valueOf(value));
        }else  if(fldType.equalsIgnoreCase('date')){   
            toUpdate.put(fieldname,Date.valueOf(value));
        }  
        else if(fldType.equalsIgnoreCase('base64') && value != null){   
            toUpdate.put(fieldname,Blob.valueof(value));
        }
        else{
            toUpdate.put(fieldname,value);
        }                 
        return toUpdate;
    }       
     
}