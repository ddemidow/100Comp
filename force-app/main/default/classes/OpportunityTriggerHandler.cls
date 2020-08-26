/*********************************************************************************
Name : Harendra Sain 
Created By : Appirio  
Created Date : 21 Dec. 2015
Purpose : Trigger Handler for send the mail on basis of below criteria

Connor Flynn  May 03,2016   S-409479 Modified, insert opportunity contact role on update/insert
Craig Schebler  Dec 22,2016   C-00185194 Modified, added criteria to renewal function
Jesse Brown   April 16, 2018  S-550868 Modified: added new methods for G100 Network Enterprise opportunity subgroup - parent/child relationship being replicated
Jesse Brown   June 5, 2018    C-00229956 Modified: allowed renewal opportunity creation to work whether called from batch or not
Jesse Brown   June 12, 2018   S-559758 Modified: added method to copy parent opportunity over to child upon insert (necessary because as of Summer '18 quick actions do not allow passing of picklist values)
*********************************************************************************/

public class OpportunityTriggerHandler {
  private static Boolean runOnceFlag = true; // Added by Vinit for S-647270 [04-Dec-2019]
  /*Start - Jai Gupta - S-506188 - Sep 06,2017 - Create Renewal Opportunity*/
  public final String WAITING_ON_DECISION = '50 - Waiting on Decision';
  public final String RENEWAL_LEADSOURCE = 'Renewal';
  public final String WLN_SUBGROUP = 'WLN';
  /*End - Jai Gupta - S-506188 - Sep 06,2017*/
  public final static String STAGENAME_100_SIGNED_CONTRACT = '100 - Signed Contract';
  public final static String GROUP_THE_MILES_GROUP = 'The Miles Group';
  public final static String ENGAGEMENT_TYPE_COACHING = 'Coaching';
  public final static String VAN_GUARD_OPPTIES_EXCLUDE = 'Vanguard Forum - HLG';            //S-462182 -----Hitesh [Feb 22, 2017]
  
  public static boolean historyTracked = false ; // Added by Jai Gupta S-565584
  //Connor Flynn S-409479
  private List<Opportunity> newLst;
  private Map<Id, Opportunity> newMap;
  private List<Opportunity> oldLst;
  private Map<Id, Opportunity> oldMap;

  public OpportunityTriggerHandler(List<Opportunity> newLstParam, Map<Id, Opportunity> newMapParam, List<Opportunity> oldLstParam, Map<Id, Opportunity> oldMapParam){
    newLst = newLstParam;
    newMap = newMapParam;
    oldLst = oldLstParam;
    oldMap = oldMapParam;
  }

  //Connor Flynn S-409479
  public void onAfterInsert(){
      //Start- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
      sendEmailOnMultipleOpp(newLst);
      //End- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
    /*Start - Jai Gupta - S-559561 - Aug 30,2018*/
    populateOpportunityOnMilestoneTask();
    /*End S-559561*/
    //START NSHARP S-488520 7.21.17
    syncContactBXStatus();
    //END NSHARP S-488520 7.21.17
    insertOpportunityContactRole(newLst);
    //aditya
    system.debug(' newlst::: ' + newlst);
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    List<Opportunity> opptiesToBeProcessed = new List<Opportunity>();
    set<Id> accids = new set<Id>();
    
    for(Opportunity opp :newLst){
      opptiesToBeProcessed.add(opp);
        accids.add(opp.accountId);
    }
    system.debug(' opptiesToBeProcessed:: ' + opptiesToBeProcessed); //aditya
    system.debug(' accids:: ' + accids); //aditya
    if(opptiesToBeProcessed.size() > 0)
        updateCompanyStatusOnAccount(opptiesToBeProcessed,accids);
    //S-429731 ---END--- Hitesh[Sept 14, 2016]

    //JesseB S-550868 calling method when Parent or Child opportunities (G100 Network Enterprise functionality) are inserted START
    Set<Id> parentIds = new Set<Id>();
    for (Opportunity opp : newLst) {
        if (opp.Parent_Opportunity__c != null) {
            parentIds.add(opp.Parent_Opportunity__c);
        }
    }
    if (parentIds != null && parentIds.size() > 0) {
        updateParentOpportunities(parentIds, newMap);
        updateChildrenOpportunities(parentIds);
    }
    //JesseB S-550868 calling method when Parent or Child opportunities (G100 Network Enterprise functionality) are inserted END
    
  }

