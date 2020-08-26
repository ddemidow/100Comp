/*****************************************************
Author  : Appirio [Hitesh - Dec 05, 2014]
Purpose : Trigger handler for trigger : TimeCardTrigger on pse__Timecard_Header__c
*****************************************************/
public class TimecardApproverTriggerHandler {  
    
    public static void beforeUpdateHandler(List<pse__Timecard_Header__c> newRecords, List<pse__Timecard_Header__c> OldRecords, Map<Id,pse__Timecard_Header__c> newMap, Map<Id,pse__Timecard_Header__c> oldMap){
        //
        Set<Id> newTimeCardIds = new Set<Id>();     
        for(pse__Timecard_Header__c tc :[select pse__Resource__r.pse__Salesforce_User__c,
                                                pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c,
                                                pse__Project__r.Managing_Director__c,
                                                pse__Status__c,
                                                pse__Submitted__c,
                                                pse__Approver__c
                                        from pse__Timecard_Header__c
                                        //LSLEVIN Case 00105964 1.6.2015 Added below null check to where clause
                                        where id in :newMap.keySet() AND pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c != null
                                        ]){
            if(newMap.get(tc.id).pse__Status__c == 'Submitted' || newMap.get(tc.id).pse__Submitted__c){
                
                //LSLEVIN Case 105964 1.6.2015 Start
                if(tc.pse__Resource__r.pse__Salesforce_User__c == null || (tc.pse__Resource__r.pse__Salesforce_User__c != tc.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c)) {
                    newMap.get(tc.id).pse__Approver__c = tc.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c;
                }
                
                if(tc.pse__Resource__r.pse__Salesforce_User__c != null && (tc.pse__Resource__r.pse__Salesforce_User__c).equals(tc.pse__Project__r.pse__Project_Manager__r.pse__Salesforce_User__c)){
                    newMap.get(tc.id).pse__Approver__c = tc.pse__Project__r.Managing_Director__c;
                }
                //LSLEVIN Case 105964 1.6.2015 END                               
            }
        }
    }
}