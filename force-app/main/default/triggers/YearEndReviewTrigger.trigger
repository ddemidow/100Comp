trigger YearEndReviewTrigger on Year_end_Review__c (before insert, before update) {
     
    if (Trigger.isInsert && trigger.isBefore){

        YearEndReviewTriggerHandler yerHandler = new YearEndReviewTriggerHandler();
        yerHandler.isInsertMethod(trigger.new); 
    }
    
    if (Trigger.isUpdate && trigger.isBefore){
        YearEndReviewTriggerHandler yerHandler = new YearEndReviewTriggerHandler();
        yerHandler.isUpdateMethod(trigger.newMap, trigger.oldMap);
    }
}