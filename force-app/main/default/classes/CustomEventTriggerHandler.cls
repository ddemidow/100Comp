/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : it is a trigger handler for Custom Event 
*********************************************************************************/
public class CustomEventTriggerHandler {
    public static void updateCountForMeetingAttended(Map<Id,Event__c> newMap,Map<Id,Event__c> oldVal,String status) {
        
        Set<Id> contactSetId = new Set<Id>();
        Map<Id,List<Event_Members__c>> insertRecord = new Map<Id,List<Event_Members__c>>();
        Map<Id,Integer> eventMap = new Map<Id,Integer>();
        List<Contact> conLstWthNumber = new List<Contact>();
        List<Event_Members__c> evtMemLst;
        
        if(status == 'afterUpdate') {
            evtMemLst = [Select id from Event_Members__c where Event__c IN: oldVal.keySet()];
            
            evtMemLst.addAll([Select id from Event_Members__c where Event__c IN: newMap.keySet()]);               
        }
        
        if(status == 'afterUndelete') {
            evtMemLst = [Select id from Event_Members__c where Event__c IN: newMap.keySet()];
        }
        
        if(status == 'afterDelete') {
            evtMemLst = [Select id from Event_Members__c where Event__c IN: oldVal.keySet()];
        }
        
        if(evtMemLst!=null && !evtMemLst.isEmpty()) {
            for(Event_Members__c evtCon : [Select id,Contact__c from Event_Members__c where id IN: evtMemLst]) {
                contactSetId.add(evtCon.Contact__c);
            }	
            
            for(Contact con : [Select Id,Name,Account_Name__c,(SELECT Day_1_Role__c,	Day_2_Role__c,Day_3_Role__c,Event_End_Date__c 
                                                               FROM Event_Members__r 
                                                               WHERE Event_End_Date__c !=null) 
                               From Contact
                               WHERE Id IN : contactSetId]) {
                                   insertRecord.put(con.Id,con.Event_Members__r);                             
                               }
            
            for(Id conId : insertRecord.keySet()) {
                for(Event_Members__c em : insertRecord.get(conId)) {
                    if(em.Event_End_Date__c > (Date.today()-395) &&
                       ((em.Day_1_Role__c=='Guest' || 
                         em.Day_1_Role__c=='Prospect' ||
                         em.Day_1_Role__c=='Member' ||
                         em.Day_1_Role__c=='Advisor') ||
                        (em.Day_2_Role__c=='Guest' || 
                         em.Day_2_Role__c=='Prospect' ||
                         em.Day_2_Role__c=='Member' ||
                         em.Day_2_Role__c=='Advisor') ||
                        em.Day_3_Role__c=='Guest' || 
                        em.Day_3_Role__c=='Prospect' ||
                        em.Day_3_Role__c=='Member' ||
                        em.Day_3_Role__c=='Advisor')) {
                            
                            if(!eventMap.containsKey(conId)) {
                                eventMap.put(conId,1);
                            }
                            else {
                                Integer count = eventMap.get(conId);
                                count = count+1;
                                eventMap.put(conId,count);
                            }
                        }
                }
            }
            
            for(Id conIdSetVal : contactSetId) {
                if(!eventMap.containsKey(conIdSetVal)) {
                    Contact con = new Contact();
                    con.Id=conIdSetVal;
                    con.Number_of_meetings_Attended__c = null;
                    conLstWthNumber.add(con);
                }
            }
            
            for(Id conIdVal : eventMap.keySet()) {
                Contact con = new Contact();
                con.Id=conIdVal;
                con.Number_of_meetings_Attended__c = eventMap.get(conIdVal);
                conLstWthNumber.add(con);
            }
            
            if(conLstWthNumber!=null && !conLstWthNumber.isEmpty()) {
                update conLstWthNumber;
            }  
        }
        
        
        
    }
}