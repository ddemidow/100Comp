@isTest(SeeAllData=true)
/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossReportingData_Test2
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Contains methods to test creation and updating of profit and loss reporting data
----------------------------------------------------------------------------------------------------- */
private class FFA_ProfitLossReportingData_Test2
{

    @future //Added for case - 00257645
   //public static testMethod void testRevenueForecasts() {//Commented for case - 00257645
    public static void testRevenueForecasts() 
    {     
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        
        pse__Time_Period__c period = [select Id, Name, pse__End_Date__c, pse__Start_Date__c 
                                      From pse__Time_Period__c
                                      Where pse__End_Date__c > :System.today()
                                      And pse__Start_Date__c <= :System.today() limit 1];
         
        pse__Forecast__c forecast = new pse__Forecast__c();
        forecast.pse__Entered_Forecast__c = 100;
        forecast.Expense_Cost_Forecast__c = 200;
        forecast.pse__Project__c = proj.Id;
        forecast.pse__Time_Period__c = period.Id;
        insert forecast;
          
        FFA_ProfitLossForecastRevenueBatch batch = new FFA_ProfitLossForecastRevenueBatch();  
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest(); 
        
        forecast = [select Id, pse__Entered_Forecast__c, Expense_Cost_Forecast__c, (SELECT Id, Amount__c, Category__c FROM Profit_Loss_Reporting_Data__r order by Category__c) from pse__Forecast__c where id = :forecast.Id];
        System.assert(forecast.Profit_Loss_Reporting_Data__r.size() == 2);
        for (Profit_Loss_Reporting_Data__c row : forecast.Profit_Loss_Reporting_Data__r) {
            if (row.Category__c == 'Cost') {
                System.assert(row.Amount__c == 200);
            } else if (row.Category__c == 'Revenue') {
                System.assert(row.Amount__c == 100);
            }
        }    
        forecast.pse__Entered_Forecast__c = 99;
        forecast.Expense_Cost_Forecast__c = 88;
        update forecast;
        
        batch = new FFA_ProfitLossForecastRevenueBatch();  
        Database.executeBatch(batch);               
    }
    @Future //Added for case - 00257645
    //public static testMethod void testRevenueForecastsException() {//Commented for case - 00257645
    public static void testRevenueForecastsException() 
    {   
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        
        pse__Time_Period__c period = [select Id, Name, pse__End_Date__c, pse__Start_Date__c 
                                      From pse__Time_Period__c
                                      Where pse__End_Date__c > :System.today()
                                      And pse__Start_Date__c <= :System.today() limit 1];
         
        pse__Forecast__c forecast = new pse__Forecast__c();
        forecast.pse__Entered_Forecast__c = 100;
        forecast.Expense_Cost_Forecast__c = 200;
        forecast.pse__Project__c = proj.Id;
        forecast.pse__Time_Period__c = period.Id;
        insert forecast;
          
        FFA_ProfitLossForecastRevenueBatch batch = new FFA_ProfitLossForecastRevenueBatch();  
        batch.testException = true;
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest(); 
    }
    
    public static testMethod void testRevenueActuals() 
    {
        ffrr__RevenueRecognitionTransactionLine__c trans = [select Id, Report_Data_Capture_Date__c 
                                                            from ffrr__RevenueRecognitionTransactionLine__c 
                                                            order by createddate desc limit 1];
        trans.Report_Data_Capture_Date__c = null;
        update trans;
        FFA_ProfitLossActualRevenueBatch batch = new FFA_ProfitLossActualRevenueBatch();  
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();     
    }
    
