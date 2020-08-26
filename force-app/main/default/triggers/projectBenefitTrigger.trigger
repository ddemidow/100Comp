trigger projectBenefitTrigger on Project_Benefit__c (before insert, 
    before update, before delete) {
    projectBenefitTriggerHandler handler = new projectBenefitTriggerHandler();
   
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    
}