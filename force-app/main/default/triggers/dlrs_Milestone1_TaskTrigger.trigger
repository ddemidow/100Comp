/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Milestone1_TaskTrigger on Milestone1_Task__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(CheckRecursive.runOnce()){
        If((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate) || (Trigger.isBefore && Trigger.isDelete)){//Added by Lalit for S-621223
                System.debug('=======Lalitdlrs_Milestone1_TaskTrigger');
            dlrs.RollupService.triggerHandler(Milestone1_Task__c.SObjectType);//temporarily commneted by Lalit
            //Milestone1_Task_Trigger_Utility.callDlrsForTMGTask();
        }
    }
    
}