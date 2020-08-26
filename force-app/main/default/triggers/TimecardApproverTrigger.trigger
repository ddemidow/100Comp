/*****************************************************
Author  : Appirio [Hitesh - Dec 05, 2014]
Purpose : Trigger on pse__Timecard_Header__c.
*****************************************************/

trigger TimecardApproverTrigger on pse__Timecard_Header__c (before update) {    
    if(Trigger.isBefore && Trigger.isUpdate)
        TimecardApproverTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);   
}