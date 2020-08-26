/***********************************************************************************************
Name : OpportunityTeamTrigger 
Created Date : 17th December, 2018
Created By : Nishant Singh
Description : S-592384                
*************************************************************************************************/

trigger OpportunityTeamTrigger on OpportunityTeamMember (after delete, after insert, after undelete,   after update) {
   //Calling methods on differnt events.
   if (Trigger.isDelete) {
      OpportunityTeamTriggerHandler.onAfterDelete(Trigger.old);
    } else if (Trigger.isInsert) {
      OpportunityTeamTriggerHandler.onAfterInsert(Trigger.new);
    } else if (Trigger.isUndelete) {
      OpportunityTeamTriggerHandler.onAfterUndelete(Trigger.new);
    } else if (Trigger.isUpdate) {
      OpportunityTeamTriggerHandler.onAfterUpdate(Trigger.old, Trigger.newMap);
    }  
}