  public void onAfterUpdate(){
      // Added by Vinit for S-647270 [04-Dec-2019] start
      if (runOnceFlag) {
      createNewRenewalOpp(newLst,oldMap);   
      }
      // Added by Vinit for S-647270 [04-Dec-2019] end
    /*Start - Jai Gupta - S-559561 - Aug 30,2018*/
    populateOpportunityOnMilestoneTask();
      
    /*End S-559561*/
    // Start by Jai Gupta | S-565584 | Oct 27th 2018
    trackHistory();
    // End by Jai Gupta | S-565584 | Oct 27th 2018
    //START NSHARP S-488520 7.21.17
    syncContactBXStatus();
    //END NSHARP S-488520 7.21.17
    insertOpportunityContactRole(newLst, oldMap);
    system.debug(' newlst::: ' + newlst);//aditya
    system.debug(' oldmap::: ' + oldmap);//aditya
    
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    List<Opportunity> opptiesToBeProcessed = new List<Opportunity>();
    set<Id> accids = new set<Id>();
    for(Opportunity opp :newLst){
        if(oldMap.get(opp.id).Final_Client_Date__c != opp.Final_Client_Date__c
            || oldMap.get(opp.id).CloseDate != opp.CloseDate
            || oldMap.get(opp.id).Probability != opp.Probability
            || oldMap.get(opp.id).StageName != opp.StageName){
            opptiesToBeProcessed.add(opp);
            accids.add(opp.accountId);
        }
    }
    
    system.debug(' opptiesToBeProcessed:: ' + opptiesToBeProcessed); //aditya
    system.debug(' accids:: ' + accids); //aditya
    if(opptiesToBeProcessed.size() > 0)
        updateCompanyStatusOnAccount(opptiesToBeProcessed,accids);
    //S-429731 ---END--- Hitesh[Sept 14, 2016]
    //JesseB S-550868 calling method to update children - passing list of all parent accounts being updated or children of this parent being updated START
    Set<Id> parentIds = new Set<Id>();
    Set<Id> parentAmountUpdate = new Set<Id>();
    for (Opportunity opp : newLst) {
        //If child has changed, add parent ID to set of opportunities for update
        if (opp.Parent_Opportunity__c != null &&
                (  opp.Description__c != oldMap.get(opp.Id).Description__c
                || opp.StageName != oldMap.get(opp.Id).StageName
                || opp.OwnerId != oldMap.get(opp.Id).OwnerId
                || opp.LeadSource != oldMap.get(opp.Id).LeadSource
                || opp.Lead_Contact_Source__c != oldMap.get(opp.Id).Lead_Contact_Source__c
                || opp.CampaignId != oldMap.get(opp.Id).CampaignId
                || opp.Renewal__c != oldMap.get(opp.Id).Renewal__c
                || opp.G100N_Opp_Type__c != oldMap.get(opp.Id).G100N_Opp_Type__c
                || opp.Issues_Speedbumps__c != oldMap.get(opp.Id).Issues_Speedbumps__c
                || opp.CloseDate != oldMap.get(opp.Id).CloseDate
                || opp.Reason_Lost__c != oldMap.get(opp.Id).Reason_Lost__c
                || opp.Membership_Begins__c != oldMap.get(opp.Id).Membership_Begins__c //JesseB new
                || opp.Membership_Expires__c != oldMap.get(opp.Id).Membership_Expires__c //JesseB new
                )
        ) {
            parentIds.add(opp.Parent_Opportunity__c);
        }
        //If parent opportunity lookup field target changes, then any non-null values, old or new, should have amounts updated.
        if (opp.Parent_Opportunity__c != oldMap.get(opp.Id).Parent_Opportunity__c) {
            if (opp.Parent_Opportunity__c != null) {
                parentIds.add(opp.Parent_Opportunity__c);
            }
            if (oldMap.get(opp.Id).Parent_Opportunity__c != null) {
                parentIds.add(oldMap.get(opp.Id).Parent_Opportunity__c); 
            }
            
        }
        //If parent opportunity's fields change, pass parent ID to update children
        if (opp.Parent_Opportunity__c == null && opp.SubGroup__c == 'G100 Network Enterprise' &&
                (  opp.Description__c != oldMap.get(opp.Id).Description__c
                || opp.StageName != oldMap.get(opp.Id).StageName
                || opp.OwnerId != oldMap.get(opp.Id).OwnerId
                || opp.LeadSource != oldMap.get(opp.Id).LeadSource
                || opp.Lead_Contact_Source__c != oldMap.get(opp.Id).Lead_Contact_Source__c
                || opp.CampaignId != oldMap.get(opp.Id).CampaignId
                || opp.Renewal__c != oldMap.get(opp.Id).Renewal__c
                || opp.G100N_Opp_Type__c != oldMap.get(opp.Id).G100N_Opp_Type__c
                || opp.Issues_Speedbumps__c != oldMap.get(opp.Id).Issues_Speedbumps__c
                || opp.CloseDate != oldMap.get(opp.Id).CloseDate
                || opp.Reason_Lost__c != oldMap.get(opp.Id).Reason_Lost__c
                || opp.Membership_Begins__c != oldMap.get(opp.Id).Membership_Begins__c //JesseB new
                || opp.Membership_Expires__c != oldMap.get(opp.Id).Membership_Expires__c //JesseB new
                )
        ){
            parentIds.add(opp.Id);            
        }
        
        //If parent or child opportunity's amount is edited, throw the parent ID into the method that will recalculate the parent ID amount
        if (opp.Parent_Opportunity__c != null && opp.Amount != oldMap.get(opp.Id).Amount ) {
            parentAmountUpdate.add(opp.Parent_Opportunity__c);
        }
        if (opp.Parent_Opportunity__c == null && opp.SubGroup__c == 'G100 Network Enterprise' && opp.Amount != oldMap.get(opp.Id).Amount) {
            parentAmountUpdate.add(opp.id);
        }
    }
    
    if (parentIds != null && parentIds.size() > 0 ) {
        updateChildrenOpportunities(parentIds);
    }
    if (parentAmountUpdate != null && parentAmountUpdate.size() > 0) {
        updateParentOpportunities(parentAmountUpdate, newMap);
    }
    //JesseB S-550868 calling method to update children - passing list of all parent accounts being updated or children of this parent being updated END      
  }

  // Start - Jai Gupta - S-559561 - Aug 30,2018
  public void populateOpportunityOnMilestoneTask() {
      Map<Id,Id> participantContactOpptyMap = new Map<id,id>();
      for(Opportunity opp : newLst) {
          if(opp.Group2__c == 'The Miles Group' && opp.IsRenewalOpportunity__c && opp.Participant_Contact__c != null) {
              if(oldMap == null || (oldMap.get(opp.Id).Participant_Contact__c != opp.Participant_Contact__c) ) {
                  participantContactOpptyMap.put(opp.Participant_Contact__c,opp.Id);
              }
          }
      }
      if(participantContactOpptyMap.size() > 0) {
          List<Milestone1_Task__c> mlToUpdate = new List<Milestone1_Task__c>();
          for(Milestone1_Task__c ml : [SELECT Id,Opportunity_Name__c,Project_Milestone__r.Assessed_Executive__c from Milestone1_Task__c where Project_Milestone__r.Assessed_Executive__c IN :participantContactOpptyMap.keySet() AND Last_Coaching_Session__c = TRUE AND Project_Milestone__r.Complete__c = FALSE]){
              if(participantContactOpptyMap.containsKey(ml.Project_Milestone__r.Assessed_Executive__c)) {
                    ml.Opportunity_Name__c = participantContactOpptyMap.get(ml.Project_Milestone__r.Assessed_Executive__c);
                    mlToUpdate.add(ml);
              }
          }

          if(mlToUpdate.size() > 0) {
              update mlToUpdate ;
          }
      }
  }
  // End S-559561

  //S-429731 ---START---- Hitesh[Sept 14, 2016]
  public void onBeforeInsert(){
      //populate  Final Client Date to the earliest among -
      //- Membership_Expires__c on Opportunity object
      // - Revenue Recognition 1 (Revenue_Recognition_Begins__c)
      // - Revenue Recognition 2 (Revenue_Recognition_Ends__c)
      // - Revenue Recognition 3 (Revenue_Recognition_3__c)
      for(Opportunity opp :newLst){ 
          set<Date> dates = getDateSet(opp);                                     
          if(dates.size() > 0)
              populateLatestDateOnOppty(dates, opp);
      }
      updateDateFieldsOnRenewalOppty(newLst); //Added By - Jai Gupta - S-506188 - Sep 06,2017
      copyParentValuesForChildOpps(newLst);//JesseB - S-559758 Calling new method to update children with parents' picklist values
  }
  
