/***********************************************************************************************
Name : ContactTeamTrigger
Created Date : 7th March , 2014
Created By : Jyoti Singh
Description : S-194517                
*************************************************************************************************/

trigger ContactTeamTrigger on Contact_Team__c  (after delete, after insert, after undelete,   after update) {
   //Calling methods on differnt events.
   if (Trigger.isDelete) {
      ContactTeamTriggerHandler.onAfterDelete(Trigger.old);
    } else if (Trigger.isInsert) {
      ContactTeamTriggerHandler.onAfterInsert(Trigger.new);
    } else if (Trigger.isUndelete) {
      ContactTeamTriggerHandler.onAfterUndelete(Trigger.new);
    } else if (Trigger.isUpdate) {
      ContactTeamTriggerHandler.onAfterUpdate(Trigger.old, Trigger.newMap);
    }  
}