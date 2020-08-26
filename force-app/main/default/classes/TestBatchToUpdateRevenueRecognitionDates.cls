@isTest
private class TestBatchToUpdateRevenueRecognitionDates {
 
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void Testmethod1() {
          
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acct = testUtil.newAccount(true);
        User partUsr = testUtil.newUserSysAdmin(true);
        Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
        Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
        insert opp;
       
       opp.Revenue_Recognition_Begins__c=null; 
       opp.Revenue_Recognition_Ends__c=null; 
       opp.Revenue_Recognition_3__c=null; 
       opp.No_Response__c=true;
       opp.Payment_Date__c = System.today().addYears(-1); 
  
       update opp;
       
       List <Opportunity> oppList = new List <Opportunity>();
       oppList.add(opp);
        
       Test.startTest();
       //BatchToUpdateRevenueRecognitionDates b = new BatchToUpdateRevenueRecognitionDates();	//COMMENTED by Rohit for S-635394 
       //Database.executeBatch(b);	//COMMENTED by Rohit for S-635394 
       //START ADDED by Rohit for S-635394 
       BatchToUpdateRevenueRecognitionDates cb = new BatchToUpdateRevenueRecognitionDates();
       Database.QueryLocator ql = cb.start(null);
       cb.execute(null,oppList);
       cb.Finish(null);
       //END ADDED by Rohit for S-635394 
       //Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new BatchToUpdateRevenueRecognitionDates());
       Test.stopTest();
        
      }
   }