    public static testMethod void testRevenueActualsException() 
    {
        ffrr__RevenueRecognitionTransactionLine__c trans = [select Id, Report_Data_Capture_Date__c 
                                                            from ffrr__RevenueRecognitionTransactionLine__c 
                                                            order by createddate desc limit 1];
        trans.Report_Data_Capture_Date__c = null;
        update trans;
        FFA_ProfitLossActualRevenueBatch batch = new FFA_ProfitLossActualRevenueBatch();  
        batch.testException = true;
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    }
    @future //Added for case - 00257645
    //public static testMethod void testLaborCostForecasts() { //Commented for case - 00257645
    public static void testLaborCostForecasts() 
    {
    
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Timecard_Header__c tch;
        pse__Timecard__c tc;
        System.runAs(usr) {
            
            tch = testUtil.newTimecardHeader(true, resource.Id, proj.Id, 
                                null, milestone.Id, System.today(), System.today().addDays(6));                         
            tch.pse__Approved__c = true;
            tch.pse__Submitted__c = true;
            tch.pse__Status__c = 'Approved';
            tch.pse__Milestone__c = milestone.Id;
            update tch;  
            tc = [select Id from pse__Timecard__c where pse__Timecard_Header__c = :tch.Id limit 1];
            System.debug('tc='+tc);
        }    
        
        FFA_ProfitLossForecastCostBatch batch = new FFA_ProfitLossForecastCostBatch();  
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    } 
    @future //Added for case - 00257645
    //public static void testLaborCostForecastsException() { //Commented for case - 00257645
    public static void testLaborCostForecastsException() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Timecard_Header__c tch;
        pse__Timecard__c tc;
        System.runAs(usr) {
            
            tch = testUtil.newTimecardHeader(true, resource.Id, proj.Id, 
                                null, milestone.Id, System.today(), System.today().addDays(6));                         
            tch.pse__Approved__c = true;
            tch.pse__Submitted__c = true;
            tch.pse__Status__c = 'Approved';
            tch.pse__Milestone__c = milestone.Id;
            update tch;  
            tc = [select Id from pse__Timecard__c where pse__Timecard_Header__c = :tch.Id limit 1];
            System.debug('tc='+tc);
        }    
        
