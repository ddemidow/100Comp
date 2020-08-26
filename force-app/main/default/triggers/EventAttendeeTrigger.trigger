/**
* Apex Trigger : EventAttendeeTrigger 
* Author : Appirio India (CM Team : Nishank)
* Created for Story S-302680
* Modified by Nitin on 27/11/2018 for S-586005
*/
Trigger EventAttendeeTrigger on Event_Members__c(After Insert,After Update,After Delete,After Undelete) {
    If(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        EventAttendeeTriggerHandler.onAfterInsertUpdate(Trigger.new, Trigger.OldMap);
        if(Trigger.isInsert) {
            EventAttendeeTriggerHandler.updateCount(Trigger.newMap,Trigger.oldMap,'afterInsert');
        }else {
            EventAttendeeTriggerHandler.updateCount(Trigger.newMap,Trigger.oldMap, 'afterUpdate');
        }  
    }
    if(Trigger.isAfter && (Trigger.isUndelete || Trigger.isDelete)) {
        if(Trigger.isDelete) {
            EventAttendeeTriggerHandler.updateCount(Trigger.newMap,Trigger.oldMap, 'afterDelete');
        }else {
            EventAttendeeTriggerHandler.updateCount(Trigger.newMap,Trigger.oldMap, 'afterUndelete');
        }
    }
}