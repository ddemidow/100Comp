@isTest
private class TestBatchToPopulateReportingEndDate {
    static  Date todayDate ;
    static  ID userId ;
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void Testmethod1() {
        userId = UserInfo.getUserId();
        todayDate = Date.today();
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
          //Insert Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.CurrencyIsoCode = 'USD';
        insert testAccount;
        system.assert(testAccount.Id != null);
        //
        Set<String> userProfile = new Set<String>();
        userProfile.add('PSE Manager');
        userProfile.add('PSE User');
        userProfile.add('System Administrator');
       
        Map<String,ID> userProfileMap = new Map<String,ID>();
       
        for(Profile profile : [Select Id,Name from Profile where Name in : userProfile]){
         userProfileMap.put(profile.Name,profile.Id);
        }
        //Insert User
        User u = new User();
        User runUser=[Select id,IsActive from User where Profile.Name ='System Administrator' AND IsActive=true LIMIT 1];
        System.runAs(runUser){
            u.Username = math.random()+'123@test.com';
            u.LastName = 'User Manager';
            u.Email = 'a@b.com';
            u.Alias = 'tes12';
            u.CommunityNickname = 'tuser31';
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
			u.ProfileId=userProfileMap.get('System Administrator');
            u.LanguageLocaleKey = 'en_US';
            u.ManagerId = UserInfo.getUserId();
            insert u;
               
        }
        //Insert region 
        pse__Region__c pse_region = new pse__Region__c();
        pse_region.Name = 'test region';
        pse_region.CurrencyIsoCode = 'USD';
        pse_region.ffpsai__OwnerCompany__c = comp.id;
        insert pse_region;
        system.assert(pse_region.Id != null);
        
        //Insert Practice
        pse__Practice__c pse_practice = new pse__Practice__c(Name = 'test practice');
        pse_practice.CurrencyIsoCode = 'USD';
        insert pse_practice;
        system.assert(pse_practice.Id != null);
        
        //Insert Group
        pse__Grp__c  pse_group = new pse__Grp__c(name='test Group');
        pse_group.CurrencyIsoCode = 'USD';
        insert pse_group;
        system.assert(pse_group.Id!=null);
        
        //Insert contact
        Contact xpm = new Contact();
        xpm.LastName = 'Test';
        xpm.AccountId = testAccount.Id;
        xpm.CurrencyIsoCode = 'USD';
        xpm.pse__Is_Resource_Active__c = true;
        xpm.pse__Is_Resource__c = true;    
        xpm.pse__Resource_Role__c ='Consultant';
        xpm.pse__Default_Cost_Rate__c = 25.0;
        xpm.pse__Region__c = pse_region.Id;
        xpm.pse__Salesforce_User__c = u.Id;  
        xpm.Email = 'a@b.com'; 
        Insert xpm; 
        
        //List<Contact> contList = new List<Contact>();
        //contList.add(xpm);
        
        //Insert Project
        List< pse__Proj__c > projectList = new List< pse__Proj__c >();
        pse__Proj__c project = new pse__Proj__c(Name='test_project');
        project.pse__Is_Billable__c = true;
        project.pse__Is_Active__c = true;
        project.pse__Project_Status__c = 'Green';
        project.pse__Allow_Timecards_Without_Assignment__c = true; 
        project.pse__Start_Date__c = todayDate.addMonths(-1);
        project.pse__End_Date__c = todayDate.addMonths(4);
        project.pse__Region__c = pse_region.Id;     
        project.pse__Practice__c = pse_practice.Id; 
        project.pse__Group__c = pse_group.Id; 
        
        project.CurrencyIsoCode ='USD';
        project.pse__Billing_Type__c = 'Administrative';
        project.pse__Project_Manager__c = xpm.id;
        project.OwnerId = u.id;
        project.pse__Project_Type__c = 'Sales';
        projectList.add(project);
        Insert projectList;
       
        List<pse__Milestone__c> mStones = new List<pse__Milestone__c>();
        for (integer i=0;i<100;i++)
        {
        pse__Milestone__c mStone1 = new pse__Milestone__c();
        mStone1.pse__Project__c = project.Id;
        mStone1.pse__Actual_Date__c  = system.today();
        mStone1.End_Date__c = system.today();
        mStone1.ffrr_exp__IncludeinRevenueRecognition__c=true;
        mStone1.pse__Milestone_Amount__c  = 1000;
        mStone1.pse__Billing_Hold__c = false;
        mStone1.pse__Exclude_from_Billing__c = false;
        mStone1.pse__Billed__c = false;
        mStone1.pse__Invoiced__c = false;
        mStone1.pse__Billing_Event_Item__c = null;
        mStone1.pse__Target_Date__c = system.today();
        mStones.add(mStone1);
       }
        Insert mStones;
        /* FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acct = testUtil.newAccount(true);
        User usr2 = testUtil.newUserSysAdmin(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        //pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact resource = testUtil.newResource(true, acct.Id, usr2.Id, pse_region.Id, cal.Id);
        pse__Expense_Report__c expReport;
        pse__Expense__c exp;
        System.runAs(usr2) {  
            pse__Schedule__c sched1 = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
            pse__Assignment__c ass1 = testUtil.newAssignment(true,project.Id,xpm.Id,sched1.Id);
            expReport = testUtil.newExpenseReport(false, project.Id, mStone1.Id, resource.Id);
            expReport.pse__Billable__c = false;
            expReport.pse__Assignment__c = ass1.id;
            insert expReport;
            exp = testUtil.newExpense(false, expReport.Id, mStone1.Id, project.Id, resource.Id, 'test', 444);
            exp.pse__Billable__c = false;
            insert exp;
            exp.pse__Status__c = 'Submitted';
            exp.pse__Expense_Date__c=system.today();
            update exp;  
        }
       */
       /*
        pse__Timecard_Header__c th1= new pse__Timecard_Header__c();
        th1.pse__Start_Date__c = date.today(); 
        th1.pse__End_Date__c = date.today()+6;
        th1.pse__Project__c =  project.Id;
        th1.pse__Resource__c = xpm.Id;
        th1.pse__Milestone__c = mStone1.Id; 
        Insert th1;
        
       pse__Timecard__c t1 = new pse__Timecard__c();
        t1.pse__Start_Date__c = date.today(); 
        t1.pse__End_Date__c = date.today() +6;
        t1.pse__Project__c =  project.Id;
        t1.pse__Total_Hours__c = 16;
        t1.pse__Resource__c = xpm.Id;
        t1.pse__Milestone__c = mStone1.Id; 
        t1.pse__Timecard_Header__c= th1.Id; 
        Insert t1;     
        */
        /*
        pse__Schedule__c sched = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
        pse__Assignment__c ass = testUtil.newAssignment(true,project.Id,xpm.Id,sched.Id);
        pse__Est_Vs_Actuals__c estObj = new pse__Est_Vs_Actuals__c();
        estObj.Name = 'test';
        estObj.pse__Project__c = project.Id;
        estObj.pse__Assignment__c = ass.Id;
        estObj.pse__Actual_Hours__c = 10;
        estObj.pse__End_Date__c = System.today().addDays(6);
        estObj.pse__Estimated_Hours__c = 15;
        estObj.pse__Start_Date__c = System.today();
        estObj.pse__Time_Period_Type__c = 'Week';
        insert estObj;
        */
        Test.startTest();         
        BatchToPopulateReportingEndDate b = new BatchToPopulateReportingEndDate();
        Database.queryLocator q = b.start(null);
        b.execute(null,projectList);
        b.Finish(null);
        //Database.executeBatch(b,200); //commented for Case -254740
        Database.executeBatch(b,50); //Modified for case 254740
        //Database.execute(b,contList);
        //Database.executeBatch(b,200);
        //Test.startTest();
        //Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new BatchToPopulateReportingEndDate());
       Test.stopTest();
       /*
       c2g__codaTransactionLineItem__c c2 = new c2g__codaTransactionLineItem__c();
       insert c2;
       */ //Commented for case 254740 
      }
   }