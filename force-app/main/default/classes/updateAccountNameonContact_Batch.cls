// Created by Shashank Singhal for Case no. 00091435 on 05-08-2014
/*
	Name								History			Author			Date			Description
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
updateAccountNameonContact_Batch		Created		Shashank Singhal	5-8-2014		This is a batch class to fetch all the contacts which are associated to some account.
																						If the value of Account_Name__c field on Contact is not equal to the name of the 
																						account then it updates the Contact's Account_Named__c with Name of the Account.
																						This is used for one time data correction process to rectify the existing records.
*/
global class updateAccountNameonContact_Batch implements Database.Batchable<SObject>, Schedulable{
	
	 // string variable to define the query to fetch the contacts
	 global static final string query = 'Select Id, Account_Name__c, Account.Name from Contact where AccountId <> Null';
	 
	 /*
		Method Name: start
		Parameters : Database.BatchableContext
		Return Type: Database.QueryLocator
		Description: This method is used to get the result from Database.getQueryLocator and pass on to Execute method
	*/
	 global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
  
    /*
		Method Name: execute
		Parameters : Database.BatchableContext, List<sObject>
		Return Type: void
		Description: This method is used to process the result from Database.getQueryLocator. The contacts are fetched
					 and if the Account_Name__c and name of the account do not match then the contact's account_name__c 
					 field is updated with the name of the account. 
	*/
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
    	// local variable declaration
    	List<Contact> contactList = (List<Contact>)scope;
    	List<Contact> contactsToUpdate = new List<Contact>();
    	
    	// iterate over the fetched contacts
    	for(Contact con:contactList)
    	{
    		// if account_name__c is not equal to name of the account
    		if(con.Account_Name__c <> con.Account.Name)
    		{
    			// assign the name of the account to the account_name__c field
    			con.Account_Name__c = con.Account.Name;
    			contactsToUpdate.add(con);
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
		Method Name: finish
		Parameters : Database.BatchableContext
		Return Type: void
		Description: empty method 
	*/
    global void finish(Database.BatchableContext bc)
    {
    
    }
    
    /*
		Method Name: execute (for scheduler)
		Parameters : SchedulableContext
		Return Type: void
		Description: this method is used to schedule the updateAccountNameonContact_Batch
	*/
    global void execute(SchedulableContext SC)
	{						
		// create object instance
		updateAccountNameonContact_Batch contactBt = new updateAccountNameonContact_Batch( );		
		// call the execute method to execute the batch
		Id batchProcessId = Database.executeBatch( contactBt );
	} 

}