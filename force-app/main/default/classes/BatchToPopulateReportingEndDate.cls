/************************************************
* Name           : BatchToPopulateReportingEndDate
* Creaetd By     : Nishank Jaisinghani
* Created Date   : 10th April 2015
* Story          : S-299883
************************************************/
global class BatchToPopulateReportingEndDate implements Database.Batchable<SObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
     List<Id> Ids = new List<Id>();
     //Ids.add('a3yF0000000HZW1IAO');
     //return Database.getQueryLocator('Select Id,Name,Reporting_End_Date__c from pse__Proj__c where Id IN: Ids');
     //START Himanshu Matharu C-00245682 [07 Dec 2018]
      return Database.getQueryLocator('Select Id,Name,Reporting_End_Date__c,Project_Closed_Date__c from pse__Proj__c WHERE Project_Closed_Date__c < LAST_N_DAYS:365');
     //END Himanshu Matharu C-00245682 [07 Dec 2018]
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){ 
        List<Id> projectIds = new List<Id>(); // List to hold Project Id's
        Map<Id,Date> TransactionEndDateLatest = new Map<Id,Date>();
        List<c2g__codaTransactionLineItem__c> TransactionEndDate = new List<c2g__codaTransactionLineItem__c>();
        List<Date> DatetobeSorted = new List<Date>();
        List<pse__Proj__c> ProjectsToBeUpdated = new List<pse__Proj__c>();
     for(sobject s: scope) {
                pse__Proj__c project = (pse__Proj__c)s;           
                projectIds.add(project.Id); // Add all Project Id's
        }    
      Map<Id, pse__Proj__c>  EndDateMap = new Map<Id, pse__Proj__c>([select id, (select id, End_Date__c from pse__Milestones__r where End_Date__c!=null order by End_Date__c desc limit 1),(Select Id, pse__Project__c, pse__Expense_Date__c from pse__Expenses__r where pse__Expense_Date__c!=null and (pse__Status__c = 'Submitted' OR pse__Status__c = 'Approved') order by pse__Expense_Date__c DESC limit 1), (Select Id, pse__Project__c, pse__End_Date__c from pse__TimecardSplits__r where pse__End_Date__c!=null and (pse__Status__c = 'Submitted' OR pse__Status__c = 'Approved') order by pse__End_Date__c DESC limit 1), (Select Id, pse__Project__c, pse__End_Date__c from pse__Est_Vs_Actuals__r where pse__End_Date__c!=null and pse__Estimated_Hours__c > 0 and pse__Time_Period_Type__c = 'Week' order by pse__End_Date__c DESC limit 1) from pse__Proj__c where Id IN:projectIds]);
      TransactionEndDate = [Select Id, c2g__Dimension4__r.Project__c, Transaction_Date__c from c2g__codaTransactionLineItem__c where c2g__Dimension4__r.Project__c IN :projectIds and Transaction_Date__c!=null AND c2g__Transaction__r.c2g__TransactionType__c != 'Currency Revaluation' order by  Transaction_Date__c DESC];
      System.debug('*******EndDateMap'+EndDateMap);  
      System.debug('*******TransactionEndDate'+TransactionEndDate);     
      
      
      // Populating ProjectId and Date from Transaction lineItem
    For(c2g__codaTransactionLineItem__c trans : TransactionEndDate)
    {
    if(!(TransactionEndDateLatest.containsKey(trans.c2g__Dimension4__r.Project__c)) && trans.Transaction_Date__c!=null)
      {
         TransactionEndDateLatest.put(trans.c2g__Dimension4__r.Project__c,trans.Transaction_Date__c);
      }
    }     
          for (Id projectId : projectIds)
      {
            DatetobeSorted.clear();
            pse__Proj__c proj = new pse__Proj__c();
            if(EndDateMap.containsKey(projectId)){
            proj = EndDateMap.get(projectId);
            List<pse__Milestone__c> milestone = proj.pse__Milestones__r;
            if(milestone.size()>0)
            DatetobeSorted.add(milestone.get(0).End_date__c);
            List<pse__Expense__c> expense = proj.pse__Expenses__r;
            if(expense.size()>0)
            DatetobeSorted.add(expense.get(0).pse__Expense_Date__c);
            List<pse__Timecard__c> timecard = proj.pse__TimecardSplits__r;
            if(timecard.size()>0)
            DatetobeSorted.add(timecard.get(0).pse__End_Date__c);
            List<pse__Est_Vs_Actuals__c> Actuals = proj.pse__Est_Vs_Actuals__r;
            if(Actuals.size()>0)
            DatetobeSorted.add(Actuals.get(0).pse__End_Date__c);
            }
      
            If(TransactionEndDateLatest.containsKey(projectId)){
            DatetobeSorted.add(TransactionEndDateLatest.get(projectId));
            }
                 if(DatetobeSorted.size()>0) {
                    DatetobeSorted.sort();
                    pse__Proj__c projectupdated= new pse__Proj__c();
                    projectupdated.Id = projectId;
                    projectupdated.Reporting_End_Date__c = DatetobeSorted[DatetobeSorted.size()-1];
                    ProjectsToBeUpdated.add(projectupdated);
                 }
      }      
          if(ProjectsToBeUpdated.size()>0){
            try{
               
                Database.update(ProjectsToBeUpdated);
              }
           catch(Exception E){
            System.debug(E.getmessage());
            }
        }
   }
    // End of Execute Method
    // Start of Finish Method
    global void finish(Database.BatchableContext BC){             
    }
    
    global void execute(SchedulableContext sc) {
      BatchToPopulateReportingEndDate b = new BatchToPopulateReportingEndDate (); 
      database.executebatch(b,50);
   }
}