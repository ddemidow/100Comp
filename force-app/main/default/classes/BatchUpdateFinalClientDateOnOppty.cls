/*******************************
Author      :Appirio India [Hitesh Pareek]
Date        :Sept 15, 2016
Purpose     :S-438975
*******************************/
global class BatchUpdateFinalClientDateOnOppty implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select CloseDate, Final_Client_Date__c, Membership_Expires__c, Revenue_Recognition_Begins__c, Revenue_Recognition_Ends__c, Revenue_Recognition_3__c from Opportunity';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Opportunity> currentOppties = (List<Opportunity>)scope;
        List<Opportunity> opptiesToBeUpdated = new List<Opportunity>();     
        
        //get opportunity's projects latest date 
        map<Id,pse__Proj__c> opptyToLatestProjMap = new map<Id,pse__Proj__c>();
        for(pse__Proj__c proj :[select pse__Opportunity__c, pse__End_Date__c from pse__Proj__c where pse__Opportunity__c in:currentOppties and pse__End_Date__c != null order by pse__End_Date__c desc]){
            if(!opptyToLatestProjMap.containsKey(proj.pse__Opportunity__c))
                opptyToLatestProjMap.put(proj.pse__Opportunity__c, proj);
            else
                continue;
        }
        
        for(Opportunity opp :currentOppties){           
            set<Date> datesToBeProcessed = getDateSet(opp);
            if(opptyToLatestProjMap.containsKey(opp.id))
                datesToBeProcessed.add(opptyToLatestProjMap.get(opp.id).pse__End_Date__c);
            if(datesToBeProcessed.size() > 0){
                populateLatestDateOnOppty(datesToBeProcessed, opp);
                opptiesToBeUpdated.add(opp);
            }
        }
        
        if(opptiesToBeUpdated.size() > 0)            
            Database.saveResult[] updateResult = Database.update(opptiesToBeUpdated, false);                    
    }
    
    private set<date> getDateSet(Opportunity opp){
    set<Date> dates = new set<Date>();
      if(opp.Membership_Expires__c != null)
          dates.add(opp.Membership_Expires__c);
      if(opp.Revenue_Recognition_Begins__c != null)
          dates.add(opp.Revenue_Recognition_Begins__c);
      if(opp.Revenue_Recognition_Ends__c != null)
          dates.add(opp.Revenue_Recognition_Ends__c );
      if(opp.Revenue_Recognition_3__c != null)
          dates.add(opp.Revenue_Recognition_3__c);
      if(opp.CloseDate != null)
          dates.add(opp.CloseDate);
      return dates;
  }
  
  public void populateLatestDateOnOppty(set<Date> dateSet, Opportunity targetOpp){
         
     map<Date, integer> earliestDateMap = new map<Date, integer>();
      
      for(Date d :dateSet){
        system.debug('****current date = '+d);
          if(!earliestDateMap.isEmpty()){
            system.debug('****Date.Today().DaysBetween(d) = '+Date.Today().DaysBetween(d));
              if(earliestDateMap.values().get(0) < Date.Today().DaysBetween(d)){
                //clear map and put new date 
                earliestDateMap.clear();
                earliestDateMap.put(d, Date.Today().DaysBetween(d));
              }              
          }else{
              earliestDateMap.put(d, Date.Today().DaysBetween(d));
          }
      }
      system.debug('**** earliestDateMap = '+earliestDateMap);
      if(!earliestDateMap.isEmpty()){
          for(Date d :earliestDateMap.keySet()){
              targetOpp.Final_Client_Date__c = d;
              break;
          }                   
      }
  }    
    
    global void finish(Database.BatchableContext BC){
   }
}