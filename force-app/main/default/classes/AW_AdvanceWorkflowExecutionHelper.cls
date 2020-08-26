// 
// (c) 2012 Appirio, Inc.
// AW_AdvanceWorkflowExecutionHelper                                                     
//
// This class is  helper class for the RuleExecution class
// and performs the associated actions
//
// 5  Dec 2012     Peter Babalis     Original
// 20 Dec 2012     Cloud Challenger
// 07 Feb 2013     Peter Babalis Added email templates,cross formula fields,insert tasks
//  
//  

public class AW_AdvanceWorkflowExecutionHelper {
    /** 
     * List of all static variables 
     */     
                
    // Map of user id and content to be send on mail        
    //public static Map<String,List<String>> userIdMailContentMap = new Map<String,List<String>>();
     //SH :-updating Map of user id and record id with template id to be send on mail      
     public static Map<String,Map<String,List<RuleAction__c>>> userIdMailContentMap = new Map<String,Map<String,List<RuleAction__c>>>();
    //cloudchallenger
     public static Boolean isBatchProcess = false;
     
     //added by SH @21/5/13
     public static String  oldValue;
     
    /*
      * @author Sneha
      * @date 30/7/2012
      * @description method joins a set using                             
    */
    public static String joinSet(Set<String> values,String joinUsing) {
         try{
         	  system.debug('-->Values  '+values);
         	  values.remove('CrossObject');
         	  values.remove('LookupObjectField');
              List<String> valueCopy = new List<String>(values);
              return String.join(valueCopy,joinUsing);
            }
           catch(Exception e){
                String msg = string.valueOf(e);
                 List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
                 AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowExecutionHelper.cls','joinSet','AW_AdvanceWorkflowExecutionHelper.cls','joinSet','RuleAction__c');
                 //other wise it is an invlaid operator on this datatype:-                   
              return null;
            }
     }
    
    
    /**
    * By Cloud Challenger
    * THis method fetch user's email id
    */
    public static Map<Id,User> getUserDetails(Set<String> userIds){
        return new Map<Id,User>([Select Name, FirstName,LastName,Id,Email from User where Id in: userIDs]);
    }
     
    
    /**
    * lets not depend on the caller that ther are providing entire details of
    * the rules & criteria lets fetch by our self       
    */
    public static List<Rule__c> getActiveCriteria(Set<Id> ruleIds,String sobjectName){
        return [Select Id,Execution_Behavior__c,Evaluation_Rule__c,Filter_Logic__c,Total_Actions__c,Total_Criteria__c,(Select Id,Field_API_Name__c,Field_Type__c ,Matching_Type__c,Matching_Value__c,Maximum_Value__c,Minimum_Value__c,Related_Object__c,CrossFormula__c FROM Rule_Criteria__r ORDER BY Name ASC) FROM Rule__c WHERE Status__c ='Active' AND  Total_Actions__c >0 AND Object__c=:sobjectName AND Id IN :ruleIds order by Order__c];
    }
    
   /**
    * get all the actions for given set of rule
    * returns all the actions that are active
    */
    public static Map<Id,Rule__c> getActiveRuleActions(Set<Id> ruleIds,String sobjectName){
        Map<Id,Rule__c> ruleActions = new Map<Id, Rule__c>([Select Id,Name,Object__c,(Select Id,Name,Action_Label__c,Notified_User__c,Reference_Id__c,Field_Type__c,Field_Name__c,Lookup_Field_Name__c,Type__c,Value__c,Long_Value__c,Related_Object__c,Notify_user__c,Email_Template__c,User_Owner_Id__c,CrossObjectField__c,Bulk_api__c,Lookup_Object__c,Lookup_field_api_name__c,lookup_where_fields__c,Apex_job_Class__c,Input_Parameters__c,output_parameters__c,Endpoint_URL__c,Callout_Method__c,Callout_timeout__c,Rule__c,Additional_Emails__c FROM Rule_Actions__r  ORDER BY Name ASC) FROM Rule__c  WHERE Status__c='Active' AND  Total_Actions__c >0 AND Object__c=:sobjectName AND Id IN :ruleIds ]);                       
        return ruleActions;
    }
    
