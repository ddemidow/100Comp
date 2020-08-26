// S-442489 - Praful Gupta - TriggerHandler for Sales Invoice object

Public class SalesInvoiceTriggerHandler
{

 public static void AverageAccountPaymentDate(List<c2g__codaInvoice__c > siRec)
  {
     Set<Id> relatedAccount = new Set<Id>();
     List<Account> accountToUpdate = new List<Account>();
     for (c2g__codaInvoice__c so : siRec) {
        if(so.c2g__PaymentStatus__c == 'Paid')
        // if status is Paid take Account Id of the record and store in set
           {
              relatedAccount.add(so.c2g__Account__c);
           }
     }
  
  try
  {  
      if(relatedAccount.size() > 0)
      { 
        // Run Inner query to calculate average for sales Invoice associated with accounts
        // assumption only paid invoice
         for (Account ship : [select Id, Name, Average_Account_Payment_Variance__c, (select id, Payment_Date_Variance__c, c2g__PaymentStatus__c from c2g__Invoices__r where c2g__PaymentStatus__c = 'Paid') from Account where Id IN :relatedAccount]) 
           {
              Decimal total = 0;
              Decimal Average = 0;
              if(ship.c2g__Invoices__r.size() > 0)
                {
                  for (c2g__codaInvoice__c si : ship.c2g__Invoices__r)
                   {
                     if(si.Payment_Date_Variance__c != null)
                     total = total + si.Payment_Date_Variance__c;
                   }
               Average = total/ship.c2g__Invoices__r.size();
               ship.Average_Account_Payment_Variance__c = Average;
               accountToUpdate.add(ship); 
            }     
        }
      } 
  } catch (exception e)
  {
     System.debug('exception1:');
  }   
   
  try
  {  
  if (accountToUpdate.size() > 0)
  update accountToUpdate;
  } catch (exception e )
  {
       System.debug('exception2:');
  }
        
}
}