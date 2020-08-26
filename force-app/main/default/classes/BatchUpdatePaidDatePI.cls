/* Created By :  Paras Dhingra
   Created Date :6/14/2015
   Description: Batch job to update Paid Date on Payable Invoice
   Story : S-320698
   Minor Modifications for Story S-339797 By Paras Dhingra
   Modified NSHARP S-334627 9.19.15
   Modified Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
*/
global class BatchUpdatePaidDatePI implements Database.Batchable<sObject> {

    //Code modified - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
    //Added specifier as global
	global String query;

    global BatchUpdatePaidDatePI() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query==null || query=='')
        {   //Fetch all valid Payable Invoice records
            query = 'Select id, Paid_Date__c,Cash_Entry_Name__c, c2g__PaymentStatus__c, c2g__Transaction__c, c2g__Account__c, c2g__Transaction__r.c2g__TransactionType__c, c2g__InvoiceTotal__c ' 
		            +'from c2g__codaPurchaseInvoice__c '
		            +'where c2g__PaymentStatus__c = \'Paid\' AND (c2g__Transaction__r.c2g__TransactionType__c = \'Purchase Invoice\' or c2g__Transaction__r.c2g__TransactionType__c = \'Cash Matching Journal\') '
		            +'AND Period_Matches_Date__c = TRUE';
        }
        if(Test.isRunningTest())
            query+= ' limit 100';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<c2g__codaPurchaseInvoice__c> scope) {
        // Fetch the Transaction Ids related to PI records
        Map<Id, c2g__codaPurchaseInvoice__c> PI_transactions = new Map<Id,c2g__codaPurchaseInvoice__c>();
        List<c2g__codaCashMatchingHistory__c> PI_CMH = new List<c2g__codaCashMatchingHistory__c>();
        Map <Id,List<c2g__codaPurchaseInvoice__c>> MR_Of_PIs = new Map<Id,List<c2g__codaPurchaseInvoice__c>>();
        List<c2g__codaCashMatchingHistory__c> CMH_MR = new List<c2g__codaCashMatchingHistory__c>();
        List<c2g__codaCashEntry__c> cashEntryList = new List<c2g__codaCashEntry__c>();
        Map<Id,c2g__codaCashEntry__c> MR_to_CashEntry = new Map<Id,c2g__codaCashEntry__c>();
        
        System.debug('scope ::'+ scope.size());
        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        //Map to hold Key => Values as TransactionId => Payable Invoice
        Map<Id, c2g__codaPurchaseInvoice__c> mapTransactionsOnNegativePIs = new Map<Id, c2g__codaPurchaseInvoice__c>();
        
        for(c2g__codaPurchaseInvoice__c PI : scope){
            if(PI.c2g__Transaction__c!=null && (PI.c2g__Transaction__r.c2g__TransactionType__c == 'Purchase Invoice' || PI.c2g__Transaction__r.c2g__TransactionType__c == 'Cash Matching Journal')) {
            	
            	//Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        		//Check for negative Invoice Total 
            	//and populate map of negative Invoice with their Transactions
            	if(PI.c2g__InvoiceTotal__c < 0)
            		mapTransactionsOnNegativePIs.put(PI.c2g__Transaction__c,PI);
            	else
                	PI_transactions.put(PI.c2g__Transaction__c,PI);//create a set of valid transactions
                
            }
        }
        
        System.debug('mapTransactionsOnNegativePIs :::'+ mapTransactionsOnNegativePIs);
        System.debug('PI_transactions :::'+ PI_transactions);
        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        //Code moved from previous line to here
        //Purchase Invoices with respect to their Ids
        Map<Id,c2g__codaPurchaseInvoice__c> PIs_to_Update_Map = new Map<Id,c2g__codaPurchaseInvoice__c>();
                        
        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        /**** Changes Start here ****/
        //Check for map's size
        if(mapTransactionsOnNegativePIs.size() > 0) {
        	
        	mapNegativeToPositiveInvoices(PIs_to_Update_Map, mapTransactionsOnNegativePIs);
        }
        
        /**** Changes Stop here ****/
        
        if(PI_transactions!=null && PI_transactions.size()>0){//Fetch Matching Reference records from Related Cash Matching enteries using related Transactions
            //START NSHARP S-334627 9.25.15 - added matching date to query
            PI_CMH = [select Id, c2g__MatchingReference__c,c2g__MatchingDate__c,c2g__TransactionLineItem__c, c2g__TransactionLineItem__r.c2g__Transaction__c
                        from c2g__codaCashMatchingHistory__c where c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
                        AND  c2g__TransactionLineItem__r.c2g__Transaction__c IN : PI_transactions.keyset() ORDER BY c2g__MatchingDate__c ASC];
            // Create a Map of Matching Reference and Related PIs
            if(PI_CMH!=null && PI_CMH.size()>0)
            {
                for(c2g__codaCashMatchingHistory__c CMH : PI_CMH){//Map MRs with Matching PIs
                    if(PI_transactions.containskey(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c)  && CMH.c2g__MatchingReference__c!=null){
                        if(MR_Of_PIs.containskey(CMH.c2g__MatchingReference__c)){
                            MR_Of_PIs.get(CMH.c2g__MatchingReference__c).add(PI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c));
                        }else{
                            List<c2g__codaPurchaseInvoice__c> tempInvoiceList = new List<c2g__codaPurchaseInvoice__c>();
                            tempInvoiceList.add(PI_transactions.get(CMH.c2g__TransactionLineItem__r.c2g__Transaction__c));
                            MR_Of_PIs.put(CMH.c2g__MatchingReference__c,tempInvoiceList);
                        }

                    }
                }
                if(MR_Of_PIs!=null && MR_Of_PIs.size()>0){
                    //Now Fetch sibling Cash Matching History Using the MRs which are of transaction type 'cash'
                    CMH_MR = [select Id ,c2g__MatchingReference__c,c2g__TransactionLineItem__c, c2g__TransactionLineItem__r.c2g__Transaction__c,
                    c2g__Account__c,c2g__TransactionLineItem__r.c2g__Account__c
                        from c2g__codaCashMatchingHistory__c where c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
                        AND (c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash' or c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Purchase Invoice')
                        AND c2g__MatchingReference__c IN : MR_Of_PIs.keyset() ORDER BY c2g__MatchingDate__c ASC];
                    
                    //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
        			//Map to hold Matching Reference Id as key and List of related Payable Invoice List
                	Map<Id, List<c2g__codaPurchaseInvoice__c>> mapMRToPIForJournalEntry = MR_Of_PIs.clone();
                
                    // Iterate over the CMH to create a Map of CMH and transactions
                    if(CMH_MR!=null && CMH_MR.size()>0){
                        Map<Id,Set<Id>> MR_to_Trans = new Map<Id,Set<Id>>();//Map of type <Transaction,MR>
                        for(c2g__codaCashMatchingHistory__c CMH : CMH_MR){// If Statement modified for Story S-339797
                            if(
                                (CMH.c2g__MatchingReference__c!=null && CMH.c2g__TransactionLineItem__r.c2g__Transaction__c!=null) &&
                                (CMH.c2g__Account__c == CMH.c2g__TransactionLineItem__r.c2g__Account__c)
                                ){
                                if(MR_to_Trans.containsKey(cmh.c2g__TransactionLineItem__r.c2g__Transaction__c)){
                                    MR_to_Trans.get(cmh.c2g__TransactionLineItem__r.c2g__Transaction__c).add(CMH.c2g__MatchingReference__c);
                                    }else{
                                        Set<Id> tempIdList = new Set<Id>();
                                        tempIdList.add(CMH.c2g__MatchingReference__c);
                                        MR_to_Trans.put(cmh.c2g__TransactionLineItem__r.c2g__Transaction__c,tempIdList );
                                    }
                                //MR_to_Trans.put(cmh.c2g__TransactionLineItem__r.c2g__Transaction__c,CMH.c2g__MatchingReference__c);
                            }
                        }
                        
                        System.debug('MR_to_Trans'+ MR_to_Trans);
                        if(MR_to_Trans!=null && MR_to_Trans.size()>0){ // Now finally query the Cash Enteries based on transactions
                          system.debug(MR_to_Trans);
                            //START NSHARP S-334627 9.25.15
                            //cashEntryList = [select id, name, c2g__Date__c, c2g__Transaction__c from c2g__codaCashEntry__c where
                            //c2g__Transaction__c IN: MR_to_Trans.keyset() ORDER BY c2g__Date__c ASC]; // Story S-339797
                            List<Id> transactionIds = new List<Id>();
                            for(c2g__codaCashEntry__c ce: [select id, name, c2g__Date__c, c2g__Transaction__c from c2g__codaCashEntry__c where
                            c2g__Transaction__c IN: MR_to_Trans.keyset() ORDER BY c2g__Date__c ASC]){
                                cashEntryList.add(ce);
                                transactionIds.add(ce.c2g__Transaction__c);
                                
                                //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
                                /***** Changes Start here *****/
                                //Loop through Set on Key of map
		        				for(Id mrId : MR_to_Trans.get(ce.c2g__Transaction__c)) {
                                	
                                	//Check for Matching Reference is already in Map's keyset
		                            if(mapMRToPIForJournalEntry.containsKey(mrId)) {
		                            	
		                            	//remove the Matching Reference key value pair from map
		                            	mapMRToPIForJournalEntry.remove(mrId);
		                            }
                                }
                                /***** Changes Stop here *****/
                            }
                            //END NSHARP S-334627 9.25.15

                            if(cashEntryList!=null && cashEntryList.size()>0)// Create a Map of MR and CashEnteries
                            {
                                for(c2g__codaCashEntry__c ce : cashEntryList){
                                    if(MR_to_Trans.containskey(ce.c2g__Transaction__c))
                                    {
                                        for(Id IdMR : MR_to_Trans.get(ce.c2g__Transaction__c)){
                                            MR_to_CashEntry.put(IdMR,ce);
                                        }
                                    }
                                }
                                
                                if(MR_to_CashEntry!=null && MR_to_CashEntry.size()>0){// Now Update the PIs
                                    Set<c2g__codaPurchaseInvoice__c> set_to_update = new Set<c2g__codaPurchaseInvoice__c>();
                                    List<c2g__codaPurchaseInvoice__c> PIs_to_Update = new List<c2g__codaPurchaseInvoice__c>();
                                    //Map<Id,c2g__codaPurchaseInvoice__c> PIs_to_Update_Map = new Map<Id,c2g__codaPurchaseInvoice__c>();
                                    
                                    for(Id MR :MR_Of_PIs.keyset()){
                                        if(MR_to_CashEntry.containskey(MR) && MR_Of_PIs.get(MR)!=null && MR_to_CashEntry.get(MR)!=null){
                                            for(c2g__codaPurchaseInvoice__c PI : MR_Of_PIs.get(MR)){
                                            	
                                            	//Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
                        						//Condition added to Check for already contained Payable Invoice Id in map as key
                                            	if(!PIs_to_Update_Map.containsKey(PI.Id)) {
                                        	
	                                                PI.Paid_Date__c = MR_to_CashEntry.get(MR).c2g__Date__c!=null?MR_to_CashEntry.get(MR).c2g__Date__c:null;
	                                                PI.Cash_Entry_Name__c = MR_to_CashEntry.get(MR).name!=null?MR_to_CashEntry.get(MR).name:null;
	                                                PIs_to_Update_Map.put(PI.Id,PI);
                                            	}
                                            }
                                            //MR_Of_PIs.get(MR).Paid_Date__c = MR_to_CashEntry.get(MR).c2g__Date__c!=null?MR_to_CashEntry.get(MR).c2g__Date__c:null;
                                            //MR_Of_PIs.get(MR).Cash_Entry_Name__c = MR_to_CashEntry.get(MR).name!=null?MR_to_CashEntry.get(MR).name:null;
                                        }
                                    }

									
//PIs_to_Update.addAll(set_to_update);
                                    if(!Test.isRunningTest()){
                                        Update PIs_to_Update_Map.values();
                                    }
									
                                    //START NSHARP S-334627 9.25.15
                                    //loop though PI_CMH update PI based on CMH Match Date
                                    List<c2g__codaPurchaseInvoice__c> purchaseInvoices = new List<c2g__codaPurchaseInvoice__c>();
                                    Map<Id,Date> matchingDateMap = new Map<Id,Date>();

                                    for(c2g__codaCashMatchingHistory__c c : [SELECT Id, c2g__MatchingReference__c,c2g__TransactionLineItem__r.c2g__Transaction__c, c2g__MatchingDate__c FROM c2g__codaCashMatchingHistory__c WHERE Id IN:PI_CMH AND c2g__TransactionLineItem__r.c2g__Transaction__c NOT IN: transactionIds]){
                                        if(c.c2g__MatchingDate__c != null){
                                            matchingDateMap.put(c.c2g__TransactionLineItem__r.c2g__Transaction__c,c.c2g__MatchingDate__c);                                     
                                        }
                                        
                                        
                                    }

                                    for(c2g__codaPurchaseInvoice__c p: [SELECT Id,Name,Cash_Entry_Name__c, Paid_Date__c, c2g__Transaction__c FROM c2g__codaPurchaseInvoice__c WHERE c2g__Transaction__c IN: matchingDateMap.keyset()]){
                                        p.Paid_Date__c = matchingDateMap.get(p.c2g__Transaction__c);
                                        purchaseInvoices.add(p);
                                    }

                                    if(!purchaseInvoices.isEmpty()){
                                        update purchaseInvoices;
                                    }
                                    //END NSHARP S-334627 9.25.15
                                }
                            }
                        }
                        
                        //Code added - Padmesh Soni (Appirio Offshore - 11/03/2015) - S-359689
                        /***** Changes Start here *****/
        				//Check for size
                        if(mapMRToPIForJournalEntry.size() > 0) {
                        	
                        	//Map of type <Transaction,MR>
                        	Map<Id,Set<Id>> jouranlMRToTrans = new Map<Id,Set<Id>>();
                        
                        	//Now Fetch sibling Cash Matching History Using the MRs which are of transaction type 'cash'
		                    for(c2g__codaCashMatchingHistory__c cashMatchingJournalHistory : [SELECT Id ,c2g__MatchingReference__c,c2g__TransactionLineItem__c, 
                    																			c2g__TransactionLineItem__r.c2g__Transaction__c,
																                    			c2g__Account__c,c2g__TransactionLineItem__r.c2g__Account__c 
																                    			FROM c2g__codaCashMatchingHistory__c 
																                    			WHERE c2g__TransactionLineItem__r.c2g__LineType__c = 'Account'
																                        		AND c2g__TransactionLineItem__r.c2g__Transaction__r.c2g__TransactionType__c = 'Cash Matching Journal'
																                        		AND c2g__MatchingReference__c IN : mapMRToPIForJournalEntry.keyset() ORDER BY c2g__MatchingDate__c ASC]) {
								
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
	                            for(Id MR :MR_Of_PIs.keyset()) {
	                            	
	                            	//Check for already contained Key and for not null values
                                    if(mapMatchingRefToJournal.containskey(MR) && MR_Of_PIs.get(MR)!=null && mapMatchingRefToJournal.get(MR)!=null) {
                                    	
                                    	//Loop through Invoices getting from loop variable
                                        for(c2g__codaPurchaseInvoice__c PI : MR_Of_PIs.get(MR)) {
                                        	
                                        	if(!PIs_to_Update_Map.containsKey(PI.Id)) {
                                        		
	                                        	//populate field value
	                                            PI.Paid_Date__c = mapMatchingRefToJournal.get(MR).c2g__JournalDate__c!=null 
	                                            					? mapMatchingRefToJournal.get(MR).c2g__JournalDate__c:null;
	                                            PI.Cash_Entry_Name__c = mapMatchingRefToJournal.get(MR).name!=null ? mapMatchingRefToJournal.get(MR).name:null;
	                                            
	                                            //populate list of Payable invoices
	                                            PIs_to_Update_Map.put(PI.Id,PI);
                                        	}
                                        }
                                    }
                                }
							}
                        }
                        /***** Changes Stop here *****/
                        
                        //PIs_to_Update.addAll(set_to_update);
                        if(!Test.isRunningTest()){
                            Update PIs_to_Update_Map.values();
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
	 *	@params			:	Map<Id,c2g__codaPurchaseInvoice__c> PIs_to_Update_Map, Map<Id, c2g__codaPurchaseInvoice__c> mapTransactionsOnNegativePIs
	 *
	 *	@return			:	void
	 **/
	global void mapNegativeToPositiveInvoices(Map<Id,c2g__codaPurchaseInvoice__c> PIs_to_Update_Map, Map<Id, c2g__codaPurchaseInvoice__c> mapTransactionsOnNegativePIs) {
		
    	Map<Id, List<c2g__codaPurchaseInvoice__c>> mapMRWithPIs = new Map<Id, List<c2g__codaPurchaseInvoice__c>>();
    	
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
                						new List<c2g__codaPurchaseInvoice__c>{mapTransactionsOnNegativePIs.get(cMH.c2g__TransactionLineItem__r.c2g__Transaction__c)});
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
        
        for(c2g__codaPurchaseInvoice__c invoice : [SELECT Id, Paid_Date__c,Cash_Entry_Name__c, c2g__PaymentStatus__c, c2g__Transaction__c,
        											c2g__Transaction__r.c2g__TransactionType__c, c2g__InvoiceTotal__c, c2g__Account__c
		            								FROM c2g__codaPurchaseInvoice__c WHERE c2g__PaymentStatus__c = 'Paid' 
		            								AND (c2g__Transaction__r.c2g__TransactionType__c = 'Purchase Invoice' 
		            								OR c2g__Transaction__r.c2g__TransactionType__c = 'Cash Matching Journal') 
		            								AND Period_Matches_Date__c = TRUE AND c2g__InvoiceTotal__c >= 0]) {
			 
			for(Id mrId : mapMRWithTransactions.keyset()) {
				
				for(Id transactionId : mapMRWithTransactions.get(mrId)) {
					
					if(mapMRWithPIs.containsKey(mrId)) {
						
						for(c2g__codaPurchaseInvoice__c payInvoice : mapMRWithPIs.get(mrId)) {
							
							if(payInvoice.c2g__Account__c == invoice.c2g__Account__c && payInvoice.c2g__InvoiceTotal__c == invoice.c2g__InvoiceTotal__c * -1) {
								
								//Get invoice instance and update the associated fields
            					invoice.Paid_Date__c = null;
            					invoice.Cash_Entry_Name__c = null;
            					
            					//populate map of PIs
            					PIs_to_Update_Map.put(invoice.Id, invoice);
            					
            					//Get invoice instance and update the associated fields
            					payInvoice.Paid_Date__c = null;
            					payInvoice.Cash_Entry_Name__c = null;
            					
            					//populate map of PIs
            					PIs_to_Update_Map.put(payInvoice.Id, payInvoice);
							}
						}
					}
				}
			}
		}	
	}
}