     public static Map<Id,Rule__c> getActiveRuleActionsSubset(Set<Id> ruleIds,String sobjectName,Set<Id> actionIds){
        Map<Id,Rule__c> ruleActions = new Map<Id, Rule__c>([Select Id,Name,Object__c,(Select Id,Name,Action_Label__c,Notified_User__c,Reference_Id__c,Field_Type__c,Lookup_Field_Name__c,Field_Name__c,Type__c,Value__c,Long_Value__c,Related_Object__c,Notify_user__c,Email_Template__c,User_Owner_Id__c,CrossObjectField__c,Bulk_api__c,Lookup_Object__c,Lookup_field_api_name__c,lookup_where_fields__c,Apex_job_Class__c,Input_Parameters__c,output_parameters__c,Rule__c,Endpoint_URL__c,Callout_Method__c,Callout_timeout__c,Additional_Emails__c FROM Rule_Actions__r WHERE Id IN : actionIds  ORDER BY Name ASC) FROM Rule__c  WHERE Status__c='Active' AND  Total_Actions__c >0 AND Object__c=:sobjectName AND Id IN :ruleIds ]);                       
        return ruleActions;
    }
    
    /**
    * By Cloud Challenger
    * Fetch InsertRelatedRecord info 
    */
    
     public static Map<Id,RuleAction__c> getInsertRelatedRecordInfo(Set<Id> ruleIds){
        return new Map<Id,RuleAction__c>([Select Id,(Select Name, Value__c,Reference_Id__c From Values_for_Action_Insert_Record__r ) from RuleAction__c where Rule__c in: ruleIds and Type__c = 'Insert Related Object']);
    }
    public static Map<Id,RuleAction__c> getInsertRelatedRecordInfoForActions(Set<Id> actionIds){
        return new Map<Id,RuleAction__c>([Select Id,(Select Name, Value__c,Reference_Id__c From Values_for_Action_Insert_Record__r ) from RuleAction__c where Id in: actionIds and Type__c = 'Insert Related Object']);
    }
    
    
   
    /*
      STRING COMPARISONS
    */
    public static Boolean isValid(String value1 , String value2 ,String op ,String fieldtype){
        
      try{   
      //updated by SH:10-dec 12    
        // 01-12-13 PGB System Null  
       // value1 = value1.trim();
        // 01-12-13 PGB System Null  
        //value2=   value2.trim();   
         if (value1!=null) value1 = value1 .trim();
         if (value2!=null) value2=   value2 .trim();   
       
        if(op.equalsIgnoreCase('Equals')){
            return ( value1 == value2 ) ? true : false;
            
        }
        if(op.equalsIgnoreCase('Not Equal To')){
            return ( value1 != value2 ) ? true : false;
             
        }            
        if(op.equalsIgnoreCase('Contains'))
            return ( value1.contains(value2) ) ? true : false;
             
        if(op.equalsIgnoreCase('Does Not Contain'))
            return ( value1.contains(value2) ) ? false: true;
      
        if(op.equalsIgnoreCase('Is Null'))
             return String.isBlank(value1) ;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return String.isNotBlank(value1);    
             
         if(op.equalsIgnoreCase('Is Changed')){
             return ( value1 != oldvalue ) ? true : false; 
         }
         
         if(op.equalsIgnoreCase('Changed From To')){
             /*List<String> oldnewval = value2.split(',');
             if(oldnewval[0] == oldvalue ){
                 if(oldnewval.size()>1 && oldnewval[1]==value1) return true;
                 else if(value1==null) return true;
                 else return false;
             }*/
             
         }   
                           
        /*if(op.equalsIgnoreCase('Starts With'))
            return ( value1.startsWith(value2) ) ? true : false;                
         
        if(op.equalsIgnoreCase('Ends With'))
            return ( value1.endsWith(value2) ) ? true : false;  
        */
        
        //updated SH : starts with & ends with to work with multiple values                   
            if(op.equalsIgnoreCase('Starts With')){
                Boolean result = false;
                for(String value : value2.split(',')){
                    result= value1.startsWith(value) || value1.startsWith('('+value) ? true:false;
                    if(result) break;
                }
                return result; 
                //return ( value1.startsWith(value2) ) ? true : false;                
            }
             
            if(op.equalsIgnoreCase('Ends With')){
                Boolean result = false;
                for(String value : value2.split(',')){
                    result= value1.endsWith(value)|| value1.startsWith(value+')') ? true:false;
                    if(result) break;
                }
                return result; 
                //return ( value1.endsWith(value2) ) ? true : false;  
            } 
        
       if(op.equalsIgnoreCase('Does Not Start With'))
             return ( value1.startsWith(value2) ) ? false: true;                
         
         if(op.equalsIgnoreCase('Does Not End With'))
             return ( value1.endsWith(value2) ) ? false: true;      
         
        if(op.equalsIgnoreCase('Regular Expression')){
            Matcher conMatcher = Pattern.compile(value2).matcher(value1);
            return conMatcher.matches();            
        }
        
        
         if(op.equalsIgnoreCase('includes')){
             Boolean result = false;
             for(String value : value2.split(',')){
                    result= value1.equalsIgnoreCase(value);
                    if(result) break;
             }
             
             return result;  
         }
        
        if(op.equalsIgnoreCase('excludes') ){
             Boolean result = false;
             for(String value : value2.split(',')){
                    result= value1.equalsIgnoreCase(value);
                    if(result) break;
             }
             return !result;
         } 
         return false;
      }
       catch(Exception e){
                String msg = string.valueOf(e);
                   
                 List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
                 AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowExecutionHelper.cls','isvalid','AW_AdvanceWorkflowExecutionHelper.cls','LogEmail','Advance_Workflow__c');
                 //other wise it is an invlaid operator on this datatype:-                   
              return false;
            } 
         
    }
    
