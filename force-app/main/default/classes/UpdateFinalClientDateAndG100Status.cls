/*********************************************************************************
Name : Arihant Jain (CASE#00223036)
Created By : Appirio 
Created Date : 15 March 2018
Purpose : Batch to update the incorrect data that was caused by the code not 
		  working correctly developed under the S-429731

*********************************************************************************/
global class UpdateFinalClientDateAndG100Status implements Database.Batchable<sObject> {
    public static boolean isbatchrunning = false;
    public String query;
    global UpdateFinalClientDateAndG100Status (String Query){
    	this.query = Query;   
    }
    global UpdateFinalClientDateAndG100Status (){
    	this.query = '';   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        isbatchrunning = true;
        String q = 'SELECT Id,Name, accountId, CloseDate, Probability, StageName, Final_Client_Date__c, Membership_Expires__c, Revenue_Recognition_Begins__c, Revenue_Recognition_Ends__c, Revenue_Recognition_3__c FROM Opportunity';
        if(query != null && !String.isBlank( query ))
        	return Database.getQueryLocator(query);
        else 
            return Database.getQueryLocator(q);
    }
     
    global void execute(Database.BatchableContext BC, List<Opportunity> opplist) {
        set<Id> accountIds = new set<Id>();
        for(Opportunity opp : opplist){
            accountIds.add(opp.accountId);
        }
        
        List<Opportunity> oppTOProcess = [SELECT Id,Name, accountId, CloseDate, Probability, StageName, Final_Client_Date__c, Membership_Expires__c, Revenue_Recognition_Begins__c, Revenue_Recognition_Ends__c, Revenue_Recognition_3__c FROM Opportunity where AccountId In: accountIds];
        
        // process each batch of records
        String VAN_GUARD_OPPTIES_EXCLUDE = 'Vanguard Forum - HLG';
        map<Id,pse__Proj__c> opptyToLatestProjMap = new map<Id,pse__Proj__c>();
        for(pse__Proj__c proj :[select pse__Opportunity__c, pse__End_Date__c from pse__Proj__c where pse__Opportunity__c in:oppTOProcess and pse__End_Date__c != null order by pse__End_Date__c desc]){
            if(!opptyToLatestProjMap.containsKey(proj.pse__Opportunity__c))
                opptyToLatestProjMap.put(proj.pse__Opportunity__c, proj);
            else
                continue;
        }
        
      	List<Opportunity> opptiesToBeUpdated = new List<Opportunity>();
		map<Id, map<string,List<Opportunity>>> accountToOpptyMap = new map<Id, map<string,List<Opportunity>>>();
   		List<Account> accountsToBeUpdated = new List<Account>();
    	 
        for(Opportunity opp : oppTOProcess){
         	  
           	  // Logic to Update the FinalClientDate on the Opportunity
         	  set<Date> datesToBeProcessed = OpportunityTriggerHandler.getDateSet(opp);                                     
              if(opptyToLatestProjMap.containsKey(opp.id))
              	datesToBeProcessed.add(opptyToLatestProjMap.get(opp.id).pse__End_Date__c);
              system.debug('****datesToBeProcessed  = '+datesToBeProcessed);
              if(datesToBeProcessed.size() > 0){
                OpportunityTriggerHandler.populateLatestDateOnOppty(datesToBeProcessed, opp);
           	    opptiesToBeUpdated.add(opp); 
              }
              
       	}
        
        try{
            if(opptiesToBeUpdated.size() > 0)
            update opptiesToBeUpdated;
        }
        catch(Exception e) {
            System.debug(e);
        }
        
        // Logic to Update the Status on Account Related to Opportunity
        for(Opportunity opp :[select Group2__c, Participant_Contact__c, Final_Client_Date__c, Probability, CloseDate, StageName, accountId
                            from Opportunity
                            where accountId in:accountIds and Group2__c != null and Group2__c !=:VAN_GUARD_OPPTIES_EXCLUDE]){

        if(accountToOpptyMap.containsKey(opp.accountId) && accountIds.contains(opp.AccountId)){
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
                string res = OpportunityTriggerHandler.getCompanyStatusString(group2,accountToOpptyMap.get(accId).get(group2));
                if(res != '')
                    companyStatusString += res + ', ';
            }
            
            companyStatusString = companyStatusString.removeEnd(', ');
            Account acc = new Account(Id = accId, G100_Companies_Status__c = companyStatusString);
            accountsToBeUpdated.add(acc);
         }
      }
    
        try{
            if(accountsToBeUpdated.size() > 0)
        	update accountsToBeUpdated;
        }
        catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}