  public void onBeforeUpdate(){
      //populate  Final Client Date to the earliest among -
        //- End date field on all of project associated to Opportunity.
        //- Membership_Expires__c on Opportunity object
        //- Revenue Recognition 1 (Revenue_Recognition_Begins__c)
        //- Revenue Recognition 2 (Revenue_Recognition_Ends__c)
        //- Revenue Recognition 3 (Revenue_Recognition_3__c)
        
        //get opportunity's projects latest date 
        map<Id,pse__Proj__c> opptyToLatestProjMap = new map<Id,pse__Proj__c>();
        for(pse__Proj__c proj :[select pse__Opportunity__c, pse__End_Date__c from pse__Proj__c where pse__Opportunity__c in:newLst and pse__End_Date__c != null order by pse__End_Date__c desc]){
            if(!opptyToLatestProjMap.containsKey(proj.pse__Opportunity__c))
                opptyToLatestProjMap.put(proj.pse__Opportunity__c, proj);
            else
                continue;
        }   
        for(Opportunity opp :newLst){
            if(opp.Membership_Expires__c != oldMap.get(opp.id).Membership_Expires__c
                || opp.Revenue_Recognition_Begins__c != oldMap.get(opp.id).Revenue_Recognition_Begins__c
                || opp.Revenue_Recognition_Ends__c != oldMap.get(opp.id).Revenue_Recognition_Ends__c
                || opp.Revenue_Recognition_3__c != oldMap.get(opp.id).Revenue_Recognition_3__c){
                    set<Date> datesToBeProcessed = getDateSet(opp);                                     
                    if(opptyToLatestProjMap.containsKey(opp.id))
                        datesToBeProcessed.add(opptyToLatestProjMap.get(opp.id).pse__End_Date__c);
                    system.debug('****datesToBeProcessed  = '+datesToBeProcessed);
                    if(datesToBeProcessed.size() > 0)
                        populateLatestDateOnOppty(datesToBeProcessed, opp);
                }
        }

        //CSCHEBLER start JesseB S-550868 updating to use more null checks and optimize START
        Set<Id> opptiesToBeRenewed = new Set<Id>();
        Id MembershipManagementRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Management').getRecordTypeId();
        Id MembershipManagementContractRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Management (Contract)').getRecordTypeId(); //JesseB S-550868 One line to add Membership Management (Contract) record type
        //check all opportunities in the new list to see if they fit membership management renewal rule
        //create new opportunities and add to list to insert
        system.debug('####EnteringLoop');
        for(opportunity opp : newlst){
          system.debug('####BeforeIf');
          system.debug('Stage Check:' +opp.StageName); //JesseB C-00229956 correcting debug
          system.debug('is it won?: ' + opp.IsWon);
          system.debug('Is it the right record type or force renewal?: ' + opp.Force_Renewal_Creation__c + opp.RecordTypeId);
          system.debug('Is it subGroup G100, G100 Network Enterprise, TC, Next, or membership NGL Adv 75k?: ' + opp.SubGroup__c + opp.Membership_Type__c);
          system.debug('Is it NOT an enterprise sale: ' + opp.G100_Network_Enterprise_Sale__c);
          
          //exact recreation of advanced workflow rule
            if(oldMap !=null && oldMap.get(opp.id).stageName != null && oldMap.get(opp.id).IsWon != true && opp.IsWon == true // Added Oldmap Condition by parag bhatt for Story S-634792
                && opp.hasBeenRenewed__c == false
                && ( 
                    (opp.RecordTypeId == MembershipManagementRecordTypeId )//Part of code commented By parag bhatt for Story S-634792 (&& oldMap.get(opp.id).StageName != '100 - Invoice Paid' && opp.StageName == '100 - Invoice Paid') //JesseB C-00229956 correcting logic for moving TO '100 - Invoice Paid'
                ||  (opp.RecordTypeId == MembershipManagementContractRecordTypeId) //Part of code commented By parag bhatt for Story S-634792 (&& oldMap.get(opp.id).StageName != '100 - Closed/Won' && opp.StageName == '100 - Closed/Won')//JesseB C-00229956 correcting logic for new Sales process adding one line for new record type
                ||  (opp.Force_Renewal_Creation__c == true ) 
                )
                && ( opp.SubGroup__c == 'G100' 
                || opp.SubGroup__c == 'TC' //Added By parag bhatt for Story S-634792
                || opp.SubGroup__c == 'Exec Network'//Added By parag bhatt for Story S-634792
                || opp.SubGroup__c == 'WLN'//Added By parag bhatt for Story S-634792
                || opp.SubGroup__c == 'G100 Mentore' //JesseB S-550868 adding one line for new Subgroup type
                || opp.SubGroup__c == 'G100 Network Enterprise' //JesseB S-550868 adding one line for new Subgroup type
                || opp.Membership_Type__c == 'NGL Advisor ($75K)' ) 
                // && opp.G100_Network_Enterprise_Sale__c != true JesseB S-550868 commenting out for new functionality for G100 Network Enterprise subgroup
                //CSCHEBLER ADDED 1 LINE BELOW C-00185194
                && opp.Parent_Opportunity__c == null)
            {
                if (opp.Membership_Begins__c == null || opp.Membership_Expires__c==null){
                    opp.addError('Please fill out when the membership begins and expires.');
                } 
                else { 
                system.debug('#### creating new renewal oppty!');
                opp.hasBeenRenewed__c = true;
                opptiesToBeRenewed.add(opp.Id);
                }
            }
        }

        //JesseB C-00229956 START changing method so it uses Future when possible but can still create membership management renewal records from batches
        if (opptiesToBeRenewed != null && opptiesToBeRenewed.size() > 0 && !System.isFuture() && !System.isBatch()) {  
            FutureCreateMembershipManagementRenewalRecord(opptiesToBeRenewed); //JesseB S-550868 changing parameter being passed so that it works for any record type (that was selected in the conditional above)
        } else if(opptiesToBeRenewed != null && opptiesToBeRenewed.size() > 0 && System.isBatch()){
            CreateMembershipManagementRenewalRecord(opptiesToBeRenewed);
        }   
  }
  //JesseB C-00229956 END changing method so it uses Future when possible but can still create membership management renewal records from batches
  //JesseB S-550868 END
    
 
  public static set<date> getDateSet(Opportunity opp){
    set<Date> dates = new set<Date>();
      if(opp.Membership_Expires__c != null)
          dates.add(opp.Membership_Expires__c);
      if(opp.Revenue_Recognition_Begins__c != null)
          dates.add(opp.Revenue_Recognition_Begins__c);
      if(opp.Revenue_Recognition_Ends__c != null)
          dates.add(opp.Revenue_Recognition_Ends__c );
      if(opp.Revenue_Recognition_3__c != null)
          dates.add(opp.Revenue_Recognition_3__c);
      //Modified By Arihant for CASE#00223036  - Updated the logic as per the Solution Plan of S-429731/ Close date used only for certain scenerios
      if(opp.Membership_Expires__c == null && opp.Revenue_Recognition_Begins__c == null && opp.Revenue_Recognition_Ends__c == null && opp.Revenue_Recognition_3__c == null && opp.CloseDate != null)
            dates.add(opp.CloseDate);
      return dates;
  }
  // Start by Jai Gupta | S-565584 | Oct 27th 2018
  private void trackHistory() { 
        if(!historyTracked) {
            String fieldSetName = 'CustomHistoryTracking' ;

            // Get the fields on which history need to be enabled from the Field set (Default name is taken as HistoryTracking)
            List<Schema.FieldSetMember> trackedFields = getFieldSetDetail('Opportunity',fieldSetName);
            List<OpportunityHistory__c> oHistory = new List<OpportunityHistory__c>();
            for(Opportunity opp : newLst) {
                // get the Id of the record to fetch old value from Map
                string recId = String.valueOf(opp.get('Id'));
                // If fields mentioned in the fieldset
                for (Schema.FieldSetMember fsm : trackedFields) {
                    String fieldName  = fsm.getFieldPath(); // get API name of field
                    String fieldLabel = fsm.getLabel(); // get Label of field
                            
                    OpportunityHistory__c oh = new OpportunityHistory__c();
                        
                    // If the new and old values are not same
                    if(opp.get(fieldName) != oldMap.get(recId).get(fieldName)) {
                            
                        // Convert values as string
                        String oldValue = String.valueOf(oldMap.get(recId).get(fieldName));
                        String newValue = String.valueOf(opp.get(fieldName));
                            
                        oh.Name = fieldLabel; // Field Label
                        oh.Field_API_Name__c   = fieldName;
                        oh.Opportunity__c = recId ;
                        oh.Old_Value__c  = oldValue ;
                        oh.New_Value__c  = newValue;
                        // Start - S-589952 - Jai Gupta - Nov 15,2018
                        oh.Edited_by__c  = UserInfo.getUserId();
                        oh.Edited_Date__c  = system.now();
                        // End - S-589952 - Jai Gupta - Nov 15,2018
                        oHistory.add(oh);
                    }
                }
            }

            if(oHistory.size() > 0) {
                insert oHistory ;
            }
            historyTracked = true ;
        }
        
  }

