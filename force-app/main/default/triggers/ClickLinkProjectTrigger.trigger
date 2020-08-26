trigger ClickLinkProjectTrigger on pse__proj__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
 // Added by Nishank for Story S-299883 to skip this trigger for BatchToPopulateReportingEndDate class
 Map<String, BatchClassId__c> BatchIdsMap = BatchClassId__c.getAll();
 Map<Id,AsyncApexJob> ProcessingBatchIds = new Map<Id,AsyncApexJob>([Select ApexClassID from AsyncApexJob where JobType='BatchApex' and Status ='Processing']);
 Set<String> CurrentBatchIds = new Set<String>();
 if(ProcessingBatchIds !=null){
 for(AsyncApexJob a : ProcessingBatchIds.values())
 {
 String s =String.ValueOf(a.ApexClassID);
 CurrentBatchIds.add(s.substring(0,15));
 }
 }
 System.debug('CurrentBatchIds ' + CurrentBatchIds );
 if(CurrentBatchIds!=null && BatchIdsMap.get('BatchToPopulateReportingEndDate')!=null && BatchIdsMap.get('BatchToPopulateReportingEndDate').Class_Id__c!=null && CurrentBatchIds.contains(BatchIdsMap.get('BatchToPopulateReportingEndDate').Class_Id__c)){}
 else{ // End of changes Added by Nishank for Story S-299883
 ffirule.IntegrationRuleEngine.triggerHandler();
 }
 
 //S-429731 ---START---- Hitesh[Sept 14, 2016]
 if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
    List<pse__proj__c> projectsToBeProcessed = new List<pse__proj__c>();
    for(pse__proj__c proj :trigger.new){
        
        if(trigger.isUpdate){
            if(trigger.oldmap.get(proj.id).pse__End_Date__c != proj.pse__End_Date__c){
                projectsToBeProcessed.add(proj);
            }
        }
        
        if(trigger.isInsert){
            if(proj.pse__End_Date__c != null)
                projectsToBeProcessed.add(proj);
        }
    }
    if(projectsToBeProcessed.size() > 0)
        ClickLinkProjectTriggerHandler.updateOpportunitiyforProject(projectsToBeProcessed);
 }
 //S-429731 ---END---- Hitesh[Sept 14, 2016]
}