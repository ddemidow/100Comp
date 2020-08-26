global class BatchToUpdatePaymentReference implements Database.Batchable<sObject>{
    
    public string query = '' ;
    global Database.Querylocator start(Database.batchableContext bc){ 
        if(String.isBlank(query)) {
            query = 'Select Id,CreatedDate,c2g__PaymentNumber__c,c2g__Account__c,c2g__Reference__c from c2g__codaCashEntry__c where c2g__PaymentNumber__c != null and c2g__Account__c != null and c2g__Type__c  = \'Payment\'';
        }
        
        if(Test.isRunningTest()) {
            query += ' LIMIT 1 ' ;
        }
        
        return database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext bc, List<c2g__codaCashEntry__c> scope){
        
        set<id> paymentIds = new set<id>();
        set<id> accountIds = new set<id>();
        
        for(c2g__codaCashEntry__c ce : scope) {
            paymentIds.add(ce.c2g__PaymentNumber__c);
            accountIds.add(ce.c2g__Account__c);
        }
        
        Map<String,c2g__codaPaymentAccountLineItem__c> paymentReferenceWithAccPaymentMap = new Map<String,c2g__codaPaymentAccountLineItem__c>();
        string separator = '|' ;
        for(c2g__codaPaymentAccountLineItem__c ce : [Select Id, c2g__Account__c , c2g__Payment__c , Payment_Reference__c  from c2g__codaPaymentAccountLineItem__c where c2g__Account__c in :accountIds AND c2g__Payment__c IN :paymentIds]) {
            if(ce.c2g__Payment__c != null && ce.c2g__Account__c != null) {
                string key = ce.c2g__Payment__c+separator+ce.c2g__Account__c;
                if(!paymentReferenceWithAccPaymentMap.containsKey(key)) {
                    paymentReferenceWithAccPaymentMap.put(key,ce);
                }
            }
        }
        
        list<c2g__codaPaymentAccountLineItem__c> paymentSummaryToUpdate = new list<c2g__codaPaymentAccountLineItem__c>();
        for(c2g__codaCashEntry__c ce : scope) {
            if(ce.c2g__PaymentNumber__c != null && ce.c2g__Account__c != null) {
                string key = ce.c2g__PaymentNumber__c+separator+ce.c2g__Account__c;
                if(paymentReferenceWithAccPaymentMap.containsKey(key)) {
                    c2g__codaPaymentAccountLineItem__c ps = paymentReferenceWithAccPaymentMap.get(key);
                    ps.Payment_Reference__c = ce.c2g__Reference__c;
                    paymentReferenceWithAccPaymentMap.remove(key);
                    paymentSummaryToUpdate.add(ps);
                }
            }
        }
        
        if(paymentSummaryToUpdate.size() > 0) {
            update paymentSummaryToUpdate ;
        }
    }
    
    global void finish(Database.BatchableContext info) {
           
    }
}