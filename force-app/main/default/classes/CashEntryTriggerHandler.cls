/*
// (c) 2017 Appirio (A Wipro company), Inc.
//
// CashEntryTriggerHandler: Handler class for CashEntryTrigger trigger
//
// 16 Nov 2017      Jai Gupta       Original (S-524906) Update payment reference field on Payment Summary object.
// 
//
*/
public class CashEntryTriggerHandler {
    
    public static void onAfterInsert(List<c2g__codaCashEntry__c> newList) {
        updatePaymentReference(newList,null);
    }
    
    private static void updatePaymentReference(List<c2g__codaCashEntry__c> newList, Map<Id,c2g__codaCashEntry__c> oldMap) {
        
        set<id> paymentIds = new set<id>();
        set<id> accountIds = new set<id>();
        
        Map<id,c2g__codaCashEntry__c> paymentCashEntry = new Map<Id,c2g__codaCashEntry__c>();
        Map<id,c2g__codaCashEntry__c> accountCashEntry = new Map<Id,c2g__codaCashEntry__c>();
        
        for(c2g__codaCashEntry__c ce : newList) {
            if(ce.c2g__PaymentNumber__c != null) {
                if(!paymentCashEntry.containsKey(ce.c2g__PaymentNumber__c)) {
                    paymentCashEntry.put(ce.c2g__PaymentNumber__c,ce) ;
                }
            }
            if(ce.c2g__Account__c != null) {        
                if(!accountCashEntry.containsKey(ce.c2g__Account__c)) {
                    accountCashEntry.put(ce.c2g__Account__c,ce) ;
                }
            }
        }
        
        if(paymentCashEntry.size() > 0 ) {
            paymentIds.addAll(paymentCashEntry.keySet());
        }
        
        if(accountCashEntry.size() > 0) {
            accountIds.addAll(accountCashEntry.keySet());
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
        for(c2g__codaCashEntry__c ce : newList) {
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
}