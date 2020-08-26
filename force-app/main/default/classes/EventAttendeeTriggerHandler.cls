/************************************************
* Name           : EventAttendeeTriggerHandler
* Created By     : Nishank Jaisinghani
* Created Date   : 10th April 2015
* Story          : S-299883
* Modified by    : Nishank Jaisinghani for Case :- 00123248 (Replaced API of Associated Opportunity for RevRec with same as that of Production
to keep in Sync)
//Sanjeev Sharma c-00218323 [12-02-2018]
************************************************/

Public Class EventAttendeeTriggerHandler{

Public static void onAfterInsertUpdate(List<Event_Members__c> newEventMembers, Map<Id,Event_Members__c> oldEventMemberMap){
    //Get List of Events Being Updated
    Set<Id> opportunitiesToBeUpdated = new Set<Id>();
    Set<Id> oppSet = new Set<Id>();  // added by jasvinder for case: 00204418
    for(Event_Members__c em : newEventMembers){
        opportunitiesToBeUpdated.add(em.Opportunity__c);
    }
    
    //Get Related Opportunities and all related Event Members Using Inner Query
    List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
    for(Opportunity o : [Select Id, Membership_Type__c, Revenue_Recognition_Begins__c, Revenue_Recognition_1_Manually_Updated__c, Revenue_Recognition_Ends__c, Revenue_Recognition_2_Manually_Updated__c, Revenue_Recognition_3__c, Revenue_Recognition_3_Manually_Updated__c,(Select Attending_As_NGL_Only__c, Event__r.End_Date__c FROM Event_Attendees__r WHERE Attended_NGL_Revenue_Recognition__c = TRUE ORDER BY Event__r.End_Date__c ASC) FROM Opportunity WHERE Id IN :opportunitiesToBeUpdated ]){ //Sanjeev Sharma c-00218323 [12-02-2018]
       if(o.Membership_Type__c == 'NGL ($75K)') //Sanjeev Sharma c-00218323 [12-02-2018]
       {
        if(!o.Revenue_Recognition_1_Manually_Updated__c){
            o.Revenue_Recognition_Begins__c = null;
        }
        if(!o.Revenue_Recognition_2_Manually_Updated__c){
            o.Revenue_Recognition_Ends__c = null;
        }
        if(!o.Revenue_Recognition_3_Manually_Updated__c){
            o.Revenue_Recognition_3__c = null;
        }
        //Loop through related event members and populate the revenue recognition fields    
        for(Event_Members__c e : o.Event_Attendees__r){
            if(!o.Revenue_Recognition_1_Manually_Updated__c &&  o.Revenue_Recognition_Begins__c == null && e.Attending_As_NGL_Only__c == 'New'){
                o.Revenue_Recognition_Begins__c = e.Event__r.End_Date__c; //Sanjeev Sharma c-00218323 [12-02-2018]
                System.debug('sst1'+e.Event__r.End_Date__c);
            }
            if(!o.Revenue_Recognition_2_Manually_Updated__c &&  o.Revenue_Recognition_Ends__c  == null && e.Attending_As_NGL_Only__c == 'Returning'){
                o.Revenue_Recognition_Ends__c = e.Event__r.End_Date__c; //Sanjeev Sharma c-00218323 [12-02-2018]
            }
            if(!o.Revenue_Recognition_3_Manually_Updated__c &&  o.Revenue_Recognition_3__c == null && e.Attending_As_NGL_Only__c == 'Graduating'){
                o.Revenue_Recognition_3__c = e.Event__r.End_Date__c; //Sanjeev Sharma c-00218323 [12-02-2018]
            }
            
            if(o.Revenue_Recognition_Begins__c!= null && o.Revenue_Recognition_Ends__c != null && o.Revenue_Recognition_3__c != null){
                break;
            }
        }
       } //Sanjeev Sharma c-00218323 [12-02-2018]
        OpportunitiesToUpdate.add(o);
    }
   // if(newEventMembers != null) System.debug('sst : newEventMembers' + newEventMembers ); //Sanjeev Sharma c-00218323 [12-02-2018]
    Map<Id,Opportunity> oppsToCombine = updateOppRecognition(newEventMembers); //Sanjeev Sharma c-00218323 [12-02-2018]
   // if(oppsToCombine != null) System.debug('sst : oppsToCombine' + oppsToCombine ); //Sanjeev Sharma c-00218323 [12-02-2018]
   //Start Sanjeev Sharma c-00218323 [12-02-2018]
    for(Opportunity o: OpportunitiesToUpdate){
        if(oppsToCombine.containsKey(o.Id)  && o.Revenue_Recognition_Begins__c == null){
            o.Revenue_Recognition_Begins__c = oppsToCombine.get(o.Id).Revenue_Recognition_Begins__c;
         //   if(o.Revenue_Recognition_Begins__c != null) System.debug('sst : o.Revenue_Recognition_Begins__c' + o.Revenue_Recognition_Begins__c ); //Sanjeev Sharma c-00218323 [12-02-2018]
        }
    }
    //Stop Sanjeev Sharma c-00218323 [12-02-2018]
    UPDATE OpportunitiesToUpdate;
  }

    //START NSHARP S-488522 7.21.17
    public static Map<Id,Opportunity> updateOppRecognition(List<Event_Members__c> newMembers){
        Map<Id,Date> oppRecMap = new Map<Id,Date>();
        Map<Id,Opportunity> newOpps = new Map<Id,Opportunity>();

        for(Event_Members__c e: [SELECT Id, Attended__c, Event_Start_Date__c,Event_End_Date__c, Opportunity__c, Opportunity__r.Revenue_Recognition_Begins__c, Opportunity__r.Revenue_Recognition_1_Manually_Updated__c, Opportunity__r.Membership_Type__c FROM Event_Members__c WHERE Id IN: newMembers]){ //Sanjeev Sharma c-00218323 [12-02-2018]
            system.debug('#### e.Opp: ' + e.Opportunity__r.Membership_Type__c);
            system.debug('#### e.Attended__c: ' + e.Attended__c);
            //if(e.Opportunity__r.Revenue_Recognition_1_Manually_Updated__c == false && e.Opportunity__r.Membership_Type__c != 'WLA Advisor' && e.Opportunity__r.Membership_Type__c != 'BX Sponsor ($150K)'){
            if(e.Opportunity__r.Membership_Type__c != null){ // added by RuchikaMaheshwari C--00227664 [22-05-2018]
              if(e.Opportunity__r.Revenue_Recognition_1_Manually_Updated__c == false  && !e.Opportunity__r.Membership_Type__c.contains('G100') && !e.Opportunity__r.Membership_Type__c.contains('TC')  && !e.Opportunity__r.Membership_Type__c.contains('WLN') ){ // Modified by RuchikaMaheshwari C--00227664 [07-05-2018]
                if(e.Attended__c == 'Yes'){
                    oppRecMap.put(e.Opportunity__c,e.Event_End_Date__c); //Sanjeev Sharma c-00218323 [12-02-2018]
                }
                else{
                    oppRecMap.put(e.Opportunity__c,null);
                }
            }
            }
        }

        if(oppRecMap.values() != null){
            for(Id i: oppRecMap.keySet()){
                Opportunity opp = new Opportunity();
                opp.Id = i;
                opp.Revenue_Recognition_Begins__c = oppRecMap.get(i);
                newOpps.put(opp.Id,opp);
                system.debug('#### opp.Revenue_Recognition_Begins__c: ' + opp.Revenue_Recognition_Begins__c);
            }
        }
        return newOpps;
    } 
    //END NSHARP S-488522 7.21.17
    
    //START - Added by Nitin on 27/11/2018 for S-586005
    public static void updateCount(Map<Id,Event_Members__c> newMap,Map<Id,Event_Members__c> oldVal, String status) {
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,List<Event_Members__c>> insertRecord = new Map<Id,List<Event_Members__c>>();
        List<Contact> conLstWthNumber = new List<Contact>();
        Map<Id,Integer> eventMap = new Map<Id,Integer>();
        
        if(status == 'afterUpdate') {
            for(Id otVal : oldVal.keySet()) {
                contactIdSet.add(oldVal.get(otVal).Contact__c);
            }
            
            for(Id val : newMap.keySet()) {
                contactIdSet.add(newMap.get(val).Contact__c);
            }    
        }
        
        if(status == 'afterInsert' || status == 'afterUndelete') {
            for(Id val : newMap.keySet()) {
                contactIdSet.add(newMap.get(val).Contact__c);
            }
        }
        
        if(status == 'afterDelete') {
            for(Id otVal : oldVal.keySet()) {
                contactIdSet.add(oldVal.get(otVal).Contact__c);
            }
        }
        
        for(Contact con : [Select Id,Name,Account_Name__c,(SELECT Day_1_Role__c,	Day_2_Role__c,Day_3_Role__c,Event_End_Date__c 
                                                           FROM Event_Members__r 
                                                           WHERE Event_End_Date__c !=null) 
                           From Contact
                           WHERE Id IN : contactIdSet]) {
                               insertRecord.put(con.Id,con.Event_Members__r);                             
                           }
        for(Id conId : insertRecord.keySet()) {
            for(Event_Members__c em : insertRecord.get(conId)) {
                if((em.Event_End_Date__c > (Date.today()-395) && em.Event_End_Date__c <= (Date.today())) &&
                   ((em.Day_1_Role__c=='Guest' || 
                     em.Day_1_Role__c=='Prospect' ||
                     em.Day_1_Role__c=='Member' ||
                     em.Day_1_Role__c=='Advisor') ||
                    (em.Day_2_Role__c=='Guest' || 
                     em.Day_2_Role__c=='Prospect' ||
                     em.Day_2_Role__c=='Member' ||
                     em.Day_2_Role__c=='Advisor') ||
                    em.Day_3_Role__c=='Guest' || 
                    em.Day_3_Role__c=='Prospect' ||
                    em.Day_3_Role__c=='Member' ||
                    em.Day_3_Role__c=='Advisor')) {
                        
                        if(!eventMap.containsKey(conId)) {
                            eventMap.put(conId,1);
                        }
                        else {
                            Integer count = eventMap.get(conId);
                            count = count+1;
                            eventMap.put(conId,count);
                        }
                    }
            }
        }
        
        for(Id conIdSetVal : contactIdSet) {
            if(!eventMap.containsKey(conIdSetVal)) {
                Contact con = new Contact();
                con.Id=conIdSetVal;
                con.Number_of_meetings_Attended__c = null;
                conLstWthNumber.add(con);
            }
        }
        for(Id conIdVal : eventMap.keySet()) {
            Contact con = new Contact();
            con.Id=conIdVal;
            con.Number_of_meetings_Attended__c = eventMap.get(conIdVal);
            conLstWthNumber.add(con);
        }
        
        if(conLstWthNumber!=null && !conLstWthNumber.isEmpty()) {
            update conLstWthNumber;
        }
    }
    //END - Added by Nitin on 27/11/2018 for S-586005
}