/*
 * Appirio, Inc
 * Name: BatchUpdateHistoricalOpportunityDesc
 * Description: [S-589952]
 * Created Date: 15 Nov 2018
 * Created By: Jai Gupta (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 */
 global class BatchUpdateHistoricalOpportunityDesc implements Database.Batchable<sObject> {
	
	public String query = '';
	String fieldLabel = 'Description' ;
	String fieldName = 'Description__c' ;
	String separator = '-----------------------------------------------------------------------------------------------------------------';
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isBlank(query)) {
			query = 'SELECT Id,Opportunity_History_c__c,History_Data_Created__c from Opportunity where History_Data_Created__c = false' ;
		}

		if(Test.isRunningTest()) {
			query += ' LIMIT 1 ' ;
		}
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
		   // Parse Opportunity_History_c__c field
		   // Create OpportunityHistory__c object records
		   // Update History_Data_Created__c field to true on Opportunity (so these records are not picked up in case of failure)
			Set<String> lastModifiedUserAlias = new Set<String>();
			List<OpportunityHistoryWrapper> oppHistoryWrapperList = new List<OpportunityHistoryWrapper>();
			List<Opportunity> oppListToupdate = new List<Opportunity>();
			for(Opportunity opp : scope) {
				if(String.isNotBlank(opp.Opportunity_History_c__c)) {
					List<String> historyvalues = opp.Opportunity_History_c__c.split(separator);
					system.debug(historyvalues.size()+'-------historyvalues---'+historyvalues);
					for(String str : historyvalues) {
						List<String> s = str.trim().split('\n');
						if(s.size() >= 3) {
							oppHistoryWrapperList.add(new OpportunityHistoryWrapper(s[0].trim(),s[1].trim(),opp.Id,s[2].trim()));
							system.debug('---------s2-----'+s[2].trim());
							lastModifiedUserAlias.add(s[0].trim());
						}
						
				   	}
			   	}
			   	opp.History_Data_Created__c = true ;
				oppListToupdate.add(opp);
		   	}
			
			if(lastModifiedUserAlias.size() > 0) {
				Map<String,id> userDetails = new Map<String,id>();
				for(User u : [Select Id, alias from user where alias IN :lastModifiedUserAlias ]) {
					userDetails.put(u.alias,u.id);
				}

				if(userDetails.size() > 0) {
					List<OpportunityHistory__c> oppHistoryToBeCreated = new List<OpportunityHistory__c>();
					for(OpportunityHistoryWrapper ohw: oppHistoryWrapperList) {
						OpportunityHistory__c oh = new OpportunityHistory__c();
						oh.Name = fieldLabel; // Field Label
                        oh.Field_API_Name__c   = fieldName;
                        oh.Opportunity__c = ohw.parentOppId ;
                        oh.Old_Value__c  = '' ;
                        oh.New_Value__c  = ohw.descNewVal;
						oh.Edited_by__c  = userDetails.get(ohw.userAlias);
                        oh.Edited_Date__c  = ohw.lastmodifieddate ;
						oppHistoryToBeCreated.add(oh);
					}
					if(oppHistoryToBeCreated.size() > 0) {
						system.debug('---------'+oppHistoryToBeCreated);
						insert oppHistoryToBeCreated ;
						update oppListToupdate ;
					}
				}
				
			}
			
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	public class OpportunityHistoryWrapper {
		public string userAlias ;
		public datetime lastmodifieddate ;
		public id parentOppId ;
		public string descNewVal ;

		public OpportunityHistoryWrapper(string ua, string lmd, id parentId, string desnewval) {
			userAlias = ua ;
			lastmodifieddate = Datetime.valueOfGmt(lmd);
			parentOppId = parentId;
			descNewVal = desnewval ;
		}
	}
}