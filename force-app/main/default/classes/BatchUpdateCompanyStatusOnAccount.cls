/*******************************
Author      :Appirio India [Hitesh Pareek]
Date        :Sept 15, 2016
Purpose     :S-438975
*******************************/
global class BatchUpdateCompanyStatusOnAccount implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select G100_Companies_Status__c from Account';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        map<Id, map<string,List<Opportunity>>> accountToOpptyMap = new map<Id, map<string,List<Opportunity>>>();
        List<Account> accountsToBeUpdated = new List<Account>();
        set<Id> accountIds = new set<Id>();         
        for(Account acc :(List<Account>)scope){
            accountIds.add(acc.id);
        }
            for(Opportunity opp :[select Group2__c, Final_Client_Date__c, Probability, CloseDate, StageName, accountId
                                from Opportunity
                                where accountId in:accountIds and Group2__c != null]){
            if(accountToOpptyMap.containsKey(opp.accountId)){
                map<string,List<Opportunity>> groupToOpptyMap_temp = accountToOpptyMap.get(opp.accountId);
                if(groupToOpptyMap_temp.containsKey(opp.Group2__c))
                    groupToOpptyMap_temp.get(opp.Group2__c).add(opp);
                else
                    groupToOpptyMap_temp.put(opp.Group2__c, new List<Opportunity>{opp});
                            
            }else{
                map<string,List<Opportunity>> groupToOpptyMap = new map<string,List<Opportunity>>();
                groupToOpptyMap.put(opp.Group2__c, new List<Opportunity>{opp});
                accountToOpptyMap.put(opp.accountId, groupToOpptyMap);
            }
        }
        
        if(!accountToOpptyMap.isEmpty()){
            for(Id accId :accountToOpptyMap.keySet()){
                string companyStatusString = '';
                for(string group2 :accountToOpptyMap.get(accId).keySet()){
                    string res = getCompanyStatusString(group2,accountToOpptyMap.get(accId).get(group2));
                    if(res != '')
                        companyStatusString += res + ',';
                }
                
                companyStatusString = companyStatusString.removeEnd(',');
                if(companyStatusString != null && companyStatusString != ''){
                    Account acc = new Account(Id = accId, G100_Companies_Status__c = companyStatusString);
                    accountsToBeUpdated.add(acc);
                }
            }
        }
        
        if(accountsToBeUpdated.size() > 0)        
        Database.saveResult[] saveResults = Database.update(accountsToBeUpdated, false);
    }             
  
  private string getCompanyStatusString(string group2, List<Opportunity> oppties){
    boolean isClient = false;
    boolean isFormerClient = false;
    boolean isProspect = false;
    string result = '';
    for(Opportunity opp :oppties){          
        if(opp.Final_Client_Date__c != null && opp.probability == 100 && opp.Final_Client_Date__c >= Date.Today()){     //- Probability = 100, Final Client date >= TODAY then "Group2__c" - Client 
            isClient = true;
        }else if(opp.Final_Client_Date__c != null && opp.probability == 100 && opp.Final_Client_Date__c < Date.Today()){  //- Probability = 100, Final Client date < TODAY then "Group2__c" - Former Client
            isFormerClient = true;
        }else if(opp.closeDate != null && opp.probability >= 0 && opp.probability < 100 && opp.Final_Client_Date__c > Date.Today() && !opp.stageName.equalsIgnoreCase('Closed/Lost')){   // - Probability > 0 AND Probability < 100, Close Date > TODAY then "Group2__c" - Prospect
            isProspect = true;
        }else
            continue;   
    }
    
    if((isClient && isFormerClient && isProspect) || (isClient && isFormerClient) || (isClient && isProspect))
        result =  group2 + ' - Client';     
    else if(isFormerClient && isProspect)
        result =  group2 + ' - Prospect and Former Client';
    else if(isProspect)
        result =  group2 + ' - Prospect';
    else if(isClient)
        result =  group2 + ' - Client';
    else if(isFormerClient)
        result =  group2 + ' - Former Client';
        
    return result;
  }
    
    global void finish(Database.BatchableContext BC){
   }
}