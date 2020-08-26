//
// (c) 2012 Appirio, Inc.
// AW_ImportExport_Controller                                                     
// This class is used to parse Advance Workflow in XML format
//
// 18 Nov 2012     Peter Babalis     Original
// 26 Jan 2012     Peter Babalis     Added Status and Version  for Rules
// 29 Mar 2013     Peter Babalis     Determines Import/Export Action and replaces the special character
//  
//
public with sharing class AW_ImportExport_Controller {

public  Boolean     chkImport   {get;set;}
    public  String      AWFId       {get;set;}
    public  String      option      {get;set;}
    public  String      ruleOpt     {get;set;}
    public  Boolean     initOption  {get;set;}
    public  Blob        xmlFile     {get;set;}
    public AW_ImportExport_Controller(){
        this.chkImport  =   false;
        this.option     =   '';
        this.ruleOpt    =   '';
        this.initOption =   false;
        this.xmlFile    =   null;
        this.AWFId      =   ApexPages.currentPage().getParameters().get('id');

    }
    public  Pagereference   checkAction(){
        initOption  =   true;
        chkImport   =   (option == '0')?true:false;
        return null;
    }   
    public  Pagereference cancel(){

        transient   Pagereference currPage  =   ApexPages.currentPage();
        transient   String  returnURL       =   currPage.getURL().substringBefore('apex') + AWFId;
        return new Pagereference(returnURL);
    }
    public  Pagereference   start(){
        if(option == '0')
            return importProcess();
        else
            return exportProcess();
    }   
    public  List<SelectOption> getRadioOptions() {
        transient   List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('0','Import')); 
        options.add(new SelectOption('1','Export')); 
        return options; 
    }   
    public  List<SelectOption> getRuleOptions() {
        transient   List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('0','--None--')); 
        options.add(new SelectOption('1','Draft')); 
        options.add(new SelectOption('2','Active'));
        options.add(new SelectOption('3','Draft & Active'));
        return options; 
    }   
    
        public static String charsToescapechars(String str){
          if(str!=null){    
	        if(str.contains('&amp;')){
	          
	            str = str.replaceAll('&amp;', '&');
	            }
	         if(str.contains('&euro;')){
	            str = str.replaceAll('&euro;', '€');
		     }
		     if(str.contains('&lt;')){
		            str = str.replaceAll('&lt;', '<');
		     }
		     if(str.contains('&gt;')){
		            str = str.replaceAll('&gt;', '>');
		     }
          }       
	        return str; 
        }
        
        public static String escapecharsTochars(String str){
        
        if(str!=null){       
	        if(str.contains('&')){
	            str = str.replaceAll('&', '&amp;');
	            }
	        if(str.contains('€')){
	            str = str.replaceAll('€', '&euro;');
	        }
	        if(str.contains('<')){
	            str = str.replaceAll('<', '&lt;');
	        }
	        if(str.contains('>')){
	            str = str.replaceAll('>', '&gt;');
	        }
        }
        return str;
    }
     
    
    public Pagereference   importProcess(){
        if(xmlFile == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please, select an XML File.'));
            xmlFile =   null;
            return null;
        }
        system.debug('--->importProcess ');
        String  refRule =   String.valueOf( Datetime.now() + Crypto.getRandomInteger());
        
         // AW_ParseXMLTo_AdvanceWorkflow_Util.parser(escapecharsTochars(xmlFile.toString()), refRule, AWFId);
         AW_ParseXMLTo_AdvanceWorkflow_Util.parser(xmlFile.toString(), refRule, AWFId);
      
        xmlFile = null;
        return new Pagereference('/apex/AW_AdvanceWorkflowImportResult_VF?id=' + AWFId + '&refRule=' + refRule);        
    }
    public Pagereference   exportProcess(){
        transient   Boolean     success =   false;
        //String        
        if(ruleOpt == '0'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please, select an export option.'));
            xmlFile =   null;
            return null;
        }       
        List<Advance_Workflow__c>   currentAWF  =   [Select Object__c, Name, Enabled__c, Description__c From Advance_Workflow__c where Id =: AWFId];
        if(currentAWF.size() > 0 && currentAWF != null && !currentAWF.isEmpty()){   
            success =   true;   
    
                
            String  awfHeader   =   '<?xml version="1.0" encoding="ISO-8859-1" ?>'  +   '\n' +
                                    '<DVANCE_WORKFLOW>' + '\n' +
                                        '<DVANCE_WORKFLOW_NAME  name="' + currentAWF[0].Name + '">' + '\n' +
                                            '<DESCRIPTION>' + currentAWF[0].Description__c + '</DESCRIPTION>' + '\n' +
                                            '<OBJECT>' + currentAWF[0].Object__c + '</OBJECT>' +    '\n' +
                                            '<ENABLED>' + currentAWF[0].Enabled__c + '</ENABLED>' +     '\n';
            String  awfBody     =   createXMLBody();
            String  awfFooter   =       '</DVANCE_WORKFLOW_NAME>' +     '\n' +  
                                    '</DVANCE_WORKFLOW>';   

            Attachment fileAttached     =   new Attachment();
            fileAttached.Name           =   currentAWF[0].Name+'-'+datetime.now() + '.xml';
            fileAttached.Body           =   Blob.valueOf(awfHeader + awfBody + awfFooter);
            fileAttached.ParentId       =   currentAWF[0].Id;
            insert fileAttached;
            AW_SendEmailUtil.sendEmailwithAttachment(fileAttached);                                             
            return new Pagereference('/apex/AW_AdvanceWorkflowExportResult_VF?success=' + success + '&id=' + AWFId);  
        }
        else    
            return new Pagereference('/apex/AW_AdvanceWorkflowExportResult_VF?success=' + success + '&id=' + AWFId);  
         }
      
    private String  createXMLBody(){
        String  body = '';
        String  optionQuery;
        String  optionCriteriaQuery;
        String  optionActionQuery;
        String ruleCriteriaQuery;
        String ruleActionQuery;
        String  ruleQuery;
        map<Id,list<Values_for_Action_Insert_Record__c>>    mapa            =   new map<Id,list<Values_for_Action_Insert_Record__c>> ();
        set<Id>                                             ruleActionID    =   new set<id>();
        Map<String, List<RuleCriteria__c>>                  criteriaMap     =   new Map<String, List<RuleCriteria__c>>();
        Map<String, List<RuleAction__c>>                    actionMap       =   new Map<String, List<RuleAction__c>>();
    
        List<Rule__c>         rl                    =   [select Name,Id,
        														Status__c,
        														Version__c,
                                                                Object__c
                                                          from Rule__c 
                                                          where Advance_Workflow__c =: AWFId ];
         
        if(ruleOpt == '1'){     
            optionCriteriaQuery=' and Rule__r.Advance_Workflow__c = null';
            ruleCriteriaQuery='select Name,Rule__c,field_name__c, Field_API_Name__c,Field_Type__c,CrossFormula__c, Matching_Type__c,Matching_Value__c, Maximum_Value__c, Minimum_Value__c, Related_Object__c from RuleCriteria__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\''+optionCriteriaQuery;
            //system.debug('>>>> ruleCriteriaQuery '+ ruleCriteriaQuery);
          
            
         
            optionActionQuery=' and Rule__r.Advance_Workflow__c = null';
            ruleActionQuery='select Name,Rule__c,Related_Object__c, CrossObjectField__c,Type__c,Field_Type__c, Field_API_Name__c,Field_Name__c, Reference_Id__c,Value__c,Long_Value__c,Notify_User__c,Email_Template__c,EmailTemplateName__c, ';
            ruleActionQuery=ruleActionQuery+'Additional_Emails__c, Apex_Job_Class__c, CallOut_Action__c, Callout_Method__c,';
            ruleActionQuery=ruleActionQuery+'Callout_Timeout__c,Lookup_Where_Fields__c, End_Point__c, Endpoint_URL__c,';
            ruleActionQuery=ruleActionQuery+'Input_Parameters__c,Lookup_Field_API_Name__c, Lookup_Field_Name__c, Lookup_Object__c,';
            ruleActionQuery=ruleActionQuery+'Output_Parameters__c,Request_Parameter__c,Response_Parameter__c,Bulk_API__c,User_Owner_Id__c';
            ruleActionQuery=ruleActionQuery+' from RuleAction__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\''+optionActionQuery;
            //system.debug('>>>> ruleActionQuery '+ ruleActionQuery);
    
            optionQuery     =    ' and Status__c in ('+ '\'Draft\''+')';
            ruleQuery   =   'select Id, Name, Object__c, Status__c,Version__c, Evaluation_Rule__c, Filter_Logic__c,FormattedFilterLogic__c,DisplayfilterLogic__c, Description__c  from Rule__c where  Object__c =\'' + rl[0].Object__c+ '\''+optionQuery;
            //system.debug('>>>> ruleQuery '+ ruleQuery);
        } 
        else if(ruleOpt == '2') {
            optionCriteriaQuery= ' and Rule__r.Advance_Workflow__c = \''  + AWFId + '\'' ;
            ruleCriteriaQuery='select Name,Rule__c,field_name__c,Field_API_Name__c,Field_Type__c, CrossFormula__c, Matching_Type__c,Matching_Value__c, Maximum_Value__c, Minimum_Value__c, Related_Object__c from RuleCriteria__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\''+optionCriteriaQuery;
           // system.debug('>>>> ruleCriteriaQuery '+ ruleCriteriaQuery);
    
            optionActionQuery= ' and Rule__r.Advance_Workflow__c = \''  + AWFId + '\'' ;
            ruleActionQuery='select Name,Rule__c,Related_Object__c, CrossObjectField__c,Type__c,Field_Type__c, Field_API_Name__c,Field_Name__c, Reference_Id__c,Value__c,Long_Value__c,Notify_User__c,Email_Template__c,EmailTemplateName__c, ';
            ruleActionQuery=ruleActionQuery+'Additional_Emails__c, Apex_Job_Class__c, CallOut_Action__c,  Callout_Method__c,';
            ruleActionQuery=ruleActionQuery+'Callout_Timeout__c,Lookup_Where_Fields__c, End_Point__c, Endpoint_URL__c,';
            ruleActionQuery=ruleActionQuery+'Input_Parameters__c,Lookup_Field_API_Name__c, Lookup_Field_Name__c, Lookup_Object__c,';
            ruleActionQuery=ruleActionQuery+'Output_Parameters__c,Request_Parameter__c,Response_Parameter__c,Bulk_API__c,User_Owner_Id__c';
            ruleActionQuery=ruleActionQuery+' from RuleAction__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\''+optionActionQuery;
    
           system.debug('>>>> ruleActionQuery '+ ruleActionQuery);
         
            optionQuery     =   ' and Status__c = \'Active\'';
            ruleQuery   =   'select Id, Name, Object__c, Status__c,Version__c, Evaluation_Rule__c, Filter_Logic__c,FormattedFilterLogic__c,DisplayfilterLogic__c, Description__c  from Rule__c where Advance_Workflow__c =\'' + AWFId + '\'' + optionQuery;  
            optioncriteriaQuery ='';
            // system.debug('>>>> ruleQuery '+ ruleQuery);
        }  
        else if(ruleOpt == '3'){
            optionCriteriaQuery='';
            ruleCriteriaQuery='select Name,Rule__c,field_name__c,Field_API_Name__c,Field_Type__c, CrossFormula__c, Matching_Type__c,Matching_Value__c, Maximum_Value__c, Minimum_Value__c, Related_Object__c from RuleCriteria__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\'';
           // system.debug('>>>> ruleCriteriaQuery '+ ruleCriteriaQuery);
            
            optionActionQuery='';
            ruleActionQuery='select Name,Rule__c,Related_Object__c, CrossObjectField__c,Type__c,Field_Type__c, Field_API_Name__c,Field_Name__c, Reference_Id__c,Value__c,Long_Value__c,Notify_User__c,Email_Template__c,EmailTemplateName__c, ';
            ruleActionQuery=ruleActionQuery+'Additional_Emails__c, Apex_Job_Class__c, CallOut_Action__c, Callout_Method__c,';
            ruleActionQuery=ruleActionQuery+'Callout_Timeout__c,Lookup_Where_Fields__c, End_Point__c, Endpoint_URL__c,';
            ruleActionQuery=ruleActionQuery+'Input_Parameters__c,Lookup_Field_API_Name__c, Lookup_Field_Name__c, Lookup_Object__c,';
            ruleActionQuery=ruleActionQuery+'Output_Parameters__c,Request_Parameter__c,Response_Parameter__c,Bulk_API__c,User_Owner_Id__c';
            ruleActionQuery=ruleActionQuery+' from RuleAction__c where Rule__r.Object__c =\'' + rl[0].Object__c+ '\''+optionActionQuery;
    
                // system.debug('>>>> ruleActionQuery '+ ruleActionQuery);
         
            optionQuery     =    ' and Status__c in ('+ '\'Draft\''+','+'\'Active\'' +')';
            ruleQuery   =   'select Id, Name, Status__c,Version__c,Object__c,  Evaluation_Rule__c, Filter_Logic__c,FormattedFilterLogic__c,DisplayfilterLogic__c, Description__c  from Rule__c where  Object__c =\'' + rl[0].Object__c+ '\''+optionQuery;
        //  ruleQuery   =   'select Id, Name, Object__c,  Evaluation_Rule__c, Filter_Logic__c,FormattedFilterLogic__c,DisplayfilterLogic__c, Description__c  from Rule__c';
            system.debug('>>>> ruleQuery '+ ruleQuery);
           }
       
        List<RuleCriteria__c>   criterias = Database.query(ruleCriteriaQuery); 
        List<RuleAction__c>     actions   = Database.query(ruleActionQuery);
        for(RuleAction__c action : actions){
            ruleActionID.add(action.id);    
        }       
        
        for(Values_for_Action_Insert_Record__c Vaction : [SELECT Name, value__C,Rule_Action__c FROM Values_for_Action_Insert_Record__c WHERE Rule_Action__c IN : ruleActionID] ){
            if(!mapa.containsKey(Vaction.Rule_Action__c))
                mapa.put(Vaction.Rule_Action__c,new list<Values_for_Action_Insert_Record__c> {Vaction});
            else{
                mapa.get(Vaction.Rule_Action__c).add(Vaction);
            }           
        }                                                                   
                                                                                                                                
                                                                
        for(RuleCriteria__c rc : criterias){            
            if(criteriaMap.get(rc.Rule__c) == null){
                List<RuleCriteria__c> listCrit  =   new List<RuleCriteria__c>();                
                criteriaMap.put(rc.Rule__c, listCrit);
            }
            criteriaMap.get(rc.Rule__c).add(rc);            
        }   
        for(RuleAction__c ra : actions){            
            if(actionMap.get(ra.Rule__c) == null){
                List<RuleAction__c> listAct =   new List<RuleAction__c>();              
                actionMap.put(ra.Rule__c, listAct);
            }
            actionMap.get(ra.Rule__c).add(ra);
            
        }       
       
            
     //     ruleQuery   =   'select Id, Name, Object__c,  Evaluation_Rule__c, Filter_Logic__c,FormattedFilterLogic__c,DisplayfilterLogic__c, Description__c  from Rule__c where Advance_Workflow__c =\'' + AWFId + '\'' + optionQuery;  
        List<Rule__c>   rules = Database.query(ruleQuery); 
        system.debug('>>>> ruleQuery '+ ruleQuery);
         
        if(rules.size() > 0 && rules != null && !rules.isEmpty()){  
            for(Rule__c r : rules){
                body += '<RULE_NAME name="\'' + r.Name + '">' + '\n';
                body += '<EVALUATION_RULE>' + r.Evaluation_Rule__c + '</EVALUATION_RULE>' + '\n';
                body += '<RULE_STATUS>' + r.Status__c + '</RULE_STATUS>' + '\n';
                body += '<RULE_VERSION>' + r.Version__c + '</RULE_VERSION>' + '\n';
                body += '<RULE_DESCRIPTION>' + escapecharsTochars(r.Description__c) + '</RULE_DESCRIPTION>' + '\n';
                body += '<DISPLAYFILTERLOGIC>' + escapecharsTochars(r.DisplayfilterLogic__c)  + '</DISPLAYFILTERLOGIC>' + '\n';    
            
                body += '<FILTER_LOGIC>' + r.Filter_Logic__c + '</FILTER_LOGIC>' + '\n';    
                             
                Integer iterator = 1;
                if(criteriaMap.get(r.Id) != null){                  
                    body += '<RULE_CRITERIA_SECTION>' + '\n';
                    for(RuleCriteria__c rc : criteriaMap.get(r.Id)){
                        body +=  '<CRITERIA num=' +'"'+ iterator +'"'+ '>' + '\n';
                        body +=  '<CRITERIA_FIELD_NAME>'+rc.field_name__c+'</CRITERIA_FIELD_NAME>' + '\n';
                        body +=  '<CRITERIA_FIELD_API_NAME>'+rc.field_api_name__c+'</CRITERIA_FIELD_API_NAME>' + '\n';
                        body +=  '<CRITERIA_FIELD_TYPE>'+rc.field_type__c+'</CRITERIA_FIELD_TYPE>' + '\n';
                        body +=  '<CROSSFORMULA>'+rc.CrossFormula__c+'</CROSSFORMULA>' + '\n';
                        body +=  '<MATCHING_TYPE>'+rc.Matching_Type__c+'</MATCHING_TYPE>' + '\n';
                        body +=  '<MATCHING_VALUE>'+ rc.Matching_Value__c +'</MATCHING_VALUE>' + '\n';
                        body +=  '<MAXIMUM_VALUE>'+rc.Maximum_Value__c+'</MAXIMUM_VALUE>' + '\n';
                        body +=  '<MINIMUM_VALUE>'+rc.Minimum_Value__c+'</MINIMUM_VALUE>' + '\n';
                        body +=  '<RELATED_OBJECT_CRITERIA>'+rc.Related_Object__c+'</RELATED_OBJECT_CRITERIA>' + '\n';
                        body +=  '</CRITERIA>' + '\n';
                        iterator++;                 
                    }                   
                    body +=  '</RULE_CRITERIA_SECTION>' + '\n';
                }
                iterator = 1;
                if(actionMap.get(r.Id) != null){ 
                    body += '<RULE_ACTION_SECTION>' + '\n';
                    for(RuleAction__c ra : actionMap.get(r.Id)){
                        body +=  '<ACTION num=' +'"'+iterator+'"'+ '>' + '\n';
                        if( ra.Related_Object__c !=null )body +=  '<RELATED_OBJECT_ACTION>'+ra.Related_Object__c+'</RELATED_OBJECT_ACTION>' + '\n';
                    	   else body +=  '<RELATED_OBJECT_ACTION>'+'</RELATED_OBJECT_ACTION>' + '\n';
                    	if( ra.Type__c !=null )body +=  '<ACTION_TYPE>'+ra.Type__c+'</ACTION_TYPE>' + '\n';
                        	else body +=  '<ACTION_TYPE>'+'</ACTION_TYPE>' + '\n';
                        if( ra.Field_Name__c !=null ) body +=  '<ACTION_FIELD_NAME>'+ra.Field_Name__c+'</ACTION_FIELD_NAME>' + '\n';
                        	else body +=  '<ACTION_FIELD_NAME>'+'</ACTION_FIELD_NAME>' + '\n';
                        if( ra.Field_TYPE__c !=null )body +=  '<ACTION_FIELD_TYPE>'+ra.Field_TYPE__c+'</ACTION_FIELD_TYPE>' + '\n';
                       	 	else body +=  '<ACTION_FIELD_TYPE>'+'</ACTION_FIELD_TYPE>' + '\n';
                        if( ra.Field_API_Name__c !=null ) body +=  '<ACTION_FIELD_API_NAME>'+ra.Field_API_Name__c+'</ACTION_FIELD_API_NAME>' + '\n';
                       	 	else body +=  '<ACTION_FIELD_API_NAME>'+'</ACTION_FIELD_API_NAME>' + '\n';
                        if( ra.Value__c !=null ) body +=  '<VALUE_for_Update>'+ra.Value__c+'</VALUE_for_Update>' + '\n';
                         	else body +=  '<VALUE_for_Update>'+'</VALUE_for_Update>' + '\n';
                        if( ra.Long_Value__c !=null )body +=  '<LONG_VALUE>'+ra.Long_Value__c+'</LONG_VALUE>' + '\n';
                    		else body +=  '<LONG_VALUE>'+'</LONG_VALUE>' + '\n';
                        body +=  '<NOTIFY_USER>'+ra.Notify_User__c+'</NOTIFY_USER>' + '\n';
                        if( ra.CrossObjectField__c !=null ) body +=  '<CROSSOBJECTFIELD>'+ra.CrossObjectField__c+'</CROSSOBJECTFIELD>' + '\n';
                    	    else body +=  '<CROSSOBJECTFIELD>'+'</CROSSOBJECTFIELD>' + '\n';
                        if( ra.Reference_Id__c !=null ) body +=  '<REFERENCE_ID>'+ra.Reference_Id__c+'</REFERENCE_ID>' + '\n';
                   	       else body +=  '<REFERENCE_ID>'+'</REFERENCE_ID>' + '\n';
                        if( ra.User_Owner_Id__c !=null )body +=  '<ACTION_USER_OWNER>'+ra.User_Owner_Id__c+'</ACTION_USER_OWNER>' + '\n';
                            else body += '<ACTION_USER_OWNER>'+'</ACTION_USER_OWNER>' + '\n';
                        if( ra.EmailTemplateName__c !=null )body +=  '<EMAIL_TEMPLATE_NAME>'+ra.EmailTemplateName__c+'</EMAIL_TEMPLATE_NAME>' + '\n';
                      	   else body += '<EMAIL_TEMPLATE_NAME>'+'</EMAIL_TEMPLATE_NAME>' + '\n';
                        if( ra.Email_Template__c !=null )body +=  '<EMAIL_TEMPLATE>'+ra.Email_Template__c+'</EMAIL_TEMPLATE>' + '\n';
                       	 	else body += '<EMAIL_TEMPLATE>'+'</EMAIL_TEMPLATE>' + '\n';
                       
                      
                        if( ra.Additional_Emails__c !=null )body +=  '<ADDITIONAL_EMAILS>'+ra.Additional_Emails__c+'</ADDITIONAL_EMAILS>' + '\n';
 							 else body += '<ADDITIONAL_EMAILS>'+'</ADDITIONAL_EMAILS>' + '\n';
                        if( ra.Apex_Job_Class__c !=null )body +=  '<APEX_JOB_CLASS>'+ra.Apex_Job_Class__c+'</APEX_JOB_CLASS>' + '\n';
 						 	 else body += '<APEX_JOB_CLASS>'+'</APEX_JOB_CLASS>' + '\n';
                        if( ra.CallOut_Action__c !=null )body +=  '<CALLOUT_ACTION>'+ra.CallOut_Action__c+'</CALLOUT_ACTION>' + '\n';
 						 	 else body += '<CALLOUT_ACTION>'+'</CALLOUT_ACTION>' + '\n';
                        if( ra.Callout_Method__c !=null )body +=  '<CALLOUT_METHOD>'+ra.Callout_Method__c+'</CALLOUT_METHOD>' + '\n';
 						 	 else body += '<CALLOUT_METHOD>'+'</CALLOUT_METHOD>' + '\n';
                       	if( ra.Callout_Timeout__c !=null )body +=  '<CALLOUT_TIMEOUT>'+ra.Callout_Timeout__c+'</CALLOUT_TIMEOUT>' + '\n';
 						 	 else body += '<CALLOUT_TIMEOUT>'+'</CALLOUT_TIMEOUT>' + '\n';
                        if( ra.Lookup_Where_Fields__c !=null )body +=  '<LOOKUP_WHERE_FIELDS>'+ra.Lookup_Where_Fields__c+'</LOOKUP_WHERE_FIELDS>' + '\n';
 						  	 else body += '<LOOKUP_WHERE_FIELDS>'+'</LOOKUP_WHERE_FIELDS>' + '\n';
                        if( ra.End_Point__c !=null )body +=  '<END_POINT>'+ra.End_Point__c+'</END_POINT>' + '\n';
 						   	 else body += '<END_POINT>'+'</END_POINT>' + '\n';
                       if( ra.Endpoint_URL__c !=null )body +=  '<ENDPOINT_URL>'+ra.Endpoint_URL__c+'</ENDPOINT_URL>' + '\n';
 					 	    else body += '<ENDPOINT_URL>'+'</ENDPOINT_URL>' + '\n';
                       if( ra.Input_Parameters__c !=null ) body +=  '<INPUT_PARAMETERS>'+ra.Input_Parameters__c+'</INPUT_PARAMETERS>' + '\n';
 					   		 else body += '<INPUT_PARAMETERS>'+'</INPUT_PARAMETERS>' + '\n';
                       if( ra.Lookup_Field_API_Name__c !=null ) body +=  '<LOOKUP_FIELD_API_NAME>'+ra.Lookup_Field_API_Name__c+'</LOOKUP_FIELD_API_NAME>' + '\n'; 
                       		else body += '<LOOKUP_FIELD_API_NAME>'+'</LOOKUP_FIELD_API_NAME>' + '\n';
                       if( ra.Lookup_Field_Name__c !=null ) body +=  '<LOOKUP_FIELD_NAME>'+ra.Lookup_Field_Name__c+'</LOOKUP_FIELD_NAME>' + '\n'; 
                       		else body += '<LOOKUP_FIELD_NAME>'+'</LOOKUP_FIELD_NAME>' + '\n';
                       if( ra.Lookup_Object__c !=null ) body +=  '<LOOKUP_OBJECT>'+ra.Lookup_Object__c+'</LOOKUP_OBJECT>' + '\n'; 
                       		else body += '<LOOKUP_OBJECT>'+'</LOOKUP_OBJECT>' + '\n';
                       if( ra.Output_Parameters__c !=null ) body +=  '<OUTPUT_PARAMETERS>'+ra.Output_Parameters__c+'</OUTPUT_PARAMETERS>' + '\n'; 
                       		else body += '<OUTPUT_PARAMETERS>'+'</OUTPUT_PARAMETERS>' + '\n';
                       if( ra.Request_Parameter__c !=null ) body +=  '<REQUEST_PARAMETER>'+ra.Request_Parameter__c+'</REQUEST_PARAMETER>' + '\n'; 
                       		else body += '<REQUEST_PARAMETER>'+'</REQUEST_PARAMETER>' + '\n';
                       if( ra.Response_Parameter__c !=null ) body +=  '<RESPONSE_PARAMETER>'+ra.Response_Parameter__c+'</RESPONSE_PARAMETER>' + '\n'; 
                       		else body += '<RESPONSE_PARAMETER>'+'</RESPONSE_PARAMETER>' + '\n';
                      body +=  '<BULK_API>'+ra.Bulk_API__c+'</BULK_API>' + '\n';
 					  if( ra.User_Owner_Id__c !=null ) body +=  '<USER_OWNER_ID>'+ra.User_Owner_Id__c+'</USER_OWNER_ID>' + '\n'; 
                       		else body += '<USER_OWNER_ID>'+'</USER_OWNER_ID>' + '\n';
                               
                        if(mapa.containsKey(ra.Id)){
                            body +=  '<INSERT_RELATED_OBJECT_SECTION>' + '\n';                          
                            Integer iterator2 = 1;
                            for(Values_for_Action_Insert_Record__c vAction : mapa.get(ra.Id)){  
                                body +=  '<Insert_Field>'+iterator+'</Insert_Field>' + '\n';
                                body +=  '<Field_Name_Insert>'+vAction.name+'</Field_Name_Insert>' + '\n';
                                body +=  '<Value_For_Insert>'+vAction.Value__c+'</Value_For_Insert>' + '\n'; 
                                iterator2++;                
                            }
                            body +=  '</INSERT_RELATED_OBJECT_SECTION>' + '\n';
                        }                       
                        
                        body +=  '</ACTION>' + '\n';
                        iterator++;                 
                    }                   
                    body +=  '</RULE_ACTION_SECTION>' + '\n';
                }               
                body += '</RULE_NAME>' + '\n';          
            } 
        }
        system.debug('BODY '+body);
        return body;
        
    }
}