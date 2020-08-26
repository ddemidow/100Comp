trigger Milestone1_Task_Trigger on Milestone1_Task__c ( before insert, before update,after insert,after update ) {

    if(trigger.isBefore) {
        Milestone1_Task_Trigger_Utility.handleTaskBeforeTrigger(trigger.new); 
        /* Start - Jai Gupta - S-559561 - Aug 30,2018 */
        if(Trigger.isInsert) {
            Milestone1_Task_Trigger_Utility.onBeforeInsert(trigger.new);
        } else if(Trigger.isUpdate) {
            Milestone1_Task_Trigger_Utility.onBeforeUpdate(trigger.new,trigger.oldMap);
        }
        // End S-559561 
    } 
    
    if(trigger.isAfter) {
        if(Trigger.isUpdate){
            //Added by jyoti for Story S-349354
            Milestone1_Task_Trigger_Utility.updateDueDateAccToScheduleDate(trigger.oldMap, trigger.newMap);
            //shift Dates of successor Tasks if Task Due Date is shifted
            Milestone1_Task_Trigger_Utility.checkSuccessorDependencies(trigger.oldMap, trigger.newMap);
            
        }
        Milestone1_Task_Trigger_Utility.handleTaskAfterTrigger(trigger.new, trigger.old);
    } 

}