  public List<Schema.FieldSetMember> getFieldSetDetail(string sobj, string fsName) {
        List<Schema.FieldSetMember> trackedFields = null ;
        Map<String, Schema.FieldSet> fieldSetMap = Schema.getGlobalDescribe().get(sobj).getDescribe().fieldSets.getMap();
        if(fieldSetMap.containsKey(fsName)) {
            trackedFields = fieldSetMap.get(fsName).getFields();
        }
        
        return trackedFields ;
    }
  // End by Jai Gupta | S-565584 | Oct 27th 2018
  /*Start - Jai Gupta - S-506188 - Sep 06,2017*/
  private void updateDateFieldsOnRenewalOppty(List<Opportunity> newLst) {
    for(Opportunity opp : newLst) {
        if(opp.StageName == WAITING_ON_DECISION 
            && opp.Renewal__c 
            && opp.LeadSource == RENEWAL_LEADSOURCE 
            && opp.SubGroup__c == WLN_SUBGROUP 
            && opp.CloseDate != null 
            && opp.Membership_Begins__c != null
            && opp.Membership_Expires__c != null
            ) {
            // i.e. it is a renewal opportunity for WLN opportunity so update the closedate, membership begins date and expires date accordingly.
            opp.Membership_Begins__c = Date.newInstance(opp.Membership_Begins__c.year()+1,opp.Membership_Begins__c.month(),opp.Membership_Begins__c.day()); // update to next year with same date
            opp.Membership_Expires__c = Date.newInstance(opp.Membership_Expires__c.year()+1,opp.Membership_Expires__c.month(),opp.Membership_Expires__c.day()); // update to next year with same date
            opp.CloseDate = Date.newInstance(opp.CloseDate.year()+1,opp.CloseDate.month(),opp.CloseDate.day()-1); // -1 day to membership begins date
        }
    }
  }
  /*End - Jai Gupta - S-506188 - Sep 06,2017*/
  public static void populateLatestDateOnOppty(set<Date> dateSet, Opportunity targetOpp){
         
     map<Date, integer> earliestDateMap = new map<Date, integer>();
      
      for(Date d :dateSet){
        system.debug('****current date = '+d);
          if(!earliestDateMap.isEmpty()){
            system.debug('****Date.Today().DaysBetween(d) = '+Date.Today().DaysBetween(d));
              if(earliestDateMap.values().get(0) < Date.Today().DaysBetween(d)){
                //clear map and put new date 
                earliestDateMap.clear();
                earliestDateMap.put(d, Date.Today().DaysBetween(d));
              }              
          }else{
              earliestDateMap.put(d, Date.Today().DaysBetween(d));
          }
      }
      system.debug('**** earliestDateMap = '+earliestDateMap);
      if(!earliestDateMap.isEmpty()){
          for(Date d :earliestDateMap.keySet()){
              targetOpp.Final_Client_Date__c = d;
              break;
          }                   
      }
  }
  
