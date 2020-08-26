// 
// (c) 2015 Appirio, Inc.
//
// Schedules the PaymentDateOnOpportunity batch
//
// 19 Aug 2015     Nick Sharp      Original    S-339373
//  3 Nov 2015     Nick Sharp      Modified    CASE 00138056 
//
global class PaymentDateOnOpportunityBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global PaymentDateOnOpportunityBatch() {
		//query for sales invoice records
		if(!Test.isRunningTest()){
			query = 'SELECT Id,c2g__Opportunity__c,c2g__InvoiceDate__c,Paid_Date__c,c2g__Opportunity__r.AccountId,c2g__Opportunity__r.Invoice_Date__c, c2g__Opportunity__r.Payment_Date__c, c2g__Opportunity__r.StageName,c2g__Opportunity__r.Group2__c,c2g__Opportunity__r.Company__c,c2g__Opportunity__r.Participant_Contact__c, c2g__PaymentStatus__c, c2g__MatchType__c FROM c2g__codaInvoice__c WHERE c2g__Opportunity__r.Group2__c = \'G100 Network\' AND c2g__Opportunity__r.StageName = \'75 - Member Invoice\' AND c2g__MatchType__c != \'Credited\' AND c2g__PaymentStatus__c =\'Paid\'';
		}
		else{
			query = 'SELECT Id,c2g__Opportunity__c,c2g__InvoiceDate__c,Paid_Date__c,c2g__Opportunity__r.AccountId, c2g__Opportunity__r.Invoice_Date__c,c2g__Opportunity__r.Payment_Date__c, c2g__Opportunity__r.StageName,c2g__Opportunity__r.Group2__c,c2g__Opportunity__r.Company__c,c2g__Opportunity__r.Participant_Contact__c, c2g__PaymentStatus__c, c2g__MatchType__c FROM c2g__codaInvoice__c WHERE c2g__Opportunity__r.Group2__c = \'G100 Network\' AND c2g__Opportunity__r.StageName = \'75 - Member Invoice\' AND c2g__MatchType__c != \'Credited\' AND c2g__PaymentStatus__c =\'Paid\' LIMIT 1';
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> scope) {
   		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		List<c2g__codaCompany__c> validCompanies = new List<c2g__codaCompany__c>([SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'G100 Inc.' OR Name = 'G100 Network, LLC']);
		List<Id> relatedAccounts = new List<Id>();
		List<Id> currentOpportunities = new List<Id>();
		Map<Id, c2g__codaInvoice__c> invoiceMap = new Map<Id, c2g__codaInvoice__c>();

		for(c2g__codaInvoice__c s: scope){
			if(s.c2g__Opportunity__c != null){
				if(invoiceMap.containsKey(s.c2g__Opportunity__c)){
					if(invoiceMap.get(s.c2g__Opportunity__c).Paid_Date__c < s.Paid_Date__c){
						invoiceMap.put(s.c2g__Opportunity__c, s);
					}
					else{
						break;
					}
				}
				else{
					invoiceMap.put(s.c2g__Opportunity__c, s);
				}
			}
		}

		for(c2g__codaInvoice__c c: invoiceMap.values()){
			if(c.c2g__Opportunity__r.Invoice_Date__c == null){
				c.c2g__Opportunity__r.Invoice_Date__c = invoiceMap.get(c.c2g__Opportunity__c).c2g__InvoiceDate__c;
			}
			c.c2g__Opportunity__r.StageName = '100 - Invoice Paid';
			c.c2g__Opportunity__r.Payment_Date__c = invoiceMap.get(c.c2g__Opportunity__c).Paid_Date__c;
			oppsToUpdate.add(c.c2g__Opportunity__r);
			relatedAccounts.add(c.c2g__Opportunity__r.AccountId);
			currentOpportunities.add(c.c2g__Opportunity__c);
		}
		
		if(!oppsToUpdate.isEmpty()){
			update oppsToUpdate;
		}


		//search for existing contact
		List<Opportunity> updatedOpportunities = new List<Opportunity>([SELECT Id, AccountId, Participant_Contact__c,Participant_Contact__r.FirstName, Participant_Contact__r.LastName FROM Opportunity WHERE Id IN: currentOpportunities]);
		List<Contact> existingContacts = new List<Contact>([SELECT Id, AccountId FROM Contact WHERE AccountId IN: relatedAccounts]);
		
		//START NSHARP CASE 00138056 11.2.2015
		Set<Contact> contactRoles = new Set<Contact>();
		//END NSHARP CASE 00138056 11.2.2015
		//create a new contact role record
		for(Opportunity o: updatedOpportunities){
			for(Contact c: existingContacts){
				if(o.AccountId == c.AccountId){
					break;
				}
				else{
					if(o.Participant_Contact__c != null){
						o.Participant_Contact__r.AccountId = o.AccountId;
						//START NSHARP CASE 00138056 11.2.2015
						//contactRolesToInsert.add(o.Participant_Contact__r);
						contactRoles.add(o.Participant_Contact__r);
						//END NSHARP CASE 00138056 11.2.2015
					}
				}
			}
		}
		//START NSHARP CASE 00138056 11.2.2015
		List<Contact> contactRolesToInsert = new List<Contact>(contactRoles);
		//END NSHARP CASE 00138056 11.2.2015
		if(!contactRolesToInsert.isEmpty()){
			update contactRolesToInsert;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}