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
//Modified by Apoorva case 00262878 6/7/19
public with sharing class Milestone1_Milestone_Trigger_Utility {
    
    public static final String INSUFFICIENT_PRIVILEGES_TO_ACCESS_PARENT_MILESTONE = system.label.Milestone1_InsufficientPrivilegesToAccessParentMilestone;
    public static final String INSUFFICIENT_PRIVILEGES_TO_ACCESS_PROJECT = system.label.Milestone1_InsufficientPrivileges;
    
    public static Boolean alreadyMadeParent = false;
    
    public static void handleMilestoneDeleteTrigger(Map<Id, Milestone1_Milestone__c> oldMap){
        
        //query for list of child milestones that are NOT part of the recs collection
        List<Milestone1_Milestone__c> extraChildren = new List<Milestone1_Milestone__c>();
        
        extraChildren = [SELECT Id
                         FROM Milestone1_Milestone__c
                         WHERE Parent_Milestone__c IN :oldMap.keySet()
                         AND Id NOT IN :oldMap.keySet()
                        ];
        
        
        // Delete / Batch delete milestones
        if( extraChildren.size() > 0 ){
            if( extraChildren.size() + Limits.getDMLRows() > Limits.getLimitDmlRows() ){
                Database.executeBatch( new Milestone1_Milestone_Batch_Delete(extraChildren) );
            }
            else{
                delete extraChildren;
            }
        }
        
    }
    
    ////Added below method by Lalit for S-621223
    @future(callout=true)
    public static void callDlrsForTMGDeliverables(){ 
            dlrs.RollupService.triggerHandler(Milestone1_Milestone__c.SObjectType);
    }
    public static void checkMilestoneManualReparent(Map<Id, Milestone1_Milestone__c> oldMap, Map<Id, Milestone1_Milestone__c> newMap){
        Boolean allPassed = true;
        list<Milestone1_Milestone__c> mlist= new list<Milestone1_Milestone__c>(); //Apoorva case 00262878 6/7/19
        mlist= newMap.values(); //Apoorva case 00262878 6/7/19
        for(Milestone1_Milestone__c newRec : mlist){ //Apoorva case 00262878 6/7/19
            Milestone1_Milestone__c oldRec = oldMap.get(newRec.Id);
            
            if(oldRec.Project__c != newRec.Project__c && newRec.Okay_to_Reparent__c == false){
                //don't want to reparent if not OK to reparent.
                allPassed = false;
                newRec.Project__c.addError(system.label.Milestone1_MilestonesShouldNotBeMoved);
            }
        }
        
        if(allPassed){
            handleMilestoneBeforeTrigger(newMap.values(), newMap);
        }
    }
    
    /*
uses changes in milestone deadline to modify successor task kickoff and deadline dates.
*/
    public static void checkSuccessorDependencies(Map<Id, Milestone1_Milestone__c> oldMap, Map<Id, Milestone1_Milestone__c> newMap) {
        //Test.StartTest();//Added by Bhagya case 254740.   //COMMENTED by Rohit for Case C-00262869 on 4 June 2019
        Map<Id, Set<Milestone1_Milestone__c>> successorMap = new Map<Id, Set<Milestone1_Milestone__c>>();
        for(Milestone1_Milestone__c successor: [SELECT Id, Kickoff__c, Deadline__c, Predecessor_Milestone__c FROM Milestone1_Milestone__c WHERE Predecessor_Milestone__c IN :newMap.keySet()]) { 
            if(!successorMap.containsKey(successor.Predecessor_Milestone__c)) {
                successorMap.put(successor.Predecessor_Milestone__c, new Set<Milestone1_Milestone__c>());
            }
            successorMap.get(successor.Predecessor_Milestone__c).add(successor);
        }
        //Test.StopTest();//Added by bhagya for case 254740 //COMMENTED by Rohit for Case C-00262869 on 4 June 2019
        List<Milestone1_Milestone__c> successorsToUpdate = new List<Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c newRec : newMap.values()) 
        {
            Milestone1_Milestone__c oldRec = oldMap.get(newRec.Id);
            if(oldRec.Deadline__c != null && newRec.Deadline__c != null) 
            {
                Integer deadlineShift = oldRec.Deadline__c.daysBetween(newRec.Deadline__c);
                if(deadlineShift != 0 && successorMap.containsKey(newRec.Id)) 
                {
                    for(Milestone1_Milestone__c successor: successorMap.get(newRec.Id)) 
                    {
                        successor.Kickoff__c = successor.Kickoff__c.addDays(deadlineShift);
                        successor.Deadline__c = successor.Deadline__c.addDays(deadlineShift);
                    }
                    successorsToUpdate.addAll(successorMap.get(newRec.Id));
                }
            }
        }
        update successorsToUpdate;
    }
    //Added by jyoti for Story S-349354
    public static void updateDueDateForCategoryAndProject(Map<Id, Milestone1_Milestone__c> oldMap, Map<Id, Milestone1_Milestone__c> newMap) {
        Set<Id> mileStoneId = new Set<Id>();
        List<TMG_Category__c> categoryList = new List<TMG_Category__c>();
        List<Milestone1_Project__c> projectList = new List<Milestone1_Project__c>();
        Set<Id> categoriesId = new Set<Id>();
        Set<Id> projectsId = new Set<Id>();
        
        for (Milestone1_Milestone__c mc : newMap.values()) {
            if ( mc.Deadline__c!= oldMap.get(mc.Id).Deadline__c) {
                mileStoneId.add(mc.id);
            }
        }
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('##### Number of Queries used in this Apex code so far: ' + Limits.getQueries());
        for(Milestone1_Milestone__c mc1: [Select Id,RecordType.Name, TMG_Category__c,Deadline__c, Project__c FROM Milestone1_Milestone__c WHERE Id In: mileStoneId and RecordType.Name = 'Executive Coaching'  ]){
            
            if(mc1.TMG_Category__c != null){
                //categoryList.add(new TMG_Category__c(Id = mc1.TMG_Category__c,Due_Date__c = mc1.Deadline__c));
                categoriesId.add(mc1.TMG_Category__c);
            }
            if(mc1.Project__c != null){
                //projectList.add( new Milestone1_Project__c(Id = mc1.Project__c, Deadline__c = mc1.Deadline__c));
                projectsId.add(mc1.Project__c);
            }
        }
        for(TMG_Category__c cat:  [Select Id, Due_Date__c, Category_Type__c, (Select Id,  Deadline__c From Deliverables__r order by  Deadline__c desc LIMIT 1) From TMG_Category__c where Id IN : categoriesId] ){
            if(cat.Deliverables__r.size() > 0 ){
                cat.Due_Date__c = cat.Deliverables__r.get(0).Deadline__c;
                categoryList.add(cat);
            }
        }
        if(categoryList.size()> 0 )
            update categoryList;
        
        for(Milestone1_Project__c project: [Select Id, Deadline__c, (Select Id, Due_Date__c From Categories__r order by  Due_Date__c desc LIMIT 1) From Milestone1_Project__c where Id IN : projectsId ]){
            if(project.Categories__r.size() > 0 ){
                project.Deadline__c = project.Categories__r.get(0).Due_Date__c;
                projectList.add(project);
            }
        }
        
        
        if(projectList.size()> 0 )
            update projectList;
        
    }
    
    // START S-589412 (create TMG Deliverable Tasks) : By Nishtha
    public static void createDeliverableTasks(List<Milestone1_Milestone__c> newTriggerList ){
        Set<Id> firstChairAndAssigedToIds = new Set<Id>();
        for(Milestone1_Milestone__c milestone : newTriggerList){
            firstChairAndAssigedToIds.add(milestone.First_Chair_Lookup__c);
            firstChairAndAssigedToIds.add(milestone.EA_Lookup__c);
        }
        List<Contact> contactList = [SELECT Id, pse__Salesforce_User__c, pse__Salesforce_User__r.Name FROM Contact WHERE Id IN :firstChairAndAssigedToIds];
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for(Contact con : contactList){
            contactMap.put(con.id, con);
        }
        
        List<Milestone1_Task__c> taskList = new List<Milestone1_Task__c>();
        for(Milestone1_Milestone__c milestone : newTriggerList){
            Id dataCollectionRecordTypeId = Schema.SObjectType.Milestone1_Milestone__c.getRecordTypeInfosByName().get('Data Collection').getRecordTypeId();
            if(milestone.RecordTypeId == dataCollectionRecordTypeId &&
               !milestone.Created_Assessment_Interview_Task__c &&
               !milestone.Debrief_Task_Created__c &&
               !milestone.Created_Feedback_Task__c){
                   
                   String firstChair = contactMap.containsKey(milestone.First_Chair_Lookup__c) ? contactMap.get(milestone.First_Chair_Lookup__c).pse__Salesforce_User__c : null;
                   String assignedTo = contactMap.containsKey(milestone.EA_Lookup__c) ? contactMap.get(milestone.EA_Lookup__c).pse__Salesforce_User__c : null;
                   
                   Milestone1_Task__c feedbackTask = new Milestone1_Task__c();
                   feedbackTask.Project_Milestone__c = milestone.Id;
                   if(assignedTo != null){
                       feedbackTask.Assigned_To__c = assignedTo;
                   }
                   if(milestone.Deadline__c != null){
                       feedbackTask.Due_Date__c = milestone.Deadline__c;
                   }
                   
                   if(firstChair != null) {
                       feedbackTask.First_Chair_User__c = firstChair;
                   }
                   feedbackTask.Name = 'FEEDBACK_' + milestone.NameClean__c;
                   feedbackTask.RecordTypeId = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName().get('Assessment Feedback Session').getRecordTypeId(); //'012F0000000jFr2';
                   feedbackTask.Task_Stage__c = 'Pending Approval';
                   taskList.add(feedbackTask);
                   
                   Milestone1_Task__c debriefTask = new Milestone1_Task__c();
                   debriefTask.Project_Milestone__c = milestone.Id;
                   if(assignedTo != null){
                       debriefTask.Assigned_To__c = assignedTo;
                   }
                   if(milestone.Deadline__c != null){
                       debriefTask.Due_Date__c = milestone.Deadline__c - 14;
                   }
                   
                   if(firstChair != null) {
                       debriefTask.First_Chair_User__c = firstChair;
                   }
                   debriefTask.Name = 'DEBRIEF_' + milestone.NameClean__c+' (w/TBD)';
                   debriefTask.RecordTypeId = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName().get('Primary Manager Debrief').getRecordTypeId(); //'012F0000000k0dfIAA';
                   debriefTask.Task_Stage__c = 'Pending Approval';
                   taskList.add(debriefTask);
                   
                   Milestone1_Task__c assessmentTask = new Milestone1_Task__c();
                   assessmentTask.Project_Milestone__c   = milestone.Id;
                   if(assignedTo != null){
                       assessmentTask.Assigned_To__c = assignedTo; 
                   }
                   if(milestone.Deadline__c != null){
                       assessmentTask.Due_Date__c = milestone.Deadline__c - 35;
                   }
                   
                   if(firstChair != null) {
                       assessmentTask.First_Chair_User__c = firstChair;
                   }
                   assessmentTask.Name = 'INT_' + milestone.NameClean__c;
                   assessmentTask.RecordTypeId = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName().get('Assessment Interview').getRecordTypeId();//'012F0000000jFr1IAE';
                   assessmentTask.Task_Stage__c = 'Pending Approval';  
                   taskList.add(assessmentTask);
               }
        }
        insert taskList;
    }//END S-589412 (create TMG Deliverable Tasks) : By Nishtha
    
    public static void checkChildDependencies(Map<Id, Milestone1_Milestone__c> oldMap, Map<Id, Milestone1_Milestone__c> newMap) {
        Map<Id, Set<Milestone1_Milestone__c>> childMap = new Map<Id, Set<Milestone1_Milestone__c>>();
        for(Milestone1_Milestone__c child: [SELECT Id, Kickoff__c, Deadline__c, Parent_Milestone__c FROM Milestone1_Milestone__c WHERE Parent_Milestone__c IN :newMap.keySet()]) {
            if(!childMap.containsKey(child.Parent_Milestone__c)) {
                childMap.put(child.Parent_Milestone__c, new Set<Milestone1_Milestone__c>());
            }
            childMap.get(child.Parent_Milestone__c).add(child);
        }
        List<Milestone1_Milestone__c> childrenToUpdate = new List<Milestone1_Milestone__c>();
        for(Milestone1_Milestone__c newRec : newMap.values()) {
            Milestone1_Milestone__c oldRec = oldMap.get(newRec.Id);
            if(oldRec.Kickoff__c != null && oldRec.Deadline__c != null && newRec.Kickoff__c != null && newRec.Deadline__c != null) {
                Integer kickoffShift = oldRec.Kickoff__c.daysBetween(newRec.Kickoff__c);
                Integer deadlineShift = oldRec.Deadline__c.daysBetween(newRec.Deadline__c);
                if(kickoffShift == deadlineShift && deadlineShift != 0 &&childMap.containsKey(newRec.Id)) {
                    for(Milestone1_Milestone__c child: childMap.get(newRec.Id)) {
                        child.Kickoff__c = child.Kickoff__c.addDays(deadlineShift);
                        child.Deadline__c = child.Deadline__c.addDays(deadlineShift);
                    }
                    childrenToUpdate.addAll(childMap.get(newRec.Id));
                }
            }
        }
        alreadyMadeParent = true;
        update childrenToUpdate;
    }
    
    public static void checkTaskDependencies(Map<Id, Milestone1_Milestone__c> oldMap, Map<Id, Milestone1_Milestone__c> newMap) {
        Map<Id, Set<Milestone1_Task__c>> taskMap = new Map<Id, Set<Milestone1_Task__c>>();
        //MJackson added Task_Stage__c to SOQL query for C00239051
        for(Milestone1_Task__c task: [SELECT Id, Start_Date__c, Due_Date__c, Project_Milestone__c, Task_Stage__c FROM Milestone1_Task__c WHERE Project_Milestone__c IN :newMap.keySet()]) {
            if(!taskMap.containsKey(task.Project_Milestone__c)) {
                taskMap.put(task.Project_Milestone__c, new Set<Milestone1_Task__c>());
            }
            taskMap.get(task.Project_Milestone__c).add(task);
        }
        List<Milestone1_Task__c> tasksToUpdate = new List<Milestone1_Task__c>();
        for(Milestone1_Milestone__c newRec : newMap.values()) {
            Milestone1_Milestone__c oldRec = oldMap.get(newRec.Id);
            if(oldRec.Kickoff__c != null && oldRec.Deadline__c != null && newRec.Kickoff__c != null && newRec.Deadline__c != null) {
                Integer kickoffShift = oldRec.Kickoff__c.daysBetween(newRec.Kickoff__c);
                Integer deadlineShift = oldRec.Deadline__c.daysBetween(newRec.Deadline__c);
                //MJackson deleted logic for deadlineshift... 'kickoffShift == deadlineShift && deadlineShift != 0' for C00239051
                if(kickoffShift != 0 && taskMap.containsKey(newRec.Id)) {
                    for(Milestone1_Task__c task: taskMap.get(newRec.Id)) {
                        if (task.Start_Date__c != null)
                        {
                            //MJackson commented out for C00239051
                            //task.Start_Date__c = task.Start_Date__c.addDays(deadlineShift);
                        }
                        //MJackson added task stage conditions for C00239051
                        if (task.Due_Date__c != null && (task.Task_Stage__c == 'Pending Approval' || task.Task_Stage__c == 'To Be Scheduled'))
                        {
                            //MJackson Update .addDays(deadlineshift) to .addDays(kickoffshift) for C00239051
                            task.Due_Date__c = task.Due_Date__c.addDays(kickoffShift);
                        }
                    }
                    tasksToUpdate.addAll(taskMap.get(newRec.Id));
                }
            }
        }
        update tasksToUpdate;
    }
    
    public static void handleMilestoneBeforeTrigger(List<Milestone1_Milestone__c> recs, Map<Id, Milestone1_Milestone__c> recMapById){
        
        if(checkAccessRightLookUpFields(recs)){
            
            //create a map of records by parent milestone ID
            Map<Id, List<Milestone1_Milestone__c>> recMapByParentId = refreshRecordMapByParent(recs);
            
            //ensure parent project IDs for all records
            Set<Id> parentMilestoneIds = new Set<Id>();
            for(Milestone1_Milestone__c rec : recs){
                //reset to false--only set to true temporarily.
                rec.Okay_to_Reparent__c = false;
                if(rec.Parent_Milestone__c != null){
                    parentMilestoneIds.add(rec.Parent_Milestone__c);
                }
            }
            if(parentMilestoneIds.size() > 0){
                List<Milestone1_Milestone__c> parentMilestones = [SELECT Id,
                                                                  Project__c,
                                                                  Parent_Milestone__c
                                                                  FROM Milestone1_Milestone__c
                                                                  WHERE Id IN :parentMilestoneIds
                                                                 ];
                
                Map<Id, Milestone1_Milestone__c> parentMilestonesMap = new Map<Id, Milestone1_Milestone__c>();
                for(Milestone1_Milestone__c parent : parentMilestones){
                    parentMilestonesMap.put(parent.Id, parent);
                }
                
                for(Milestone1_Milestone__c rec : recs){
                    // Check parent sharing permissions
                    
                    if(rec.Parent_Milestone__c != null){
                        // Parent milestone not accessible
                        if(parentMilestonesMap.get(rec.Parent_Milestone__c).Parent_Milestone__c != null){
                            rec.Parent_Milestone__c.addError(system.label.Milestone1_SubMilestonesCanOnlyGoOneLevelDeep);
                        } else {
                            rec.Project__c = parentMilestonesMap.get(rec.Parent_Milestone__c).Project__c;
                        }
                    }
                }
            }
            
            //query for list of child milestones that are NOT part of the recs collection
            List<Milestone1_Milestone__c> extraChildren = new List<Milestone1_Milestone__c>();
            if(recMapById != null && recMapById.size() > 0){
                extraChildren = [SELECT Id,
                                 Name,
                                 Parent_Milestone__c,
                                 Parent_Milestone__r.Name,
                                 Hours_Budget__c,
                                 Expense_Budget__c,
                                 Total_Actual_Hours__c,
                                 Total_Actual_Expense__c,
                                 Total_Estimated_Hours__c,
                                 Total_Estimated_Expense__c,
                                 Total_Open_Tasks__c,
                                 Total_Late_Tasks__c,
                                 Total_Complete_Tasks__c,
                                 Total_Blocked_Tasks__c
                                 FROM Milestone1_Milestone__c
                                 WHERE Parent_Milestone__c IN :recMapById.keySet()
                                 AND Id NOT IN :recMapById.keySet()
                                ];
            }
            
            //map children by their parent milestone ID
            Map<Id, List<Milestone1_Milestone__c>> extraChildrenMap = new Map<Id, List<Milestone1_Milestone__c>>();
            for(Milestone1_Milestone__c extraChild : extraChildren){
                System.debug('*** extra child found: ' + extraChild.Name + ', parent is ' + extraChild.Parent_Milestone__r.Name);
                System.debug('*** child is: ' + extraChild);
                if(extraChildrenMap.get(extraChild.Parent_Milestone__c) == null){
                    extraChildrenMap.put(extraChild.Parent_Milestone__c, new List<Milestone1_Milestone__c>());
                }
                extraChildrenMap.get(extraChild.Parent_Milestone__c).add(extraChild);
            }
            
            //query for late tasks
            //TODO do we need this here? Is there a better way to handle this?
            List<Milestone1_Task__c> lateTasks = new List<Milestone1_Task__c>();
            if(recMapById != null && recMapById.size() > 0){
                lateTasks = [SELECT Id,
                             Project_Milestone__c
                             FROM Milestone1_Task__c
                             WHERE Project_Milestone__c IN :recMapById.keySet()
                             AND Complete__c = false
                             AND Due_Date__c < :Date.today()
                            ];
            }
            
            //map late tasks by parent milestone
            Map<Id, List<Milestone1_Task__c>> lateTasksByMilestoneId = new Map<Id, List<Milestone1_Task__c>>();
            for(Milestone1_Task__c lateTask : lateTasks){
                if(lateTasksByMilestoneId.get(lateTask.Project_Milestone__c) == null){
                    lateTasksByMilestoneId.put(lateTask.Project_Milestone__c, new List<Milestone1_Task__c>());
                }
                lateTasksByMilestoneId.get(lateTask.Project_Milestone__c).add(lateTask);
            }
            
            //instantiate sets of value helpers, to track new field values
            Map<Id, Milestone1_Milestone_Values_Helper> parentHelpers = new Map<Id, Milestone1_Milestone_Values_Helper>();
            List<Milestone1_Milestone_Values_Helper> selfHelpers = new List<Milestone1_Milestone_Values_Helper>();
            
            //while there are still records in recs, pull out those that are NOT the parent to
            //any other record in recs (in other words, the bottom-most records) and process them
            while(recs.size() > 0){
                List<Milestone1_Milestone__c> topChildren = new List<Milestone1_Milestone__c>();
                List<Milestone1_Milestone__c> bottomChildren = new List<Milestone1_Milestone__c>();
                recMapByParentId = refreshRecordMapByParent(recs);
                
                for(Milestone1_Milestone__c rec : recs){
                    if(recMapByParentId.get(rec.Id) == null){
                        //record is not the parent to any other records in our set
                        bottomChildren.add(rec);
                    } else {
                        //record is the parent to another record in our set
                        topChildren.add(rec);
                    }
                }
                recs = topChildren;
                
                for(Milestone1_Milestone__c rec : bottomChildren){
                    
                    //update number of late tasks from tasks
                    if(lateTasksByMilestoneId.get(rec.Id) == null){
                        rec.Late_Tasks_in_Tasks__c = 0;
                    } else {
                        rec.Late_Tasks_in_Tasks__c = lateTasksByMilestoneId.get(rec.Id).size();
                    }
                    
                    if(rec.Parent_Milestone__c != null){
                        if(recMapById!=null&&recMapById.get(rec.Parent_Milestone__c) != null){
                            //record has parent and parent is in our recs list
                            //create helper for parent and add our values to it
                            if(parentHelpers.get(rec.Parent_Milestone__c) == null){
                                parentHelpers.put(rec.Parent_Milestone__c, new Milestone1_Milestone_Values_Helper(recMapById.get(rec.Parent_Milestone__c)));
                            }
                            parentHelpers.get(rec.Parent_Milestone__c).addValuesFromChild(rec);
                        } else {
                            //record has parent, but parent is not in our recs list
                            //create self-helper
                            selfHelpers.add(new Milestone1_Milestone_Values_Helper(rec));
                        }
                    } else {
                        //record does not have parent milestone
                        //create self-helper
                        selfHelpers.add(new Milestone1_Milestone_Values_Helper(rec));
                    }
                }
            }
            
            List<Milestone1_Milestone_Values_Helper> allHelpers = selfHelpers.clone();
            allHelpers.addAll(parentHelpers.values());
            
            for(Milestone1_Milestone_Values_Helper helper : allHelpers){
                //if the record is the parent to milestones outside of the set we're updating, add their values
                List<Milestone1_Milestone__c> recChildren = extraChildrenMap.get(helper.oldRecord.Id);
                if(recChildren != null){
                    for(Milestone1_Milestone__c extraChild : recChildren){
                        helper.addValuesFromChild(extraChild);
                    }
                }
                
                //overwrite old values with new
                helper.updateOldWithNew();
            }
        }
    }
    
    
    
    //TODO do we need this or could we be using oldMap / newMap?
    /*
private static Map<Id, Milestone1_Milestone__c> createRecMapById(List<Milestone1_Milestone__c> recs){
//create a map of records by ID
Map<Id, Milestone1_Milestone__c> recMapById = new Map<Id, Milestone1_Milestone__c>();
for(Milestone1_Milestone__c rec : recs){
System.debug('*** Milestone "' + rec.Name + '" with Id ' + rec.Id + ' begin after trigger');
if(rec.Id != null){
recMapById.put(rec.Id, rec);
}
}
return recMapById;
}
*/
    
    public static void handleMilestoneAfterTrigger(Map<Id, Milestone1_Milestone__c> recs){
            if(CheckRecursive.runOnceHandleMilestoneAfterTrigger()){//Added by Lalit for S-621223
                updateParents(recs);
            }
        
    }
    
    private static void updateParents(Map<Id, Milestone1_Milestone__c> recMapById){
        //Map<Id, Milestone1_Milestone__c> recMapById = createRecMapById(recs);
        
        //instantiate sets of parent IDs, to be updated afterward
        Set<Id> milestoneUpdateSet = new Set<Id>();
        Set<Id> projectUpdateSet = new Set<Id>();
        
        for(Milestone1_Milestone__c rec : recMapById.values()){
            if(rec.Parent_Milestone__c != null){
                if(recMapById.get(rec.Parent_Milestone__c) != null){
                    //record has parent and parent is in our recs list
                    //do nothing, as the parent has already been updated
                } else {
                    //record has parent, but parent is not in our recs list
                    //mark parent milestone to be updated
                    milestoneUpdateSet.add(rec.Parent_Milestone__c);
                    System.debug('*** added parent ' + rec.Parent_Milestone__c + ' to list of milestones to update (child: ' + rec.Name + ')');
                }
            } else {
                //record does not have parent milestone
                //mark parent project to be updated
                projectUpdateSet.add(rec.Project__c);
            }
        }
        
        if(milestoneUpdateSet.size() > 0 && !alreadyMadeParent){
            updateMilestones(milestoneUpdateSet);
        }
        //TODO force projects to go out and true themselves up, top down style
        if(projectUpdateSet.size() > 0){
            updateProjects(projectUpdateSet);
        }
    }
    
    //create a map of records by parent milestone ID
    private static Map<Id, List<Milestone1_Milestone__c>> refreshRecordMapByParent(List<Milestone1_Milestone__c> recs){
        Map<Id, List<Milestone1_Milestone__c>> recMapByParentId = new Map<Id, List<Milestone1_Milestone__c>>();
        for(Milestone1_Milestone__c rec : recs){
            if(rec.Parent_Milestone__c != null){
                if(recMapByParentId.get(rec.Parent_Milestone__c) == null){
                    recMapByParentId.put(rec.Parent_Milestone__c, new List<Milestone1_Milestone__c>());
                }
                recMapByParentId.get(rec.Parent_Milestone__c).add(rec);
            }
        }
        return recMapByParentId;
    }
    
    
    //call an update to any parent milestones that weren't part of our trigger set
    private static void updateMilestones(Set<Id> idSet) {
        if( idSet.size() + Limits.getDMLRows() > Limits.getLimitDmlRows() ){
            batchUpdateMilestones(idSet);
        }
        else{
            update [SELECT Id FROM Milestone1_Milestone__c WHERE Id IN :idSet];
        }
    }
    
    /**
* Batch update milestones
*
* @param idSet Set of milestone ids
*/
    private static void batchUpdateMilestones( Set<Id> idSet ){
        if( idSet.size() > 0 ){
            Database.executeBatch( new Milestone1_Milestone_Batch_Update(idSet) );
        }
    }
    
    //call an update to any parent projects
    private static void updateProjects(Set<Id> idSet) {
        /*if( idSet.size() + Limits.getDMLRows() > Limits.getLimitDmlRows() ){//Commented by Lalit for 
            batchUpdateProjects(idSet);
        }
        else{
            update [SELECT Id FROM Milestone1_Project__c WHERE Id IN :idSet ];
        }*/
        
        if( idSet.size()  > 0){//Added if block by Lalit for 
            batchUpdateProjects(idSet);
        }
    }
    
    /**
* Batch update projects
*
* @param idSet Set of project ids
*/
    private static void batchUpdateProjects( Set<Id> idSet ){
        if( idSet.size() > 0 ){
            Database.executeBatch( new Milestone1_Project_Batch_Update(idSet) );
        }
    }
    
    
    
    
    /**
* Check if the User have privileges over current Object
* getting a Name field permissions
* @params ObjectName
* @return boolean
*/
    public static Boolean milestonePermissions( String objectName ) {
        if( objectName != null ) {
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult descRes = schemaMap.get( objectName ).getDescribe();
            return descRes.isCreateable();
        }
        return false;
    }
    
    /**
*  Check access right to references of Milestones such as Parent_Milestone__c and Project__c, if
*  the user is not a sysadmin.
*/
    private static Boolean checkAccessRightLookUpFields(List<Milestone1_Milestone__c> milestones){
        Boolean hasPermission = Milestone1_General_Utility.isSysAdmin();
        if(!hasPermission){
            //check the permission over Project__c field for new milestones
            if(Trigger.isinsert){
                hasPermission = checkAccessRightReferences(milestones, 'Project__c', 'Milestone1_Project__Share',Userinfo.getUserId(),
                                                           INSUFFICIENT_PRIVILEGES_TO_ACCESS_PROJECT);
            }
            //check the permission over Parent_Milestone__c for updates
            hasPermission = checkAccessRightReferences(milestones, 'Parent_Milestone__c','Milestone1_Milestone__Share',Userinfo.getUserId(),
                                                       INSUFFICIENT_PRIVILEGES_TO_ACCESS_PARENT_MILESTONE);
        }
        return hasPermission;
    }
    
    /**
*  Given a list of sobjects, a reference field, a user,
*  check the permission to Read in the share objects for the references objects.
*/
    private static Boolean checkAccessRightReferences(List<Sobject> sobjectList, String reference,String sharedObjectName,String userId,String errorMessage){
        String query = 'SELECT UserOrGroupId,AccessLevel,ParentId FROM $1 WHERE UserOrGroupId = \'$3\' ';
        Sobjecttype milestoneShareSObjectType = Schema.getGlobalDescribe().get(sharedObjectName);
        Boolean hasPermission = true;
        
        if(milestoneShareSObjectType != null){
            List<String> referenceObjects = new List<String>();
            String referenceObjectId;
            for(Sobject myObject : sobjectList){
                referenceObjectId = String.valueOf(myObject.get(reference));
                if(referenceObjectId != null){
                    referenceObjects.add(referenceObjectId);
                }
            }
            String querySharedObjects = query.replace('$1',sharedObjectName);
            querySharedObjects = querySharedObjects.replace('$3',userId);
            Sobject sharedObjectFound;
            List<Sobject> sharedObjects = Database.query(querySharedObjects);
            for(Sobject myObject : sobjectList){
                sharedObjectFound = null;
                if(myObject.get(reference) != null){
                    for(Sobject sharedObject : sharedObjects){
                        if(myObject.get(reference) == sharedObject.get('ParentId')){
                            sharedObjectFound = sharedObject;
                            break;
                        }
                    }
                    if(sharedObjectFound == null || sharedObjectFound.get('AccessLevel') == 'Read'){
                        myObject.addError(errorMessage);
                        hasPermission = false;
                    }
                }
            }
        }
        return hasPermission;
    }
    
    // START S-250078 - By Hemlata
    // To populate category tasks fields
    public static void populateCategoryTasksfields(Set<Id> categoryIds) {
        List<TMG_Category__c> categoryList = [select Id, Late_Tasks__c, Open_Tasks__c, Total_Tasks__c from TMG_Category__c where id in :categoryIds];
        Map<Id,List<Milestone1_Milestone__c>> categoryToDeliverableMap = new Map<Id,List<Milestone1_Milestone__c>> ();
        for (Milestone1_Milestone__c  mc1 : [select Id, Total_Open_Tasks__c, Total_Late_Tasks__c, Total_Complete_Tasks__c, TMG_Category__c from
                                             Milestone1_Milestone__c where TMG_Category__c in :categoryIds ] ) {
                                                 if (categoryToDeliverableMap.containsKey(mc1.TMG_Category__c))  {
                                                     categoryToDeliverableMap.get(mc1.TMG_Category__c).add(mc1);
                                                 }   else {
                                                     categoryToDeliverableMap.put(mc1.TMG_Category__c, new List<Milestone1_Milestone__c>{mc1});
                                                 }
                                             } // for
        if (categoryList != null && categoryList.size() > 0) {
            for (TMG_Category__c category : categoryList) {
                Decimal totalTasks = 0;
                Decimal openTasks = 0;
                Decimal lateTasks = 0;
                if (categoryToDeliverableMap.containsKey(category.Id)) {
                    for (Milestone1_Milestone__c milestone1 : categoryToDeliverableMap.get(category.ID)) {
                        if (milestone1.Total_Open_Tasks__c != null) {
                            totalTasks = totalTasks + milestone1.Total_Open_Tasks__c;
                        }
                        if (milestone1.Total_Complete_Tasks__c != null) {
                            totalTasks = totalTasks + milestone1.Total_Complete_Tasks__c;
                        }
                        if (milestone1.Total_Open_Tasks__c != null) {
                            openTasks = openTasks + milestone1.Total_Open_Tasks__c;
                        }
                        if (milestone1.Total_Late_Tasks__c != null) {
                            lateTasks = lateTasks + milestone1.Total_Late_Tasks__c;
                        }
                    }
                    
                }
                category.Total_Tasks__c = totalTasks;
                category.Open_Tasks__c = openTasks;
                category.Late_Tasks__c = lateTasks;
            }
            update categoryList;
        }
    }
    // END S-250078 - By Hemlata
    
    
    /**
* Test batch update of milestones with parent milestones
*/
    /*START COMMENTED by Rohit for Case C-00262869 on 4 June 2019
    public static testmethod void testMilestoneBatchUpdate(){
        // Create project
        Milestone1_Project__c project = Milestone1_Test_Utility.sampleProject('My Project');
        
        insert project;
        
        // Create parent milestones
        List<Milestone1_Milestone__c> pList = new List<Milestone1_Milestone__c>();
        
        for(Integer i = 0; i < 101; i++){
            pList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, null, 'My Parent Milestone ' + i) );
        }
        
        try{
            insert pList;
        }
        catch(Exception e){
            system.assert( false, e.getMessage() );
        }
        
        // Create milestones
        List<Milestone1_Milestone__c> mList = new List<Milestone1_Milestone__c>();
        
        for(Integer j = 0; j < 101; j++){
            mList.add( Milestone1_Test_Utility.sampleMilestone(project.Id, pList.get(j).Id, 'My Milestone ' + j ) );
        }
        
        try{
            insert mList;
        }
        catch(Exception e){
            system.assert( false, e.getMessage() );
        }
        
        try{
        test.startTest();//Apoorva case 00262878 6/7/19
            update [SELECT Id FROM Milestone1_Milestone__c WHERE Id IN :mList];
            system.assert(true, 'Milestones update successful');
            test.stopTest();//Apoorva case 00262878 6/7/19
        }
        catch(Exception e){
            system.assert( false, e.getMessage() );
        }
    }
    *///END COMMENTED by Rohit for Case C-00262869 on 4 June 2019
}