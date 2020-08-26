global class UpdateAccountNameOnContact implements Database.Batchable<SObject>, Schedulable, Database.stateful{
	
	 global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,AccountId,Account_Name__c from Contact where AccountId != null and Account_Name__c = '']);
    }
  
    global void execute(Database.BatchableContext bc, Contact[] contactLstNew)
    {
      List<Id> accountIds = new List<Id>();
	  Map<Id,String> accountIdAndName = new Map<Id,String>();
	  List<Contact> conToUpdate = new List<Contact>();
	  system.debug('contactLstNew@@@'+contactLstNew);
	    for(Contact con : contactLstNew)
	    {
	        if(con.AccountId != null)
	        {
	            accountIds.add(con.AccountId);
	        }
	    }
	    for(Account acc: [select id,name from Account where id in: accountIds])
	    {
	     	accountIdAndName.put(acc.id,acc.Name);
	    }
	    for(Contact con : contactLstNew)
	    {
	    	if(con.AccountId != null && accountIdAndName.containsKey(con.AccountId) && con.Account_Name__c != accountIdAndName.get(con.AccountId))
	        {
	        	con.Account_Name__c = accountIdAndName.get(con.AccountId);
	        	conToUpdate.add(con);
	        }
	    }
	    if(conToUpdate.size() > 0)
	    {
	    	update conToUpdate;
	    }
    }

    global void finish(Database.BatchableContext bc)
    {
    
    }
    
    //exucute for scheduler
    global void execute(SchedulableContext SC)
	{						
		UpdateAccountNameOnContact contactBt = new UpdateAccountNameOnContact( );		
		Id batchProcessId = Database.executeBatch( contactBt );
	} 

}