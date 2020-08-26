/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 13 Jan 2015
Purpose : Batch class to update the calendar days
*********************************************************************************/
global class UpdateDealSheetCalendarDaysBatch  implements Database.Batchable<sObject>{
  
   global String Query;
   
    // Constructor
    global UpdateDealSheetCalendarDaysBatch(){        
        
    }
    
      // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
     
     Query = 'SELECT id, Calendar_Day__c, Fixed_Revenue__c, Role__c, Fixed_Cost__c, Start_Date__c, End_Date__c from Deal_Sheet_Line_Item__c where Start_Date__c != null AND End_Date__c != null ';
              
        return Database.getQueryLocator(Query);
      
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC,List<Deal_Sheet_Line_Item__c> DealSheetLineItem){ 
    
      List<Deal_Sheet_Line_Item__c> DsliToUpdate = new List<Deal_Sheet_Line_Item__c>();    
      
        for(Deal_Sheet_Line_Item__c dsli: DealSheetLineItem){           
           dsli.Calendar_Day__c = HoursBetweenTwoDates(dsli.Start_Date__c, dsli.End_Date__c);
           DsliToUpdate.add(dsli);        
        }
        if(DsliToUpdate.size() > 0){
           update DsliToUpdate;
        }
      }
      global Integer HoursBetweenTwoDates( Date startDate ,Date endDate){
        DateTime dtStart = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day(),0,0,0);
        DateTime dtEnd = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day(),0,0,0);
        Integer dayCount = 0;
        if(dtStart == null || dtEnd == null) return 0;
    
          if(dtStart > dtEnd) {
            DateTime dtTemp = dtEnd;
            dtEnd = dtStart;
            dtStart = dtTemp;
          }
          while (dtStart.Date() <= dtEnd.Date()) {
                   if (dtStart.format('EEE') != 'Sat' && dtStart.format('EEE') != 'Sun'){
                    dayCount ++;
            }
              dtStart = datetime.newInstance(dtStart.Year(), dtStart.Month(), dtStart.Day()+1, 00, 00, 00);
          }
          return dayCount;
      }
     // Finish Method
    global void finish(Database.BatchableContext BC){
        
    }
      
}