    /*
      DECIMAL/NUMBER COMPARISONS
    */
        public static Boolean isValid(Decimal value1 , Decimal value2 ,String op,String fieldtype,RuleCriteria__c cr ){
       
            if(op.equalsIgnoreCase('Equals'))
                return ( value1 == value2 ) ? true : false;
            
            if(op.equalsIgnoreCase('Not Equal To'))
                return ( value1 != value2 ) ? true : false;
            
            if(op.equalsIgnoreCase('Greater Than'))
                return ( value1 > value2 ) ? true : false;
             
            if(op.equalsIgnoreCase('Less Than'))
                return ( value1 < value2 ) ? true : false;
             
            if(op.equalsIgnoreCase('Greater or Equal'))
                return ( value1 >= value2 ) ? true : false;
                 
            if(op.equalsIgnoreCase('Less or Equal'))
                return ( value1 <= value2 ) ? true : false;
        
            if(op.equalsIgnoreCase('Is Null'))
                 return ( value1 == null) ? true : false;

             
             if(op.equalsIgnoreCase('Is Not Null'))
                 return ( value1 != null) ? true: false;      
                 
             if(op.equalsIgnoreCase('between')){
                Decimal min = decimal.valueOf(cr.Minimum_Value__c);
                Decimal max = decimal.valueOf(cr.Maximum_Value__c);
                return  (value1 >min && value1 < max) ? true:false;                 
            } 
            
             if(op.equalsIgnoreCase('Is Changed')){
                 return ( value1 != Decimal.valueof(oldvalue) ) ? true : false; 
             }
             
             if(op.equalsIgnoreCase('Changed From To')){
                 List<String> oldnewval = String.valueof(value2).split(',');
                 if(oldnewval[0] == oldvalue ){
                     if(oldnewval.size()>1 && oldnewval[1]==String.valueof(value1)) return true;
                     else if(value1==null) return true;
                     else return false;
                 }
             }   
               
            //other wise it is an invlaid operator on this datatype:-                   
            return false;
        }
        
         /*
      DATE COMPARISONS
    */
    public static Boolean isValid(Date value1 , Date value2 ,String op,String fieldtype,RuleCriteria__c cr ){
      
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('between')){
            
            Date min = Date.parse(cr.Minimum_Value__c);
            Date max = Date.parse(cr.Maximum_Value__c);
             
            return  (value1 > min && value1 < max) ? true:false;                
        }    
        
         if(op.equalsIgnoreCase('Is Changed')){
                 return ( value1 != Date.parse(oldvalue) ) ? true : false; 
         }
             
             if(op.equalsIgnoreCase('Changed From To')){
                 List<String> oldnewval = String.valueof(value2).split(',');
                 if(Date.parse(oldnewval[0]) == Date.parse(oldvalue) ){
                     if(oldnewval.size()>1 && Date.parse(oldnewval[1])==value1) return true;
                     else if(value1==null) return true;
                     else return false;
                 }
             }   
              
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
    
