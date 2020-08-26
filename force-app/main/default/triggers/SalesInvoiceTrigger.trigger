// S-442489 - Praful Gupta - Trigger for Sales Invoice object
trigger SalesInvoiceTrigger on c2g__codaInvoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
   
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate ))
    {
       SalesInvoiceTriggerHandler.AverageAccountPaymentDate(Trigger.new);
    }   
    
     if(trigger.isAfter && (trigger.isDelete ))
    {
       SalesInvoiceTriggerHandler.AverageAccountPaymentDate(Trigger.old);
    } 
       
}