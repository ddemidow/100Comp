/****************************************
 Created By : Kritika Bhati
 Description : Handler class for MilestoneTrigger(S-534163)
Created Date: 12/27/2017
 * ************************************/
public class MilestoneTriggerHandler {
     private static id fetchRecordTypeId(string sObj, string rt) {
        return Schema.getGlobalDescribe().get(sObj).getDescribe().getRecordTypeInfosByName().get(rt).getRecordTypeId();
    }
    public static void updateTotalProjectAmount( Map<Id, pse__Milestone__c> oldMap, List<pse__Milestone__c> newList){
        Id milRecordTypeId = fetchRecordTypeId('pse__Milestone__c', 'Billable Milestone');
        Set<Id> selProjSet = new Set<Id>();
        if(newList != null){
        	for(pse__Milestone__c mil: newList){
            	if(mil.RecordTypeId == milRecordTypeId && mil.pse__Exclude_from_Billing__c == false && mil.pse__Project__c != null && oldMap == null){
                selProjSet.add(mil.pse__Project__c);
            	}
                else if(oldMap != null && (mil.pse__Milestone_Amount__c != oldMap.get(mil.id).pse__Milestone_Amount__c || mil.pse__Exclude_from_Billing__c != oldMap.get(mil.id).pse__Exclude_from_Billing__c || mil.pse__Project__c != oldMap.get(mil.id).pse__Project__c 
                        	|| (mil.RecordTypeId != oldMap.get(mil.id).RecordTypeId 
                                && (mil.RecordTypeId == milRecordTypeId || oldMap.get(mil.id).RecordTypeId == milRecordTypeId)))){
                                    	
                                    if(oldMap.get(mil.id).pse__Project__c != null){
                                        	selProjSet.add(oldMap.get(mil.id).pse__Project__c);
                                        }
                                    if(mil.pse__Project__c != null){
                                        	selProjSet.add(mil.pse__Project__c);
                    					}
                                }
            }
        }
        else{
            for(pse__Milestone__c milOld : oldMap.values()){
                if(milOld.RecordTypeId == milRecordTypeId && milOld.pse__Project__c != null){
                selProjSet.add(milOld.pse__Project__c);
            }
            }
        }
        if(selProjSet.size() > 0){
        calTotalProjectAmountOnProject(selProjSet);
        }
    }
    public static void calTotalProjectAmountOnProject(Set<Id> selProjects){
        List<pse__Proj__c> selProjectsList = new List<pse__Proj__c>();
       
    	Id milRecordTypeId = fetchRecordTypeId('pse__Milestone__c', 'Billable Milestone');
        
        for(pse__Proj__c projToUpdate: [Select Id, Total_Contract_Amount__c, (Select Id, pse__Milestone_Amount__c
                                                                              FROM pse__Milestones__r
                                                                              WHERE RecordTypeId = :milRecordTypeId
                                                                              AND  pse__Exclude_from_Billing__c = false)
                                       FROM pse__Proj__c
                                       WHERE Id IN :selProjects]){
             Decimal sum= 0;
            for(pse__Milestone__c selMil: projToUpdate.pse__Milestones__r ){
               sum = sum + selMil.pse__Milestone_Amount__c;     
                   }
             projToUpdate.Total_Contract_Amount__c = sum;
             selProjectsList.add(projToUpdate) ;                            
             }
         if(selProjectsList.size() > 0){
           update selProjectsList;
         }   
        }
    }