  private void updateCompanyStatusOnAccount(List<Opportunity> newOppList, set<Id> accids){
    map<Id, map<string,List<Opportunity>>> accountToOpptyMap = new map<Id, map<string,List<Opportunity>>>();
    List<Account> accountsToBeUpdated = new List<Account>();
    set<Id> accountIds = new set<Id>();
    //Connor Flynn S-447295 Start
    Set<Id> contactIds = new Set<Id>();
    map<Id, map<string,List<Opportunity>>> contactToOpptyMap = new map<Id, map<string,List<Opportunity>>>();
    List<Contact> contactToBeUpdated = new List<Contact>();
    //Connor Flynn S-447295 End
    system.debug(' newOppList::updateCompanyStatusOnAccount ' + newOppList );//aditya
    system.debug(' accids::updateCompanyStatusOnAccount ' + accids );//aditya
    for(Opportunity opp :newOppList){
        accountIds.add(opp.accountId);
        contactIds.add(opp.Participant_Contact__c);
    }
    
    for(Opportunity opp :[select Group2__c, Participant_Contact__c, Final_Client_Date__c, Probability, CloseDate, StageName, accountId
                            from Opportunity
                            where (accountId in:accountIds OR Participant_Contact__c in:contactIds) and Group2__c != null and Group2__c !=:VAN_GUARD_OPPTIES_EXCLUDE]){         //S-462182 -----Hitesh [Feb 22, 2017] --Added Group2__c !=:VAN_GUARD_OPPTIES_EXCLUDE condition

        if(accountToOpptyMap.containsKey(opp.accountId) && accountIds.contains(opp.AccountId)){
            map<string,List<Opportunity>> groupToOpptyMap_temp = accountToOpptyMap.get(opp.accountId);
            if(groupToOpptyMap_temp.containsKey(opp.Group2__c))
                groupToOpptyMap_temp.get(opp.Group2__c).add(opp);
                
            else
                groupToOpptyMap_temp.put(opp.Group2__c, new List<Opportunity>{opp});
        }else{
            map<string,List<Opportunity>> groupToOpptyMap = new map<string,List<Opportunity>>();
            groupToOpptyMap.put(opp.Group2__c, new List<Opportunity>{opp});
            accountToOpptyMap.put(opp.accountId, groupToOpptyMap);
        }
        //Connor Flynn S-447295 Start
        if(opp.Participant_Contact__c != null && contactIds.contains(opp.Participant_Contact__c)){
          if(contactToOpptyMap.containsKey(opp.Participant_Contact__c)){
              map<string,List<Opportunity>> groupToOpptyMap_temp = contactToOpptyMap.get(opp.Participant_Contact__c);
              if(groupToOpptyMap_temp.containsKey(opp.Group2__c))
                  groupToOpptyMap_temp.get(opp.Group2__c).add(opp);
              else
                  groupToOpptyMap_temp.put(opp.Group2__c, new List<Opportunity>{opp});
                          
          }else{
              map<string,List<Opportunity>> groupToOpptyMap = new map<string,List<Opportunity>>();
              groupToOpptyMap.put(opp.Group2__c, new List<Opportunity>{opp});
              contactToOpptyMap.put(opp.Participant_Contact__c, groupToOpptyMap);
          }
        }
        //Connor Flynn S-447295 End
      }
    if(!accountToOpptyMap.isEmpty()){
        for(Id accId :accountToOpptyMap.keySet()){
            string companyStatusString = '';
            for(string group2 :accountToOpptyMap.get(accId).keySet()){
                string res = getCompanyStatusString(group2,accountToOpptyMap.get(accId).get(group2));
                if(res != '')
                    companyStatusString += res + ', ';
            }
            
            companyStatusString = companyStatusString.removeEnd(', ');
            Account acc = new Account(Id = accId, G100_Companies_Status__c = companyStatusString);
            accountsToBeUpdated.add(acc);
        }
    }
    //Connor Flynn S-447295 Start
    if(!contactToOpptyMap.isEmpty()){
        for(Id contId :contactToOpptyMap.keySet()){
            string companyStatusString = '';
            for(string group2 :contactToOpptyMap.get(contId).keySet()){
                string res = getCompanyStatusString(group2,contactToOpptyMap.get(contId).get(group2));
                if(res != '')
                    companyStatusString += res + ', ';
            }
            
            companyStatusString = companyStatusString.removeEnd(', ');
            Contact cont = new Contact(Id = contId, G100_Companies_Status__c = companyStatusString);
            contactToBeUpdated.add(cont);
        }
    }
    //Connor Flynn S-447295 End
    system.debug(' accountsToBeUpdated::updateCompanyStatusOnAccount ' + accountsToBeUpdated );//aditya
    if(accountsToBeUpdated.size() > 0)
        update accountsToBeUpdated;
    //Connor Flynn S-447295 Start
    if(contactToBeUpdated.size() > 0){
      update contactToBeUpdated;
    }
    //Connor Flynn S-447295 End
  }

  
  public static string getCompanyStatusString(string group2, List<Opportunity> oppties){ //Modified By Arihant For CASE#00223036
    boolean isClient = false;
    boolean isFormerClient = false;
    boolean isProspect = false;
    string result = '';
    for(Opportunity opp :oppties){          
        if(opp.probability == 100 && opp.Final_Client_Date__c >= Date.Today()){     //- Probability = 100, Final Client date >= TODAY then "Group2__c" - Client 
            isClient = true;
        }else if(opp.probability == 100 && opp.Final_Client_Date__c < Date.Today()){  //- Probability = 100, Final Client date < TODAY then "Group2__c" - Former Client
            isFormerClient = true;
        }else 
        //Modified By Arihant for CASE#00221043 - Updated the logic as per the Solution Plan of S-429731
        if(opp.probability >= 0 && opp.probability < 100 && opp.CloseDate > Date.Today() && !opp.stageName.equalsIgnoreCase('Closed/Lost')){   // - Probability > 0 AND Probability < 100, CloseDate > TODAY then "Group2__c" - Prospect
            isProspect = true;
        }else
            continue;   
    }
   
    if((isClient && isFormerClient && isProspect) || (isClient && isFormerClient) || (isClient && isProspect))
        result =  group2 + ' - Client';     
    else if(isFormerClient && isProspect)
        result =  group2 + ' - Prospect and Former Client';
    else if(isProspect)
        result =  group2 + ' - Prospect';
    else if(isClient)
        result =  group2 + ' - Client';
    else if(isFormerClient)
        result =  group2 + ' - Former Client';
         
    return result;
  }
  //S-429731 ---END---- Hitesh[Sept 14, 2016]
  
  //on after insert, doesn't use old map
  public void insertOpportunityContactRole(List<Opportunity> oppList){
    List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
  
    for(Opportunity opp : oppList){
      if(opp.Participant_Contact__c != null){
        oppContactRole.add(new OpportunityContactRole(OpportunityId = opp.Id, ContactId = opp.Participant_Contact__c, isPrimary = true));
      }
    }

    insert oppContactRole;
    
  }
  //On after update, uses old map
  public void insertOpportunityContactRole(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap){
    List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
    system.debug('oppList::insertOpportunityContactRole' + oppList );//aditya
    system.debug('oldOppMap::insertOpportunityContactRole' + oldOppMap );//aditya
    for(Opportunity opp : oppList){
      if(opp.Participant_Contact__c != null && (opp.Participant_Contact__c  != oldOppMap.get(opp.Id).Participant_Contact__c)){
        oppContactRole.add(new OpportunityContactRole(OpportunityId = opp.Id, ContactId = opp.Participant_Contact__c, isPrimary = true));
      }
    }
    system.debug('oppContactRole::1' + oppContactRole);//aditya
    system.debug('oppContactRole::size' + oppContactRole.size());//aditya
    if (oppContactRole != null && oppContactRole.size() > 0 ){ //JesseB adding null/empty check
        insert oppContactRole;
    }
    
  }
  //Connor Flynn S-409479 End

   // Create a Map to store all renewal opps for bulk inserting
  
  public static void onAfterUpdate (List<Opportunity> NewOppList, Map<Id, Opportunity> oldOppMap){
    createRenewalOppty(NewOppList, oldOppMap);
  }
  
    // Added by Vinit for S-647270 [04-Dec-2019] start
    private static void createNewRenewalOpp(List<Opportunity> NewOppList, Map<Id, Opportunity> oldOppMap) {
        
        list<Opportunity> oppList =  new list <Opportunity>(); 
        for(opportunity opp : NewOppList){
           
          if (opp.SubGroup__c == 'BX' && opp.StageName == '100 - Closed/Won' && 
              (opp.Membership_Type__c == 'BX Individual Annual Membership ($15K)' 
               || opp.Membership_Type__c == 'BX Corporate Member ($25K)') && 
             (opp.StageName != oldOppMap.get(opp.id).StageName || opp.SubGroup__c != oldOppMap.get(opp.id).SubGroup__c 
              || opp.Membership_Type__c != oldOppMap.get(opp.id).Membership_Type__c 
              || opp.LeadSource != oldOppMap.get(opp.id).LeadSource)) {
              Opportunity newOpp = new Opportunity();
              Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Management (Contract)').getRecordTypeId();     
               newOpp.RecordTypeId = devRecordTypeId;
               newOpp.LeadSource = 'Renewal';
               newOpp.OwnerId = opp.OwnerId;
               newOpp.Renewal__c = true;
               newOpp.G100N_Opp_Type__c = 'Renewal';
               newOpp.SubGroup__c = opp.SubGroup__c;
                   if (opp.Group2__c != null) {
                       
               		newOpp.Group2__c = opp.Group2__c; 
                   } 
               newOpp.Membership_Type__c = opp.Membership_Type__c;
                   if (opp.Amount != null) {
                       
               		newOpp.Amount = opp.Amount;
                   }
               if (opp.Membership_Begins__c != null) {
                   newOpp.CloseDate = opp.Membership_Begins__c.addYears(1).addDays(-2);
               	   newOpp.Membership_Begins__c = opp.Membership_Begins__c.addYears(1); 
               }
               if (opp.Membership_Expires__c != null) {
               	   newOpp.Membership_Expires__c = opp.Membership_Expires__c.addYears(1);      
               }
               newOpp.StageName = '70 - In Negotiation';  
               newOpp.Probability = 70; 
               newOpp.AccountId =  opp.AccountId;
               newOpp.Name = opp.Name;    
               newOpp.Participant_Contact__c = opp.Participant_Contact__c;    
                   
               oppList.add(newOpp);    
          }
        }
        
        if (oppList.size() > 0) {
            insert oppList;
            runOnceFlag = false;
        }
    }
  
