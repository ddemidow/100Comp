/**
 *  Purpose         :   This class is used to E-Mail alerts to notify users when an open opportunity reachs the following ages:
 *							(1) G100 Opportunties: 186 Days
 *							(2) NGL Opportunities: 56 Days
 *							(3) Next Opportunities: 252 Days
 *							(4) TC Opportunities: 181 Days
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   02/23/2016
 *
 *  Current Version :   V_1.0
 *
 *  Revision Log    :   V_1.0 - Created - S-374199
 **/
global class Batch_OpportunityAgeAlerts implements Database.Batchable<sObject>, Database.Stateful{

	//Class Properties
    //String to hold Notification Type
    global Integer notificationType;
    global Static Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE Name =: Constants.USER_NAME_COURTNEY_HEHRE AND IsActive = true]);
    global Static String notifyUserId = mapUsers.size() > 0 ? String.valueOf((new List<Id>(mapUsers.keyset()))[0]) : ''; //Modified By Arihant for CASE#00222502

	//Instance of Email Alert Default
	global Email_Alert_Default__c configDefault;

    //Constructor defintion
    global Batch_OpportunityAgeAlerts(Integer notificationType) {

        //assign from local variable to global varialbe
        this.notificationType = notificationType;
    }

    //Start method definition of Batchable interface abstract method
    global Database.QueryLocator start(Database.BatchableContext BC) {

    	//Check for notification counter
        if(notificationType == 1) {

			//Check for already contained key
			if(Email_Alert_Default__c.getAll().containsKey(Constants.OPPROTUNITY_SUBGROUP_G100)) {

				//getting instance
				configDefault = Email_Alert_Default__c.getAll().get(Constants.OPPROTUNITY_SUBGROUP_G100);
			}

			//Getting query result from Opportuntiy sobject for G100 Opportunties: 186 Days
            return Database.getQueryLocator([SELECT Id, OwnerId, SubGroup__c, Name, Owner.Name, StageName, CloseDate FROM Opportunity
            									WHERE IsClosed = false AND Age_Custom__c =: configDefault.Age__c
            									//Added for S-420591
            									AND Renewal__c = false
            									//end S-420591
            									AND (OwnerId =: notifyUserId OR SubGroup__c =: Constants.OPPROTUNITY_SUBGROUP_G100)]);
        } else if(notificationType == 2) {

			//Check for already contained key
			if(Email_Alert_Default__c.getAll().containsKey(Constants.OPPROTUNITY_SUBGROUP_NGL)) {
				configDefault = Email_Alert_Default__c.getAll().get(Constants.OPPROTUNITY_SUBGROUP_NGL);
			}

			//Getting query result from Opportuntiy sobject for NGL Opportunities: 56 Days
            return Database.getQueryLocator([SELECT Id, OwnerId, SubGroup__c, Name, Owner.Name, StageName, CloseDate FROM Opportunity
            									WHERE IsClosed = false AND Age_Custom__c =: configDefault.Age__c
            									//Added for S-420591
            									AND Renewal__c = false
            									//end S-420591
            									AND (OwnerId =: notifyUserId OR SubGroup__c =: Constants.OPPROTUNITY_SUBGROUP_NGL)]);
        } else if(notificationType == 3) {

			//Check for already contained key
			if(Email_Alert_Default__c.getAll().containsKey(Constants.OPPROTUNITY_SUBGROUP_NEXT)) {
				configDefault = Email_Alert_Default__c.getAll().get(Constants.OPPROTUNITY_SUBGROUP_NEXT);
			}

            //Getting query result from Opportuntiy sobject for Next Opportunities: 252 Days
            return Database.getQueryLocator([SELECT Id, OwnerId, SubGroup__c, Name, Owner.Name, StageName, CloseDate FROM Opportunity
            									WHERE IsClosed = false AND Age_Custom__c =: configDefault.Age__c
            									//Added for S-420591
            									AND Renewal__c = false
            									//end S-420591
            									AND (OwnerId =: notifyUserId OR SubGroup__c =: Constants.OPPROTUNITY_SUBGROUP_NEXT)]);
        } else {

			//Check for already contained key
			if(Email_Alert_Default__c.getAll().containsKey(Constants.OPPROTUNITY_SUBGROUP_TC)) {
				configDefault = Email_Alert_Default__c.getAll().get(Constants.OPPROTUNITY_SUBGROUP_TC);
			}

            //Getting query result from Opportuntiy sobject for TC Opportunities: 181 Days
            return Database.getQueryLocator([SELECT Id, OwnerId, SubGroup__c, Name, Owner.Name, StageName, CloseDate FROM Opportunity
            									WHERE IsClosed = false AND Age_Custom__c =: configDefault.Age__c
            									//Added for S-420591
            									AND Renewal__c = false
            									//end S-420591
            									AND (OwnerId =: notifyUserId OR SubGroup__c =: Constants.OPPROTUNITY_SUBGROUP_TC)]);
        }
    }

    //Execute method definition of Batchable interface abstract method
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

		//Map to hold Unique key and List of Opportunities
		Map<String, List<Opportunity>> mapOppsWithRecipient = new Map<String, List<Opportunity>>();

		//String of default unique key for Courtney user
		String courtneyHandler = 'Courtney,Default,'
									+ (mapUsers.containsKey(notifyUserId) && String.isNotBlank(mapUsers.get(notifyUserId).Email) ? mapUsers.get(notifyUserId).Email : '');

		//Check for notification counter
        if(notificationType == 1) {

			//String of default unique key for G100
			String uniqueKey = configDefault != null ? configDefault.FirstName__c + ',' + configDefault.Name + ',' + configDefault.Email__c + ',' + configDefault.Duration__c
								: '';

			//Loop through scope variable
			for(Opportunity opportunity : scope) {

				//Check for not null or blank and verify for OwnerId
				if(String.isNotBlank(notifyUserId) && opportunity.ownerId.equals(notifyUserId)) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(courtneyHandler)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(courtneyHandler, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(courtneyHandler).add(opportunity);
				} else if(opportunity.SubGroup__c == Constants.OPPROTUNITY_SUBGROUP_G100 && configDefault != null) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(uniqueKey)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(uniqueKey, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(uniqueKey).add(opportunity);
				}
			}
		} else if(notificationType == 2) {

			String uniqueKey = configDefault != null ? configDefault.FirstName__c + ',' + configDefault.Name + ',' + configDefault.Email__c + ',' + configDefault.Duration__c
								: '';

            //Loop through scope variable
			for(Opportunity opportunity : scope) {

				//Check for not null or blank and verify for OwnerId
				if(String.isNotBlank(notifyUserId) && opportunity.ownerId.equals(notifyUserId)) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(courtneyHandler)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(courtneyHandler, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(courtneyHandler).add(opportunity);
				} else if(opportunity.SubGroup__c == Constants.OPPROTUNITY_SUBGROUP_NGL && configDefault != null) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(uniqueKey)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(uniqueKey, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(uniqueKey).add(opportunity);
				}
			}
        } else if(notificationType == 3) {

			String uniqueKey = configDefault != null ? configDefault.FirstName__c + ',' + configDefault.Name + ',' + configDefault.Email__c + ',' + configDefault.Duration__c
								: '';

			//Loop through scope variable
			for(Opportunity opportunity : scope) {

				//Check for not null or blank and verify for OwnerId
				if(String.isNotBlank(notifyUserId) && opportunity.ownerId.equals(notifyUserId)) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(courtneyHandler)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(courtneyHandler, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(courtneyHandler).add(opportunity);
				} else if(opportunity.SubGroup__c == Constants.OPPROTUNITY_SUBGROUP_NEXT && configDefault != null) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(uniqueKey)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(uniqueKey, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(uniqueKey).add(opportunity);
				}
			}
        } else {

			String uniqueKey = configDefault != null ? configDefault.FirstName__c + ',' + configDefault.Name + ',' + configDefault.Email__c + ',' + configDefault.Duration__c
								: '';

            //Loop through scope variable
			for(Opportunity opportunity : scope) {

				//Check for not null or blank and verify for OwnerId
				if(String.isNotBlank(notifyUserId) && opportunity.ownerId.equals(notifyUserId)) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(courtneyHandler)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(courtneyHandler, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(courtneyHandler).add(opportunity);
				} else if(opportunity.SubGroup__c == Constants.OPPROTUNITY_SUBGROUP_TC && configDefault != null) {

					//Check for not having unique keyword as map's key
					if(!mapOppsWithRecipient.containsKey(uniqueKey)) {

						//populate map with blank Opportunity list
						mapOppsWithRecipient.put(uniqueKey, new List<Opportunity>());
					}

					//adding element in map's key value pair
					mapOppsWithRecipient.get(uniqueKey).add(opportunity);
				}
			}
        }

        System.debug('mapOppsWithRecipient :::'+  mapOppsWithRecipient);

        //Check for size of map
        if(mapOppsWithRecipient.size() > 0) {

        	//Call Email Body generator's method to get email messages
        	List<Messaging.SingleEmailMessage> emailMessages = OpportunityAgeAlertsEmailGenerator.getOppsMedianAgeEmailBody(mapOppsWithRecipient);

        	System.debug('emailMessages :::'+  emailMessages);
        	//Check for size of list
        	if(emailMessages.size() > 0) {
        		Messaging.sendEmail(emailMessages);
        	}
        }
    }

    //Finish method definition of Batchable interface abstract method
    global void finish(Database.BatchableContext BC) {

    	System.debug('notificationType :::'+ notificationType);

        //Initialize Batch process again for next tasks
        Batch_OpportunityAgeAlerts batchProcess = notificationType == 1 ? new Batch_OpportunityAgeAlerts(2)
        											: notificationType == 2 ? new Batch_OpportunityAgeAlerts(3)
        											: notificationType == 3 ? new Batch_OpportunityAgeAlerts(4) : null;

        if(batchProcess != null)
            //Execute the batch to delete the orphan Report Balances
            Database.executeBatch(batchProcess, 200);
    }
}