        FFA_ProfitLossForecastCostBatch batch = new FFA_ProfitLossForecastCostBatch();  
        batch.testException = true;
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    }
    @future //Added for case - 00257645
    //public static testMethod void testLaborCostActuals() {//Commented for case - 00257645
    public static void testLaborCostActuals() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Timecard_Header__c tch;
        pse__Timecard__c tc;
        System.runAs(usr) {
            
            tch = testUtil.newTimecardHeader(true, resource.Id, proj.Id, 
                                null, milestone.Id, System.today(), System.today().addDays(6));                         
            tch.pse__Approved__c = true;
            tch.pse__Submitted__c = true;
            tch.pse__Status__c = 'Approved';
            tch.pse__Milestone__c = milestone.Id;
            tch.pse__Include_In_Financials__c = true;
            update tch;  
            tc = [select Id from pse__Timecard__c where pse__Timecard_Header__c = :tch.Id limit 1];
            System.debug('tc='+tc);
        }    
        
        FFA_ProfitLossActualLaborCostBatch batch = new FFA_ProfitLossActualLaborCostBatch();  
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    }
     @future //Added for case - 00257645
     //public static testMethod void testLaborCostActualsException() {//Commented for case - 00257645
     public static void testLaborCostActualsException() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Timecard_Header__c tch;
        pse__Timecard__c tc;
        System.runAs(usr) {
            
            tch = testUtil.newTimecardHeader(true, resource.Id, proj.Id, 
                                null, milestone.Id, System.today(), System.today().addDays(6));                         
            tch.pse__Approved__c = true;
            tch.pse__Submitted__c = true;
            tch.pse__Status__c = 'Approved';
            tch.pse__Milestone__c = milestone.Id;
            tch.pse__Include_In_Financials__c = true;
            update tch;  
            tc = [select Id from pse__Timecard__c where pse__Timecard_Header__c = :tch.Id limit 1];
            System.debug('tc='+tc);
        }    
        
        FFA_ProfitLossActualLaborCostBatch batch = new FFA_ProfitLossActualLaborCostBatch();  
        batch.testException = true;
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest(); 
    }
    @future //Added for case - 00257645
    //public static testMethod void testExpenseCostActuals() {//Commented for case - 00257645
    public static void testExpenseCostActuals() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
        c2g__codaGeneralLedgerAccount__c gl = testUtil.newGLAccount();  
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);     
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr) {
            expReport = testUtil.newExpenseReport(true, proj.Id, milestone.Id, resource.Id);
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'Auto Mileage', 100);
            exp.pse__Status__c = 'Approved';
            exp.pse__Distance__c = 200;
            exp.pse__Tax_Type__c = 'GST';
            exp.pse__Incurred_Tax__c = 100;
            exp.pse__Milestone__c = milestone.Id;
            exp.pse__Include_In_Financials__c = true;
            exp.pse__Approved__c = true;
            exp.pse__Billing_Amount__c = 200;
            exp.ffpsai__ExpenseGLACode__c = gl.Id;
            insert exp;
        }  
        
        FFA_ProfitLossActualExpenseCostBatch batch = new FFA_ProfitLossActualExpenseCostBatch();  
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    }
    @future //Added for case - 00257645
    //public static testmethod void testExpenseCostActualsException() {//Commented for case - 00257645
    public static void testExpenseCostActualsException() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
        c2g__codaGeneralLedgerAccount__c gl = testUtil.newGLAccount();  
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);     
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr) {
            expReport = testUtil.newExpenseReport(true, proj.Id, milestone.Id, resource.Id);
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'Auto Mileage', 100);
            exp.pse__Status__c = 'Approved';
            exp.pse__Distance__c = 200;
            exp.pse__Tax_Type__c = 'GST';
            exp.pse__Incurred_Tax__c = 100;
            exp.pse__Milestone__c = milestone.Id;
            exp.pse__Include_In_Financials__c = true;
            exp.pse__Approved__c = true;
            exp.pse__Billing_Amount__c = 200;
            exp.ffpsai__ExpenseGLACode__c = gl.Id;
            insert exp;
        }  
        
        FFA_ProfitLossActualExpenseCostBatch batch = new FFA_ProfitLossActualExpenseCostBatch();  
        batch.testException = true;
        Test.StartTest();
            Database.executeBatch(batch);         
        Test.StopTest();
    }

    public static testMethod void testScheduler() {
        String CRON_EXP = '0 0 1 * * ?';
        FFA_ProfitLossReportingDataScheduler sch = new FFA_ProfitLossReportingDataScheduler();
        System.schedule('1 am report data capture Job', CRON_EXP, sch);  
    }
   
    // Start
     public static testMethod void processRevenueActualsTest()
    {
		Profit_Loss_Reporting_Data__c prfLoss= new Profit_Loss_Reporting_Data__c();
        insert prfLoss;
        ffrr__RevenueRecognitionTransactionLine__c trans = [select Id, Report_Data_Capture_Date__c,ffrr__RecognizedDate__c
                                                            from ffrr__RevenueRecognitionTransactionLine__c 
                                                            order by createddate desc limit 1];
        trans.Report_Data_Capture_Date__c = null;
        //trans.Profit_Loss_Reporting_Data__c = prfLoss.id;
        update trans;
        List<ffrr__RevenueRecognitionTransactionLine__c> revList = new List<ffrr__RevenueRecognitionTransactionLine__c>();
        revList.add(trans);
        test.startTest();
        FFA_ProfitLossReportingDataActions.processRevenueActuals(revList);
        test.stopTest();
        
    }
    public static testMethod void processRevenueForecastsTest()
    {
       FFA_TestUtility testUtil = new FFA_TestUtility();
       User usr = testUtil.newUserSysAdmin(true);      
       Account acct = testUtil.newAccount(true);
       pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
       pse__Region__c reg = testUtil.newRegionMaster(true);
       Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
       pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id); 
       Id practId = [select Id from pse__Practice__c limit 1].Id;
       pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        
        pse__Time_Period__c period = [select Id, Name, pse__End_Date__c, pse__Start_Date__c 
                                      From pse__Time_Period__c
                                      Where pse__End_Date__c > :System.today()
                                      And pse__Start_Date__c <= :System.today() limit 1];
   		pse__Forecast__c forecast = new pse__Forecast__c();
        forecast.pse__Entered_Forecast__c = 100;
        forecast.Expense_Cost_Forecast__c = 200;
        forecast.pse__Project__c = proj.Id;
        forecast.pse__Time_Period__c = period.Id;
        insert forecast;
        List<pse__Forecast__c> forecastList = new List<pse__Forecast__c>();
        forecastList.add(forecast);
        test.startTest();
        FFA_ProfitLossReportingDataActions.processRevenueForecasts(forecastList);
        test.stopTest();
    }
    public static testMethod void processLaborCostForecastsTest()
    {
      	FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserFFAdmin(true);
        System.runAs(usr) {      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'Time and Materials', resource.Id, acct.Id);
        pse__Schedule__c sched = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
        //pse__Assignment__c ass = testUtil.newAssignment(true,proj.Id,resource.Id,sched.Id); 
        pse__Assignment__c a = new pse__Assignment__c();
    	a.Name = 'AssignmentName';
    	a.pse__Project__c = proj.Id;
    	a.pse__Schedule__c = sched.Id;
    	a.pse__Bill_Rate__c = 40.00;
    	a.pse__Is_Billable__c = true;
    	a.pse__Cost_Rate_Amount__c = 80.00;
    	a.CurrencyIsoCode = 'USD';
    	a.pse__Resource__c = resource.Id;
        insert a;
           
        pse__Est_Vs_Actuals__c estObj = new pse__Est_Vs_Actuals__c();
        estObj.Name = 'test';
        estObj.CurrencyISOCode = 'USD';
        estObj.pse__Project__c = proj.Id;
        estObj.pse__Assignment__c = a.Id;
        estObj.pse__Actual_Hours__c = 10;
        estObj.pse__End_Date__c = System.today().addDays(6);
        estObj.pse__Estimated_Hours__c = 15;
        estObj.pse__Start_Date__c = System.today();
        insert estObj;
        List<pse__Est_Vs_Actuals__c> costList = new List<pse__Est_Vs_Actuals__c>();
        costList.add(estObj);
        test.startTest();
        FFA_ProfitLossReportingDataActions.processLaborCostForecasts(costList); 
        test.stopTest();      
    }
    }
    public static testMethod void processLaborCostActualsTest()
    {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
          
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);    
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Timecard_Header__c tch;
        pse__Timecard__c tc;
        System.runAs(usr) {
            
            tch = testUtil.newTimecardHeader(true, resource.Id, proj.Id, 
                                null, milestone.Id, System.today(), System.today().addDays(6));                         
            tch.pse__Approved__c = true;
            tch.pse__Submitted__c = true;
            tch.pse__Status__c = 'Approved';
            tch.pse__Milestone__c = milestone.Id;
            tch.pse__Include_In_Financials__c = true;
            update tch;  
            tc = [select Id,CurrencyIsoCode,pse__Project__r.pse__Account__c,
                  pse__Assignment__r.pse__Cost_Rate_Amount__c,Is_Daily_Bill_Rate__c,pse__Total_Hours__c,
                  pse__Resource__r.pse__External_Resource__c,pse__End_Date__c,Report_Data_Capture_Date__c,
                  pse__Resource__c,pse__Project__c
                  from pse__Timecard__c where pse__Timecard_Header__c = :tch.Id limit 1];

        List<pse__Timecard__c> timeList = new List<pse__Timecard__c>();
        timeList.add(tc);
        test.startTest();
        FFA_ProfitLossReportingDataActions.processLaborCostActuals(timeList);
        test.stopTest();  
        }
    }
    public static testMethod void processExpenseCostActualsTest()
    {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);      
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);      
        c2g__codaGeneralLedgerAccount__c gl = testUtil.newGLAccount();  
        pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
        Id practId = [select Id from pse__Practice__c limit 1].Id;
        pse__Proj__c proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);     
        pse__Milestone__c milestone = testUtil.newMilestone(true, proj.Id, 100, System.today());
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr) {
            expReport = testUtil.newExpenseReport(true, proj.Id, milestone.Id, resource.Id);
            exp = testUtil.newExpense(false, expReport.Id, milestone.Id, proj.Id, resource.Id, 'Auto Mileage', 100);
            exp.pse__Status__c = 'Approved';
            exp.pse__Distance__c = 200;
            exp.pse__Tax_Type__c = 'GST';
            exp.pse__Incurred_Tax__c = 100;
            exp.pse__Milestone__c = milestone.Id;
            exp.pse__Include_In_Financials__c = true;
            exp.pse__Approved__c = true;
            exp.pse__Billing_Amount__c = 200;
            exp.ffpsai__ExpenseGLACode__c = gl.Id;
            insert exp;
            List<pse__Expense__c> expList = new List<pse__Expense__c>();
            expList.add(exp);
            test.startTest();
            FFA_ProfitLossReportingDataActions.processExpenseCostActuals(expList);
            test.stopTest();  
        
        }
    }
    //End
}