public with sharing class AW_RetrieveVersionController {
	
	static 	String xmlString 						=	null;
	static	AW_ParseXML_Rule_Helper 				wfRule				=	null;
	static	AW_ParseXML_Criteria_Helper		  		auxCriteria			=	null;
	static	AW_ParseXML_Action_Helper 				auxAction			=	null;	
	static	AW_ParseXML_RelatedAction_Helper		auxRelatedAction	=	null;	
	static	Integer 			ruleNumber 			=	0;
	public  Rule_Archive__c		ruleArchive			=	null;
	static	decimal				version			=	0;
	Static	String				objeto				=	null;

	public AW_RetrieveVersionController(){
	
		list<Rule_Archive__c> ruleArchive = [SELECT body__c,Version__c,Object__c FROM Rule_Archive__c WHERE id =: ApexPages.currentPage().getParameters().get('id')];
		
		if(!ruleArchive.isEmpty()){
			//System.debug('\n---->BODY: '+ruleArchive.Body__c);
			xmlString	=	ruleArchive[0].Body__c;
			version		=	ruleArchive[0].Version__c;
			objeto		=	ruleArchive[0].Object__c;
			parser();
		}
	
	}	

	public static String  parser(){
		
		DOM.Document doc 	= 	new DOM.Document();     
  		try {
    		doc.load(xmlString);    
    		DOM.XMLNode root = doc.getRootElement();
    		walkThrough(root);

    		//Testeando objeto auxiliar FRAN
    		System.debug('\n--->Descripcion object: '+wFRule);

    		return null;
    	}catch (System.XMLException e) {  // invalid XML
    		return e.getMessage();
		}
	}
	

	
	public static void retrieveRule(){
		
		integer exists = 0;
		//Comprobar si existe una Rule (on name) con estado Active o draft, 
		//Si existe poner estado draft y name = name + dateTime (seconds)
		list<Rule__c> rule = [SELECT Name,status__c 
						FROM Rule__c 
						WHERE Name =: wfRule.ruleName AND ( (status__c = 'Active') OR (status__c = 'Draft') )];
						
		if( !rule.isEmpty()){
			exists = 1;
		}

		if(wfRule != null){
				
			Rule__c ruleSF 					=   new Rule__c();
			if(exists == 0){
				ruleSF.Name						=	wfRule.ruleName;
			}else{
				ruleSF.Name						=	wfRule.ruleName+datetime.now();
			}
			ruleSF.Object__c				=	objeto;
			ruleSF.Description__c			=	wfRule.description;
			ruleSF.Evaluation_Rule__c		=	wfRule.evaluationRule;
			ruleSF.DisplayfilterLogic__c	=	wfRule.ruleCriteria;
			ruleSF.Order__c					=	wfRule.orderRule;
			ruleSF.Execution_Behavior__c	=	'';   					//wfRule.executionBehavior
			ruleSF.Filter_Logic__c			=	wfRule.filterLogic;
			ruleSF.Version__c				=	null;					//version		
			ruleSF.Status__c				=	'Draft';						
			insert ruleSF;
//			listaRulesInsert.add(ruleSF);
					
			//Se insertan listas de criteria
			if(!wfRule.criterias.isEmpty()){
				for(AW_ParseXML_Criteria_Helper cr : wfRule.criterias){	
					RuleCriteria__c criteria		=   new RuleCriteria__c();
					criteria.field_name__c			= 	cr.criteriaName;	
					criteria.CrossFormula__c		= 	cr.crossFormula;
					criteria.Matching_Type__c		=	cr.matchingType;
					criteria.Matching_Value__c		=	cr.matchingValue1;
					criteria.Maximum_Value__c		=	cr.maximumValue;
					criteria.Minimum_Value__c		=	cr.minimumValue;
					criteria.Related_Object__c		=	cr.criteriarelatedObject;
					criteria.Rule__c				=	ruleSF.id;
					insert criteria;
				}
			}
					
			//Se insertan las listas de action
			if(!wfRule.actions.isEmpty()){
				for(AW_ParseXML_Action_Helper ac : wfRule.actions){	
					RuleAction__c action	     	=   new RuleAction__c();
					action.Related_Object__c		=	ac.actionrelatedObject;
					action.Field_API_Name__c		=	ac.actionfieldAPIName;
					action.Type__c					=	ac.typeAction;
					action.Field_Name__c			=	ac.actionfieldName;
					action.Value__c					=	ac.actionvalue;
					action.Long_Value__c			=	ac.actionlongValue;
					action.Email_Template__c		=	ac.actionEmail_Template;
					action.EmailTemplateName__c 	=	ac.actionEmailTemplateName;
					action.CrossObjectField__c		=	ac.actionCrossObjectField;
					action.Field_Type__c			=	ac.actionField_Type;
					action.Reference_Id__c			=	ac.actionReference_Id;
					action.User_Owner_Id__c			=	ac.actionUser_Owner;
					action.Rule__c					=	ruleSF.Id;
					if(ac.actionnotifyUser == 'TRUE') action.Notify_User__c = true;
					insert action;
							
					//Se insertan las listas RelatedActions
					if(!ac.listaRAction.isEmpty()){
						for(AW_ParseXML_RelatedAction_Helper ra : ac.listaRAction){
							Values_for_Action_Insert_Record__c relatedAction	=   new Values_for_Action_Insert_Record__c();
							relatedAction.Rule_Action__c	=	action.id;
							relatedAction.Name				=	ra.FieldName;
							relatedAction.Value__c			=	ra.value;
							insert relatedAction;
						}								
					}
							
				}
						
			}					
		}
				
	}
	
	//Se mapea el XML en objeto auxliar WFAdvance
	public static void walkThrough(DOM.XMLNode node) {
		
 		String result = '\n';
  		if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
  						
  			
  			/*---------SECCION RULE----------*/
  			if(node.getName() 		== 'RULE_NAME'){	
  				
  				ruleNumber++;			
  				wfRule				=	new AW_ParseXML_Rule_Helper();
  				wfRule.ruleNumber	=	ruleNumber;
  				wfRule.ruleName		=	node.getAttribute('name', null);
  			}
  			else if(node.getName() 	== 'RULE_DESCRIPTION'){
  				wfRule.description	=	node.getText();
  			}else if(node.getName() == 'ORDER' && node.getText()!='null' ){
  				wfRule.orderRule	=	integer.valueOf(node.getText());
  			}else if(node.getName() == 'EVALUATION_RULE'){
  				wfRule.evaluationRule	=	node.getText();
  			}else if(node.getName() == 'EXECUTION_BEHAVIOR'){
  				wfRule.executionBehavior	=	node.getText();
  			}else if(node.getName() == 'DISPLAYFILTERLOGIC'){
  				wfRule.ruleCriteria	=	node.getText();
  			}else if(node.getName() == 'FILTER_LOGIC'){
  				wfRule.filterLogic	=	node.getText();
  			}
  			
  			
  			/*----- CRITERIA SECTION-------------*/
  			else if(node.getName() == 'CRITERIA'){
  				auxCriteria			=	new AW_ParseXML_Criteria_Helper();
  				wfRule.criterias.add(auxCriteria);
  			}else if(node.getName() == 'RULE_CRITERIA_FIELD_NAME'){
  				auxCriteria.criteriaName	=	node.getText();
  			}else if(node.getName() == 'CrossFormula'){
  				auxCriteria.crossFormula	=	node.getText();
  			}else if(node.getName() == 'MATCHING_TYPE'){
  				auxCriteria.matchingType	=	node.getText();
  			}else if(node.getName() == 'MATCHING_VALUE'){
  				auxCriteria.matchingValue1	=	node.getText();
  			}else if(node.getName() == 'MAXIMUM_VALUE'){
  				auxCriteria.maximumValue	=	node.getText();
  			}else if(node.getName() == 'MINIMUM_VALUE'){
  				auxCriteria.minimumValue	=	node.getText();
  			}else if(node.getName() == 'RELATED_OBJECT_CRITERIA'){
  				auxCriteria.criteriarelatedObject	=	node.getText();
  			}    
  			
  			
  			/*---- ACTION SECTION   ------------*/
  			else if(node.getName() == 'ACTION'){
  				auxAction		=		new AW_ParseXML_Action_Helper();
  				wfRule.actions.add(auxAction);
  			}else if(node.getName() == 'RELATED_OBJECT_ACTION'){
  				auxAction.actionrelatedObject = node.getText();
  			}else if(node.getName() == 'ACTION_TYPE'){
  				auxAction.typeAction = node.getText();
  			}else if(node.getName() == 'Field_Name'){
  				auxAction.actionfieldName = node.getText();
  			}else if(node.getName() == 'VALUE_for_Update'){
  				auxAction.actionvalue = node.getText();
  			}else if(node.getName() == 'LONG_VALUE'){
  				auxAction.actionlongValue = node.getText();
  			}else if(node.getName() == 'NOTIFY_USER'){
  				auxAction.actionnotifyUser = node.getText();
  			}else if(node.getName() == 'REFERENCE_ID'){
  				auxAction.actionReference_Id = node.getText();
  			}else if(node.getName() == 'CROSSOBJECTFIELD'){
  				auxAction.actionCrossObjectField = node.getText();
  			}else if(node.getName() == 'ACTION_USER_OWNER'){
  				auxAction.actionUser_Owner = node.getText();
  			}else if(node.getName() == 'ACTION_FIELD_API_NAME'){
  				auxAction.actionfieldAPIName = node.getText();
  			}else if(node.getName() == 'EMAIL_TEMPLATE_NAME'){
  				auxAction.actionEmailTemplateName = node.getText();
  			}else if(node.getName() == 'EMAIL_TEMPLATE'){
  				auxAction.actionEmail_Template = node.getText();
  			}else if(node.getName() == 'EMAIL_TEMPLATE'){
  				auxAction.actionEmail_Template = node.getText();
  			}
  			
  			
  			/*----SECCION RELATEDOBJECT-ACTION--*/
  			else if(node.getName() == 'Insert_Field'){
  				system.debug('>>Insert_Field'+ node.getName());
  				auxRelatedAction	=	new AW_ParseXML_RelatedAction_Helper();
  				auxAction.listaRAction.add(auxRelatedAction);
  			}else if(node.getName() == 'Field_Name_Insert'){
  				system.debug('>>Insert_Field'+ node.getName());
  				system.debug('>>Insert_Field'+ node.getText());
  				auxRelatedAction.fieldName = node.getText();
  			}else if(node.getName() == 'Value_For_Insert'){
  				auxRelatedAction.value = node.getText();
  				system.debug('>>Insert_Field'+ node.getText());
  			}
  			
		    for (Dom.XMLNode child: node.getChildElements()) {
		      walkThrough(child);
		    }
		    		    
	  	}
 	  	
	}

	@isTest
	static void MyTest() {
		
				 String body = 		'<RULE_NAME name="Account Rule NAME B">'+
									'<RULE_DESCRIPTION>DESCRIPTION FIELD SAMPLE ACOUNT RULE WITH 2 FILTER CRITERIA AND 6 ACTION</RULE_DESCRIPTION>'+
									'<AVAILABLE>True</AVAILABLE>'+
									'<ORDER>0</ORDER>'+
									'<EVALUATION_RULE>"Record is created or edited and did not previously meet the rule criteria"</EVALUATION_RULE>'+
									'<EXECUTION_BEHAVIOR>null</EXECUTION_BEHAVIOR>'+
									'<DISPLAYFILTERLOGIC>Account.CrossFormula = Inside Sales AND Account.BillingCountry != USA</DISPLAYFILTERLOGIC>'+
									'<FILTER_LOGIC>null</FILTER_LOGIC>'+
									'<RULE_CRITERIA_SECTION>'+
									'<CRITERIA num="1">'+
									'<RULE_CRITERIA_FIELD_NAME>"CrossFormula"</RULE_CRITERIA_FIELD_NAME>'+
									'<CrossFormula>null</CrossFormula>'+
									'<MATCHING_TYPE>"Equals"</MATCHING_TYPE>'+
									'<MATCHING_VALUE>"Inside Sales"</MATCHING_VALUE>'+
									'<MAXIMUM_VALUE>null</MAXIMUM_VALUE>'+
									'<MINIMUM_VALUE>null</MINIMUM_VALUE>'+
									'<RELATED_OBJECT_CRITERIA>null</RELATED_OBJECT_CRITERIA>'+
									'</CRITERIA>'+
									'<CRITERIA num="2">'+
									'<RULE_CRITERIA_FIELD_NAME>"BillingCountry"</RULE_CRITERIA_FIELD_NAME>'+
									'<CrossFormula>null</CrossFormula>'+
									'<MATCHING_TYPE>"Equals"</MATCHING_TYPE>'+
									'<MATCHING_VALUE>"Inside Sales"</MATCHING_VALUE>'+
									'<MAXIMUM_VALUE>null</MAXIMUM_VALUE>'+
									'<MINIMUM_VALUE>null</MINIMUM_VALUE>'+
									'<RELATED_OBJECT_CRITERIA>"Opp"</RELATED_OBJECT_CRITERIA>'+
									'</CRITERIA>'+
									'</RULE_CRITERIA_SECTION>'+
									'<RULE_ACTION_SECTION>'+
									'<ACTION num="1">'+
									'<RELATED_OBJECT_ACTION>null</RELATED_OBJECT_ACTION>'+
									'<ACTION_TYPE>null</ACTION_TYPE>'+
									'<Field_Name>null</Field_Name>'+
									'<VALUE_for_Update>null</VALUE_for_Update>'+
									'<LONG_VALUE>null</LONG_VALUE>'+
									'<NOTIFY_USER>false</NOTIFY_USER>'+
									'<EMAIL_TEMPLATE>null</EMAIL_TEMPLATE>'+
									'</ACTION>'+
									'<ACTION num="2">'+
									'<RELATED_OBJECT_ACTION>null</RELATED_OBJECT_ACTION>'+
									'<ACTION_TYPE>null</ACTION_TYPE>'+
									'<Field_Name>null</Field_Name>'+
									'<VALUE_for_Update>null</VALUE_for_Update>'+
									'<LONG_VALUE>null</LONG_VALUE>'+
									'<NOTIFY_USER>false</NOTIFY_USER>'+
									'<EMAIL_TEMPLATE>null</EMAIL_TEMPLATE>'+
									'<INSERT_RELATED_OBJECT_SECTION>'+
									'<Insert_Field>1</Insert_Field>'+
									'<Field_Name_Insert>"LastName"</Field_Name_Insert>'+
									'<Value_For_Insert>"Barr"</Value_For_Insert>'+
									'<Insert_Field>2</Insert_Field>'+
									'<Field_Name_Insert>"Department"</Field_Name_Insert>'+
									'<Value_For_Insert>"Finance"</Value_For_Insert>'+
									'</INSERT_RELATED_OBJECT_SECTION>'+
									'</ACTION>'+
									'</RULE_ACTION_SECTION>'+
									'</RULE_NAME>';				

	
		Rule_Archive__c ruleArchive =  new Rule_Archive__c(Object__c = 'account');
		ruleArchive.Body__c	= body;
		insert ruleArchive;	
		
		PageReference pageRef = Page.AW_RetrieveVersion_VF;
		Test.setCurrentPage(pageRef);
		
		pageRef.getParameters().put('id', ruleArchive.id);
		
	 	AW_RetrieveVersionController retrieveVersion1	=	new AW_RetrieveVersionController();
	 	
	 	AW_RetrieveVersionController.xmlString = body;
	 	     
        Rule__c rule	=	new Rule__c(Name = 'Account Rule NAME B',status__c = 'Active',version__c = 1,description__c = 'descripcion',
        								Evaluation_Rule__c='evaluation',Object__c='account');
       	insert rule;	 
       	
        AW_RetrieveVersionController.retrieveRule();
       		
	 	
	}	
	
}