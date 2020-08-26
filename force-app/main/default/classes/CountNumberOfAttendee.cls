/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : it is a batch class for Counting Number of Attendee
*********************************************************************************/
global class CountNumberOfAttendee implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id,Name,Account_Name__c,(Select Day_1_Role__c,	Day_2_Role__c,Day_3_Role__c,Event_End_Date__c from Event_Members__r where Event_End_Date__c !=null) From Contact');
        
    }
    
    global void execute(Database.BatchableContext BC,List<Contact> conLst) {
        Map<Id,Integer> eventMap = new Map<Id,Integer>();
        List<Id> conId = new List<Id>();
        List<Id> eveId = new List<Id>();
        List<Contact> conLstWthNumber = new List<Contact>();
        for(Contact contactLst : conLst) {
            for(Event_Members__c em : contactLst.Event_Members__r) {
                if((em.Event_End_Date__c > (Date.today()-395) && em.Event_End_Date__c <= (Date.today())) &&
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
                    em.Day_3_Role__c=='Advisor')){
                        
                        if(!eventMap.containsKey(contactLst.Id)) {
                            eventMap.put(contactLst.Id,1);
                        }
                        else {
                            Integer count = eventMap.get(contactLst.Id);
                            count = count+1;
                            eventMap.put(contactLst.Id,count);
                        }
                    }
            }     
        }
        
        for(Id conIdVal : eventMap.keySet()) {
            System.debug('>>>conId>>>'+conIdVal);
            System.debug('>>>Count>>>'+eventMap.get(conIdVal));
            Contact con = new Contact();
            con.Id=conIdVal;
            con.Number_of_meetings_Attended__c = eventMap.get(conIdVal);
            conLstWthNumber.add(con);
        }
        
        if(conLstWthNumber!=null && !conLstWthNumber.isEmpty()) {
            update conLstWthNumber;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}