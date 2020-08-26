/**************************************************************************************************
Description:      This class contains methods that perform actions on the Assignment object.
                  These methods are called from trigger FFA_Assignment_Trigger
                  1) When an assignment is created, change the owner of the assignment 
                  to the Salesforce user of the resource (if the resource has an active SF user); 
                  otherwise, current function applies.
                  2) Keep the owner of the assignment and the owner of the schedule associated to it consistent.
                    - When the assignment is created and its owner is set to the salesforce user of the resource, 
                    this owner should also be applied as the schedule owner.
                    - On an existing assignment record - If its owner is updated, update the owner of the schedule associated to it.
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
12/01/2013              Liz Ichihashi                   Created new class.
**************************************************************************************************/
public with sharing class FFA_AssignmentActions {

    /* Commented for the case #00138614 #START

    // called on before insert and update of assignment
    public static void setAndSyncOwner(List<pse__Assignment__c> oldList, List<pse__Assignment__c> newList) {
        Map<Id, pse__Assignment__c> oldMap;
        
        if (oldList != null && oldList.size() > 0) {
            oldMap = new Map<Id, pse__Assignment__c>(oldList);
        }

        Set<Id> contactIds = new Set<Id>();
        List<pse__Assignment__c> assignmentsToUpdate = new List<pse__Assignment__c>();
        for (pse__Assignment__c assignRow : newList) {
            if (oldMap == null) {
                //this is an insert, look for the resource's related salesforce user
                contactIds.add(assignRow.pse__Resource__c);
                assignmentsToUpdate.add(assignRow);
            } else {
                //this is an update, see if the owner is being changed
                if (oldMap.get(assignRow.Id).OwnerId != assignRow.OwnerId) {
                    contactIds.add(assignRow.pse__Resource__c);
                    assignmentsToUpdate.add(assignRow);
                }
            }
        }
        
        Map<Id, pse__Assignment__c> scheduleIdToAssignmentMap  = new Map<Id, pse__Assignment__c>();
        if (assignmentsToUpdate.size() > 0) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id, pse__Salesforce_User__c, pse__Salesforce_User__r.IsActive 
                                                                From Contact Where id in :contactIds]);                                    
            for (pse__Assignment__c assignRow : assignmentsToUpdate) {
                Contact cont = contactMap.get(assignRow.pse__Resource__c);
                if (cont != null && cont.pse__Salesforce_User__c != null && 
                    cont.pse__Salesforce_User__r.IsActive &&
                    cont.pse__Salesforce_User__c != assignRow.OwnerId) {
                    // update the owner id on the assignment row to be the salesforce user of the resource (Contact)
                    assignRow.OwnerId = cont.pse__Salesforce_User__c;
                    scheduleIdToAssignmentMap.put(assignRow.pse__Schedule__c, assignRow);
                }
            }
            List<pse__Schedule__c> schedulesToUpdate = [Select Id, OwnerId 
                                                        From pse__Schedule__c 
                                                        Where id in :scheduleIdToAssignmentMap.keySet()];
            for (pse__Schedule__c schedRow : schedulesToUpdate) {
                pse__Assignment__c assignment = scheduleIdToAssignmentMap.get(schedRow.Id);
                if (assignment != null && schedRow.OwnerId != assignment.OwnerId) {
                    // update the owner id on the schedule row to be the same as the owner of the assignment 
                    schedRow.OwnerId = assignment.OwnerId;
                }
            } 
            update schedulesToUpdate;                                       
        }
    }
    
     Commented for the case #00138614 #STOP */
}