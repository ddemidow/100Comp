/************************************************
* Name           : DealSheet_Trigger
* Creaetd By     : Alka Taneja
* Created Date   : 14 Sep, 2015
* Story          : S-320861
* Description    : To handle all trigger events of Deal_Sheet__c object 
* Revision Log	 : Modified - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
*					Chnages: Trigger defined for Before Insert and Delete.
*					V_1.1 - Modified - Padmesh Soni(02/22/2016 - Appirio Offshore) - S-374088
*						Changes:
*							1. New method call on After insert.
************************************************/

trigger DealSheet_Trigger on Deal_Sheet__c (before delete, after insert, after update, after undelete, before insert, before update){
    /*
  //after insert
  if(Trigger.isAfter && Trigger.isInsert){
    DealSheet_TriggerHandler.onAfterInsert(Trigger.new);
  }
  
  //after update
  if(Trigger.isAfter && Trigger.isUpdate){
    DealSheet_TriggerHandler.onAfterUpdate(Trigger.new, trigger.OldMap);
  }
  
  //after delete
  else if(Trigger.isBefore && Trigger.isDelete){
    DealSheet_TriggerHandler.onBeforeDelete(Trigger.old);
  }*/
  
  //Code modified - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
  /*** Code Changes Start here ***/
  //after undelete
  if(Trigger.isAfter && Trigger.isUndelete){
    DealSheet_TriggerHandler.onAfterUnDelete(Trigger.new);
  }

	//Check for event type
	if(Trigger.isBefore) {
  		
  		//Check for request type
		if(Trigger.isInsert || Trigger.isUpdate) {
			
			//Call trigger handler class method
			DealSheet_TriggerHandler.onBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
		}
	}
	/*** Code Changes Stop here ***/
	
	//Code modified - Padmesh Soni (02/22/2016 - Appirio Offshore) - S-374088
	/*** Code Changes Start here ***/
	//Check for event type
	if(Trigger.isAfter) {
  		
  		//Check for request type
		if(Trigger.isInsert) {
			
			//Call trigger handler class method
			DealSheet_TriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
		}
	}
	/*** Code Changes Stop here ***/
	//Code modified - Padmesh Soni (02/22/2016 - Appirio Offshore) - S-374088
}