Trigger Milestone1_Milestone_Trigger on Milestone1_Milestone__c (before insert, before update, before delete,
                                 after insert, after update, after delete) {
 //  Added Set S-250078                              
  Set<Id> categorySet = new Set<Id>();
  if(Trigger.isbefore){
    if(Trigger.isDelete){
      Milestone1_Milestone_Trigger_Utility.handleMilestoneDeleteTrigger(trigger.oldMap);
    } 
    else if(Trigger.isUpdate){
      //prevent manual reparenting of Milestones
      Milestone1_Milestone_Trigger_Utility.checkMilestoneManualReparent(trigger.oldMap, trigger.newMap);
    } 
    else {
      //insert
      Milestone1_Milestone_Trigger_Utility.handleMilestoneBeforeTrigger(trigger.new, trigger.newMap);
    }
  } 
  else {
    if(Trigger.isDelete){
      Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.oldMap);
      // START S-250078 - By Hemlata
      for(Milestone1_Milestone__c oldMc1 : Trigger.oldMap.values()) {
        if (oldMc1.TMG_Category__c != null) {
            categorySet.add(oldMc1.TMG_Category__c);
        }
      } // for
      // END S-250078 - By Hemlata
    } 
    else if(Trigger.isUpdate){
        Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.newMap);
        //shift Deadline of successor Milestones if Milestone Deadline is shifted
        Milestone1_Milestone_Trigger_Utility.checkSuccessorDependencies(trigger.oldMap, trigger.newMap);
        //shift children Milestone dates if Milestone dates are shifted
        Milestone1_Milestone_Trigger_Utility.checkChildDependencies(trigger.oldMap, trigger.newMap);
        //shift Task dates if Milestone dates are shifted
        Milestone1_Milestone_Trigger_Utility.checkTaskDependencies(trigger.oldMap, trigger.newMap);
        //Added by jyoti for Story S-349354
         Milestone1_Milestone_Trigger_Utility.updateDueDateForCategoryAndProject(trigger.oldMap, trigger.newMap);
        // START S-250078 - By Hemlata
        for (Milestone1_Milestone__c mc1 : Trigger.New) {
            if (mc1.TMG_Category__c != Trigger.oldMap.get(mc1.Id).TMG_Category__c || mc1.Total_Open_Tasks__c!= Trigger.oldMap.get(mc1.Id).Total_Open_Tasks__c
              || mc1.Total_Late_Tasks__c!= Trigger.oldMap.get(mc1.Id).Total_Late_Tasks__c || mc1.Total_Complete_Tasks__c!= Trigger.oldMap.get(mc1.Id).Total_Complete_Tasks__c) {
                if (mc1.TMG_Category__c != null) {
                    categorySet.add(mc1.TMG_Category__c);
                }
                if (Trigger.oldMap.get(mc1.Id).TMG_Category__c != null) {
                    categorySet.add(Trigger.oldMap.get(mc1.Id).TMG_Category__c);
                }
            }
        }// for
        // END S-250078 - By Hemlata
    } 
    else {
      Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.newMap);
      // START S-250078 - By Hemlata
       for(Milestone1_Milestone__c mc1 : Trigger.new) {
        if (mc1.TMG_Category__c != null) {
            categorySet.add(mc1.TMG_Category__c);
        }
      } // for
      // END S-250078 - By Hemlata
    }
    // START S-250078 - By Hemlata
    // To call on after insert, after update, after delete
    if (categorySet.size() >0) {
        Milestone1_Milestone_Trigger_Utility.populateCategoryTasksfields(categorySet);
    }
    // END S-250078 - By Hemlata    
  }
  
  
  
}