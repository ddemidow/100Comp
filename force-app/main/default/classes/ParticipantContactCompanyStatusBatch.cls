global class ParticipantContactCompanyStatusBatch implements Database.Batchable<sObject>{


global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select Id, G100_Companies_Status__c, (Select Id, Group2__c, probability, Final_Client_Date__c, StageName From 	Membership_Opportunities__r Where Group2__c != null) From Contact Where Id in (Select Participant_Contact__c From Opportunity) ';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Contact> contactList) {
		for(Contact tmpContact : contactList){
		    Map<String, List<Opportunity>> mapGroupToOpportunities = new Map<String, List<Opportunity>>();
		    
		    for(Opportunity opp : tmpContact.Membership_Opportunities__r){
		        if(!mapGroupToOpportunities.containsKey(opp.Group2__c)){
		            mapGroupToOpportunities.put(opp.Group2__c, new List<Opportunity>());
		        }    
			    mapGroupToOpportunities.get(opp.Group2__c).add(opp);
			}
			String companyStatus = '';
			for(String groupName : mapGroupToOpportunities.keyset()){
				String group2 = groupName;
				List<Opportunity> oppties = mapGroupToOpportunities.get(groupName);
				boolean isClient = false;
				boolean isFormerClient = false;
				boolean isProspect = false;
				string result = '';
				for(Opportunity opp :oppties){          
					if(opp.probability == 100 && opp.Final_Client_Date__c >= Date.Today()){     //- Probability = 100, Final Client date >= TODAY then "Group2__c" - Client 
						isClient = true;
					}else if(opp.probability == 100 && opp.Final_Client_Date__c < Date.Today()){  //- Probability = 100, Final Client date < TODAY then "Group2__c" - Former Client
						isFormerClient = true;
					}else if(opp.probability >= 0 && opp.probability < 100 && opp.Final_Client_Date__c > Date.Today() && !opp.stageName.equalsIgnoreCase('Closed/Lost')){   // - Probability > 0 AND Probability < 100, Final_Client_Date__c > TODAY then "Group2__c" - Prospect
						isProspect = true;
					}else{
						continue;   
					}
				}

				if((isClient && isFormerClient && isProspect) || (isClient && isFormerClient) || (isClient && isProspect)){
					result =  group2 + ' - Client';     
				}
				else if(isFormerClient && isProspect){
					result =  group2 + ' - Prospect and Former Client';
				}
				else if(isProspect){
					result =  group2 + ' - Prospect';
				}
				else if(isClient){
					result =  group2 + ' - Client';
				}
				else if(isFormerClient){
					result =  group2 + ' - Former Client';
				}

				if(result != null && result != ''){
					companyStatus += result;
				}
			}
			tmpContact.G100_Companies_Status__c = companyStatus;
    	}
    	update contactList;
	}
	
	global void finish(Database.BatchableContext BC) {
	}

}