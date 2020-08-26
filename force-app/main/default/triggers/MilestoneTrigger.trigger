/****************************************
 Created By : Kritika Bhati
 Description : S-534163
 Created Date: 12/27/2017
 * ************************************/
trigger MilestoneTrigger on pse__Milestone__c (before insert, after insert, after update, after delete, after undelete) {
	if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            MilestoneTriggerHandler.updateTotalProjectAmount(null, Trigger.New);
        }
         if(Trigger.isUpdate) {
            MilestoneTriggerHandler.updateTotalProjectAmount(Trigger.OldMap, Trigger.New);
    }
        if(Trigger.isDelete) {
            MilestoneTriggerHandler.updateTotalProjectAmount(Trigger.OldMap, null);
    }
        if(Trigger.isUndelete) {
            MilestoneTriggerHandler.updateTotalProjectAmount(null, Trigger.New);
    }

}

}