     /*
       DATETIME COMPARISONS
    */
    public static Boolean isValid(Datetime value1 , Datetime value2 ,String op,String fieldtype,RuleCriteria__c cr ){
     
        if(op.equalsIgnoreCase('Equals'))
            return ( value1 == value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Not Equal To'))
            return ( value1 != value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Greater Than'))
            return ( value1 > value2 ) ? true : false;
         
        if(op.equalsIgnoreCase('Less Than'))
            return ( value1 < value2 ) ? true : false;
        
        if(op.equalsIgnoreCase('Greater or Equal'))
            return ( value1 >= value2 ) ? true : false;
             
        if(op.equalsIgnoreCase('Less or Equal'))
            return ( value1 <= value2 ) ? true : false;
     
        if(op.equalsIgnoreCase('Is Null'))
             return ( value1 == null) ? true : false;
         
         if(op.equalsIgnoreCase('Is Not Null'))
             return ( value1 != null) ? true: false;              
     
        if(op.equalsIgnoreCase('between')){
            
            Datetime min = Datetime.parse(cr.Minimum_Value__c);
            Datetime max = Datetime.parse(cr.Maximum_Value__c);
            
            return  (value1 >min && value1<max) ? true:false;               
        } 
        
         if(op.equalsIgnoreCase('Is Changed')){
                 return ( value1 != Datetime.parse(oldvalue) ) ? true : false; 
         }
             
             if(op.equalsIgnoreCase('Changed From To')){
                 List<String> oldnewval = String.valueof(value2).split(',');
                 if(Datetime.parse(oldnewval[0]) == Datetime.parse(oldvalue) ){
                     if(oldnewval.size()>1 && Datetime.parse(oldnewval[1])==value1) return true;
                     else if(value1==null) return true;
                     else return false;
                 }
             }    
             
        //other wise it is an invlaid operator on this datatype:-                   
        return false;
    }
    
    public static String getCrossFormulaValue(SObject record,String formula){
        List<String> reference = formula.split('\\.'); 
        String fieldToFetch = reference[reference.size()-1];
        
        SObject fetchedRecord ;
        for(Integer i=0;i<reference.size()-1;i++){
              if(reference[i]=='.' || reference[i].trim()=='' ) continue;
              
              //second condition :- @any point the reference returns null we cannot evaluate further
              if(i>=1 && fetchedRecord==null) return null;
              
              fetchedRecord = fetchedRecord==null ?  record.getSObject(reference[i]):fetchedRecord.getSObject(reference[i]);
              if(fetchedRecord == null) break;
              system.debug('fetched fetchedRecord-->'+fetchedRecord);
        }
        
        if(fetchedRecord!=null) 
         return string.valueof(fetchedRecord.get(fieldToFetch));
        
        return null;
    }
    
    //call the methods to do actual comparison based on the fieldtypes
        public static Boolean doComparison(String recordFieldValue,String comparisonValue,String fieldtype,RuleCriteria__c cr){
                 Boolean result=false;
                 
                 if(cr.Matching_Type__c.equalsIgnoreCase('Is Null') || cr.Matching_Type__c.equalsIgnoreCase('Is Not Null')){
                     result =  isValid(recordFieldValue,comparisonValue,cr.Matching_Type__c,fieldtype); 
                 }else if(recordFieldValue!=null){                 
                      //if the datatype is string/url/email/phone/reference  
                     if(fieldtype=='string' || fieldtype=='reference' || fieldtype=='textarea' || fieldtype=='boolean' || fieldtype=='url'||fieldtype=='email'||fieldtype=='phone' || fieldtype=='picklist' || fieldtype=='multipicklist'){
                            //call the method to valid string
                          result =  isValid(recordFieldValue,comparisonValue,cr.Matching_Type__c,fieldtype);    
                     }else if(fieldtype=='date'){
                           comparisonValue=comparisonValue ==null ? Date.today().format() : comparisonValue;
                          
                           result = isValid(Date.valueOf(recordFieldValue),convertToDate(comparisonValue),cr.Matching_Type__c,fieldtype,cr); 
                     }else if(fieldtype=='integer' || fieldtype=='double' || fieldtype=='currency' || fieldtype=='number' || fieldtype=='percent'){
                         comparisonValue = comparisonValue ==null ? '0': comparisonValue;
                         result = isValid(decimal.valueOf(recordFieldValue),decimal.valueOf(comparisonValue),cr.Matching_Type__c,fieldtype,cr); 
                     }else if(fieldtype=='datetime'){
                        comparisonValue= comparisonValue ==null ? Datetime.now().format() : comparisonValue+' 00:00 AM';
                        result = isValid(Datetime.valueOf(recordFieldValue),Datetime.parse(comparisonValue),cr.Matching_Type__c,fieldtype,cr);  
                              
                     }
                 }
                 
                 return result;
        }
        
        public static Date convertToDate(String comparisonValue){
            try{
               return Date.parse(comparisonValue);
            }catch(Exception e){
                List<String> dateSplit=comparisonValue.split('/');
                return date.newinstance(Integer.valueof(dateSplit[2]),Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]));
            }
        }
        
