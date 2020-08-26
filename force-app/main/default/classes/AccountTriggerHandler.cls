// Created by Shashank Singhal for Case no. 00091435 on 05-08-2014
/*
	Name					History			Author			Date			Description
-------------------------------------------------------------------------------------------------------------------------------------------------------
AccountTriggerHandler		Created		Shashank Singhal	5-8-2014		This is a helper class for Account Trigger. This helper class is used to
																			update the Account_Name__c on the associtaed Contacts if the Account Name is 
																			modified.
AccountTriggerHandler		Modified    Paras Dhingra		6-5-2015		Added a method to prevent unauthorized merge of Vendor Accounts. Story S-311626
*/
public class AccountTriggerHandler {
	
	/*
		Method Name: onAfterUpdateofAccount
		Parameters : Map<id, Account>, Map<Id, Account>
		Return Type: Void
		Description: This method check if the name of the account is modified. If it is modified then Account_Name__c
					 Field is updated on all the associated contacts.
	*/
	public static void onAfterUpdateofAccount(Map<Id, Account> oldMap, Map<Id, Account> newMap)
	{
		// Local variable declaration
		set<string> accIds = new set<string>();
		List<Contact> contactsToUpdate = new List<Contact>();
		
		// Iterate over all the accounts which are updated
		for(Account acc:newMap.Values())
		{
			// if the account name is modified
			if(acc.Name <> oldMap.get(acc.id).Name)
			{
				// add account Ids to set
				accIds.add(acc.Id);
			}
		}
		
		// if set is not empty
		If(!accIds.isEmpty())
		{
			// fetch name and associated contacts for accounts where name is changed and iterate over them
			for(Account acc : [Select Id, Name, (Select Id, Account_Name__c from Contacts) from Account where Id IN:accIds])
			{
				// iterate over the associated contacts
				for(Contact con:acc.Contacts)
				{
					// if account_name__c is not equal to name of the account
					if(con.Account_Name__c <> acc.Name)
					{
						// assign the name of the account to the account_name__c field
						con.Account_Name__c = acc.Name;
						contactsToUpdate.add(con);
					}
				}
			}
		}
		
		// if contact list to update is not empty 
		if(!contactsToUpdate.isEmpty())
		{
			// update the contacts
			update contactsToUpdate;
		}
	}
	
	/*
		Method Name: onAfterDeleteofAccount
		Parameters : Map<id, Account>
		Return Type: Void
		Description: This method check for the merged accounts and updates the Account_Name__c in the 
					 Contacts associated to the master record.
	*/
	public static void onAfterDeleteofAccount(Map<Id, Account> oldMap)
	{
		// Local variable declaration
		set<string> masterAccountIds = new set<string>();
		List<Contact> contactsToUpdate = new List<Contact>();
		
		/* Story S-311626 #Start Fetch the current UserId and compare it with the Custom setting to check if user is authorized. */
		Boolean isCurrentUserAuthorized = false;
		Merge_Vendor_Accounts__c mva = Merge_Vendor_Accounts__c.getInstance();
		isCurrentUserAuthorized = mva.Allow_merge__c;
		Map<Id,Id> MasterRecordIdMap = new Map<Id,Id>();
		/*Story S-311626 #End*/
		// Iterate over all the accounts which are deleted
		for(Account acc:oldMap.values())
		{
			if(acc.MasterRecordId <> null)
			{
				// check if user is authorized to merge Vendor type accounts S-311626 # Start
				if(acc.Type == 'Vendor' && !isCurrentUserAuthorized)
					acc.addError('You cannot merge Vendor type accounts. Please contact your administrator for further information');
				// S-311626 #End
				// add account Ids to set
				masterAccountIds.add(acc.MasterRecordId);
				//Create a masterRecordId map
				MasterRecordIdMap.put(acc.masterRecordId, acc.Id);// Created for Story S-311626
			}
		}
		
		// if set is not empty
		If(!masterAccountIds.isEmpty())
		{
			// fetch name and associated contacts for accounts where name is changed and iterate over them
			for(Account acc : [Select Id, Type, Name, (Select Id, Account_Name__c from Contacts) from Account where Id IN:masterAccountIds])
			{
				//S-311626 #Start.
				// check for Accounts if the master account is not of type vendor
				if(acc.Type == 'Vendor' && !isCurrentUserAuthorized)
				{
					oldMap.get(MasterRecordIdMap.get(acc.Id)).addError('You cannot merge Vendor type accounts.Please contact your administrator for further information');
				}
				//#S-311626 #End
				// iterate over the associated contacts
				for(Contact con:acc.Contacts)
				{
					// if account_name__c is not equal to name of the account
					if(con.Account_Name__c <> acc.Name)
					{
						// assign the name of the account to the account_name__c field
						con.Account_Name__c = acc.Name;
						contactsToUpdate.add(con);
					}
				}
			}
		}
		
		// if contact list to update is not empty 
		if(!contactsToUpdate.isEmpty())
		{
			// update the contacts
			update contactsToUpdate;
		}
	}
}