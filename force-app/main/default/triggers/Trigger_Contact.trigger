/************************************************************************************************************************
Name            :  ContactTrigger
Created by      :  Hemant [Appirio JDC] - 2013/11/22
Related Story   :  S-158728
Description     :  To handle all triggers of Contact
*************************************************************************************************************************/
trigger Trigger_Contact on Contact (before update,before insert, after delete, after Update) {
    
  //Event on Before Update
  if(trigger.isBefore && trigger.isUpdate){
    ContactTriggerHandler.onBeforeUpdate(trigger.new, trigger.oldMap);
  }
   //Added By Akanksha for Story S-166333
  if(trigger.isBefore && trigger.isInsert){
    ContactTriggerHandler.onBeforeInsert(trigger.new);
  } //End By Akanksha for Story S-166333
  
  // Added by Jyoti for Case 00082028 -modified by NBOCK to catch exceptions for case 00086698
  if(trigger.isAfter && trigger.isDelete){
      Set<Id> masterContId =  new Set<Id>();
      for(Contact con: trigger.old){
          system.debug('*****'+ con.MasterRecordID);
          if(con.MasterRecordID != null)
              masterContId.add(con.MasterRecordID);
      }
      if(masterContId.size()>0){
          List<ContactMasterRecord__c> cmrList = new List<ContactMasterRecord__c>();
          for(Id i: masterContId){
              ContactMasterRecord__c cmr = new ContactMasterRecord__c();
              cmr.Name = i;
              cmrList.add(cmr);
          } 
          if(cmrList.size()>0)
          try{
              insert cmrList;
          }
          catch(DMLException e){
            List<ContactMasterRecord__c> duplicates = cmrList;
              if(duplicates.size()>1)
                delete duplicates[0];
                update cmrList;
          }
      }
      
  } 
  // End by Jyoti for Case 00082028 -modified by NBOCK to catch exceptions for case 00086698
  
}