/*******************************
Author		:Appirio India [Hitesh Pareek]
Date 		:Sept 14, 2016
Purpose		:S-429731
*******************************/
public without sharing class ClickLinkProjectTriggerHandler {
    public static void updateOpportunitiyforProject(List<pse__proj__c> newProjects){
    	List<Opportunity> opptiesToBeUpdated = new List<Opportunity>();
    	map<Id,List<pse__proj__c>> opptyToProjectMap = new map<Id,List<pse__proj__c>>();
    	map<Id,Opportunity> opptyMap = new map<Id,Opportunity>();
    	for(pse__proj__c proj :[select pse__End_Date__c,pse__Opportunity__r.CloseDate,pse__Opportunity__r.Membership_Expires__c, pse__Opportunity__r.Revenue_Recognition_Begins__c, pse__Opportunity__r.Revenue_Recognition_Ends__c, pse__Opportunity__r.Revenue_Recognition_3__c
    							from pse__proj__c
    							where id in:newProjects and pse__Opportunity__c != null]){
    		Opportunity opp = new Opportunity(id=proj.pse__Opportunity__c,
    											CloseDate = proj.pse__Opportunity__r.CloseDate, 
    											Membership_Expires__c = proj.pse__Opportunity__r.Membership_Expires__c,
    											Revenue_Recognition_Begins__c = proj.pse__Opportunity__r.Revenue_Recognition_Begins__c,
    											Revenue_Recognition_Ends__c = proj.pse__Opportunity__r.Revenue_Recognition_Ends__c,
    											Revenue_Recognition_3__c = proj.pse__Opportunity__r.Revenue_Recognition_3__c);    		
    		opptyMap.put(proj.pse__Opportunity__c, opp);
    		if(opptyToProjectMap.containsKey(proj.pse__Opportunity__c))
    			opptyToProjectMap.get(proj.pse__Opportunity__c).add(proj);
    		else
    			opptyToProjectMap.put(proj.pse__Opportunity__c, new List<pse__proj__c>{proj});
    	}
    	    	
    	for(Id oppId :opptyToProjectMap.keySet()){
    		Opportunity oppTemp = opptyMap.get(oppId);
    		set<Date> dateSet = OpportunityTriggerHandler.getDateSet(oppTemp);
    		for(pse__proj__c proj :opptyToProjectMap.get(oppId)){
    			if(proj.pse__End_Date__c != null)
    				dateSet.add(proj.pse__End_Date__c);
    		}
    		OpportunityTriggerHandler.populateLatestDateOnOppty(dateSet,oppTemp);
    		opptiesToBeUpdated.add(oppTemp);
    	}
    	
    	if(opptiesToBeUpdated.size() > 0)
    		update opptiesToBeUpdated;
    }
}