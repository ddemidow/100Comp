/*************************************************************************
Name : BatchUpdateContactTeamOnContact
Author : Jyoti Singh (Appirio JDC)
Date :  7th Mar , 2014
Usage : This class is used to update Contact data.
**************************************************************************/
global class BatchUpdateContactTeamOnContact implements Database.Batchable<SObject>{
    
    //DataBase.Batchable Start method
    global database.querylocator start(Database.BatchableContext BC){
       
       String query = 'Select id from Contact ';                    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, LIST<SObject> listData){
         List<Contact> contactLists = (List<Contact>)listData;         
         
         List<Contact_Team__c > contactTeams = new List<Contact_Team__c>([Select Team_Member__r.Name, Team_Member__c, Contact__c From Contact_Team__c where Contact__c in : contactLists and Team_Member__c!= Null order by Role__c ASC]);
         Map<ID , String> mapContatTeams  = new Map<ID , String>();
         if(contactTeams.size() > 0){
             for(Contact_Team__c  cont : contactTeams){
                 String partnerNames = '';
                 if(mapContatTeams.ContainsKey(cont.Contact__c) && cont.Team_Member__c != null){
                     partnerNames = mapContatTeams.get(cont.Contact__c) + ', '+ cont.Team_Member__r.Name;
                 }  
                 else if(cont.Team_Member__c != null){
                     partnerNames = cont.Team_Member__r.name;
                 }
                 mapContatTeams.put(cont.Contact__c ,partnerNames );
             }
             
             List<Contact> contacts = new List<Contact>();
             
             for(Id cntct : mapContatTeams.keyset()){
                 contacts.Add(new Contact(Id = cntct , Contact_Team_Members__c= mapContatTeams.get(cntct ) ));
             }
             //system.debug('==='+contactSpouse);
             database.update(contacts , false);
         }
         
    }
    
    global void finish(Database.BatchableContext BC){
         
    }
    
    /** COMMENTED START by Rohit for S-635394
     public static testmethod void BatchUpdateContactTeamOnContactTest(){
          BatchUpdateContactTeamOnContact contactBatch = new BatchUpdateContactTeamOnContact ();     
          Test.startTest();
          Database.executeBatch(contactBatch , 1);
          Test.stopTest();
       }
     COMMENTED END by Rohit for S-635394**/
    
   }