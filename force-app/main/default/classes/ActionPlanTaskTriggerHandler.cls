/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : it is a Trigger Handler for Task
*********************************************************************************/
public class ActionPlanTaskTriggerHandler {
    public static void updateCountForEvent(Map<Id,Task> newMap,Map<Id,Task> oldVal,String status) {
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,List<Task>> insertRecord = new Map<Id,List<Task>>();
        Map<Id,Integer> eventMap = new Map<Id,Integer>();
        Map<Id,Integer> eventMeetingMap = new Map<Id,Integer>(); 
        List<Contact> conLstWthNumber = new List<Contact>();
        List<Contact> conLstWthMeetNumber = new List<Contact>();
        
        
        if(status == 'afterUpdate') {
            System.debug('>>>inside is update>>>');
            for(Id otVal : oldVal.keySet()) {
                if(checkEventRelatedToContact(oldVal.get(otVal).WhoId))
                    contactIdSet.add(oldVal.get(otVal).WhoId);
            }
            System.debug('>>>inside is update>>>');
            for(Id val : newMap.keySet()) {
                if(checkEventRelatedToContact(newMap.get(val).WhoId))
                    contactIdSet.add(newMap.get(val).WhoId);
            }    
        }
        
        if(status == 'afterInsert' || status == 'afterUndelete') {
            for(Id val : newMap.keySet()) {
                if(checkEventRelatedToContact(newMap.get(val).WhoId))
                    contactIdSet.add(newMap.get(val).WhoId);
            }
        }
        
        if(status == 'afterDelete') {
            for(Id otVal : oldVal.keySet()) {
                if(checkEventRelatedToContact(oldVal.get(otVal).WhoId))
                    contactIdSet.add(oldVal.get(otVal).WhoId);
            }
        }
        System.debug('>>>contactIdSet>>>'+contactIdSet); 
        for(Contact con : [Select Id,Name,Account_Name__c,(select id, subject,status, who.id,What.id,type,ActivityDate,Owner.Name 
                                                           FROM Tasks
                                                           WHERE ActivityDate !=null) 
                           From Contact
                           WHERE Id IN : contactIdSet]) {
                               insertRecord.put(con.Id,con.Tasks);
                           }
        System.debug('>>>insertRecord>>>'+insertRecord);
        for(Id conId : insertRecord.keySet()) {
            for(Task tk : insertRecord.get(conId)) {
                
                if((tk.ActivityDate >= (Date.today()-365) &&
                    tk.ActivityDate < Date.today()) &&
                   tk.Status=='Completed' &&
                   (tk.type=='Call' || (tk.subject.containsIgnoreCase('Call') ||
                                        tk.subject.containsIgnoreCase('Check-in') ||
                                        tk.subject.containsIgnoreCase('touch base') ||
                                        tk.subject.containsIgnoreCase('Call Notes') ||
                                        tk.subject.containsIgnoreCase('CN:'))) &&
                   (checkTheAssignedUser(tk.Owner.Name))) {
                       System.debug('>>>inside Call>>>');
                       System.debug('>>>Subject>>>'+tk.Subject);
                       if(!eventMap.containsKey(conId)) {
                           System.debug('>>>Call 1>>>');
                           eventMap.put(conId,1);
                       }
                       else {
                           System.debug('>>>Increment Call>>>');
                           Integer countCalls = eventMap.get(conId);
                           countCalls = countCalls+1;
                           eventMap.put(conId,countCalls);
                       }
                   }
                if((tk.ActivityDate >= (Date.today()-365) &&
                    tk.ActivityDate < Date.today()) &&
                   tk.Status=='Completed' &&
                   (tk.type=='Meeting' || ((tk.subject.containsIgnoreCase('meeting') ||
                                            tk.subject.containsIgnoreCase('inperson') ||
                                            tk.subject.containsIgnoreCase('in-person'))&&
                                           (!tk.subject.containsIgnoreCase('Call') ||
                                            !tk.subject.containsIgnoreCase('Check-in')))) &&
                   (checkTheAssignedUser(tk.Owner.Name))) {
                       System.debug('>>>inside Meeting>>>');
                       System.debug('>>>Subject Meeting>>>'+tk.Subject);
                       if(!eventMeetingMap.containsKey(conId)) {
                           System.debug('>>>Meeting 1>>>');
                           eventMeetingMap.put(conId,1);
                       }
                       else {
                           System.debug('>>>Increment Meeting>>>');
                           Integer countMeetings = eventMeetingMap.get(conId);
                           countMeetings = countMeetings+1;
                           eventMeetingMap.put(conId,countMeetings);
                       }
                   } 
            }
        }
        
        System.debug('>>>EventMap>>>'+eventMap); 
        for(Id conIdSetVal : contactIdSet) {
            if(!eventMap.containsKey(conIdSetVal)) {
                Contact con = new Contact();
                con.Id=conIdSetVal;
                con.G100_N_Calls__c = null;
                conLstWthNumber.add(con);
            }
            if(!eventMeetingMap.containsKey(conIdSetVal)) {
                Contact con = new Contact();
                con.Id=conIdSetVal;
                con.G100_N_Meetings__c = null;
                conLstWthMeetNumber.add(con);
            }   	
        }
        for(Id conIdVal : eventMap.keySet()) {
            System.debug('>>>conId>>>'+conIdVal);
            System.debug('>>>Count>>>'+eventMap.get(conIdVal));
            Contact con = new Contact();
            con.Id=conIdVal;
            con.G100_N_Calls__c = eventMap.get(conIdVal);
            conLstWthNumber.add(con);
        }
        
        for(Id conIdMeetVal : eventMeetingMap.keySet()) {
            Contact con = new Contact();
            con.Id=conIdMeetVal;
            con.G100_N_Meetings__c = eventMeetingMap.get(conIdMeetVal);
            conLstWthMeetNumber.add(con);
        }
        
        if(conLstWthNumber!=null && !conLstWthNumber.isEmpty()) {
            update conLstWthNumber;
        }
        
        if(conLstWthMeetNumber!=null && !conLstWthMeetNumber.isEmpty()) {
            update conLstWthMeetNumber;
        } 
    }
    
    
    public static boolean checkEventRelatedToContact(Id conOrLeadId) {
        System.debug('>>>contactId>>>'+conOrLeadId);
        String s1 = String.valueOf(conOrLeadId);
        System.debug('>>>s1>>>'+s1);
        System.debug('>>>s1.startsWith>>>'+s1.startsWith('003'));
        if(s1.startsWith('003'))
            return true;
        
        return false;
    } 
    
    public static boolean checkTheAssignedUser(String userName) {
        if(userName.containsIgnoreCase('kumail') || userName.containsIgnoreCase('irene') || userName.containsIgnoreCase('ruthy') ||
           userName.containsIgnoreCase('adriana') || userName.containsIgnoreCase('erin') || userName.containsIgnoreCase('silke') ||
           userName.containsIgnoreCase('maria') || userName.containsIgnoreCase('nancy') || userName.containsIgnoreCase('trace') ||
           userName.containsIgnoreCase('tartag') || userName.containsIgnoreCase('kendall') || userName.containsIgnoreCase('ellen') ||
           userName.containsIgnoreCase('brita') || userName.containsIgnoreCase('felicia') || userName.containsIgnoreCase('scudder') ||
           userName.containsIgnoreCase('daniel casse') || userName.containsIgnoreCase('kevin'))
            return true;
        return false;
    }
}