global class UpdateEmails implements Database.Batchable<sObject>{
  global final String Query;
  global final string EmailFields;
 
  global UpdateEmails(String q, String e){Query=q;EmailFields=e;}
 
  global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
  }
 
  global void execute(Database.BatchableContext BC, List<sObject> scope){
     List<sObject> sObjectListForUpdate = new List<sObject>();
     for(sObject s : scope){
       sObject newSObject = (sObject)s;
       for (String emailFld : EmailFields.split(';')) {
         if (newSObject.get(emailFld) != null) {
           string updatedEmail = String.valueOf(newSObject.get(EmailFld)) + '.fake';
           newSObject.put(EmailFld, updatedEmail);
         }
       }
       sObjectListForUPdate.add(newSObject);
     } 
     database.update(sObjectListForUpdate, false);
   }
     
   global void finish(Database.BatchableContext BC){}
}