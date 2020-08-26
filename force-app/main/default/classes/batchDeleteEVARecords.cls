/** @author : Paras Dhingra(Appirio)
  * @Created Date : 6/4/2015
  * @Description : Cleaning up EVA Records to save Data Storage 
  * @Story : S-306218
*/
global class batchDeleteEVARecords implements Database.Batchable<sObject> {
	
	public String query{get;set;}
	
	global batchDeleteEVARecords() {
		
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(query!=null && query!=''){

		}
		else{
			query = 'Select id from  pse__Est_Vs_Actuals__c  where '+
			'pse__Resource__r.pse__Region__r.Name LIKE \'High%\''+
			'OR pse__Resource__r.pse__Region__r.Name LIKE \'%Miles%\''+
			'OR pse__Resource__r.pse__Region__r.Name LIKE \'G100%\'' + 
			'OR ('+
			'(pse__Resource__r.pse__Region__r.Name LIKE \'SSA%\' ' +
			'OR pse__Resource__r.pse__Region__r.Name LIKE \'CEO%\')'+
			'AND pse__Resource__r.pse__Exclude_from_Resource_Planner__c = TRUE)' +
			' OR pse__Assignment__r.pse__Exclude_from_Planners__c = TRUE'; /*pse__Resource__r.pse__Region__r.Name LIKE 'High%'
			OR pse__Resource__r.pse__Region__r.Name LIKE '%Miles%'
		        OR pse__Resource__r.pse__Region__r.Name LIKE 'G100%' 
			OR (
			(pse__Resource__r.pse__Region__r.Name LIKE 'SSA%'
			OR pse__Resource__r.pse__Region__r.Name LIKE 'CEO%')
			AND pse__Resource__r.pse__Exclude_from_Resource_Planner__c = TRUE)
			OR pse__Assignment__r.pse__Exclude_from_Planners__c = TRUE*/

		}
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Database.delete(scope,false);
	
	}
	
	global void finish(Database.BatchableContext BC) {
	}
	
}