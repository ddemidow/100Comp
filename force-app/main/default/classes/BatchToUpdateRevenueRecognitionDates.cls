/************************************************
* Name           : BatchToPopulateReportingEndDate
* Creaetd By     : Nishank Jaisinghani
* Created Date   : 10th April 2015
* Story          : S-299883
************************************************/
global class BatchToUpdateRevenueRecognitionDates implements Database.Batchable<SObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    //Added Revenue_Recognition_Completed__c = true condition in below query by Jyoti for case 00139114
    String Query = 'Select Id,Revenue_Recognition_Begins__c,Revenue_Recognition_Ends__c,Revenue_Recognition_3__c,No_Response__c,Payment_Date__c,Payment_Date_1_Year__c,Payment_Date_2_Years__c from Opportunity';
    Query = Query + ' where (Revenue_Recognition_Begins__c=null OR  Revenue_Recognition_Ends__c=null OR Revenue_Recognition_3__c=null) AND Payment_Date__c!=null AND Revenue_Recognition_Completed__c = FALSE AND Membership_Type__c = \'NGL ($75K)\'';
    System.debug('********'+Query);    
    return Database.getQueryLocator(Query); 
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){ 
    List<Opportunity> LstToBeUpdated = new List<Opportunity>();
     for(sobject s: scope) {
               Opportunity Opp = (Opportunity)s;
               
               if(opp.Revenue_Recognition_Begins__c==null && ((opp.No_Response__c==true &&  date.today() >= opp.Payment_Date__c.addYears(1)) || (date.today() >= opp.Payment_Date__c.addYears(2)))){
                 Date d = Date.newInstance(date.today().Year(), 12, 31);
                 opp.Revenue_Recognition_Begins__c = d;
               }  
               
                if(opp.Revenue_Recognition_Ends__c==null &&  ((opp.No_Response__c == true && date.today() >= opp.Payment_Date__c.addYears(1)) || date.today() >= opp.Payment_Date__c.addYears(2))){
                 Date d = Date.newInstance(date.today().Year(), 12, 31);
                 opp.Revenue_Recognition_Ends__c = d;
               } 
                  
                if(opp.Revenue_Recognition_3__c==null && ((opp.No_Response__c==true &&  date.today() >= opp.Payment_Date__c.addYears(1)) || date.today() >= opp.Payment_Date__c.addYears(2))){
                 Date d = Date.newInstance(date.today().Year(), 12, 31);
                 opp.Revenue_Recognition_3__c = d;
               }            
               LstToBeUpdated.add(opp);
        }    
         if(LstToBeUpdated.size()>0){
            try{
               
                Database.update(LstToBeUpdated);
          }
           catch(Exception E){
        
            }
        }
    }
    // End of Execute Method
    // Start of Finish Method
    global void finish(Database.BatchableContext BC){             
    }
    
    global void execute(SchedulableContext sc) {
      BatchToUpdateRevenueRecognitionDates b = new BatchToUpdateRevenueRecognitionDates(); 
      database.executebatch(b,500);
   }
}