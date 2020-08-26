// 
// (c) 2015 Appirio, Inc.
//
// 
//
// 10 AUG 2015     Nick Sharp      Modified   S-340006
// 16 MAY 2018     Jessica Schilling        Case 00228607       Modified logic to remove check for 'Monthly'
//
/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public class Milestone1_Task_Trigger_Utility {

    private static final Schema.SObjectType entitySubscriptionType = Milestone1_Schema_Helper.getGlobalDescribe().get('entitysubscription');
    public static final string SUBSCRIPTION_LIMIT_EXCEEDED = system.label.Milestone1_MaximumPer;

    public static void handleTaskAfterTrigger(List<Milestone1_Task__c> recs, List<Milestone1_Task__c> oldRecs) {
        Milestone1_Task__c oldRec;
        //Place all the RecIds into a List for SOQL in Clause on Subscription Query
        List<String> recIds = new List<String>();
        for(Milestone1_Task__c rec : recs) { recIds.add(rec.Id); }

        List<sObject> existingSubscriptions = new List<sObject>();
        //Retrieve existing list of Subscriptions for the Task(s) and store in Map by User. Salesforce does not allow user to subscribe to same object more than once so we can store in map.
        if(Milestone1_Schema_Helper.isOrgChatterEnabled()){
            String queryString = 'Select Id, ParentId, SubscriberId from EntitySubscription where ParentId in (';
            for(Id recId:recIds)
                queryString += '\''+recId+'\',';
            queryString = queryString.substring(0,queryString.length()-1) + ')'; //trim the trailing comma
            existingSubscriptions= Database.query(queryString);
        }
        //Create a Map of Users to Subscriptions
        Map<String,List<sObject>> userSubscriptionMap = Milestone1_Task_Trigger_Utility.buildUserSubscriptionMap(existingSubscriptions);

        List<sObject> subscriptionsAddList = new List<sObject>();
        List<sObject> subscriptionsDeleteList = new List<sObject>();

        //Iterate over the list of Tasks and evaluate the Chatter rules to follow/unfollow based on Custom Settings for Users/Profiles
        Integer i = 0;
        for(Milestone1_Task__c rec : recs)
        {
            oldRec = null;
            //Retrieve the old record which matches current record
            if(oldRecs != null && oldRecs.size() > i){
                oldRec = oldRecs.get(i);
            }
            //If the Task is Assigned to a User then we can proceed
            if(rec.Assigned_To__c != null)
            {
                List<sObject> existingSubscriptionList = userSubscriptionMap.get(rec.Assigned_To__c);
                sObject existingSubscription = getSubscriptionForUserAndRec(rec,existingSubscriptionList,userSubscriptionMap);

                AutoChatterSetting chatterSettings = new AutoChatterSetting(rec.Assigned_To__c, rec.Assigned_To__r.ProfileId);
                //If the custom setting for automatically following is true, lets perform auto chatter logic
                if(chatterSettings.autoFollow)
                {
                    //If the there is not an existing subscription for the user, go ahead and follow the object. This prevents DUPLICATE_VALUE exception on subscription insert.
                    if(existingSubscription == null && entitySubscriptionType != null)
                    {
                        sObject subscription = entitySubscriptionType.newSObject();
                        subscription.put('parentId',rec.id);
                        subscription.put('SubscriberId',rec.Assigned_To__c);
                        subscriptionsAddList.add(subscription);
                    }
                }
                //If the custom setting for automatically unfollowing is true, let perform auto chatter logic to unfollow for the user.
                if(chatterSettings.autoCompleteFollow && rec.Complete__c && existingSubscription != null)
                {
                    subscriptionsDeleteList.add(existingSubscription);
                }
            }
            //Lets remove the previous Assigned To Follower if oldRec exists, and if the Assignment changed to another user.
            if(oldRec != null && oldRec.Assigned_To__c != null && oldRec.Assigned_To__c != rec.Assigned_To__c)
            {
                system.debug('Unfollow..');
                AutoChatterSetting chatterSettings = new AutoChatterSetting(oldRec.Assigned_To__c, oldRec.Assigned_To__r.ProfileId);
                List<sObject> existingSubscriptionList = userSubscriptionMap.get(oldRec.Assigned_To__c);
                sObject existingSubscription = getSubscriptionForUserAndRec(oldRec,existingSubscriptionList,userSubscriptionMap);
                if(chatterSettings.autoUnassignFollow && existingSubscription != null)
                {
                    subscriptionsDeleteList.add(existingSubscription);
                }
            }
            i++;
        }
        //Perform Inserts and Deletes of Subscriptions
        try{
            insert subscriptionsAddList;
            delete subscriptionsDeleteList;
        }
        catch(Exception e){
            //TODO Validate the type of exception
            recs[0].addError(e.getMessage());
        }


    }

    //Added below method by Lalit for S-621223
    @future(callout=true)
    public static void callDlrsForTMGTask(){ 
            dlrs.RollupService.triggerHandler(Milestone1_Task__c.SObjectType);
    }

    /* Added by jyoti for Story S-349354
     due dates of other tasks if current task schedule date is updated
    */

    public static void updateDueDateAccToScheduleDate(Map<Id, Milestone1_Task__c> oldMap, Map<Id, Milestone1_Task__c> newMap) {
        Map<Id, Set<Milestone1_Task__c>> successorMap = new Map<Id, Set<Milestone1_Task__c>>();
        Map<Id, Date> delSchdMap = new  Map<Id, Date>();
        Id recordTypeId = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName().get('Coaching Session').getRecordTypeId();   //Added by Shubham for the Case# 00140610
        for(Milestone1_Task__c newRec : newMap.values()) {
            Milestone1_Task__c oldRec = oldMap.get(newRec.Id);
            //if(oldRec.Scheduled_Date__c != newRec.Scheduled_Date__c && newRec.Scheduled_Date__c != null && newRec.ProjectRecordType__c == 'Executive Coaching') {
            if(oldRec.Scheduled_Date__c != newRec.Scheduled_Date__c && newRec.Scheduled_Date__c != null && newRec.RecordTypeId == recordTypeId) {   //Added by Shubham for the Case# 00140610
                if(!delSchdMap.containsKey(newRec.Project_Milestone__c))
                    delSchdMap.put(newRec.Project_Milestone__c,newRec.Scheduled_Date__c);
            }
        }
        List<Milestone1_Task__c> successorsToUpdate = new List<Milestone1_Task__c>();

        Date duedate;
        Integer i=0;
        
        //for(Milestone1_Task__c successor: [SELECT Id, Start_Date__c, Due_Date__c,Scheduled_Date__c,Task_Stage__c, Project_Milestone__c,Project_Milestone__r.TMG_Category__r.Frequency__c, Predecessor_Task__c FROM Milestone1_Task__c WHERE Project_Milestone__c IN:delSchdMap.keySet() and ProjectRecordType__c = 'Executive Coaching' and Project_Milestone__r.TMG_Category__r.RecordTypeId = '012F0000001Ep1rIAC' and Project_Milestone__r.TMG_Category__r.Frequency__c !='See Description' and Id not IN:newMap.keySet() and (Scheduled_Date__c = null or Task_Stage__c = 'Scheduled') order By  Due_Date__c asc]) {
        //Added by Shubham for the Case# 00140610 #Start
        /* Code Modified by Shobhit Pant for case 00211515 11/13/2017 START */
        //Adding DueDateCheck field to the query
        //for(Milestone1_Task__c successor: [SELECT Id, Start_Date__c, Due_Date__c,Scheduled_Date__c,Task_Stage__c, Project_Milestone__c,Project_Milestone__r.TMG_Category__r.Frequency__c, Predecessor_Task__c FROM Milestone1_Task__c WHERE Project_Milestone__c IN:delSchdMap.keySet() and RecordTypeId = :recordTypeId and Project_Milestone__r.TMG_Category__r.RecordTypeId = '012F0000001Ep1rIAC' and Project_Milestone__r.TMG_Category__r.Frequency__c !='See Description' and Id not IN:newMap.keySet() and (Scheduled_Date__c = null or Task_Stage__c = 'Scheduled') order By  Due_Date__c asc]) {
        for(Milestone1_Task__c successor: [SELECT Id, DueDateCheck__c, Start_Date__c, Due_Date__c,Scheduled_Date__c,Task_Stage__c, Project_Milestone__c,Project_Milestone__r.TMG_Category__r.Frequency__c, Predecessor_Task__c FROM Milestone1_Task__c WHERE Project_Milestone__c IN:delSchdMap.keySet() and RecordTypeId = :recordTypeId and Project_Milestone__r.TMG_Category__r.RecordTypeId = '012F0000001Ep1rIAC' and Project_Milestone__r.TMG_Category__r.Frequency__c !='See Description' and Id not IN:newMap.keySet() and (Scheduled_Date__c = null or Task_Stage__c = 'Scheduled') order By  Due_Date__c asc]) {
        /* Code Modified by Shobhit Pant for case 00211515 11/13/2017 END */
        //Added by Shubham for the Case# 00140610 #End  
          //Modified below 1 line JSCHILLING Case 00228607 5/17/2018 Added check to not run below logic for Monthly records
          if (successor.Due_Date__c > delSchdMap.get(successor.Project_Milestone__c) && successor.Project_Milestone__r.TMG_Category__r.Frequency__c != 'Monthly') {
            Date Scheduledate = delSchdMap.get(successor.Project_Milestone__c);
            Integer monthsToAdd = 1;
            if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Bi-monthly'){
                monthsToAdd = 2;
            }
            else if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Quarterly'){
                monthsToAdd = 3;
            }
            if(i==0){
                if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Every 6 weeks'){
                    duedate = Scheduledate.addDays(42);
                }
               // if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Monthly' || successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Bi-monthly' ||successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Quarterly'){//Code commented by kritika bhati for S-545118
                if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Bi-monthly' ||successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Quarterly'){//Added by Kritika Bhati for S-545118
                    duedate = Scheduledate.addMonths(monthsToAdd);
                }

            }
            else{
                if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Every 6 weeks'){
                    duedate = duedate.addDays(42);
                }
                //Modified below 1 line JSCHILLING Case 00228607 5/16/2018 Removed check for 'Monthly'
                if(successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Bi-monthly' ||successor.Project_Milestone__r.TMG_Category__r.Frequency__c == 'Quarterly'){
                    duedate = duedate.addMonths(monthsToAdd);
                }
            }
            successor.Due_Date__c = duedate;
            successor.DueDateCheck__c = true; //Single line change by Shobhit Pant for case 00211515 11/13/2017
            successorsToUpdate.add(successor);
              i++;

          }
        }
        if (successorsToUpdate.size() > 0){
           update successorsToUpdate;
         }

        }

    /*
    handles successor dependencies.
    looks at changes to predecessor task due date and adjusts successor tasks start and due date by the same number of days.
    */

    public static void checkSuccessorDependencies(Map<Id, Milestone1_Task__c> oldMap, Map<Id, Milestone1_Task__c> newMap) {
        Map<Id, Set<Milestone1_Task__c>> successorMap = new Map<Id, Set<Milestone1_Task__c>>();
        for(Milestone1_Task__c successor: [SELECT Id, Start_Date__c, Due_Date__c, Predecessor_Task__c FROM Milestone1_Task__c WHERE Predecessor_Task__c IN :newMap.keySet() AND Id NOT IN :newMap.keySet()]) {
            if(!successorMap.containsKey(successor.Predecessor_Task__c)) {
                successorMap.put(successor.Predecessor_Task__c, new Set<Milestone1_Task__c>());
            }
            successorMap.get(successor.Predecessor_Task__c).add(successor);
        }
        List<Milestone1_Task__c> successorsToUpdate = new List<Milestone1_Task__c>();
        for(Milestone1_Task__c newRec : newMap.values()) {
            Milestone1_Task__c oldRec = oldMap.get(newRec.Id);
            if(oldRec.Due_Date__c != null && newRec.Due_Date__c != null) {
                Integer deadlineShift = oldRec.Due_Date__c.daysBetween(newRec.Due_Date__c);
                if(deadlineShift != 0 && successorMap.containsKey(newRec.Id)) {
                    for(Milestone1_Task__c successor: successorMap.get(newRec.Id)) {
                        successor.Start_Date__c = successor.Start_Date__c.addDays(deadlineShift);
                        successor.Due_Date__c = successor.Due_Date__c.addDays(deadlineShift);
                    }
                    successorsToUpdate.addAll(successorMap.get(newRec.Id));
                }
            }
        }
        update successorsToUpdate;
    }

    public static sObject getSubscriptionForUserAndRec(Milestone1_Task__c rec, List<sObject> existingSubscriptionList, Map<String,List<sObject>> userSubscriptionMap)
    {
        sObject existingSubscription = null;
        if(userSubscriptionMap.get(rec.Assigned_To__c) != null)
        {
            for(sObject tempSubscription : existingSubscriptionList)
            {
                if( (id)tempSubscription.get('SubscriberId') == rec.Assigned_To__c && (id) tempSubscription.get('ParentId') == rec.Id)
                {
                    existingSubscription = tempSubscription;
                    break;
                }
            }
        }
        return existingSubscription;
    }

    public static Map<String,List<sObject>> buildUserSubscriptionMap(List<sObject> existingSubscriptions)
    {
        Map<String,List<sObject>> userSubscriptionMap = new Map<String,List<sObject>>();
        for(sObject aSubscription : existingSubscriptions)
        {
            if(userSubscriptionMap.get( (id)aSubscription.get('SubscriberId')) == null)
            {
                userSubscriptionMap.put( (id)aSubscription.get('SubscriberId'),new List<sObject>());

            }
            List<sObject> tempList = userSubscriptionMap.get( (id)aSubscription.get('SubscriberId'));
            tempList.add(aSubscription);
            userSubscriptionMap.put( (id)aSubscription.get('SubscriberId'),tempList);
        }
        return userSubscriptionMap;
    }

    public static void handleTaskBeforeTrigger(List<Milestone1_Task__c> recs){
        Map<String,Milestone1_Milestone__c> taskMilestoneMap = Milestone1_Task_Trigger_Utility.retrieveParentMilestones(recs);
        for( Milestone1_Task__c rec : recs ){
            if( rec.Index_Helper__c.length() > 255 ){ rec.Index__c = rec.Index_Helper__c.substring(0, 255); }
            else { rec.Index__c = rec.Index_Helper__c; }
            
            /* Start - Jyoti Singh - S-215985 */
            /* Commented out code as per the updated requirement under story S-215985 -- JYOTI SINGH*/
            /* if( rec.Due_Date__c == null ) {
                Milestone1_Milestone__c parentMilestone = taskMilestoneMap.get(rec.Project_Milestone__c);
                if(parentMilestone != null) { rec.Due_Date__c = parentMilestone.Deadline__c; }
            }*/
            /* End - Jyoti Singh - S-215985 */

            if(rec.Start_Date__c == null)
            {
                Milestone1_Milestone__c parentMilestone = taskMilestoneMap.get(rec.Project_Milestone__c);
                if(parentMilestone != null)
                {
                    rec.Start_Date__c = parentMilestone.KickOff__c;

                }
                if (rec.Start_Date__c == null || rec.Start_Date__c < Date.TODAY()) {
                    rec.Start_Date__c = Date.Today();
                }

            }

          //START NSHARP S-340006 8.10.15 - remove functionality to add current user to Assigned To field
          //if(rec.Assigned_To__c == null)
          //{
          //  rec.Assigned_To__c = UserInfo.getUserId();
          //}
          //END NSHARP S-340006 8.10.15
            if (rec.Complete__c == false && rec.Days_Late_Formula__c > 0) {
                rec.Days_Late__c = rec.Days_Late_Formula__c;
            } else {
                rec.Days_Late__c = 0;
            }

        }
    }

    public static Map<String,Milestone1_Milestone__c> retrieveParentMilestones(List<Milestone1_Task__c> recs)
    {
        Set<String> ids = new Set<String>();
        for(Milestone1_Task__c rec : recs) { ids.add(rec.Project_Milestone__c); }
        List<Milestone1_Milestone__c> parentMilestones = [Select Id, Name, Deadline__c, KickOff__c from Milestone1_Milestone__c where Id in :ids];

        Map<String,Milestone1_Milestone__c> taskMilestoneMap = new Map<String,Milestone1_Milestone__c>();
        for( Milestone1_Milestone__c parentMilestone : parentMilestones ) {
            taskMilestoneMap.put(parentMilestone.ID,parentMilestone);
        }

        return taskMilestoneMap;
    }

    private class AutoChatterSetting
    {
        public Boolean autoFollow = false;
        public Boolean autoCompleteFollow = false;
        public Boolean autoUnassignFollow = false;

        public autoChatterSetting(String userid, String profileId)
        {
            Milestone1_Settings__c orgChatterDefaults = Milestone1_Settings__c.getOrgDefaults();
            Milestone1_Settings__c profileChatter = Milestone1_Settings__c.getInstance(userid);
            Milestone1_Settings__c userChatter = Milestone1_Settings__c.getInstance(profileid);

            //If the User has a custom Chatter setting, use this setting else use a profile setting if available
            if(userChatter != null)
            {
                autoFollow = userChatter.Auto_Follow_Task__c;
                autoCompleteFollow = userChatter.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = userChatter.Auto_Unfollow_Reassignment__c;
            }else if(profileChatter != null)
            {
                autoFollow = profileChatter.Auto_Follow_Task__c;
                autoCompleteFollow = profileChatter.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = profileChatter.Auto_Unfollow_Reassignment__c;
            }else if(orgChatterDefaults != null)
            {
                autoFollow = orgChatterDefaults.Auto_Follow_Task__c;
                autoCompleteFollow = orgChatterDefaults.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = orgChatterDefaults.Auto_Unfollow_Reassignment__c;
            }
        }
    }

    /**
    * This method prevent task creations for Users w/o Permissions over parent Milestone of task.
    * Checks if OWD for Milestone1_Milestone__c object are Private and then, checks if the current User have read/write permissons.
    * The way to do it its if Milestone1_Milestone__share exist, so we need do a QueryString to avoid compilations errors if that Object doesn't exist.
    * @params       taskList
    * @return       boolean
    * @author       Sebastian Mu�oz
    * @createDate   January 19, 2011
    */
    public static Boolean checkOWDPermissions( List<Milestone1_Task__c> taskList ){

        //First of all, if the User is a SysAdmin and we are not runing a Test, leave this method.
        List<Sobject> obj_share = new List<Sobject>();
        if( Milestone1_General_Utility.isSysAdmin() && !Test.isRunningTest() ){
            return true;
        }
        else if( Schema.getGlobalDescribe().get('Milestone1_Milestone__Share') != null ){
            String inClause = '(';
            for( Milestone1_Task__c cTask : taskList ){
                inClause += '\'' + cTask.Project_Milestone__c + '\',';
            }
            inClause = inClause.substring( 0, inClause.length() - 1 );
            inClause += ')';

            String queryStr = 'Select m.UserOrGroupId, m.RowCause, m.ParentId, m.AccessLevel From Milestone1_Milestone__Share m';
            queryStr        += ' where m.ParentId IN '+ inClause +' AND m.UserOrGroupId = \''+ Userinfo.getUserId() +'\' AND m.AccessLevel = \'Read\'';
            obj_share = Database.query( queryStr );

            return obj_share.isEmpty();
        }
        return true;
    }
