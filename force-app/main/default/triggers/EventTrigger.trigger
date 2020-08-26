/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27/11/2018
Purpose : it is an Event Trigger
*********************************************************************************/
trigger EventTrigger on Event__c (after update,after delete,after undelete) {
	    if (trigger.isUpdate && trigger.isAfter){
         	CustomEventTriggerHandler.updateCountForMeetingAttended(Trigger.newMap,Trigger.oldMap,'afterUpdate');   
        } 

		if(Trigger.isAfter && (Trigger.isUndelete || Trigger.isDelete)) {
         if(Trigger.isDelete) {
             CustomEventTriggerHandler.updateCountForMeetingAttended(Trigger.newMap,Trigger.oldMap, 'afterDelete');
         }else {
             CustomEventTriggerHandler.updateCountForMeetingAttended(Trigger.newMap,Trigger.oldMap, 'afterUndelete');
         }
     }    
}