/***********************************************************
Author      : Appirio [Hitesh - Dec 08, 2014]
Purpose     : Extension to the page - DealSheetAddEditPage

Modifications:

    NSHARP CASE 00121406 6.10.15   Modified
    Paras Dhingra S-302979 Modified Added Resource Search feature
    Paras Dhingra S-320690 Modified Added Enhancements to DS and DSLI sections
    Paras Dhingra 00126541 Modified Updated the EVA query for Resource search functionality
    NSHARP    S-334593    8.17.15  Modified
    Vipul Jain CASE 00140576 18.11.2015 - Modified.
    Connor Flynn/KJOVANOVIC Case00131301 Fixed Save and close button
***********************************************************/
public with sharing class DealSheetAddEditExtension2 {
    public String inputfromUser {get;set;}
    public List<Schema.FieldSetMember> fieldSetMemberList {get;set;}
    public List<Schema.FieldSetMember> EditDetailsfieldSetMemberList {get;set;} //Added by Nishank for Story S-299054
    public Set<Schema.FieldSetMember> AllfieldSetMemberSet {get;set;} //Added by Nishank for Story S-299054
    public List<Schema.FieldSetMember> AllfieldSetMemberList {get;set;} //Added by Nishank for Story S-299054
    public String parentRecordId {get;set;}
    public List<SObjectRowWrapper> sObjectRowWrapperList {get;set;}
    public static boolean parentRecordCreated {get;set;}
    public static boolean renderDSLIButtons {get;set;}
    public SObject parentRecord {get;set;}
    private Map<String, SObjectType> globalDescribe;
    // Index for the row to be deleted.
    public String selectedRowIndexToDelete {get;set;}
    public static Map<String,Integer> fieldToLengthMap {get;set;}
    public static Map<String,Boolean> fieldToLengthMapNew {get;set;} //Added by Nishank for Story S-299054
    /*Adding properties for Resource Search functionality for Story S-302979. Added by Paras Dhingra 6/11/2015 #Start*/
  //These three fields could be used to map Skill to search and related Rating
  public pse__Skill_Certification_Rating__c skill_1 {get; set;}
  public pse__Skill_Certification_Rating__c skill_2 {get; set;}
  public pse__Skill_Certification_Rating__c skill_3 {get; set;}
  //Date fields will help determine date from which resources are needed
  public pse__Est_Vs_Actuals__c Start_Date {get;set;}
  public pse__Est_Vs_Actuals__c End_Date{get;set;}
  public Map<Id,resourceWrapper> resourceWrapperList {get;set;}
  public List<Date> weekSet {get;set;}
  public Boolean MapValid {get{if(resourceWrapperList!=null && resourceWrapperList.size()>0)
      return true;
    else
      return false; } set;}
      //KJOVANOVIC 8.21.15
      public boolean saveAndCloseButton = false;
      // END KJOVANOVIC 8.21.15
  //Wrapper class to show capture ResourceSearch Results
  //START Vipul Jain CASE 00140576 18.11.2015 - adding Clone Functionality, for click from Standard Salesforce Page.
  public Boolean isClone;
  ///END
  public class resourceWrapper{
    public Contact resource{get;set;}
    public List<pse__Skill_Certification_Rating__c> skill_Ratings {get; set;}
    public Map <Date, pse__Est_Vs_Actuals__c> weekResultsList{get;set;}//to Contain week by Week Rating
    public resourceWrapper(){
      resource = new Contact();
      skill_Ratings = new List<pse__Skill_Certification_Rating__c>();
      weekResultsList = new Map <Date,pse__Est_Vs_Actuals__c>();
    }
  }


  private Integer getRating(pse__Skill_Certification_Rating__c skill){ // This method is based on the Formula field to Calculate Rating
    return (skill.pse__Rating__c == 'None'?1:Integer.valueOf(skill.pse__Rating__c.left(2).trim()));
  }
  public void searchResources(){
    //Fetch the contacts based on Skills
    // If at-least one skill is entered by User fetch the Contacts based on that
    List <Contact> resourceContacts= new List<Contact>();
    resourceWrapperList = new Map<Id,resourceWrapper>();
    weekSet = new List<Date>();
    List <pse__Est_Vs_Actuals__c> estVsActualsList = new List<pse__Est_Vs_Actuals__c>();
    Map <Contact,Set<pse__Skill_Certification_Rating__c>> contactSkillMap = new Map<Contact,Set<pse__Skill_Certification_Rating__c>> ();
    Set <Id> validContacts = new Set<Id>();
     ResourceParameter__c validRolesList  = ResourceParameter__c.getInstance('roleList');
    String [] validRoles = validRolesList.roles__c.split(',');
    if((skill_1!=null && skill_1.pse__Skill_Certification__c!=null) ||
       (skill_2!=null && skill_2.pse__Skill_Certification__c!=null) ||
       (skill_3!=null && skill_3.pse__Skill_Certification__c!=null)
      )
      {// Fetch the Contacts which has any of these Skills
        Set<Id> skillsId = new set<Id>();
        Map<Id,Integer> userSkillRating = new Map<Id,Integer>();
        if(skill_1!=null && skill_1.pse__Skill_Certification__c!=null)
        {
          skillsId.add(skill_1.pse__Skill_Certification__c);
          userSkillRating.put(skill_1.pse__Skill_Certification__c,getRating(skill_1));
        }
        if(skill_2!=null && skill_2.pse__Skill_Certification__c!=null)
        {
          skillsId.add(skill_2.pse__Skill_Certification__c);
          userSkillRating.put(skill_2.pse__Skill_Certification__c,getRating(skill_2));
        }
        if(skill_3!=null && skill_3.pse__Skill_Certification__c!=null)
        {
          skillsId.add(skill_3.pse__Skill_Certification__c);
          userSkillRating.put(skill_3.pse__Skill_Certification__c,getRating(skill_3));
        }
        if(skillsId!=null){// Fetch all the contacts of selected skill
           //START NSHARP S-334593 8.17.15 - added firstname, lastname to below query
           resourceContacts = [select id, name, firstname, lastname, (select id, pse__Rating__c,pse__Skill_Certification__c ,pse__Skill_Certification__r.name,pse__Resource__c,pse__Numerical_Rating__c from pse__Skill_Certification_Ratings__r) from Contact where Id IN(select pse__Resource__c from pse__Skill_Certification_Rating__c where pse__Skill_Certification__c IN:skillsId) AND pse__Resource_Role__c IN : validRoles AND  pse__Is_Resource_Active__c = true];
           //END NSHARP S-334593 8.17.15
          //Filter contacts based on rating entered by Users
          System.debug('**resources**');
          for(Contact con : resourceContacts ){
              contactSkillMap.put(con,new Set<pse__Skill_Certification_Rating__c>());
              for(pse__Skill_Certification_Rating__c skillRating : con.pse__Skill_Certification_Ratings__r){
                if(userSkillRating.containsKey(skillRating.pse__Skill_Certification__c))
                {
                  if(skillRating.pse__Numerical_Rating__c>=userSkillRating.get(skillRating.pse__Skill_Certification__c))
                  {
                    if(contactSkillMap.containsKey(con))
                    {
                      contactSkillMap.get(con).add(skillRating);
                    }
                  }
                }
              }
            }
          for(Contact con : contactSkillMap.keyset()){
              if(contactSkillMap.get(con).size()<1)
                contactSkillMap.remove(con);
              else
                validContacts.add(con.id);
            }
          }
          else{ //No Skills selected. Fetch all active PSA resource contacts
          //START NSHARP S-334593 8.17.15 - added firstname, lastname to below query
          resourceContacts = [select id, name,firstname, lastname, (select id,pse__Resource__c,pse__Rating__c,pse__Skill_Certification__r.name, pse__Skill_Certification__c,pse__Numerical_Rating__c from pse__Skill_Certification_Ratings__r limit 3) from Contact where pse__Resource_Role__c IN :validRoles AND  pse__Is_Resource_Active__c = true];
          //END NSHARP S-334593 8.17.15
          for(Contact con : resourceContacts){
            contactSkillMap.put(con,new Set<pse__Skill_Certification_Rating__c>());
            validContacts.add(con.id);
            for(pse__Skill_Certification_Rating__c skillRating : con.pse__Skill_Certification_Ratings__r){
              if(contactSkillMap.containsKey(con))
                {
                  contactSkillMap.get(con).add(skillRating);
                }
            }
          }
        }

      }
      // Changes done for Case 00126541 by Paras Dhingra 7/8/2015 #start
      // Code Commented to accomodate changes. Setting default values for Start and End date
      /*
      if((Start_Date !=null && Start_Date.pse__Start_Date__c!=null)&&(End_Date !=null && End_Date.pse__End_Date__c!=null)){
        estVsActualsList = [select id, pse__Resource__c, pse__Estimated_Hours__c,pse__Start_Date__c, pse__End_Date__c from pse__Est_Vs_Actuals__c
        where pse__Time_Period_Type__c=  'Week' AND
        pse__Start_Date__c >=: Start_Date.pse__Start_Date__c AND pse__End_Date__c <= :End_Date.pse__End_Date__c AND
        pse__Resource__c IN :validContacts];
      }else if((Start_Date !=null && Start_Date.pse__Start_Date__c!=null) && (End_Date ==null || End_Date.pse__End_Date__c==null)){
        estVsActualsList = [select id, pse__Resource__c, pse__Estimated_Hours__c,pse__Start_Date__c, pse__End_Date__c from pse__Est_Vs_Actuals__c
        where pse__Time_Period_Type__c=  'Week' AND
        pse__Start_Date__c >=: Start_Date.pse__Start_Date__c AND
        pse__Resource__c IN :validContacts];
      }else if((Start_Date ==null || Start_Date.pse__Start_Date__c==null) && (End_Date !=null && End_Date.pse__End_Date__c!=null))
      {
        estVsActualsList = [select id, pse__Resource__c, pse__Estimated_Hours__c,pse__Start_Date__c, pse__End_Date__c from pse__Est_Vs_Actuals__c
        where pse__Time_Period_Type__c=  'Week' AND
        pse__Start_Date__c >=:(End_Date.pse__End_Date__c-180) AND pse__End_Date__c <= :End_Date.pse__End_Date__c AND
        pse__Resource__c IN :validContacts];
      }else {
        estVsActualsList = [select id, pse__Resource__c, pse__Estimated_Hours__c,pse__Start_Date__c, pse__End_Date__c from pse__Est_Vs_Actuals__c
        where pse__Time_Period_Type__c=  'Week' AND
        pse__Start_Date__c >=:(Date.today()-180) AND
        pse__Resource__c IN :validContacts];
        System.debug('**validContacts**'+validContacts);
      }*/
     // Setting default values for start and end date will make sure that result set is manageable
     if(Start_Date ==null || Start_Date.pse__Start_Date__c==null){
      Start_Date.pse__Start_Date__c = Date.today();
     }
     if(End_Date == null || End_Date.pse__End_Date__c == null){
      End_Date.pse__End_Date__c = Date.today() + 90;
     }
      estVsActualsList = [select id, pse__Resource__c, pse__Estimated_Hours__c,pse__Start_Date__c, pse__End_Date__c from pse__Est_Vs_Actuals__c
                          where pse__Time_Period_Type__c=  'Week' AND
                          pse__Start_Date__c >=: Start_Date.pse__Start_Date__c AND
                          pse__End_Date__c <= :End_Date.pse__End_Date__c AND
                          pse__Resource__r.Parent_Region__c ='SSA' AND
                          pse__Resource__r.pse__Exclude_from_Resource_Planner__c = false AND
                          pse__Assignment__r.pse__Exclude_from_Planners__c = false AND
                          pse__Resource__c IN :validContacts];
      // case 00126541 #End
      //Now process the records
      if(estVsActualsList!=null && estVsActualsList.size()>0){
        System.debug('**Contact Skill Map**'+contactSkillMap);
        for(Contact con : contactSkillMap.keySet()){
          resourceWrapper rwrap = new resourceWrapper();
          if(!resourceWrapperList.containsKey(con.id)){
            rwrap.resource = con;
            rwrap.skill_Ratings.addAll(contactSkillMap.get(con));
            rwrap.weekResultsList = new Map<Date,pse__Est_Vs_Actuals__c>();
            resourceWrapperList.put(con.id,rwrap);
          }
        }
        for(pse__Est_Vs_Actuals__c eva: estVsActualsList ){
          if(resourceWrapperList.containsKey(eva.pse__Resource__c) && eva.pse__Start_Date__c!=null){
            weekSet.add(eva.pse__Start_Date__c);
            if(resourceWrapperList.get(eva.pse__Resource__c).weekResultsList.containsKey(eva.pse__Start_Date__c))
              resourceWrapperList.get(eva.pse__Resource__c).weekResultsList.get(eva.pse__Start_Date__c).pse__Estimated_Hours__c += eva.pse__Estimated_Hours__c==null?0.0:eva.pse__Estimated_Hours__c;
            else
              resourceWrapperList.get(eva.pse__Resource__c).weekResultsList.put(eva.pse__Start_Date__c,eva);
            //resourceWrapperList.get(eva.pse__Resource__c).weekResultsList.sort();
          }
        }
      }
      Set<Date> tempSet = new Set<Date>();
      tempSet.addAll(weekSet);
      weekSet = new List<Date>();
      weekSet.addAll(tempSet);
      weekSet.sort();
      //add null values to each map
      for(Id rwrap : resourceWrapperList.keySet())
      {
        for(Date dt: weekSet){
          if(!(resourceWrapperList.get(rwrap).weekResultsList.containsKey(dt)))
            resourceWrapperList.get(rwrap).weekResultsList.put(dt,new pse__Est_Vs_Actuals__c());
        }
        System.debug('**Date KeySey' + resourceWrapperList.get(rwrap).weekResultsList.keySet());
      }
  }
  /* Paras Dhingra S-302979 #END */
    public DealSheetAddEditExtension2(ApexPages.StandardController con){
    	//START Vipul Jain CASE 00140576 18.11.2015 - adding Clone Functionality, for click from Standard Salesforce Page.
    	String cloneTrue = apexpages.currentpage().getparameters().get('clone');
    	if(cloneTrue=='1'){
    		isClone = true;
    	}
    	else{
    		isClone = false;
    	}
    	//END
        skill_1 = new pse__Skill_Certification_Rating__c();
        skill_2 = new pse__Skill_Certification_Rating__c();
        skill_3 = new pse__Skill_Certification_Rating__c();
        Start_Date = new pse__Est_Vs_Actuals__c();
        End_Date = new pse__Est_Vs_Actuals__c();
        globalDescribe = Schema.getGlobalDescribe();
        fieldToLengthMapNew = new Map<String,Boolean>();//Added by Nishank for Story S-299054
        //fieldToLengthMapNew = DSLIFieldLengths__c.getAll();//Added by Nishank for Story S-299054
        fieldToLengthMap = new Map<String,Integer>();
        for(DSLIFieldLengths__c record :DSLIFieldLengths__c.getAll().values()){
            fieldToLengthMap.put(record.name,Integer.valueOf(record.Length_In_Pixels__c));
            fieldToLengthMapNew.put(record.name,record.IsFormula__c); //Added by Nishank for Story S-299054
        }

        System.debug('*****custom Setting***'+fieldToLengthMap);
        System.debug('*****custom Setting***'+fieldToLengthMapNew); //Added by Nishank for Story S-299054
        try{

        	parentRecordId = Apexpages.currentPage().getParameters().get('id');
        	parentRecord = con.getRecord();
			System.debug('****parentRecord initially'+parentRecord.get(Schema.Deal_Sheet__c.id)) ;
            init();

        }catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        //
    }

	//START Vipul Jain CASE 00140576 20.11.2015 - adding Clone Functionality, for click from Standard Salesforce Page.
    public pageReference initClone(){
     if(isClone){
     	return cloneDealSheet();
     	}
     else return null;

    }
    //END

    /*Added a conditional map to disable and enable fields. Paras Dhingra  S-320690 #Start */
    public Map<String, Boolean> getDisableEnableFields(){
      Map<String,Boolean> disableEnableFields = new Map<String,Boolean>();
      Map<String, Schema.SObjectField> fieldLabel = Schema.SObjectType.Deal_Sheet_Line_Item__c.fields.getMap();//Get the field label of DealSheetLineItem
      if(sObjectRowWrapperList!=null){
        for(SObjectRowWrapper sobj : sObjectRowWrapperList){
            for(Schema.FieldSetMember fsm : fieldSetMemberList){
              if(fsm.getLabel()==fieldLabel.get('Daily_Cost_Rate__c').getDescribe().getLabel()
                &&
                ( (sobj.record.get('Role__c')==null) ||
                  (sobj.record.get('Role__c')!=null && !(String.valueof(sobj.record.get('Role__c')) == 'Independent Contractor')))
                ){
                disableEnableFields.put(String.valueOf(sobj.rowIndex)+fsm.getLabel(),false);
              }
              else if(((fsm.getLabel()==fieldLabel.get('Billable_Days__c').getDescribe().getLabel()||fsm.getLabel()==fieldLabel.get('Daily_Bill_Rate__c').getDescribe().getLabel()) && sobj.record.get('Line_Type__c')!=null && String.valueof(sobj.record.get('Line_Type__c')) == 'Fixed Amount'))
              {
                disableEnableFields.put(String.valueOf(sobj.rowIndex)+fsm.getLabel(),false);
              }
              else if((fsm.getLabel()==fieldLabel.get('Fixed_Revenue__c').getDescribe().getLabel() && sobj.record.get('Line_Type__c')!=null && String.valueOf(sobj.record.get('Line_Type__c')) == 'Resource') ){
                disableEnableFields.put(String.valueOf(sobj.rowIndex)+fsm.getLabel(),false);
              }
              else
                disableEnableFields.put(String.valueOf(sobj.rowIndex)+fsm.getLabel(),true);
            }
          }
      }
       FillMaps();   //Added by Nishank for Case:-00127442
      return disableEnableFields;
    }
    /* S-320690 #End*/
    public void init(){

        fieldSetMemberList = getFieldSetFields('Table_Columns');
        EditDetailsfieldSetMemberList = getFieldSetFields('Edit_Details_Section');//Added by Nishank for Story S-299054
        AllfieldSetMemberSet = new Set<Schema.FieldSetMember>();
        AllfieldSetMemberList = new List<Schema.FieldSetMember>();
        AllfieldSetMemberSet.addAll(EditDetailsfieldSetMemberList);
        AllfieldSetMemberSet.addAll(fieldSetMemberList);
        AllfieldSetMemberList.addAll(AllfieldSetMemberSet);//End of changes by Nishank for Story S-299054
        System.debug('*****custom Setting***'+fieldToLengthMap);
        sObjectRowWrapperList = loadChildRecordsByParentId(AllfieldSetMemberList, Deal_Sheet_Line_Item__c.sobjectType, 'Deal_Sheet_Line_Item__c', 'Deal_Sheet__c', parentRecordId, 1);//modified by Nishank for Story S-299054
        if(sObjectRowWrapperList.size() == 0)
               sObjectRowWrapperList = addBlankRows(Deal_Sheet_Line_Item__c.sObjectType, 1, -1,'Deal_Sheet__c', parentRecordId);
        if(parentRecordId != null){
            parentRecordCreated = true;
            renderDSLIButtons = true;
        }

        // Added for the story #S-349314 #START
        Set<Id> setId = new Set<Id>();

        for(sObjectRowWrapper rw : sObjectRowWrapperList){
            setId.add(rw.record.id);
        }

        Map<Id, Deal_Sheet_Line_Item__c> mapDSLI = new Map<Id, Deal_Sheet_Line_Item__c>([select id, Total_Cost__c, Total_Revenue__c from Deal_Sheet_Line_Item__c where id in :setId]);

        for(sObjectRowWrapper rw : sObjectRowWrapperList) {
            if(mapDSLI.containsKey(rw.record.id)) {
                Deal_Sheet_Line_Item__c dlsi = (Deal_Sheet_Line_Item__c) rw.record;
                rw.record.put('Total_Cost_Field__c', mapDSLI.get(dlsi.id).Total_Cost__c);
                rw.record.put('Total_Revenue_Field__c', mapDSLI.get(dlsi.id).Total_Revenue__c);
            }
        }
        
        // Added for the story #S-349314 #END
    }

    public void createTimeHeaderRecordAction(){
        System.debug('*****inside createTimeHeaderRecordAction');
        if(parentRecord.get(Schema.Deal_Sheet__c.id) == null){
            System.debug('*****Creating parent record first time');
            insert parentRecord;
            System.debug('***** After Insert');
            sObjectRowWrapperList = addBlankRows(Deal_Sheet_Line_Item__c.sObjectType, 1, -1,'Deal_Sheet__c', parentRecord.Id);//Modified by Nishank for Story S-299054
        }else{
            System.debug('****updating the record');
            update parentRecord;

        }
        parentRecordId = parentRecord.id;

        //System.debug('*******created Record: '+parentRecord);
        //return null;
        parentRecordCreated  = true;
        renderDSLIButtons  = true;
          PageReference pr = Page.DealSheetAddEditPage2;
          pr.getParameters().put('id',parentRecordId);
          pr.setRedirect(true);
          //return pr;
    }

    public pageReference refreshWindow(){
        if(parentRecordId != null){
            PageReference pr = Page.DealSheetAddEditPage2;
              pr.getParameters().put('id',parentRecordId);
              pr.setRedirect(true);
              return pr;
          }else
              return null;
    }

    public static List<Schema.FieldSetMember> getFieldSetFields(String fieldSetName) {
        List<Schema.FieldSetMember> fieldSetMemberList;
        if(!String.isBlank(fieldSetName)) {
         Schema.DescribeSObjectResult describeSObjectResultObj = Deal_Sheet_Line_Item__c.sobjectType.getDescribe();
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        fieldSetMemberList = fieldSetObj.getFields();
            System.debug('**** Before For loop');
            // Removed debug statements for Case:-00127442
            for(Schema.FieldSetMember member :fieldSetMemberList){
                System.debug('***** In for loop');
                if(!fieldToLengthMap.containsKey(member.getLabel()))
                    fieldToLengthMap.put(member.getLabel(),0);
                if(!fieldToLengthMapNew.containsKey(member.getLabel()))//Added by Nishank for Story S-299054
                    fieldToLengthMapNew.put(member.getLabel(),false);//Added by Nishank for Story S-299054
            }

        }
      return fieldSetMemberList;
    }


    /*
      Method to load all child records using the object type, field set and parent record id passed as argument.
    */
    public static List<SObjectRowWrapper> loadChildRecordsByParentId(List<Schema.FieldSetMember> fieldSetMemberList, Schema.SObjectType sobjectType, String objectName, String parentFieldAPIName, String parentRecordId, Integer rowSize) {
          String queryStr = prepareSOQLQuery(fieldSetMemberList, objectName);

          queryStr += ' where '+ parentFieldAPIName +' =: parentRecordId ';

          List<sObject> objectList = Database.query(queryStr);

        List<SObjectRowWrapper> sObjectRowWrapperList = new List<SObjectRowWrapper>();

        Integer counter = 0;
        for(sObject obj  : objectList) {
          // Preparing the object wrapper
          sObjectRowWrapper objectRowWrapper = new SObjectRowWrapper(counter, obj);
          sObjectRowWrapperList.add(objectRowWrapper);
          counter++;
        }

        // Adding blank rows
        if(sObjectRowWrapperList.size() >0){
            if(sObjectRowWrapperList.size() < rowSize) {
              Integer lastRowIndex = sObjectRowWrapperList.get(sObjectRowWrapperList.size()-1).rowIndex;
              sObjectRowWrapperList.addAll(addBlankRows(sobjectType, rowSize - sObjectRowWrapperList.size(), lastRowIndex+1, parentFieldAPIName, parentRecordId));
            }
        }
        return sObjectRowWrapperList;
  }

  /*
      Method to add blanks rows as per rowCount passed as parameter.
    */
    public static List<SObjectRowWrapper> addBlankRows(Schema.SObjectType sobjectType, Integer rowCount, Integer lastRowIndex,
      String parentFieldAPIName, String parentRecordId) {
      List<SObjectRowWrapper> sObjectBlankRowWrapperList = new List<SObjectRowWrapper>();

      Integer counter = lastRowIndex ;//Modified by Nishank for Story S-299054
      for(Integer i = 0; i < rowCount; i++) {
        // Creating a new sObject record.
        sObject newObject = sobjectType.newSObject(null, true);
        // Setting parent field value.
        newObject.put(parentFieldAPIName, parentRecordId);
        sObjectBlankRowWrapperList.add(new SObjectRowWrapper(counter, newObject));
        counter++;
      }
      // Re calculate the line items field's width from custom setting - start
          fieldToLengthMap = new Map<String,Integer>();
            for(DSLIFieldLengths__c record :DSLIFieldLengths__c.getAll().values()){
                fieldToLengthMap.put(record.name,Integer.valueOf(record.Length_In_Pixels__c));
            }
            for(Schema.FieldSetMember member :Deal_Sheet_Line_Item__c.sobjectType.getDescribe().FieldSets.getMap().get('Table_Columns').getFields()){
                if(!fieldToLengthMap.containsKey(member.getLabel()))
                    fieldToLengthMap.put(member.getLabel(),0);
            }
     // Re calculate the line items field's width from custom setting - End

      return sObjectBlankRowWrapperList;
    }


    /*  Method to add empty rows as per the "addMore" parameter passed to controller.
        Default value as DEFAULT_ADD_MORE_SIZE if addMore parameter is missing.
    */
  public PageReference addNewRows() {
    System.debug('*****inside Add Rows');
    Schema.SObjectType childsObjectType = globalDescribe.get('Deal_Sheet_Line_Item__c');

    Integer lastRowIndex = sObjectRowWrapperList.get(sObjectRowWrapperList.size()-1).rowIndex;
    System.debug('*******last row indx'+lastRowIndex);
    sObjectRowWrapperList.addAll(addBlankRows(Deal_Sheet_Line_Item__c.sobjectType, 1, lastRowIndex+1, 'Deal_Sheet__c', parentRecordId));
    //Story S-320690 by Paras Dhingra #Start
    //fetch last record of type resource
    Integer counter = sObjectRowWrapperList.size()-2; // fetch the index of second last element
    while(counter > 0)
    {
      if(sObjectRowWrapperList.get(counter).record.get('Line_Type__c') =='Resource')
        break;//Resource found
      else
        counter--;
    }
    if(counter>0)
      sObjectRowWrapperList.get(sObjectRowWrapperList.size()-1).record = sObjectRowWrapperList.get(counter).record.clone(false,false,false,false);// Added to copy values of last row. Story S-320690 by Paras Dhingra
    //Story S-320690 by Paras Dhingra #End
    parentRecordCreated = true;
    renderDSLIButtons  = true;
    FillMaps();   //Added by Nishank for Story S-299054
    return null;
  }

   /*
    Method to delete row based on the selectedRowIndexToDelete value. Only one row will
    be deleted at a time.
  */
  public PageReference deleteRow() {
      PageReference pr;
    try {
      if(!String.isBlank(selectedRowIndexToDelete)) {
        Integer index = Integer.valueOf(selectedRowIndexToDelete);

        deleteSelectedRow(sObjectRowWrapperList, index);
        parentRecordCreated = true;
        renderDSLIButtons = true;
          pr = Page.DealSheetAddEditPage2;
          pr.getParameters().put('id',parentRecordId);
          pr.setRedirect(true);

      }
    } catch(Exception ex) {Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error while delete the selected row.' )); } //Modified by Nishank for Story S-299054
    if(parentRecordId != null)
        return pr;
    else
        return null;
  }

  /*
    Method for deleting selected row from the data structure and also deleteing the related records
    form the data base if they exist.
  */
  public static void deleteSelectedRow(List<SObjectRowWrapper> sObjectRowWrapperList, Integer selectedRowIndex) {
    SObjectRowWrapper removedsObjectRowWrapper = sObjectRowWrapperList.remove(selectedRowIndex);

    if(removedsObjectRowWrapper != null) {
      if(removedsObjectRowWrapper.record != null && removedsObjectRowWrapper.record.Id != null) {
        // deleting the record with id.
        delete removedsObjectRowWrapper.record;
      }
    }
  }


   /*
    Saving (insert and update) records that are added or edited by user. The reocrds that are
    marked as dirty are processed for inser and update.
  */
  public PageReference saveAll() {

  	// Added for the story #S-349314 #START
  	for(sObjectRowWrapper rw : sObjectRowWrapperList){
       rw.errorMessage = null;
    }
    // Added for the story #S-349314 #END

    List<SObject> listToInsert = new List<SObject>();
    List<SObject> listToUpdate = new List<SObject>();
    PageReference pr;
    SavePoint sp = Database.setSavePoint();
    try {
      System.debug('****soBject wrapper'+sObjectRowWrapperList);
      for(SObjectRowWrapper rw : sObjectRowWrapperList) {

          //if(rw.isRowdirty) {
          if(rw.record.id != null) {
          System.debug('rw.Record ******'+rw.record);
            //Story S-368446 harendra--- start
              rw.record.put('Calendar_Day__c',HoursBetweenTwoDates(Date.valueOf(rw.record.get('Start_Date__c')), Date.valueOf(rw.record.get('End_Date__c'))));
            //harendra----- end
            listToUpdate.add(rw.record);
          } else {
          System.debug('rw.Record ******'+rw.record);
              Deal_Sheet_Line_Item__c dsl = (Deal_Sheet_Line_Item__c)rw.record;
              dsl.Deal_Sheet__c = parentRecordId ;
              //((Deal_Sheet_Line_Item__c)rw.record).id = parentRecordId ;
              //rw.record.get(Schema.Deal_Sheet_Line_Item__c.Deal_Sheet__c) = parentRecordId;
            listToInsert.add(rw.record);
            rw.insertIndex = listToInsert.size()-1;
          }
        //}
      }
      System.debug('****listToUpdate.isEmpty() : '+listToUpdate.isEmpty()+'  *******!listToInsert.isEmpty() : '+!listToInsert.isEmpty());
      // Updated for Story S-320690 #start
      database.saveresult[] srUpdate;
      database.saveresult[] srInsert;
      if(!listToUpdate.isEmpty())  srUpdate =  Database.update(listToUpdate,false);//update listToUpdate;
      if(!listToInsert.isEmpty())  srInsert = Database.insert(listToInsert,false);//insert listToInsert;
      Boolean dmlFailed = false;
      if(srUpdate!=null && srUpdate.size()>0){ // Fetch to add errormessages
        for(Integer i=0 ; i<srUpdate.size(); i++)
        {
          if(srUpdate[i].isSuccess()){

            }else{
              dmlFailed = true;
              for(sObjectRowWrapper rw : sObjectRowWrapperList){
                if(rw.record.id == listToUpdate[i].Id){
                  Database.error  err= srUpdate.get(i).getErrors().get(0);
                   rw.errorMessage = 'Error occurred:'+err.getMessage();
                   System.debug('#### Error: ' + rw.errorMessage);
                }

              }

            }
        }
      }
      if(srInsert!=null && srInsert.size()>0){
        for(Integer i=0; i<srInsert.size();i++){
          if(srInsert[i].isSuccess()){

            }else{
              dmlFailed = true;
               for(sObjectRowWrapper rw : sObjectRowWrapperList){
                if(rw.insertIndex == i){
                   Database.error  err = srInsert.get(i).getErrors().get(0);
                   rw.errorMessage = 'Error occurred:'+err.getMessage();
                   System.debug('### rw.error message insert?: ' + rw.errorMessage);
                 }

              }
            }
        }
      }
      if(!dmlFailed){
        System.debug('### dml not failed' );
        parentRecordCreated = true;
        renderDSLIButtons  = true;
        //init();


        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'All Deal Sheet Line Items Saved Successfully'));
        //START KJOVANOVIC CASE 00131301 8.19.15

        if(saveAndCloseButton) {
          System.debug('#### in save and close');

          // Commented for the story #S-349314 #START
          // Schema.DescribeSObjectResult objDef = Deal_Sheet__c.sObjectType.getDescribe();
          // PageReference pageR = new PageReference( '/'+ objDef.getKeyPrefix() + '/o');
          // pageR.setRedirect(true);
          // Commented for the story #S-349314 #END

          // Added for the story #S-349314 #START
          PageReference pageR = new PageReference( '/' + parentRecordId);
          pageR.setRedirect(true);
          // Added for the story #S-349314 #END

          System.debug(pageR + '*********');
          if(parentRecordId != null){
            try{
            	update parentRecord;
                return pageR;

            }
            catch(Exception e){
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'Error. Could not update parent Record'));
              return null;
            }

          }

        }

      pr = Page.DealSheetAddEditPage2;
      pr.getParameters().put('id', parentRecordId);
      pr.setRedirect(true);

      //END KJOVANOVIC CASE 00131301 8.19.15
      }else{
        Database.Rollback(sp);
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'An error occurred refer below for more details'));
      }
       // Updated for Story S-320690 #stop
    } catch(Exception e) {
      Database.Rollback(sp);
      Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
      if(parentRecordId != null){
        //START NSHARP CASE 00121406 7.7.15
        try{
        	update parentRecord;
        	return pr;

        }
        catch(Exception e){
          return null;
        }
        //END NSHARP CASE 00121406 7.7.15
      }
      else{
          return null;
        }
  }

  public pageReference saveDealSheet(){
    //START NSHARP CASE 00121406 6.10.15 - adding try/catch to catch validation errors and present them to the user
    try{

      	 if(parentRecord.get(Schema.Deal_Sheet__c.id) == null ){
            System.debug('*****updating parent record');
            System.debug('**** parent Record ' + parentRecord);
            insert parentRecord;
        }
     	else{
            System.debug('****updating the record');
            update parentRecord;
        }

        return saveAll();
    }
    catch(Exception e){
      return null;
    }
    //END NSHARP CASE 00121406 6.10.15
  }
  /*Created By: Paras Dhingra
    Created Date : 6/9/2015
    Story: S-320690
    Objective  : This method will save the deal sheet and close the edit page to redirect back to Standard VF page
    #Start
    */
  public pageReference saveAndClose(){
    //START KJOVANOVIC CASE 00131301 8.19.15
    saveAndCloseButton = true;
    //START Vipul Jain CASE 00140576 19.11.2015 - To allow 'Save and Close' Button functionality work.
    saveDealSheet();
    Schema.DescribeSObjectResult objDef = Deal_Sheet__c.sObjectType.getDescribe();
    PageReference pageRef = new PageReference('/' + objDef.getKeyPrefix() + '/o' );
    pageRef.setRedirect(true);
    return pageRef;
    //END
    //saveDealSheet();
  //System.debug('*********' + 'AftersaveNclose');
 //END KJOVANOVIC CASE 00131301 8.19.15

    //START NSHARP CASE 00121406 7.6.15
    //PageReference pr = new pageReference('/'+parentRecordId);
    //return pr;
  // return null;
    //END NSHARP CASE 00121406 7.6.15
  }
  // S-320690 #End
  /*Created By: Paras Dhingra
    Created Date : 6/9/2015
    Story: S-320690
    Objective  : This method will dynamically fetch the list page of Deal Sheets object and redirect user to the same
    #Start
    */
  public pageReference goBack(){
    Schema.DescribeSObjectResult objDef = Deal_Sheet__c.sObjectType.getDescribe();
   PageReference pageRef = new PageReference('/' + objDef.getKeyPrefix() + '/o' );
   pageRef.setRedirect(true);


   return pageRef;
  }
  /*S-320690 #End */
  public pageReference cloneDealSheet(){
      System.debug('******Inside Clone***');
      sObject clonedRecord ;
      if(parentRecord.get(Schema.Deal_Sheet__c.id) != null){
          clonedRecord = parentRecord.Clone(false,true,false,false);
          insert clonedRecord;
          parentRecordId = clonedRecord.id;

          System.debug('*******clonedRecord '+clonedRecord);
          System.debug('**********clonerec id '+clonedRecord);
          return cloneDealSheetChilds();
      }else{
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No Deal_Sheet__c record found to be cloned.'));
          return null;
      }
  }

  public PageReference cloneDealSheetChilds() {

    List<Deal_Sheet_Line_Item__c> listToInsert = new List<SObject>();
    PageReference pr;
    SavePoint sp = Database.setSavePoint();
    try {
    System.debug('****soBject wrapper'+sObjectRowWrapperList);
      for(SObjectRowWrapper rw : sObjectRowWrapperList) {
          System.debug('rw.Record ******'+rw.record);
              Deal_Sheet_Line_Item__c dsl = (Deal_Sheet_Line_Item__c)rw.record.clone(false,true,false,false);
              dsl.Deal_Sheet__c = parentRecordId ;
              //((Deal_Sheet_Line_Item__c)rw.record).id = parentRecordId ;
              //rw.record.get(Schema.Deal_Sheet_Line_Item__c.Deal_Sheet__c) = parentRecordId;
            listToInsert.add(dsl);

      }

      if(!listToInsert.isEmpty()) insert listToInsert;

      parentRecordCreated = true;
      renderDSLIButtons  = true;
      //init();
      Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'All Deal Sheet Line Items Saved Successfully'));
      pr = Page.DealSheetAddEditPage2;
      pr.getParameters().put('id', parentRecordId);
      pr.setRedirect(true);
    } catch(Exception e) {
      Database.Rollback(sp);
      Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
      if(parentRecordId != null){
      	//START Vipul Jain CASE 00140576 25.11.2015
      	if(!isClone){
      	update parentRecord;
      	}
      	//END
          return pr;

      }
      else
          return null;
  }

  /*
    Method for preparing soql query with fields configured using field set list passed as argument
  */
  public static String prepareSOQLQuery(List<Schema.FieldSetMember> fieldSetMemberList, String objectName)
  {
      List<String> fieldAPINameList = new List<String>();
      for(Schema.FieldSetMember f : fieldSetMemberList) {
        fieldAPINameList.add(f.getFieldPath());
      }

      // Commented for the story S-349314
      //String query = 'select ' + String.join(fieldAPINameList, ',') + ' from '+ objectName ;

      // Add for the story #S-349314 #START
      String query = 'select ' + String.join(fieldAPINameList, ',');

      if(objectName.equals('Deal_Sheet_Line_Item__c')) {
            query += ',Total_Cost__c, Total_Revenue__c ';
      }

      query += ' from '+ objectName ;
      // Added for the story #S-349314 #END

      return query;
  }
      /*
    Wrapper class holding sObject and related details to show on UI
  */
  public class SObjectRowWrapper {
      public Integer rowIndex {get;set;}
      public sObject record {get;set;}

      public String rowStatus {get; private set;}
      public boolean isRowdirty {get;set;}
      public boolean isSelected {get;set;}
      public String errorMessage{get;set;} // Created for Story S-320690 by Paras Dhingra
      public Integer insertIndex {get; set;}
      public SObjectRowWrapper(Integer index, sObject obj) {
        this.rowIndex = index;
        this.record = obj;
        this.isRowdirty = false;
        this.isSelected = false;
        this.rowStatus = obj.id != null ? 'Saved' : 'New';
        errorMessage = '';
      }
  }
  //Added by Nishank for Story S-299054
  public Void FillMaps(){
       globalDescribe = Schema.getGlobalDescribe();
        fieldToLengthMapNew = new Map<String,Boolean>();//Added by Nishank for Story S-299054
        //fieldToLengthMapNew = DSLIFieldLengths__c.getAll();//Added by Nishank for Story S-299054
        fieldToLengthMap = new Map<String,Integer>();
        for(DSLIFieldLengths__c record :DSLIFieldLengths__c.getAll().values()){
            fieldToLengthMap.put(record.name,Integer.valueOf(record.Length_In_Pixels__c));
            fieldToLengthMapNew.put(record.name,record.IsFormula__c); //Added by Nishank for Story S-299054
        }
        System.debug('*****custom Setting***'+fieldToLengthMap);
        System.debug('*****custom Setting***'+fieldToLengthMapNew); //Added by Nishank for Story S-299054
        try{
        List<Schema.FieldSetMember> fieldSetMemberList1 = getFieldSetFields('Table_Columns');
        List<Schema.FieldSetMember> EditDetailsfieldSetMemberList1 = getFieldSetFields('Edit_Details_Section');//Added by Nishank for Story S-299054
            //init();
        }catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

  }  //End of changes added by Nishank for Story S-299054

  // Added for the story #S-349314 #START

  public void updateTotals() {

  	for(sObjectRowWrapper rw : sObjectRowWrapperList){
       rw.errorMessage = null;
    }

    List<SObject> listToInsert = new List<SObject>();
    List<SObject> listToUpdate = new List<SObject>();

    Set<Id> setIds = new Set<Id>();
    Set<Id> setIdsNotToRemove = new Set<Id>();

    SavePoint sp = Database.setSavePoint();

    try {

      for(SObjectRowWrapper rw : sObjectRowWrapperList) {

          if(rw.record.id != null) {
            //Story S-368446 harendra--- start
              rw.record.put('Calendar_Day__c',HoursBetweenTwoDates(Date.valueOf(rw.record.get('Start_Date__c')), Date.valueOf(rw.record.get('End_Date__c'))));
            //harendra----- end
            listToUpdate.add(rw.record);
            setIdsNotToRemove.add(rw.record.id);

          } else {
              Deal_Sheet_Line_Item__c dsl = (Deal_Sheet_Line_Item__c)rw.record;
              dsl.Deal_Sheet__c = parentRecordId ;
            listToInsert.add(rw.record);
            rw.insertIndex = listToInsert.size()-1;
          }
      }


      database.saveresult[] srUpdate;
      database.saveresult[] srInsert;
      if(!listToUpdate.isEmpty())  srUpdate =  Database.update(listToUpdate,false);//update listToUpdate;
      if(!listToInsert.isEmpty())  srInsert = Database.insert(listToInsert,false);//insert listToInsert;


      Boolean dmlFailed = false;
      if(srUpdate!=null && srUpdate.size()>0){ // Fetch to add errormessages
        for(Integer i=0 ; i<srUpdate.size(); i++)
        {
          if(srUpdate[i].isSuccess()){

            }else{
              dmlFailed = true;
              for(sObjectRowWrapper rw : sObjectRowWrapperList){
                if(rw.record.id == listToUpdate[i].Id){
                  Database.error  err= srUpdate.get(i).getErrors().get(0);
                   rw.errorMessage = 'Error occurred:'+err.getMessage();
                }

              }

            }
        }
      }
      if(srInsert!=null && srInsert.size()>0){
        for(Integer i=0; i<srInsert.size();i++){
          if(srInsert[i].isSuccess()){

            }else{
              dmlFailed = true;
               for(sObjectRowWrapper rw : sObjectRowWrapperList){
                if(rw.insertIndex == i){
                   Database.error  err = srInsert.get(i).getErrors().get(0);
                   rw.errorMessage = 'Error occurred:'+err.getMessage();
                 }

              }
            }
        }
      }

      if(!dmlFailed){

        for(Deal_Sheet_Line_Item__c dlsi: (List<Deal_Sheet_Line_Item__c>)listToUpdate) {
            setIds.add(dlsi.id);
        }
        for(Deal_Sheet_Line_Item__c dlsi: (List<Deal_Sheet_Line_Item__c>)listToInsert) {
            setIds.add(dlsi.id);
        }

        Map<Id,Deal_Sheet_Line_Item__c> mapDlsi = new Map<Id,Deal_Sheet_Line_Item__c>([select id, Total_Cost__c, Total_Revenue__c from Deal_Sheet_Line_Item__c where id in :setIds]);

        // Update total cost and total revenue fields for the records which has been updated
        for(sObjectRowWrapper rw : sObjectRowWrapperList){
            if(mapDlsi.containsKey(rw.record.id)) {

                Deal_Sheet_Line_Item__c dlsi = (Deal_Sheet_Line_Item__c) rw.record;
                rw.record.put('Total_Cost_Field__c', mapDlsi.get(dlsi.id).Total_Cost__c);
                rw.record.put('Total_Revenue_Field__c', mapDlsi.get(dlsi.id).Total_Revenue__c);
                system.debug('+++++++mapDlsi.get(dlsi.id).Total_Cost__c++++++++++++'+mapDlsi.get(dlsi.id).Total_Cost__c);
                 system.debug('+++++++mapDlsi.get(dlsi.id).Total_Revenue__c++++++++++++'+mapDlsi.get(dlsi.id).Total_Revenue__c);
            }
        }

        // Update total cost and total revenue fields for the records which has been inseted
        if(listToInsert!=null && listToInsert.size()>0){
            for(Integer i=0; i<listToInsert.size();i++){
                for(sObjectRowWrapper rw : sObjectRowWrapperList){
                    if(rw.insertIndex == i && mapDlsi.containsKey(listToInsert[i].id)){
                        rw.record.put('Total_Cost_Field__c', mapDlsi.get(listToInsert[i].id).Total_Cost__c);
                        rw.record.put('Total_Revenue_Field__c', mapDlsi.get(listToInsert[i].id).Total_Revenue__c);
                    }
                }
            }
        }

      }else{
        Database.Rollback(sp);
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, 'An error occurred refer below for more details'));
      }

    } catch(Exception e) {
      Database.Rollback(sp);
      Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }

    Database.Rollback(sp);

    for(sObjectRowWrapper rw : sObjectRowWrapperList){
        if(!setIdsNotToRemove.contains(rw.record.id)) {
            rw.record.put('Id', null);
        }
    }

  }
  // Added for the story #S-349314 #END

   //Harendra---Test---START for the story #S-368446
  public Integer HoursBetweenTwoDates( Date startDate ,Date endDate){
    DateTime dtStart = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day(),0,0,0);
    DateTime dtEnd = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day(),0,0,0);
	  Integer dayCount = 0;
	  if(dtStart == null || dtEnd == null) return 0;

		  if(dtStart > dtEnd) {
		    DateTime dtTemp = dtEnd;
		    dtEnd = dtStart;
		    dtStart = dtTemp;
		  }
			while (dtStart.Date() <= dtEnd.Date()) {
			         if (dtStart.format('EEE') != 'Sat' && dtStart.format('EEE') != 'Sun'){
			          dayCount ++;
        }
          dtStart = datetime.newInstance(dtStart.Year(), dtStart.Month(), dtStart.Day()+1, 00, 00, 00);
      }
      return dayCount;
    }
  //Harendra---Test---END    #S-368446
}