/* Start - Jai Gupta - S-559561 - Aug 30,2018 */
    public static void onBeforeUpdate(List<Milestone1_Task__c> newList, Map<Id,Milestone1_Task__c> oldMap) {
        populateOpportunityOnLastCoaching(newList,oldMap);
    }

    public static void onBeforeInsert(List<Milestone1_Task__c> newList) {
        populateOpportunityOnLastCoaching(newList,null);
    }

    public static void populateOpportunityOnLastCoaching(List<Milestone1_Task__c> newList, Map<Id,Milestone1_Task__c> oldMap) {
        // if the last coaching is marked as true on task
        // get deliverable
        // get executive
        set<Id> milestoneTask = new set<Id>();
        for(Milestone1_Task__c mt : newList) {
            if(mt.Last_Coaching_Session__c && (oldMap == null || !oldMap.get(mt.Id).Last_Coaching_Session__c)) {
                milestoneTask.add(mt.Id);
            }
        }
        if(milestoneTask.size() > 0) {
            List<Milestone1_Task__c> mlList = new List<Milestone1_Task__c>();
            Map<Id,Id> contactDeliverableMap = new Map<Id,Id>();
            Map<Id,Milestone1_Task__c> milestoneDetails = new Map<Id,Milestone1_Task__c>([Select Id,Project_Milestone__c,Project_Milestone__r.Assessed_Executive__c from Milestone1_Task__c where Id in :milestoneTask AND Project_Milestone__r.Complete__c = false]);
            for(Milestone1_Task__c ml : milestoneDetails.values()) {
                if(ml.Project_Milestone__r.Assessed_Executive__c != null) {
                    contactDeliverableMap.put(ml.Project_Milestone__r.Assessed_Executive__c,ml.Project_Milestone__c);
                }
            }
            Map<Id,Id> deliverableOpptyMap = new Map<Id,Id>();
            if(contactDeliverableMap.size() > 0) {
                for(Opportunity opp : [Select Id,Participant_Contact__c from Opportunity where Participant_Contact__c IN :contactDeliverableMap.keySet() AND IsRenewalOpportunity__c = TRUE AND Group2__c = 'The Miles Group' Order by CreatedDate Desc]) {
                    if(contactDeliverableMap.containsKey(opp.Participant_Contact__c)) {
                        if(!deliverableOpptyMap.containsKey(contactDeliverableMap.get(opp.Participant_Contact__c))) {
                            Id key = contactDeliverableMap.get(opp.Participant_Contact__c) ;
                            deliverableOpptyMap.put(key,opp.Id);
                        }
                    }
                }
            }

            if(deliverableOpptyMap.size() > 0) {
                for(Milestone1_Task__c mt : newList) {
                    
                    if(milestoneDetails.containsKey(mt.Id)) {
                        system.debug('mt.Project_Milestone__c :: ');
                        if(deliverableOpptyMap.containsKey(mt.Project_Milestone__c)) {
                            mt.Opportunity_Name__c = deliverableOpptyMap.get(mt.Project_Milestone__c);
                        }
                        system.debug('mt.Project_Milestone__c :: '+mt.Opportunity_Name__c);
                    }
                }
            }
        }
    }
    /* End S-559561*/
}