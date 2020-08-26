/* Created By :  Paras Dhingra
   Created Date :6/14/2015
   Description: Batch job to update Paid Date on Sales Invoice
   Story : S-320698
   Minor Modifications for Story S-339797 By Paras Dhingra
   Modified Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
*/
global class BatchUpdatePaidDateSI implements Database.Batchable<sObject> {

        global String query;

    global BatchUpdatePaidDateSI() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query==null || query=='')
        {   //Fetch all valid Sales Invoice records
            query = 'Select id, Cash_Entry_Name__c, paid_date__c, c2g__PaymentStatus__c, c2g__Account__c, c2g__Transaction__c,c2g__Transaction__r.c2g__TransactionType__c, c2g__InvoiceTotal__c from c2g__codaInvoice__c '
            +'where c2g__PaymentStatus__c = \'Paid\' AND (c2g__Transaction__r.c2g__TransactionType__c = \'Invoice\' or c2g__Transaction__r.c2g__TransactionType__c = \'Cash Matching Journal\')';
            // +' AND Id = \'a1qF0000000DotG\'';
        }
        if(Test.isRunningTest())
            query+= ' limit 100';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<c2g__codaInvoice__c> scope) {
        // Fetch the Transaction Ids related to SI records
        System.debug('**Scope size**'+scope.size());
        Map<Id, c2g__codaInvoice__c> SI_transactions = new Map<Id,c2g__codaInvoice__c>();
        List<c2g__codaCashMatchingHistory__c> SI_CMH = new List<c2g__codaCashMatchingHistory__c>();
        Map <Id,c2g__codaInvoice__c> MR_Of_SIs = new Map<Id,c2g__codaInvoice__c>();
        List<c2g__codaCashMatchingHistory__c> CMH_MR = new List<c2g__codaCashMatchingHistory__c>();
        List<c2g__codaCashEntry__c> cashEntryList = new List<c2g__codaCashEntry__c>();
        Map<Id,c2g__codaCashEntry__c> MR_to_CashEntry = new Map<Id,c2g__codaCashEntry__c>();
        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        //Map to hold Key => Values as TransactionId => Sales Invoice
        Map<Id, c2g__codaInvoice__c> mapTransactionsOnNegativeSIs = new Map<Id, c2g__codaInvoice__c>();
        
        for(c2g__codaInvoice__c SI : scope){
            if(SI.c2g__Transaction__c!=null && SI.c2g__Transaction__r.c2g__TransactionType__c == 'Invoice') {
            	
      	      	//Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        		//Check for negative Invoice Total 
            	//and populate map of negative Invoice with their Transactions
            	if(SI.c2g__InvoiceTotal__c < 0)
            		mapTransactionsOnNegativeSIs.put(SI.c2g__Transaction__c,SI);
            	else
					SI_transactions.put(SI.c2g__Transaction__c,SI);//create a set of valid transactions
if(SI.id=='a1qF0000000EaWn' || SI.id=='a1qF0000000EaWnIAK')
                System.debug('**Record found**'+SI.id+ SI.paid_date__c);
            }
        }
        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        //Code moved from previous line to here
        //Purchase Invoices with respect to their Ids
        Map<Id,c2g__codaInvoice__c> SIs_to_Update_Map = new Map<Id,c2g__codaInvoice__c>();
                        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        /**** Changes Start here ****/
        //Check for map's size
        if(mapTransactionsOnNegativeSIs.size() > 0) {
        		
        	mapNegativeToPositiveInvoices(SIs_to_Update_Map, mapTransactionsOnNegativeSIs);
        }
        /**** Changes Stop here ****/
        
        if(SI_transactions!=null && SI_transactions.size()>0){//Fetch Matching Reference records from Related Cash Matching enteries using related Transactions
            SI_CMH = [select Id, c2g__MatchingReference__c,c2g__MatchingDate__c,c2g__TransactionLineItem__c, c2g__TransactionLineItem__r.c2g__Transaction__c
                        from c2g__codaCashMatchingHistory__c where c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
                        AND  c2g__TransactionLineItem__r.c2g__Transaction__c IN : SI_transactions.keyset() ORDER BY c2g__MatchingDate__c DESC];
            // Fetch only Recent CMHs
            Map<Id,c2g__codaCashMatchingHistory__c> recentCMH_SI = new Map<Id,c2g__codaCashMatchingHistory__c>();
            for(c2g__codaCashMatchingHistory__c cmh : SI_CMH){
                if(recentCMH_SI.containsKey(cmh.c2g__TransactionLineItem__c)){
                    if(recentCMH_SI.get(cmh.c2g__TransactionLineItem__c).c2g__MatchingDate__c < cmh.c2g__MatchingDate__c)
                        recentCMH_SI.put(cmh.c2g__TransactionLineItem__c,cmh);
                }else{
                    recentCMH_SI.put(cmh.c2g__TransactionLineItem__c,cmh);
                }
            }
            // Create a Map of Matching Reference and Related SIs
            if(SI_CMH!=null && SI_CMH.size()>0)
            {
                for(c2g__codaCashMatchingHistory__c CMH : recentCMH_SI.values()){//Map MRs with Matching SIs
                    if(SI_transactions.containskey(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c)){
                        MR_Of_SIs.put(CMH.c2g__MatchingReference__c,SI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c));
                        if(SI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c).id=='a1qF0000000EaWn' || SI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c).id=='a1qF0000000EaWnIAK')
                            System.debug('**Record found**'+SI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c).id+ SI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c).paid_date__c);
                    }
                }
                if(MR_Of_SIs.containskey('a1yF0000002U4CT')||(MR_Of_SIs.containskey('a1yF0000002U4CTIA0'))){
                    System.debug('**MR found**'+MR_Of_SIs.get('a1yF0000002U4CT'));
                    System.debug('**MR found**'+MR_Of_SIs.get('a1yF0000002U4CTIA0'));
                }
                if(MR_Of_SIs!=null && MR_Of_SIs.size()>0){
                    //Now Fetch sibling Cash Matching History Using the MRs which are of transaction type 'cash'
                    CMH_MR = [select Id ,c2g__MatchingReference__c, c2g__MatchingDate__c, c2g__TransactionLineItem__c, c2g__TransactionLineItem__r.c2g__Transaction__c,
                        c2g__Account__c, c2g__TransactionLineItem__r.c2g__Account__c
                        from c2g__codaCashMatchingHistory__c where c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
                        AND c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash'
                        AND c2g__MatchingReference__c IN : MR_Of_SIs.keyset()];
                        
                    //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        			//Map to hold Matching Reference Id as key and List of related Payable Invoice List
                	Map<Id, c2g__codaInvoice__c> mapMRToSIForJournalEntry = MR_Of_SIs.clone();
                
                    // Iterate over the CMH to create a Map of CMH and transactions
                    if(CMH_MR!=null && CMH_MR.size()>0){
                        Map<Id,Id> MR_to_Trans = new Map<Id,Id>();//Map of type <Transaction,MR>

                        for(c2g__codaCashMatchingHistory__c CMH : CMH_MR){
                            if(
                                (CMH.c2g__MatchingReference__c!=null && CMH.c2g__TransactionLineItem__r.c2g__Transaction__c!=null) &&
                                (CMH.c2g__Account__c == CMH.c2g__TransactionLineItem__r.c2g__Account__c)
                            )
                                MR_to_Trans.put(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c,CMH.c2g__MatchingReference__c);
                        }
if(MR_to_Trans.containskey('a2YF0000000EkUm')||(MR_to_Trans.containskey('a2YF0000000EkUmMAK'))){
                    System.debug('**Transaction found**'+MR_to_Trans.get('a2YF0000000EkUm'));
                    System.debug('**Transaction__c found**'+MR_to_Trans.get('a2YF0000000EkUmMAK'));
                }
                        if(MR_to_Trans!=null && MR_to_Trans.size()>0){ // Now finally query the Cash Enteries based on transactions
                            //START NSHARP S-334627 9.25.15
                            //cashEntryList = [select id, name, c2g__Date__c, c2g__Transaction__c from c2g__codaCashEntry__c where
                            //c2g__Transaction__c IN: MR_to_Trans.keyset() ORDER BY c2g__Date__c ASC];
                            List<Id> transactionIds = new List<Id>();
                            for(c2g__codaCashEntry__c ce: [select id, name, c2g__Date__c, c2g__Transaction__c from c2g__codaCashEntry__c where
                            c2g__Transaction__c IN: MR_to_Trans.keyset() ORDER BY c2g__Date__c ASC]){
                                cashEntryList.add(ce);
                                transactionIds.add(ce.c2g__Transaction__c);
                                
                                //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
                                /***** Changes Start here *****/
                                //Check for Matching Reference is already in Map's keyset
	                            if(mapMRToSIForJournalEntry.containsKey(MR_to_Trans.get(ce.c2g__Transaction__c))) {
	                            	
	                            	//remove the Matching Reference key value pair from map
	                            	mapMRToSIForJournalEntry.remove(MR_to_Trans.get(ce.c2g__Transaction__c));
	                            }
                                /***** Changes Stop here *****/
                            }
                            //END NSHARP S-334627 9.25.15
                            if(cashEntryList!=null && cashEntryList.size()>0)// Create a Map of MR and CashEnteries
                            {
                                for(c2g__codaCashEntry__c ce : cashEntryList){
                                    if(MR_to_Trans.containskey(ce.c2g__Transaction__c))
                                        MR_to_CashEntry.put(MR_to_Trans.get(ce.c2g__Transaction__c),ce);
                                }
                                if(MR_to_CashEntry.containskey('a2YF0000000EkUm')||(MR_to_CashEntry.containskey('a2YF0000000EkUmMAK'))){
                    System.debug('**Transaction found**'+MR_to_CashEntry.get('a2YF0000000EkUm'));
                    System.debug('**Transaction__c found**'+MR_to_CashEntry.get('a2YF0000000EkUmMAK'));
                }
                                if(MR_to_CashEntry!=null && MR_to_CashEntry.size()>0){// Now Update the SIs
                                    Set<c2g__codaInvoice__c> set_to_update = new Set<c2g__codaInvoice__c>();
                                    for(Id MR :MR_Of_SIs.keyset()){
                                        if(MR_Of_SIs.get(MR).id=='a1qF0000000EaWn' ||MR_Of_SIs.get(MR).id=='a1qF0000000EaWnIAK')
                                                System.debug('**Record found**'+MR_Of_SIs.get(MR).id+ MR_Of_SIs.get(MR).paid_date__c);
                                        if(MR_to_CashEntry.containskey(MR) && MR_Of_SIs.get(MR)!=null && MR_to_CashEntry.get(MR)!=null){
                                            MR_Of_SIs.get(MR).paid_date__c = MR_to_CashEntry.get(MR).c2g__Date__c!=null?MR_to_CashEntry.get(MR).c2g__Date__c:null;
                                            MR_Of_SIs.get(MR).Cash_Entry_Name__c = MR_to_CashEntry.get(MR).name;
                                            if(MR_Of_SIs.get(MR).id=='a1qF0000000EaWn' ||MR_Of_SIs.get(MR).id=='a1qF0000000EaWnIAK')
                                                System.debug('**Record found**'+MR_Of_SIs.get(MR).id+ MR_Of_SIs.get(MR).paid_date__c);
                                        }
                                    }
                                    List<c2g__codaInvoice__c> SIs_to_Update = new List<c2g__codaInvoice__c>();
                                    
                                    for(c2g__codaInvoice__c invoice : MR_Of_SIs.values()) {
                                    	
                                    	if(!SIs_to_Update_Map.containsKey(invoice.Id))
                                    		set_to_update.add(invoice);
                                    }
                                    //set_to_update.addAll(MR_Of_SIs.values());
                                    
                                    if(set_to_update.size() > 0)
                                    	SIs_to_Update.addAll(set_to_update);
                                    if(!Test.isRunningTest())
                                        Update SIs_to_Update;

                                }

                                //START NSHARP S-334627 9.25.15
                                List<c2g__codaInvoice__c> salesInvoices = new List<c2g__codaInvoice__c>();
                                Map<Id,Date> matchingDateMap = new Map<Id,Date>();

                                for(c2g__codaCashMatchingHistory__c c : [SELECT Id, c2g__TransactionLineItem__r.c2g__Transaction__c, c2g__MatchingDate__c FROM c2g__codaCashMatchingHistory__c WHERE Id IN:SI_CMH AND c2g__TransactionLineItem__r.c2g__Transaction__c NOT IN: transactionIds]){
                                    if(c.c2g__MatchingDate__c != null){
                                        matchingDateMap.put(c.c2g__TransactionLineItem__r.c2g__Transaction__c,c.c2g__MatchingDate__c);
                                    }
                                }

                                for(c2g__codaInvoice__c p: [SELECT Id, Paid_Date__c, c2g__Transaction__c FROM c2g__codaInvoice__c WHERE c2g__Transaction__c IN: matchingDateMap.keyset()]){
                                    p.Paid_Date__c = matchingDateMap.get(p.c2g__Transaction__c);
                                    salesInvoices.add(p);
                                }

                                if(!salesInvoices.isEmpty()){
                                    update salesInvoices;
                                }
                                //END NSHARP S-334627 9.25.15
                            }
                        }
                        
                        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
                        /***** Changes Start here *****/
        				//Check for size
                        if(mapMRToSIForJournalEntry.size() > 0) {
                        	
                        	//Map of type <Transaction,MR>
                        	Map<Id,Set<Id>> jouranlMRToTrans = new Map<Id,Set<Id>>();
                        
                        	//Now Fetch sibling Cash Matching History Using the MRs which are of transaction type 'cash'
		                    for(c2g__codaCashMatchingHistory__c cashMatchingJournalHistory : [SELECT Id ,c2g__MatchingReference__c,c2g__TransactionLineItem__c, 
                    																			c2g__TransactionLineItem__r.c2g__Transaction__c,
																                    			c2g__Account__c,c2g__TransactionLineItem__r.c2g__Account__c 
																                    			FROM c2g__codaCashMatchingHistory__c 
																                    			WHERE c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
																                        		AND c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash Matching Journal'
																                        		AND c2g__MatchingReference__c IN : mapMRToSIForJournalEntry.keyset()]) {
								
								//Check for not null and to find Account on Cash Matching History is same as on Transaction Line Item's Account
								if((cashMatchingJournalHistory.c2g__MatchingReference__c!=null && cashMatchingJournalHistory.c2g__TransactionLineItem__r.c2g__Transaction__c!=null) &&
	                                (cashMatchingJournalHistory.c2g__Account__c == cashMatchingJournalHistory.c2g__TransactionLineItem__r.c2g__Account__c)) {
									
									//Check for already contained key of Line Item's Transaction 
									//and add new element on map's key existing set
	                                if(jouranlMRToTrans.containsKey(cashMatchingJournalHistory.c2g__TransactionLineItem__r.c2g__Transaction__c))
	                                    jouranlMRToTrans.get(cashMatchingJournalHistory.c2g__TransactionLineItem__r.c2g__Transaction__c).add(cashMatchingJournalHistory.c2g__MatchingReference__c);
	                                else
                                        jouranlMRToTrans.put(cashMatchingJournalHistory.c2g__TransactionLineItem__r.c2g__Transaction__c,new Set<Id>{cashMatchingJournalHistory.c2g__MatchingReference__c});
	                            }
							}
							
							//Check for size of map
							if(jouranlMRToTrans.size() > 0) {
								
								//Map to hold Matching Reference Id with respect to its related Journal Entry
								Map<Id,c2g__codaJournal__c> mapMatchingRefToJournal = new Map<Id,c2g__codaJournal__c>();

								//Loop through Journal Entries on Transactions
								for(c2g__codaJournal__c journalEntry : [SELECT Id, Name, c2g__JournalDate__c, c2g__Transaction__c 
																			FROM c2g__codaJournal__c WHERE c2g__Transaction__c IN: jouranlMRToTrans.keyset() 
																			ORDER BY c2g__JournalDate__c ASC]) {
									
									//Check for already contained key as Transaction of Journal
	                                if(jouranlMRToTrans.containskey(journalEntry.c2g__Transaction__c)) {
	                                	
	                                	//Loop through getting Set of Ids of Matching Reference from map
                                        for(Id IdMR : jouranlMRToTrans.get(journalEntry.c2g__Transaction__c)){
                                        	
                                        	//populate map of MR to Journal
                                            mapMatchingRefToJournal.put(IdMR, journalEntry);
                                        }
                                    }
	                            }
	                            
	                            //Loop throuhg map's keyset of Matching References w.r.t its Payable Invoice
	                            for(Id MR :MR_Of_SIs.keyset()) {
	                            	
	                            	//Check for already contained Key and for not null values
                                    if(mapMatchingRefToJournal.containskey(MR) && MR_Of_SIs.get(MR)!=null && mapMatchingRefToJournal.get(MR)!=null) {
                                    	
                                    	//Loop through Invoices getting from loop variable
                                        c2g__codaInvoice__c SI = MR_Of_SIs.get(MR);
                                    	
                                    	if(!SIs_to_Update_Map.containsKey(SI.Id)) {
                                    		
                                        	//populate field value
                                            SI.Paid_Date__c = mapMatchingRefToJournal.get(MR).c2g__JournalDate__c!=null 
                                            					? mapMatchingRefToJournal.get(MR).c2g__JournalDate__c:null;
                                            SI.Cash_Entry_Name__c = mapMatchingRefToJournal.get(MR).name!=null ? mapMatchingRefToJournal.get(MR).name:null;
                                            
                                            //populate list of Payable invoices
                                            SIs_to_Update_Map.put(SI.Id,SI);
                                    	}
                                    }
                                }
							}
                        }
                        /***** Changes Stop here *****/
                        
                        //PIs_to_Update.addAll(set_to_update);
                        if(!Test.isRunningTest()){
                            Update SIs_to_Update_Map.values();
                        }

                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
	
	/**						~~~~~~~~~~ New Mehtod added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689 ~~~~~~~~~~ 
	 *	@description	:	This method is used to set Cash Entry Name and Paid Date as null on Negative invoices
	 *
	 *	@params			:	Map<Id,c2g__codaInvoice__c> SIs_to_Update_Map, Map<Id, c2g__codaInvoice__c> mapTransactionsOnNegativePIs
	 *
	 *	@return			:	void
	 **/
	global void mapNegativeToPositiveInvoices(Map<Id,c2g__codaInvoice__c> SIs_to_Update_Map, Map<Id, c2g__codaInvoice__c> mapTransactionsOnNegativePIs) {
		
    	Map<Id, List<c2g__codaInvoice__c>> mapMRWithPIs = new Map<Id, List<c2g__codaInvoice__c>>();
    	
    	Map<Id, Set<Id>> mapMRWithTransactions = new Map<Id, Set<Id>>();
        
        
    	//Loop through Cash Matching history
        for(c2g__codaCashMatchingHistory__c cMH : [SELECT Id, c2g__MatchingReference__c,c2g__MatchingDate__c,c2g__TransactionLineItem__c, c2g__Account__c,
        												c2g__TransactionLineItem__r.c2g__Transaction__c FROM c2g__codaCashMatchingHistory__c 
		            									WHERE c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
		            									AND (c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash' 
		            									OR c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Purchase Invoice')
		                        						AND c2g__TransactionLineItem__r.c2g__Transaction__c IN: mapTransactionsOnNegativePIs.keyset()]) {
        	//Map MRs with Matching PIs
            if(cMH.c2g__MatchingReference__c!=null) {
            	
            	if(mapMRWithPIs.containsKey(cMH.c2g__MatchingReference__c)) {
            	
            		//populate map with Matching Reference Id to Cash Matching History
                	mapMRWithPIs.get(cMH.c2g__MatchingReference__c).add(mapTransactionsOnNegativePIs.get(cMH.c2g__TransactionLineItem__r.c2g__Transaction__c));
            	} else {
                	//populate map with Matching Reference Id to Cash Matching History
                	mapMRWithPIs.put(cMH.c2g__MatchingReference__c, 
                						new List<c2g__codaInvoice__c>{mapTransactionsOnNegativePIs.get(cMH.c2g__TransactionLineItem__r.c2g__Transaction__c)});
            	}            
            }
        }
        
        //Set to hold all Transactions Ids
        Set<Id> transactionIds = new Set<Id>();
        
        //Loop through Cash Matching history
		for(c2g__codaCashMatchingHistory__c cMH : [SELECT Id, c2g__MatchingReference__c,c2g__MatchingDate__c,c2g__TransactionLineItem__c, c2g__Account__c,
        												c2g__TransactionLineItem__r.c2g__Transaction__c FROM c2g__codaCashMatchingHistory__c 
		            									WHERE c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
		            									AND (c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash' 
		            									OR c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Purchase Invoice')
		                        						AND c2g__TransactionLineItem__r.c2g__Transaction__c IN: mapTransactionsOnNegativePIs.keyset()
		                        						ORDER BY c2g__MatchingDate__c]) {
        	//Map MRs with Matching PIs
            if(cMH.c2g__MatchingReference__c!=null) {
            	
            	if(mapMRWithTransactions.containsKey(cMH.c2g__MatchingReference__c)) {
            	
            		//populate map with Matching Reference Id to Cash Matching History
                	mapMRWithTransactions.get(cMH.c2g__MatchingReference__c).add(cMH.c2g__TransactionLineItem__r.c2g__Transaction__c);
            	} else {
                	//populate map with Matching Reference Id to Cash Matching History
                	mapMRWithTransactions.put(cMH.c2g__MatchingReference__c, new Set<Id>{cMH.c2g__TransactionLineItem__r.c2g__Transaction__c});
            	}
            	transactionIds.add(cMH.c2g__TransactionLineItem__r.c2g__Transaction__c);
            }
        }
        
        for(c2g__codaInvoice__c invoice : [SELECT Id, Paid_Date__c,Cash_Entry_Name__c, c2g__PaymentStatus__c, c2g__Transaction__c,
        											c2g__Transaction__r.c2g__TransactionType__c, c2g__InvoiceTotal__c, c2g__Account__c
		            								FROM c2g__codaInvoice__c WHERE c2g__PaymentStatus__c = 'Paid' 
		            								AND (c2g__Transaction__r.c2g__TransactionType__c = 'Purchase Invoice' 
		            								OR c2g__Transaction__r.c2g__TransactionType__c = 'Cash Matching Journal') 
		            								AND c2g__InvoiceTotal__c >= 0]) {
			 
			for(Id mrId : mapMRWithTransactions.keyset()) {
				
				for(Id transactionId : mapMRWithTransactions.get(mrId)) {
					
					if(mapMRWithPIs.containsKey(mrId)) {
						
						for(c2g__codaInvoice__c payInvoice : mapMRWithPIs.get(mrId)) {
							
							if(payInvoice.c2g__Account__c == invoice.c2g__Account__c && payInvoice.c2g__InvoiceTotal__c == invoice.c2g__InvoiceTotal__c * -1) {
								
								//Get invoice instance and update the associated fields
            					invoice.Paid_Date__c = null;
            					invoice.Cash_Entry_Name__c = null;
            					
            					//populate map of PIs
            					SIs_to_Update_Map.put(invoice.Id, invoice);
            					
            					//Get invoice instance and update the associated fields
            					payInvoice.Paid_Date__c = null;
            					payInvoice.Cash_Entry_Name__c = null;
            					
            					//populate map of PIs
            					SIs_to_Update_Map.put(payInvoice.Id, payInvoice);
							}
						}
					}
				}
			}
		}	
	}
}