       // Added by Vinit for S-647270 [04-Dec-2019] ends
       
    Private static void createRenewalOppty(List<Opportunity> NewOppList, Map<Id, Opportunity> oldOppMap){
      list<Opportunity> RenewalOppToInsert =  new list <Opportunity>();
      Id ASRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advisory Services').getRecordTypeId();
      system.debug('createrenewaloppty::newopplist' + NewOppList );//aditya
      system.debug('createrenewaloppty::oldOppMap' + oldOppMap );//aditya
      for(opportunity opp : NewOppList){
        
        if(opp.StageName == STAGENAME_100_SIGNED_CONTRACT && opp.Group2__c == GROUP_THE_MILES_GROUP 
          && opp.Engagement_Type__c == ENGAGEMENT_TYPE_COACHING && opp.CloseDate == date.today()
          &&(oldOppMap.get(opp.Id).StageName != opp.StageName || oldOppMap.get(opp.Id).Group2__c != opp.Group2__c 
            || oldOppMap.get(opp.Id).Engagement_Type__c != opp.Engagement_Type__c) || oldOppMap.get(opp.Id).CloseDate != opp.CloseDate)
          RenewalOppToInsert.add(CreatedRenewalRecord(opp, ASRecTypeId));
      }
      
      system.debug('++++++RenewalOppToInsert+++++++++++'+RenewalOppToInsert);
      if(RenewalOppToInsert.size() > 0){
        insert RenewalOppToInsert;
      }
      
    }
    
    private static Opportunity CreatedRenewalRecord (Opportunity opp, Id recTypeId){
      
          // Only create renewal opps for closed won deals    
             Opportunity renewal = new Opportunity();
             renewal = (Opportunity)opp.clone(false,true,true,true);
             renewal.IsRenewalOpportunity__c = true;
             renewal.AccountId   = opp.AccountId;
             renewal.amount = opp.amount;
             renewal.Lead_Contact_Source__c = opp.Lead_Contact_Source__c;
             renewal.LeadSource = opp.LeadSource;
             renewal.Participant_Contact__c = opp.Participant_Contact__c;
             renewal.Project_Name__c = 'Renewal_' + opp.Name;
             renewal.Project_Start_Date__c = opp.CloseDate;
             if(opp.Project_Start_Date__c != null  && opp.Project_End_Date__c != null ){
               
             if(Math.abs(opp.Project_End_Date__c.monthsBetween(opp.Project_Start_Date__c))+1 == 12){
                renewal.Project_End_Date__c = renewal.Project_Start_Date__c.addMonths(9);
                renewal.CloseDate   = opp.CloseDate.addmonths(9); 
             }else{
                 renewal.Project_End_Date__c = renewal.Project_Start_Date__c.addMonths(4);
                 renewal.CloseDate   = opp.CloseDate.addmonths(4); 
              }
             }
             //renewal.Name        = opp.Name + 'Renewal';
             // Add a year
             renewal.StageName   = '05 - Meeting Scheduled';
             renewal.RecordTypeId  =  recTypeId;
             renewal.OwnerId     = opp.OwnerId;
      return renewal;    
               
  }

  //START NSHARP S-488520 7.21.17
  public void syncContactBXStatus(){
    List<Contact> contactsToUpdate = new List<Contact>();
    Set<String> targetLostReasons = new Set<String>{'Budgetary Restrictions', 'Lost to Competitor', 'No Reason Given', 'No response', 'Schedule Conflicts'};
    /** Added - Jai Gupta - S-506189 - 12 Sep, 2017 - Updated Organizational or Structural Changes value*/
    Set<String> blankLostReasons = new Set<String>{'Disqualified', 'Inherited Membership', 'Value Proposition', 'Job change', 'Organizational or Structural Changes', 'Not Interested'};
    /* Start - Jai Gupta - S-506189 - 12 Sep, 2017 - Similar functionality for WLN status */
    string PROSPECT_CURRENT_OPP = 'Prospect (Current Opp)' ;
    string TARGET_POTENTIAL_OPP = 'Target (Potential Opp)' ;
    /* End - Jai Gupta - S-506189 - 12 Sep, 2017 - Similar functionality for WLN status */
    /* Added in query - Jai Gupta - S-506189 - 12 Sep, 2017 - Added Participant_Contact__r.WLN_Status__c and Similar functionality for WLN status */
    for(Opportunity o: [SELECT Id, StageName, Reason_Lost__c, Participant_Contact__c, Participant_Contact__r.WLN_Status__c,Participant_Contact__r.BX_Status__c, SubGroup__c FROM Opportunity WHERE Id IN: newLst]){
      if(Trigger.isInsert || o.StageName != oldMap.get(o.Id).StageName || o.Reason_Lost__c != oldMap.get(o.Id).Reason_Lost__c){
        /*Start - Jai Gupta - S-506189 - 12 Sep, 2017 - Added WLN condition*/
        if(o.Participant_Contact__c != null && o.SubGroup__c != null 
                && (o.SubGroup__c == 'BX' && (o.Participant_Contact__r.BX_Status__c == null || !o.Participant_Contact__r.BX_Status__c.containsIgnoreCase('member'))
                    || o.SubGroup__c == WLN_SUBGROUP && (o.Participant_Contact__r.WLN_Status__c == null || !o.Participant_Contact__r.WLN_Status__c.containsIgnoreCase('member')))
            ){
        /*End - Jai Gupta - S-506189 - 12 Sep, 2017*/
        // Added - BY Jai Gupta - updated || to && - S-506189 - 12 Sep, 2017
          if(o.StageName != '00 - Closed/Lost' && o.StageName != '100 - Invoice Paid' && o.Reason_Lost__c == null){
            if(o.SubGroup__c == 'BX') {
                o.Participant_Contact__r.BX_Status__c = PROSPECT_CURRENT_OPP;
            /*Start - Jai Gupta - S-506189 - 12 Sep, 2017*/
            } else if(o.SubGroup__c == WLN_SUBGROUP) {
                o.Participant_Contact__r.WLN_Status__c = PROSPECT_CURRENT_OPP;
            }
            /*End - Jai Gupta - S-506189 - 12 Sep, 2017*/
            contactsToUpdate.add(o.Participant_Contact__r);
          }
          else if(o.StageName == '00 - Closed/Lost' && targetLostReasons.contains(o.Reason_Lost__c)){
            if(o.SubGroup__c == 'BX') {
                o.Participant_Contact__r.BX_Status__c = TARGET_POTENTIAL_OPP;
            /*Start - Jai Gupta - S-506189 - 12 Sep, 2017*/
            } else if(o.SubGroup__c == WLN_SUBGROUP) {
                o.Participant_Contact__r.WLN_Status__c = TARGET_POTENTIAL_OPP;
            }
            /*End - Jai Gupta - S-506189 - 12 Sep, 2017*/
            contactsToUpdate.add(o.Participant_Contact__r);
          }
          else if(o.StageName == '00 - Closed/Lost' && blankLostReasons.contains(o.Reason_Lost__c)){
            o.Participant_Contact__r.BX_Status__c = null;
            o.Participant_Contact__r.WLN_Status__c = null ; // Added by Jai Gupta - S-506189 - 12 Sep, 2017
            contactsToUpdate.add(o.Participant_Contact__r);
          }
        }
      }
    }
    system.debug('contacts to update ' +contactsToUpdate);
    if (contactsToUpdate != null && contactsToUpdate.size() > 0) { //JesseB adding null/size check and debug log
        update contactsToUpdate;
    }
    
  }
  //END NSHARP S-488520 7.21.17

