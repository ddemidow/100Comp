/*
// (c) 2017 Appirio (A Wipro company), Inc.
//
// CashEntryTrigger: CashEntryTrigger trigger
//
// 16 Nov 2017      Jai Gupta       Original (S-524906) Update payment reference field on Payment Summary object.
// 
//
*/
trigger CashEntryTrigger on c2g__codaCashEntry__c (after insert) {
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            CashEntryTriggerHandler.onAfterInsert(trigger.new);
        }
    }
}