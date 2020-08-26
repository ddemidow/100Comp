/************************************************
* Name           : DealSheet_TriggerHandler
* Creaetd By     : Alka Taneja
* Created Date   : 14 Sep, 2015
* Story          : S-320861 
* Revision Log	 : Modified - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
*					Chnages: Create_Delete_Reporting_Balance__c field to be setted true
*					V_1.1 - Modified - Padmesh Soni(02/22/2016 - Appirio Offshore) - S-374088
*						Changes:
*							1. When User creates a new Deal Sheet, the new record have 5 Deal Sheet Line Item records.
*							2. This will not run when clone the record of existing.
*
************************************************/
public with sharing class DealSheet_TriggerHandler {

  /****************************************************************************
    Method : Call on After Insert on DealSheet 
  ****************************************************************************/
  //Code commented - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
  /**public static void onAfterInsert(List<Deal_Sheet__c> DealSheets) {
    
    //populateRptBalanceRecords(DealSheets);
  }**/
	
	/**						~~~~~~~~~~ New Mehtod added - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837 ~~~~~~~~~~ 
	 *	@description	:	This method is used to set the Create/Delete Reporting Balance flag on insert or delete.
	 *
	 *	@params			:	List<Deal_Sheet__c> newDealSheets(trigger.new), Map<Id, Deal_Sheet__c> oldMapDealSheets(trigger.oldMap)
	 *
	 *	@return			:	void
	 **/
	public static void onBeforeInsertUpdate(List<Deal_Sheet__c> newDealSheets, Map<Id, Deal_Sheet__c> oldMapDealSheets) {
    	
    	//Loop through trigger.new
		for(Deal_Sheet__c newDealSheet : newDealSheets) {
		
			//set true Create/Delete Reporting Balance
			newDealSheet.Create_Delete_Reporting_Balance__c = true;
		}
	}
	
  /****************************************************************************
  Method : Call on After Update on DealSheet 
  ****************************************************************************/
  //Code commented - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
  /**public static void onAfterUpdate(List<Deal_Sheet__c> DealSheets, Map<Id, Deal_Sheet__c> oldDealSheetsMap) {
    
    //populateRptBalanceRecords(DealSheets);
  }**/
  
  /****************************************************************************
    Method : Call on After UnDelete on DealSheet 
  ****************************************************************************/
  public static void onAfterUnDelete(List<Deal_Sheet__c> DealSheets) {
    
	    /*** Code Changes start here - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837 ****/
	    //Code commented
	    //populateRptBalanceRecords(DealSheets);
		
		//List to hold all Deal Sheets which need to be updated
		List<Deal_Sheet__c> dealSheetsToBeUpdated = new List<Deal_Sheet__c>();
		
		//Loop through trigger.new
		for(Deal_Sheet__c newDealSheet : DealSheets) {
			
			//Its causing System.FinalException: Record is read-only
  			//set true Create/Delete Reporting Balance
			//newDealSheet.Create_Delete_Reporting_Balance__c = true;
			
			//populate list of Deal Sheet which need to be updated
			dealSheetsToBeUpdated.add(new Deal_Sheet__c(Id = newDealSheet.Id, Create_Delete_Reporting_Balance__c = true));
		}
		
		//Check  for size of list
		if(dealSheetsToBeUpdated.size() > 0) {
			
			//Perform Update DML operation on list
			update dealSheetsToBeUpdated;
		}
		/*** Code Changes stop here - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837 ****/
  }
  
  /****************************************************************************
  Method : Call on After Delete on DealSheet 
  ****************************************************************************/
  //Code commented - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
  /**
  public static void onBeforeDelete(List<Deal_Sheet__c> DealSheets) {
    
    //Code commented - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
	//deleteOldRptBalanceRecords(DealSheets);
  }**/
  
	/**						~~~~~~~~~~ New Mehtod added - Padmesh Soni (02/22/2016 - Appirio Offshore) - S-374088 ~~~~~~~~~~ 
	 *	@description	:	This method is used to handle all After insert events and functionality.
	 *
	 *	@params			:	List<Deal_Sheet__c> newDealSheets(trigger.new), Map<Id, Deal_Sheet__c> oldMapDealSheets(trigger.oldMap)
	 *
	 *	@return			:	void
	 **/
	public static void onAfterInsert(List<Deal_Sheet__c> DealSheets, Map<Id, Deal_Sheet__c> oldMapDealSheets) {
    	
    	//Call method to create Deal Sheet Line Items on DS
		populateDefautlDSLIonDealsSheet(DealSheets);
	}
	
	/**						~~~~~~~~~~ New Mehtod added - Padmesh Soni (02/22/2016 - Appirio Offshore) - S-374088 ~~~~~~~~~~ 
	 *	@description	:	This method is used to have any new DS (excluding clone, this should only run for create) start off with 5 default DSLIs:
	 *
	 *	@params			:	List<Deal_Sheet__c> newDealSheets(trigger.new)
	 *
	 *	@return			:	void
	 **/
	public static void populateDefautlDSLIonDealsSheet(List<Deal_Sheet__c> newDealSheets) {
    	
    	//Set to hold Deal Sheet Ids
    	Set<Id> dealSheetIds = new Set<Id>();
    	
    	//Loop through trigger.new
		for(Deal_Sheet__c newDealSheet : newDealSheets) {
			
			//Check for record is created from Clone process or not
			if(!newDealSheet.isClone()) {
				
				//populate set of Deal Sheet Ids
				dealSheetIds.add(newDealSheet.Id);
			}
		}
		
		System.debug('dealSheetIds :::'+ dealSheetIds);
		
		//Check for size of set
		if(dealSheetIds.size() > 0) {
			
			//Initialize list of Deal Sheet Line Items on Deal Sheet
			List<Deal_Sheet_Line_Item__c> dSLIsToBeInserted = new List<Deal_Sheet_Line_Item__c>();
			
			//Loop through set of Ids 
			for(Id dSId : dealSheetIds) {
				
				//populate list of records to be inserted
				dSLIsToBeInserted.add(new Deal_Sheet_Line_Item__c(Line_Type__c = 'Resource', Role__c = 'Managing Director', Start_Date__c = Date.today().addDays(30), 
																		End_Date__c = Date.today().addDays(120), Billable_Days__c = 5, Daily_Bill_Rate__c = 3000, 
																		Deal_Sheet__c = dSId));
				dSLIsToBeInserted.add(new Deal_Sheet_Line_Item__c(Line_Type__c = 'Resource', Role__c = 'Director', Start_Date__c = Date.today().addDays(30), 
																		End_Date__c = Date.today().addDays(120), Billable_Days__c = 60, Daily_Bill_Rate__c = 2350, 
																		Deal_Sheet__c = dSId));
				dSLIsToBeInserted.add(new Deal_Sheet_Line_Item__c(Line_Type__c = 'Resource', Role__c = 'Associate Director', Start_Date__c = Date.today().addDays(30), 
																		End_Date__c = Date.today().addDays(120), Billable_Days__c = 60, Daily_Bill_Rate__c = 1900, 
																		Deal_Sheet__c = dSId));
				dSLIsToBeInserted.add(new Deal_Sheet_Line_Item__c(Line_Type__c = 'Resource', Role__c = 'Associate Consultant', Start_Date__c = Date.today().addDays(30), 
																		End_Date__c = Date.today().addDays(120), Billable_Days__c = 60, Daily_Bill_Rate__c = 1400, 
																		Deal_Sheet__c = dSId));
				dSLIsToBeInserted.add(new Deal_Sheet_Line_Item__c(Line_Type__c = 'Resource', Role__c = 'Business Analyst', Start_Date__c = Date.today().addDays(30), 
																		End_Date__c = Date.today().addDays(120), Billable_Days__c = 60, Daily_Bill_Rate__c = 1200, 
																		Deal_Sheet__c = dSId));
			}
			
			//Check for size of List
			if(dSLIsToBeInserted.size() > 0) {
				
				//perform DML insert operation
				insert dSLIsToBeInserted;
			}
		}
	}
}