  //CSCHEBLER start JesseB S-550868 START updates to method to allow creating membership management renewal for multiple types of opportunities
  //JesseB C-00229956 START changing method so it uses Future when possible but can still create membership management renewal records from batches
  @future
  private static void FutureCreateMembershipManagementRenewalRecord(Set<Id> opptiesToBeRenewed){
      CreateMembershipManagementRenewalRecord(opptiesToBeRenewed);
  }

  //JesseB C-00229956 END changing method so it uses Future when possible but can still create membership management renewal records from batches
  private static void CreateMembershipManagementRenewalRecord (Set<Id> opptiesToBeRenewed){
    List<Opportunity> oppsForRenewal = [SELECT Id, AccountId, Amount, CloseDate, ffrrtemplate__c, Group2__c, Membership_Begins__c, Membership_Expires__c, Membership_Type__c, Name, Next_Close_Date__c, Next_Membership_Start__c, Next_Membership_End__c, OwnerId, Participant_Contact__c, Product__c, pse__Practice__c, pse__Region__c, RecordTypeId, Renewal__c, StageName, SubGroup__c
                                       FROM Opportunity WHERE Id IN : opptiesToBeRenewed];
    List<Opportunity> newRenewals = new List<Opportunity>();
    system.debug('#### Prepping new oppty');
    for (Opportunity opp : oppsForRenewal) {
        Opportunity renewal = new Opportunity();
        renewal.AccountId = opp.AccountId;
        renewal.Amount = opp.Amount;
        renewal.CloseDate = opp.Next_Close_Date__c; 
        renewal.ffrrtemplate__c = opp.ffrrtemplate__c;
        renewal.Group2__c = opp.Group2__c;
        renewal.Membership_Begins__c = opp.Next_Membership_Start__c;
        renewal.Membership_Expires__c = opp.Next_Membership_End__c;
        renewal.Membership_Type__c = opp.Membership_Type__c;
        renewal.Name = opp.Name;
        renewal.OwnerId = opp.OwnerId;
        renewal.Participant_Contact__c = opp.Participant_Contact__c;
        renewal.Product__c = opp.Product__c;
        renewal.pse__Practice__c = opp.pse__Practice__c;
        renewal.pse__Region__c = opp.pse__Region__c;
        renewal.RecordTypeId = opp.RecordTypeId;
        renewal.Renewal__c = True;
        renewal.StageName = '70 - In Negotiation'; //Added By parag bhatt for Story S-634792
        renewal.SubGroup__c = opp.SubGroup__c;
        if (opp.SubGroup__c == 'G100' || opp.SubGroup__c == 'Exec Network' || opp.SubGroup__c == 'TC' || opp.SubGroup__c == 'WLN') { //Added By parag bhatt for Story S-634792
            renewal.G100N_Opp_Type__c = 'Renewal';
        }
        newRenewals.add(renewal);
    }
    if (newRenewals.size() > 0 && newRenewals != null) {
        insert newRenewals;
    }
  }
  //CSCHEBLER end JesseB S-550868 Updates END

    //Method for updating parent opportunities' amount based on the sum of their children opportunities' amounts.
    //Method added by JesseB S-550868 START
    private static void updateParentOpportunities (Set<Id> parentIds, Map<Id,Opportunity> newMap){
        List<Opportunity> parentsList = new List<Opportunity>();
        List<AggregateResult> groupedResults = [SELECT Sum(Amount) amt, Parent_Opportunity__c FROM Opportunity
                                              WHERE Parent_Opportunity__c IN: parentIds GROUP BY Parent_Opportunity__c];
        for (AggregateResult sumAmt : groupedResults) {
            Opportunity parentOpp = new Opportunity();
            parentOpp.Id = (id)sumAmt.get('Parent_Opportunity__c');
            parentOpp.Amount = (decimal)sumAmt.get('amt');
            parentsList.add(parentOpp);
        }
        update parentsList;
    }
    //Method added by JesseB S-550868 END

