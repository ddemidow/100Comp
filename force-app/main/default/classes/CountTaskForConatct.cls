/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : it is a batch class to count Task for Contact
*********************************************************************************/
global class CountTaskForConatct implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id,Name,Account_Name__c,(select id, subject,status, who.id,What.id,type,ActivityDate,Owner.Name FROM Tasks WHERE ActivityDate !=null) From Contact'); 
    }
    
    global void execute(Database.BatchableContext BC,List<Contact> conLst) {
        Map<Id,Integer> eventMap = new Map<Id,Integer>();
        List<Id> conId = new List<Id>();
        List<Id> taskId = new List<Id>();
        List<Contact> conLstWthNumber = new List<Contact>();
        ActionPlanTaskTriggerHandler apth = new ActionPlanTaskTriggerHandler();
        
        
        
        for(Contact contactLst : conLst) {
            for(Task tk : contactLst.Tasks) {
                if(tk.type!=null && tk.subject!=null){
                    if((tk.ActivityDate >= (Date.today()-365) &&
                        tk.ActivityDate < Date.today()) &&
                       tk.Status=='Completed' &&
                       (tk.type=='Call' || (tk.subject.containsIgnoreCase('Call') ||
                                            tk.subject.containsIgnoreCase('Check-in') ||
                                            tk.subject.containsIgnoreCase('touch base') ||
                                            tk.subject.containsIgnoreCase('Call Notes') ||
                                            tk.subject.containsIgnoreCase('CN:'))) &&
                       (tk.Owner.Name.containsIgnoreCase('kumail') || tk.Owner.Name.containsIgnoreCase('irene') || tk.Owner.Name.containsIgnoreCase('ruthy') ||
                        tk.Owner.Name.containsIgnoreCase('adriana') || tk.Owner.Name.containsIgnoreCase('erin') || tk.Owner.Name.containsIgnoreCase('silke') ||
                        tk.Owner.Name.containsIgnoreCase('maria') || tk.Owner.Name.containsIgnoreCase('nancy') || tk.Owner.Name.containsIgnoreCase('trace') ||
                        tk.Owner.Name.containsIgnoreCase('tartag') || tk.Owner.Name.containsIgnoreCase('kendall') || tk.Owner.Name.containsIgnoreCase('ellen') ||
                        tk.Owner.Name.containsIgnoreCase('brita') || tk.Owner.Name.containsIgnoreCase('felicia') || tk.Owner.Name.containsIgnoreCase('scudder') ||
                        tk.Owner.Name.containsIgnoreCase('daniel casse') || tk.Owner.Name.containsIgnoreCase('kevin'))) {
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
        }
        
        for(Id conIdVal : eventMap.keySet()) {
            System.debug('>>>conId>>>'+conIdVal);
            System.debug('>>>Count>>>'+eventMap.get(conIdVal));
            Contact con = new Contact();
            con.Id=conIdVal;
            con.G100_N_Calls__c = eventMap.get(conIdVal);
            conLstWthNumber.add(con);
        }
        
        if(conLstWthNumber!=null && !conLstWthNumber.isEmpty()) {
            update conLstWthNumber;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }    
}