        /**
         * This method will sort the option list on there label values
         */
        public static void sortSelectListOnLabel(List<SelectOption> options){
            Map<String,List<SelectOption>> mapping = new Map<String,List<SelectOption>>();
            for(Selectoption opt : options) {
                List<SelectOption> optList = new List<SelectOption>();
                if(mapping.containsKey(opt.getLabel())){
                    optList = mapping.get(opt.getLabel());
                }
                else{
                    mapping.put(opt.getLabel(),optList);
                }
                optList.add(opt);
            }
            List<String> sortKeys = new List<String>();
            sortKeys.addAll(mapping.keySet());
            sortKeys.sort();
            options.clear();
            for (String key : sortKeys) {
                options.addAll(mapping.get(key));
            }
        }
    //String templateId ==> RuleAction__c a
    /*public static Map<String,Map<String,List<String>>> buildListForEmail(Map<String,Map<String,List<String>>> usersInSendEmailAction,String referenceId,String templateId,String objId){
        if(!usersInSendEmailAction.containsKey(referenceId)){
            //if no                       
            List<String> temp = new List<String>{templateId};
            Map<String ,List<String>> objTemp=  new Map<String ,List<String>>();
            objTemp.put(objId,temp);
            usersInSendEmailAction.put(referenceId,objTemp);
        }
        else{
            Map<String ,List<String>> objTemp = usersInSendEmailAction.get(referenceId);
            if(!objTemp.containsKey(objId))
                objTemp.put(objId,new List<String>{templateId});
            else

                objTemp.get(objId).add(templateId);
                
            usersInSendEmailAction.put(referenceId,objTemp);
        }
        return usersInSendEmailAction;
    }  */
    
    public static Map<String,Map<String,List<RuleAction__c>>> buildListForEmail(Map<String,Map<String,List<RuleAction__c>>> usersInSendEmailAction,String referenceId,RuleAction__c a,String objId){
        if(!usersInSendEmailAction.containsKey(referenceId)){
            //if no                       
            List<RuleAction__c> temp = new List<RuleAction__c>{a};
            Map<String ,List<RuleAction__c>> objTemp=  new Map<String ,List<RuleAction__c>>();
            objTemp.put(objId,temp);
            usersInSendEmailAction.put(referenceId,objTemp);
        }
        else{
            Map<String ,List<RuleAction__c>> objTemp = usersInSendEmailAction.get(referenceId);
            if(!objTemp.containsKey(objId))
                objTemp.put(objId,new List<RuleAction__c>{a});
            else

                objTemp.get(objId).add(a);
                
            usersInSendEmailAction.put(referenceId,objTemp);
        }
        return usersInSendEmailAction;
    }
      
     public static void StartAWSchedular(DateTime dt,String sobjType){
            
            //Integer delayTime = 15;
            AdvanceWorkflowConf__c conf = AdvanceWorkflowConf__c.getInstance('WorkflowConf');
            Integer delayTime = 0;
            if(conf == null){
                conf = new AdvanceWorkflowConf__c(name='WorkflowConf',Delay_Time__c=15,Batch_Size__c=100);
                insert conf;
            }
            if(conf != null && conf.Delay_Time__c >= 0){
                delayTime = Integer.valueOf(conf.Delay_Time__c);
            }
            
            
            DateTime thisTime = dt.addMinutes(delayTime);            
            integer minute = thisTime.minute();
            integer second = thisTime.second();
            integer hour = thisTime.hour();
            integer year = thisTime.year();
            integer month = thisTime.month();
            integer day = thisTime.day();
                    
            String timeStamp = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
            String cronJobID = System.schedule('New Scheduled Job' + System.now(),timeStamp, new AW_Advance_WorkflowScheduler(sobjType,dt));
     }
     
     
     
      
     public static void handleError(Exception e){
         system.debug(e);
         String msg = string.valueOf(e);
         List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
         AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowExecution.cls','applyInsertChildActions','AW_AdvanceWorkflowExecution.cls','LogEmail','');
        
     }  
}