    //Method for updating children opportunities' field values to match their parent opportunities' field values
    //Method added by JesseB S-550868 START
    private static void updateChildrenOpportunities (Set<Id> parentIds) { 
        List<Opportunity> parents = [SELECT Id, AccountId, Description__c, StageName, OwnerId, LeadSource, Lead_Contact_Source__c, Membership_Begins__c, Membership_Expires__c, CampaignId, Renewal__c, G100N_Opp_Type__c, Issues_Speedbumps__c, CloseDate, Reason_Lost__c,
                                (SELECT Id, AccountId, Parent_Opportunity__c, Description__c, StageName, OwnerId, LeadSource, Lead_Contact_Source__c, Membership_Begins__c, Membership_Expires__c, CampaignId, Renewal__c, G100N_Opp_Type__c, Issues_Speedbumps__c, CloseDate, Reason_Lost__c FROM ChildOpportunities__r WHERE Parent_Opportunity__c IN: parentIds)
                                   FROM Opportunity WHERE Id IN: parentIds
                                  ];

        Set<Opportunity> childrenSet = new Set<Opportunity>();
        for (Opportunity parent : parents){
            for(Opportunity child: parent.ChildOpportunities__r) {
                Boolean addToSet = false;
                if (child.Description__c != parent.Description__c){
                    child.Description__c = parent.Description__c;
                    addToSet = true;
                }
                if (child.StageName != parent.StageName) {
                    child.StageName = parent.StageName;
                    addToSet = true;
                }
                if (child.OwnerId != parent.OwnerId){
                    child.OwnerId = parent.OwnerId;
                    addToSet = true;
                }
                if (child.AccountId != parent.AccountId) {
                    child.AccountId = parent.AccountId;
                    addToSet = true;
                }
                if (child.LeadSource == null && parent.LeadSource != null) {
                    child.LeadSource = parent.LeadSource;
                    addToSet = true;
                }
                if (child.Lead_Contact_Source__c == null && parent.Lead_Contact_Source__c != null) {
                    child.Lead_Contact_Source__c = parent.Lead_Contact_Source__c;
                    addToSet = true;
                }
                if (child.CampaignId == null && parent.CampaignId != null) {
                    child.CampaignId = parent.CampaignId;
                    addToSet = true;
                }
                if (child.Renewal__c != parent.Renewal__c){
                    child.Renewal__c = parent.Renewal__c;
                    addToSet = true;
                }
                if (child.G100N_Opp_Type__c != parent.G100N_Opp_Type__c){
                    child.G100N_Opp_Type__c = parent.G100N_Opp_Type__c;
                    addToSet = true;
                }
                if (child.Issues_Speedbumps__c == null && parent.Issues_Speedbumps__c != null) {
                    child.Issues_Speedbumps__c = parent.Issues_Speedbumps__c;
                    addToSet = true;
                }
                if (child.CloseDate != parent.CloseDate){
                    child.CloseDate = parent.CloseDate;
                    addToSet = true;
                }
                if (child.Reason_Lost__c != parent.Reason_Lost__c){
                    child.Reason_Lost__c = parent.Reason_Lost__c;
                    addToSet = true;
                }
                //Jesse B S-559758 START child record should inherit membership begin/end dates from parent
                if (child.Membership_Begins__c != parent.Membership_Begins__c) {
                    child.Membership_Begins__c = parent.Membership_Begins__c;
                    addToSet = true;
                }
                if (child.Membership_Expires__c != parent.Membership_Expires__c) {
                    child.Membership_Expires__c = parent.Membership_Expires__c;
                    addToSet = true;
                }
                //JesseB S-559758 END child record should inherit membership begin/end dates from parent
                if (addToSet == true){
                    childrenSet.add(child);
                }
                
            }
        }
        List<Opportunity> childrenList = new List<Opportunity>(childrenSet);
        update childrenList;
        //JesseB S-550868 END
    }
    
    //JesseB S-559758 START Method to copy Parent Opportunities' picklist values on insert
    private static void copyParentValuesForChildOpps(List<Opportunity> newLst) {
        Map<Id, Opportunity> childToParentMap = new Map<Id,Opportunity>();
        List<Opportunity> newOppsWithParents = new List<Opportunity>();
        List<Id> parentIds = new List<Id>();
        for (Opportunity o : newLst) {
            if (o.Parent_Opportunity__c != null){
                parentIds.add(o.Parent_Opportunity__c);
                newOppsWithParents.add(o);
                }
        }
        
        Map<Id,Opportunity> parentsMap = new Map<Id,Opportunity>([SELECT Id, LeadSource, G100N_Opp_Type__c, StageName, Parent_Opportunity__c, SubGroup__c
                                FROM Opportunity WHERE Id IN: parentIds
                                ]);
        for (Opportunity child : NewOppsWithParents){
            if(parentsmap.get(child.Parent_Opportunity__c).Parent_Opportunity__c != null || parentsMap.get(child.Parent_Opportunity__c).SubGroup__c != 'G100 Network Enterprise') {
                //Opportunity o = (Opportunity)Trigger.NewMap.get(child.Id);
                child.addError('Child opportunities can only be created from a G100 Network Enterprise opportunity that is not itself a child.'); //JesseB testing adding error
            }
            child.StageName = parentsMap.get(child.Parent_Opportunity__c).StageName;
            child.G100N_Opp_Type__c = parentsMap.get(child.Parent_Opportunity__c).G100N_Opp_Type__c;
            child.LeadSource = parentsMap.get(child.Parent_Opportunity__c).LeadSource;
            
        }                       
    }             
    //JesseB S-559758 END
    //Start- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
    public void sendEmailOnMultipleOpp(List<Opportunity> newList) {
        Set<ID> setOfPartContId = new Set<ID>();
        Map<Id, List<Id>> mapContactOppotunities = new Map<Id, List<Id>>();
        Set<ID> setOfNewIds = new Set<ID>();
        List<Messaging.SingleEmailMessage> mails = 
                new List<Messaging.SingleEmailMessage>();
        sendEmailOnMultipleOpportunities__c sendEmailDetails = sendEmailOnMultipleOpportunities__c.getOrgDefaults();
        System.debug('sendEmailDetails>> '+sendEmailDetails);
        for(Opportunity opp: newList){ 
        	if(opp.Participant_Contact__c != null && opp.SubGroup__c == 'Exec Network'){
                setOfNewIds.add(opp.Id);    
                setOfPartContId.add(opp.Participant_Contact__c);
                if(!mapContactOppotunities.containsKey(opp.Participant_Contact__c)){
                	mapContactOppotunities.put(opp.Participant_Contact__c, new List<Id>()); 
                }
                mapContactOppotunities.get(opp.Participant_Contact__c).add(opp.Id);
            }
        }
        if(setOfPartContId.size() >0){
            List<Contact> listOfContact = [Select Id, Name,(select id,StageName from Opportunities where StageName = '100 - Closed/Won' or  StageName = '00 - Closed/Lost' LIMIT 1),AccountId from Contact where id in:setOfPartContId];
            for(Contact con: listOfContact){
                Boolean sendOnce = true;
                if(con.Opportunities.size() > 0){
                        if(sendEmailDetails != null){
                            Messaging.SingleEmailMessage mail = 
                                new Messaging.SingleEmailMessage();
                            List<String> sendTo = new List<String>();
                            sendTo.add(sendEmailDetails.sendToEmailAddress__c);
                            mail.setToAddresses(sendTo);
                            mail.setSenderDisplayName(sendEmailDetails.senderDisplayName__c);
                            mail.setSubject(sendEmailDetails.Subject__c);
                            String body = sendEmailDetails.body__c;
                            body = body.replace('{!contactname}',con.Name);
                            body = body.replace('{!accountid}',con.AccountId);
                            if(mapContactOppotunities.get(con.Id) != null){
                                String oppsIds = String.join(mapContactOppotunities.get(con.Id), ',');
                                body = body.replace('{!opportunityid}',oppsIds);
                            }
                            body = body + sendEmailDetails.processBuilderName__c;
                            mail.setHtmlBody(body);
                            mails.add(mail);
                        }
                }
            }
            if(mails.size() >0){
                Messaging.sendEmail(mails);
            }
        }
    }
    //End- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
}