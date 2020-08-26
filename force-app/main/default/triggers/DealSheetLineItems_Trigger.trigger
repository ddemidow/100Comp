/************************************************
* Name           : DealSheetLineItems_Trigger
* Creaetd By     : Alka Taneja
* Created Date   : 23 Sep, 2015
* Story          : S-320861
* Revision Log   : Modified - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
*                   Chnages: Trigger defined for after delete, after insert, after update, before delete
************************************************/
trigger DealSheetLineItems_Trigger on Deal_Sheet_Line_Item__c (after delete, after insert, after update, before delete) { //Updated for the Case 00138614
    
  Set<Id> setDealSheetIds = new Set<Id>();

  //after insert
  if(Trigger.isAfter && Trigger.isInsert){
    
    for(Deal_Sheet_Line_Item__c dsli : Trigger.new) {
        setDealSheetIds.add(dsli.Deal_Sheet__c);
    }
    
    //Code added - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
    /**** Code changes start here ****/
    //List to hold Deal Sheet records which are need to be updated
    List<Deal_Sheet__c> dealSheetsToBeUpdated = new List<Deal_Sheet__c>();
    
    //Loop through Set of Ids
    for(Id dealSheetId : setDealSheetIds) {
        
        //populate list of Deal Sheet
        dealSheetsToBeUpdated.add(new Deal_Sheet__c(Id = dealSheetId, Create_Delete_Reporting_Balance__c = true));
    }
    
    if(dealSheetsToBeUpdated.size() > 0)
        update dealSheetsToBeUpdated;
    /**** Code changes stop here ****/
    
    /**Map<Id, Deal_Sheet__c> mapDealSheetIdToRecord = new Map<Id, Deal_Sheet__c>([select Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, 
                                                                                Managing_Director__c, Project__r.Dimension4__c 
                                                                                From Deal_Sheet__c
                                                                                WHERE Id IN: setDealSheetIds]);
    
    DealSheet_TriggerHandler.onAfterInsert(mapDealSheetIdToRecord.values());**/
  }
  
  //after update
  if(Trigger.isAfter && Trigger.isUpdate){
    
    setDealSheetIds.clear();
    
    for(Deal_Sheet_Line_Item__c dsli : Trigger.new) {
        setDealSheetIds.add(dsli.Deal_Sheet__c);
    }
    
    //Code added - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
    /**** Code changes start here ****/
    //List to hold Deal Sheet records which are need to be updated
    List<Deal_Sheet__c> dealSheetsToBeUpdated = new List<Deal_Sheet__c>();
    
    //Loop through Set of Ids
    for(Id dealSheetId : setDealSheetIds) {
        
        //populate list of Deal Sheet
        dealSheetsToBeUpdated.add(new Deal_Sheet__c(Id = dealSheetId, Create_Delete_Reporting_Balance__c = true));
    }
    
    if(dealSheetsToBeUpdated.size() > 0)
        update dealSheetsToBeUpdated;
        
    /**** Code changes stop here ****/
    /**Map<Id, Deal_Sheet__c> mapDealSheetIdToRecord = new Map<Id, Deal_Sheet__c>([select Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, 
                                                                                Managing_Director__c, Project__r.Dimension4__c 
                                                                                From Deal_Sheet__c
                                                                                WHERE Id IN: setDealSheetIds]);
                                                                                
    DealSheet_TriggerHandler.onAfterUpdate(mapDealSheetIdToRecord.values(), mapDealSheetIdToRecord);**/
  }
  
  //after delete
  else if(Trigger.isbefore && Trigger.isDelete){
    
    setDealSheetIds.clear();
    
    for(Deal_Sheet_Line_Item__c dsli : Trigger.old) {
        setDealSheetIds.add(dsli.Deal_Sheet__c);
    }
    
    //Code added - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
    /**** Code changes start here ****/
    //List to hold Deal Sheet records which are need to be updated
    List<Deal_Sheet__c> dealSheetsToBeUpdated = new List<Deal_Sheet__c>();
    
    //Loop through Set of Ids
    for(Id dealSheetId : setDealSheetIds) {
        
        //populate list of Deal Sheet
        dealSheetsToBeUpdated.add(new Deal_Sheet__c(Id = dealSheetId, Create_Delete_Reporting_Balance__c = true));
    }
    
    if(dealSheetsToBeUpdated.size() > 0)
        update dealSheetsToBeUpdated;
    /**** Code changes stop here ****/
        
    /**Map<Id, Deal_Sheet__c> mapDealSheetIdToRecord = new Map<Id, Deal_Sheet__c>([select Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, 
                                                                                Managing_Director__c, Project__r.Dimension4__c 
                                                                                From Deal_Sheet__c
                                                                                WHERE Id IN: setDealSheetIds]);
                                                                                
    DealSheet_TriggerHandler.onbeforeDelete(mapDealSheetIdToRecord.values());**/
  }
  
  //after undelete
  if(Trigger.isAfter && Trigger.isUndelete){
    
    setDealSheetIds.clear();
    
    for(Deal_Sheet_Line_Item__c dsli : Trigger.new) {
        setDealSheetIds.add(dsli.Deal_Sheet__c);
    }
    
    //Code added - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
    /**** Code changes start here ****/
    //List to hold Deal Sheet records which are need to be updated
    List<Deal_Sheet__c> dealSheetsToBeUpdated = new List<Deal_Sheet__c>();
    
    //Loop through Set of Ids
    for(Id dealSheetId : setDealSheetIds) {
        
        //populate list of Deal Sheet
        dealSheetsToBeUpdated.add(new Deal_Sheet__c(Id = dealSheetId, Create_Delete_Reporting_Balance__c = true));
    }
    
    if(dealSheetsToBeUpdated.size() > 0)
        update dealSheetsToBeUpdated;
        
    /**** Code changes stop here ****/
    /**Map<Id, Deal_Sheet__c> mapDealSheetIdToRecord = new Map<Id, Deal_Sheet__c>([select Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, 
                                                                                Managing_Director__c, Project__r.Dimension4__c 
                                                                                From Deal_Sheet__c
                                                                                WHERE Id IN: setDealSheetIds]);
                                                                                
    DealSheet_TriggerHandler.onAfterUnDelete(mapDealSheetIdToRecord.values());**/
  }
}