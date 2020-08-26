/************************************************
* Name           : batchOpportunityUpdate
* Creaetd By     : Lokesh Korani
* Created Date   : 25th march 2020
* Story          : S-654715
************************************************/
//START - Commented by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
//global class batchOpportunityUpdate implements Database.Batchable <sObject>,Schedulable{ 
//END - Commented by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
//START - Added by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
global class batchOpportunityUpdate implements Database.Batchable <sObject>,Schedulable, Database.Stateful{ 
    global List<Opportunity> updateOpps = new List<Opportunity>();
    global map<id,Set<String>> mapofAccountIdtoGroup = new map<id,Set<String>>();
    //END - Added by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,StageName, AccountId, Opp12__c,Group2__c, SubGroup__c, Membership_Begins__c, Membership_Expires__c FROM Opportunity ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        System.debug('Scope>>>'+Scope);
        //START - Commented by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
        //List<Opportunity> updateOpps = new List<Opportunity>();
        //map<id,Set<String>> mapofAccountIdtoGroup = new map<id,Set<String>>();
        //END - Commented by Pushpendra |C-00278867 | 11/06/2020 |To resolve case by making batch stateful
        for(Opportunity opp : scope) {
            if(opp.StageName == '100 - Closed/Won' && opp.Group2__c == 'G100 Network' && opp.SubGroup__c != 'Mentore' && opp.SubGroup__c != 'G100 Network Enterprise'
               && opp.Membership_Begins__c <= System.today() && opp.Membership_Expires__c >= System.today()) 
            {   if(mapofAccountIdtoGroup.containsKey(opp.accountID) && !mapofAccountIdtoGroup.get(opp.accountID).contains(opp.SubGroup__c)){
                opp.opp12__C = 1;
                mapofAccountIdtoGroup.get(opp.accountID).add(opp.SubGroup__c);
            }
             else if(!mapofAccountIdtoGroup.containsKey(opp.accountID)){
                 opp.opp12__C = 1;
                 mapofAccountIdtoGroup.put(opp.accountID,new set<string>{opp.SubGroup__c});
             }
             else {opp.opp12__C = 0;}
             updateOpps.add(opp);
                
            } else if((opp.StageName != '100 - Closed/Won' ||opp.Group2__c != 'G100 Network' || opp.SubGroup__c == 'Mentore' || opp.SubGroup__c == 'G100 Network Enterprise'
                      || opp.Membership_Begins__c > System.today() || opp.Membership_Expires__c < System.today()) && opp.opp12__C == 1)  
            {
                opp.opp12__C = 0;
                updateOpps.add(opp); 
            }
        }
        if(updateOpps.size() > 0) {
        //START - Modified by Mohit |C-00279213 | 7/03/2020 |Remove failing records    
            database.update(updateOpps,false);
        //End - Modified by Mohit |C-00279213 | 7/03/2020 |Remove failing records    
        }    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        batchOpportunityUpdate b = new batchOpportunityUpdate(); 
        database.executebatch(b, 50);
    }
}