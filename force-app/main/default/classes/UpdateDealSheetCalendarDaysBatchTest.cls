/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 13 Jan. 2016
Purpose : Renewal Oppty Batch test class
*********************************************************************************/
@IsTest
private with sharing class UpdateDealSheetCalendarDaysBatchTest {
    static testMethod void UpdateDealSheetCalendarMethod (){
      Deal_Sheet__c dc = new Deal_Sheet__c();
      dc.Project_Name__c = 'testing';     
      insert dc;
      
        Deal_Sheet_Line_Item__c dsli = new  Deal_Sheet_Line_Item__c ();
        dsli.Deal_Sheet__c = dc.id;        
        dsli.Start_Date__c = date.today();
        dsli.End_Date__c = date.today().adddays(10);
        Integer numberDaysDue = dsli.Start_Date__c.daysBetween(dsli.End_Date__c);
        dsli.Calendar_Day__c = numberDaysDue;
        insert dsli;
        
        UpdateDealSheetCalendarDaysBatch uc = new UpdateDealSheetCalendarDaysBatch();
		    Test.startTest();
		    Database.executeBatch(uc);
		    Test.stopTest();
    }
    
    static testMethod void CalculateDays (){
       DateTime startDateTime = DateTime.newInstance(2008, 1, 1, 0, 0, 0);
       DateTime enddateTime = DateTime.newInstance(2008, 1, 30, 0, 0, 0);
       Date startDate = date.newinstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
       Date endDate = date.newinstance(enddateTime.year(), enddateTime.month(), enddateTime.day());

       Integer numberDaysDue = startDate.daysBetween(enddate);
 system.debug('==========+++===='+numberDaysDue);
      System.assert(numberDaysDue == 29); 
     
    }

}