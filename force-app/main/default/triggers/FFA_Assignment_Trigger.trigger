trigger FFA_Assignment_Trigger on pse__Assignment__c (before insert, before update) {
    
    // Commented for the case #00138614
    // FFA_AssignmentActions.setAndSyncOwner(trigger.old, trigger.new);
}