public class YearEndReviewTriggerHandler {
    public void YearEndReviewTriggerHandler(){
        
    }
    public void isInsertMethod(List<Year_end_Review__c> newList){
        
         Set<Id> MidYearIds = new Set<Id>();

        for (Year_end_Review__c yrs : newList){
        
            if(yrs.Mid_Year_Review__c!=null)
                MidYearIds.add(yrs.Mid_Year_Review__c);
        }
        
        map<Id,Id> RelatedGoals = new map<Id,Id>();
        if(MidYearIds.size()>0){

            for(Mid_Year_Review__c midyrs : [Select Id, Goal__r.Id from Mid_Year_Review__c where Id IN:MidYearIds]){
                if(!RelatedGoals.containsKey(midyrs.Id) ){
                    RelatedGoals.put(midyrs.Id,midyrs.Goal__r.Id);
                }
            }
        }
                            
       for (Year_end_Review__c yrs : newList){
        system.debug('=======>'+RelatedGoals);
            if(!RelatedGoals.isEmpty() && RelatedGoals.containsKey(yrs.Mid_Year_Review__c))
                yrs.Goal__c = RelatedGoals.get(yrs.Mid_Year_Review__c);
            
        }
        
    }
    
    public void isUpdateMethod(Map<Id,Year_end_Review__c> newMap,Map<Id,Year_end_Review__c> oldMap){
        Set<Id> MidYearIds = new Set<Id>();
        for(Year_end_Review__c  yrs: newMap.values()){
            if(oldMap.get(yrs.Id).Mid_Year_Review__c!=yrs.Mid_Year_Review__c){
                MidYearIds.add(yrs.Mid_Year_Review__c);
            }
        }
        
        map<Id,Id> RelatedGoals = new map<Id,Id>();
        if(MidYearIds.size()>0){

            for(Mid_Year_Review__c midyrs : [Select Id, Goal__r.Id from Mid_Year_Review__c where Id IN:MidYearIds]){
                if(!RelatedGoals.containsKey(midyrs.Id)){
                    RelatedGoals.put(midyrs.Id,midyrs.Goal__r.Id);
                }
            }
            
            
       }

       for(Year_end_Review__c  yrs: newMap.values()){
       system.debug('=======>RelatedGoals Counts===>'+RelatedGoals);
          
           if(RelatedGoals.containsKey(yrs.Mid_Year_Review__c)){
                   system.debug(yrs.Mid_Year_Review__c+'===In ELSE====>'+RelatedGoals);
                   
                  yrs.Goal__c = RelatedGoals.get(yrs.Mid_Year_Review__c);
           }
           system.debug('=======>'+ yrs.Goal__c);
       
       }
        
    }
}