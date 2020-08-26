/*
Author - Jyoti Singh (JDC)
Story - S-343933 
Date - 09/15/2015
Usage - 
*/
global class BatchToCreatePayableInvoice implements Database.Batchable<sObject>{
    
     global Database.Querylocator start(Database.batchableContext bc){   
     
        String query = 'Select  Id,pse__Status__c,pse__Project__r.pse__Region__r.Name,pse__Project__r.pse__Practice__r.Name,Converted_to_AP__c,pse__External_Resource__c,pse__Resource__c,pse__Billable__c,pse__Project__r.pse__Region__r.Dimension1__c,pse__Project__r.pse__Practice__r.Dimension2__c,pse__Resource__r.pse__Region__r.ffpsai__OwnerCompany__c,pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c,pse__Total_Cost__c,pse__Project__r.Dimension4__c,pse__Project__c,pse__Milestone__c From pse__Timecard__c where pse__Status__c = \'Approved\' and Converted_to_AP__c = FALSE and pse__External_Resource__c = TRUE  and pse__Billable__c = TRUE order by pse__Resource__r.pse__Region__r.ffpsai__OwnerCompany__c,pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c';
        system.debug('**query**'+query); 
        return Database.getQueryLocator(query);                                                                                   
     }
     
     global void execute(Database.BatchableContext bc, List<pse__Timecard__c> timeCardList){
            AggregateResult[] groupedResults = [Select  pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c account,  Sum(Cost__c) totalcost From pse__Timecard__c where Id IN: timeCardList AND pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c != Null GROUP BY pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c];
            
            List<c2g__codaPurchaseInvoice__c> payableInvoiceList = new List<c2g__codaPurchaseInvoice__c>();
            List<c2g__codaPurchaseInvoiceExpenseLineItem__c> payableInvoiceLineItemList = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();
            List<pse__Timecard__c> timeCardListToUpdate = new List<pse__Timecard__c>();
            
            date myDate = Date.today();
            String month ='';
            Integer mnth = myDate.month() - 1;
            if(mnth == 0){
            	month = 'DEC';
            }
            if(mnth == 1){
                month = 'JAN';
            }
            if(mnth == 2){
                month = 'FEB';
            }
            if(mnth == 3){
                month = 'MAR';
            }
            if(mnth == 4){
                month = 'APR';
            }
            if(mnth == 5){
                month = 'MAY';
            }
            if(mnth == 6){
                month = 'JUN';
            }
            if(mnth == 7){
                month = 'JUL';
            }
            if(mnth == 8){
                month = 'AUG';
            }
            if(mnth == 9){
                month = 'SEP';
            }
             if(mnth == 10){
                month = 'OCT';
            }
            if(mnth == 11){
                month = 'NOV';
            }
                        
           
            
            String monthYear  = '';
            if(month != 'DEC'){
            	monthYear = month + ' ' + myDate.year();
            }
            else{
            	integer year = myDate.year() - 1;
            	monthYear = month + ' ' + year;
            }
            
            Set<Id> accIds = new Set<Id>();
            
            for(AggregateResult ar: groupedResults){
                String accID = (Id)ar.get('account');
                accIds.add(accId);
            }       
            
            Set<Id> projectId = new Set<Id>();
            Set<String> dimension2Name = new Set<String>();
            Set<String> dimension1Name = new Set<String>();
            
            for(pse__Timecard__c ts: timeCardList){
                    If(ts.pse__Project__c!= null){
                        projectId.add(ts.pse__Project__c);
                        if(ts.pse__Project__r.pse__Practice__c!=null){
                        	dimension2Name.add(ts.pse__Project__r.pse__Practice__r.Name);
                        }
                        if(ts.pse__Project__r.pse__Region__c!= null){
                        	dimension1Name.add(ts.pse__Project__r.pse__Region__r.Name);
                        }
                    }
                    
             }
            
            Map<String,Id> dimension1Map = new Map<String, Id> ();
            
            for(c2g__codaDimension1__c dm1: [Select Id, Name from c2g__codaDimension1__c where Name in :dimension1Name]){
            	dimension1Map.put(dm1.Name, dm1.Id);
            }
            
            Map<String,Id> dimension2Map = new Map<String, Id> ();
            for(c2g__codaDimension2__c dm2: [Select Id, Name from c2g__codaDimension2__c where Name in :dimension2Name]){
            	dimension2Map.put(dm2.Name, dm2.Id);
            }
            
            Map<Id, Id> projectMilestoneMap = new Map<Id, Id> ();
            for(pse__Milestone__c pm: [Select Id, pse__Project__c from pse__Milestone__c where pse__Project__c IN:  projectId and pse__Closed_for_Expense_Entry__c = false]){
                projectMilestoneMap.put(pm.pse__Project__c,pm.Id);
            }
            
            Map<Id,Id> accountCompanyMap  = new Map<Id,Id>();
            for(Id accountId: accIds){
                c2g__codaPurchaseInvoice__c payableInvoice = new c2g__codaPurchaseInvoice__c();
                payableInvoice.c2g__Account__c  = accountId;                
                payableInvoice.c2g__InvoiceDate__c = date.newinstance(Date.today().year(),Date.today().month(),1).addDays(-1);              
                payableInvoice.c2g__AccountInvoiceNumber__c = monthYear + 'test2';
                payableInvoice.c2g__InvoiceStatus__c = 'In Progress';
                payableInvoice.c2g__DerivePeriod__c = TRUE;
                payableInvoice.c2g__DeriveCurrency__c = TRUE;
                 for(pse__Timecard__c ts: timeCardList){
                    If( accountId == ts.pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c){
                       payableInvoice.ffpsai__ExpenseReportResource__c = ts.pse__Resource__c;                       
                       accountCompanyMap.put(ts.pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c,ts.pse__Resource__r.pse__Region__r.ffpsai__OwnerCompany__c);
                    }
                 }                  
                payableInvoiceList.add(payableInvoice); 
                system.debug('*****payableInvoice*****'+payableInvoice);            
            }
            
            if(payableInvoiceList.size()>0){
                Database.Insert(payableInvoiceList, false);                
                List<c2g__codaPurchaseInvoice__c> createdPayableInvoiceList = new List<c2g__codaPurchaseInvoice__c>();
                createdPayableInvoiceList = [Select Id,c2g__Account__c,c2g__InvoiceCurrency__c, c2g__OwnerCompany__c from c2g__codaPurchaseInvoice__c where Id IN: payableInvoiceList];
                
                for(c2g__codaPurchaseInvoice__c payInvoice: createdPayableInvoiceList){                    
                    
                    c2g__codaPurchaseInvoiceExpenseLineItem__c payableExpenseLineItem = new c2g__codaPurchaseInvoiceExpenseLineItem__c();
                    payableExpenseLineItem.Expense_Type__c = 'Subcontractor Fees';
                    payableExpenseLineItem.c2g__PurchaseInvoice__c = payInvoice.Id;
                    payableExpenseLineItem.c2g__GeneralLedgerAccount__c = 'a1dF0000000BXfm';
                    payableExpenseLineItem.ffap__SetGLAToDefault__c = false;
                    
                    for(AggregateResult ar: groupedResults){
                        if(payInvoice.c2g__Account__c == (Id)ar.get('account')){
                            payableExpenseLineItem.c2g__NetValue__c = (Decimal)ar.get('totalcost'); 
                            break;         
                        }                       
                    }
                    
                    for(pse__Timecard__c ts: timeCardList){
                       
                        if(payInvoice.c2g__Account__c == ts.pse__Resource__r.ffpsai__ExpenseReimbursementAccount__c){
                            if(ts.pse__Project__c != null)
                            	payableExpenseLineItem.c2g__Dimension4__c = ts.pse__Project__r.Dimension4__c;
                            if(projectMilestoneMap.get(ts.pse__Project__c)!= null)
                            	payableExpenseLineItem.Milestone__c  = projectMilestoneMap.get(ts.pse__Project__c);
                            //payableExpenseLineItem.Milestone__c  = ts.pse__Milestone__c;
                            payableExpenseLineItem.ffpsai__Project__c = ts.pse__Project__c;
                            if(ts.pse__Project__c!= null && ts.pse__Project__r.pse__Region__c != null && dimension1Map.get(ts.pse__Project__r.pse__Region__r.Name)!= null)
                            	payableExpenseLineItem.c2g__Dimension1__c = dimension1Map.get(ts.pse__Project__r.pse__Region__r.Name);
                            
                            if(ts.pse__Project__c!= null && ts.pse__Project__r.pse__Practice__c != null && dimension2Map.get(ts.pse__Project__r.pse__Practice__r.Name)!= null)
                            	payableExpenseLineItem.c2g__Dimension2__c = dimension2Map.get(ts.pse__Project__r.pse__Practice__r.Name);
                            payableInvoiceLineItemList.add(payableExpenseLineItem);
                            break;
                        }
                    }   
                    system.debug('*****payableInvoiceLineItemList*****'+payableInvoiceLineItemList);
                    
                }
                 for(pse__Timecard__c ts: timeCardList){
                    ts.Converted_to_AP__c = TRUE;
                    timeCardListToUpdate.add(ts);
                 }
                                
                if(payableInvoiceLineItemList.size()>0)
                    Database.Insert(payableInvoiceLineItemList, false);
                
                    
                List<c2g__codaPurchaseInvoice__c> pIList = new  List<c2g__codaPurchaseInvoice__c>();
                List<c2g__codaPurchaseInvoice__c> pIListToUpdate = new  List<c2g__codaPurchaseInvoice__c>();
                Map<Id, String> companyInvoiceCurrencyMap = new Map<Id, String>();
                pIList = [Select Id,c2g__Account__c,c2g__Account__r.c2g__CODAAccountTradingCurrency__c , c2g__OwnerCompany__c,c2g__InvoiceCurrency__c From c2g__codaPurchaseInvoice__c where Id in: payableInvoiceList];
                for(c2g__codaPurchaseInvoice__c payableInvoice :  pIList){                	
                	if(accountCompanyMap != null && accountCompanyMap.get(payableInvoice.c2g__Account__c) != null){                		
                		companyInvoiceCurrencyMap.put(accountCompanyMap.get(payableInvoice.c2g__Account__c), payableInvoice.c2g__Account__r.c2g__CODAAccountTradingCurrency__c);
                	}
                	
                }   
                
                Map<String,Id> companyInvoiceCurrencyIdMap = new  Map<String,Id>();
                for(c2g__codaAccountingCurrency__c accCurrency: [Select Id,Name, c2g__OwnerCompany__c from c2g__codaAccountingCurrency__c where c2g__OwnerCompany__c IN : companyInvoiceCurrencyMap.keySet() and Name IN : companyInvoiceCurrencyMap.values() ]){
                	String key = accCurrency.Name + '_' + accCurrency.c2g__OwnerCompany__c;
                	companyInvoiceCurrencyIdMap.put(key,accCurrency.Id);
                }
               	
               	for(c2g__codaPurchaseInvoice__c payableInvoice :  pIList){                	
                	if(accountCompanyMap != null && accountCompanyMap.get(payableInvoice.c2g__Account__c) != null){
                		payableInvoice.c2g__OwnerCompany__c = accountCompanyMap.get(payableInvoice.c2g__Account__c);
                		if(companyInvoiceCurrencyIdMap != null && companyInvoiceCurrencyMap != null && accountCompanyMap != null ) {
                			String key = companyInvoiceCurrencyMap.get(accountCompanyMap.get(payableInvoice.c2g__Account__c)) +'_' +accountCompanyMap.get(payableInvoice.c2g__Account__c);
                			payableInvoice.c2g__InvoiceCurrency__c = companyInvoiceCurrencyIdMap.get(key);
                		}	
                		pIListToUpdate.add(payableInvoice);
                	}
               	}	
                	
                if(pIListToUpdate.size()>0){
                	update pIListToUpdate;
                }
                 
                if(timeCardListToUpdate.size()>0)
                    update timeCardListToUpdate;    
            }
     }
     
     global void finish(Database.BatchableContext info) {
           
     }
}