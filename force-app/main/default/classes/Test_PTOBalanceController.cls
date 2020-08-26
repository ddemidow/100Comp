/*******************************************************************************
* @Class       : Test_PTOBalanceController
* @author      : Hemlata Mandowara (Appirio JDC)
* @date        : Aug 2014
* @description : Test Class of PTOBalanceController (S-253235)
*******************************************************************************/
@isTest
private class Test_PTOBalanceController {
    static testMethod void testPTOBalanceController() {
       Profile p = [SELECT Id FROM Profile WHERE Name='FinancialForce Admin']; 
       User u = createTestUser(p.Id,'test','user1');
       System.runAs(u) {
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Contact c1 = new Contact();
        c1.AccountId = acc.Id;
        c1.Vacation_Beg_Bal__c = 100;
        c1.Sick_Begin_Balance__c = 50;
        c1.pse__Salesforce_User__c = u.Id;
        c1.LastName = 'test Contact';
        insert c1;
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
       //Insert region 
        pse__Region__c region = new pse__Region__c();
        region.Name = 'test region';
        region.CurrencyIsoCode = 'USD';
        region.ffpsai__OwnerCompany__c = comp.id;
        insert region ;
        
        pse__Proj__c vacationProj = createProject('Vacation',acc,region );
        pse__Proj__c sickProj = createProject('Sick',acc,region );
        
        List<pse__Milestone__c > mlist = new List<pse__Milestone__c >();
        
        pse__Milestone__c vacStone = new pse__Milestone__c();
        vacStone.pse__Project__c = vacationProj.Id;
        vacStone.pse__Target_Date__c = date.today() +10;
        mlist.add(vacStone);
        
        pse__Milestone__c sickStone = new pse__Milestone__c();
        sickStone.pse__Project__c = sickProj.Id;
        sickStone.pse__Target_Date__c = date.today() +10;
        mlist.add(sickStone);
        
        insert mlist;
        
        List<pse__Timecard_Header__c> tlist = new List<pse__Timecard_Header__c>();
        
        pse__Timecard_Header__c th1= new pse__Timecard_Header__c();
        th1.pse__Start_Date__c = date.today(); 
        th1.pse__End_Date__c = date.today()+6;
        th1.pse__Project__c = vacationProj.Id;
        th1.pse__Resource__c = c1.Id;
        th1.pse__Milestone__c = mlist[0].Id;
        tlist.add(th1);
        
        pse__Timecard_Header__c th2 = new pse__Timecard_Header__c();
        th2.pse__Start_Date__c = date.today(); 
        th2.pse__End_Date__c = date.today() +6;
        th2.pse__Project__c = sickProj.Id;
        th2.pse__Resource__c = c1.Id;
        th2.pse__Milestone__c = mlist[1].Id;
        tlist.add(th2);
        
        insert tlist;
        
        List<pse__Timecard__c> tclist = new List<pse__Timecard__c >();
        
        pse__Timecard__c t1 = new pse__Timecard__c();
        t1.pse__Start_Date__c = date.today(); 
        t1.pse__End_Date__c = date.today() +6;
        t1.pse__Project__c = vacationProj.Id;
        t1.pse__Total_Hours__c = 16;
        t1.pse__Resource__c = c1.Id;
        t1.pse__Milestone__c = mlist[0].Id;
        t1.pse__Timecard_Header__c= tlist[0].Id;
        tclist.add(t1);
        
        pse__Timecard__c t2 = new pse__Timecard__c();
        t2.pse__Start_Date__c = date.today(); 
        t2.pse__End_Date__c = date.today() +6;
        t2.pse__Project__c = sickProj.Id;
        t2.pse__Total_Hours__c = 16;
        t2.pse__Resource__c = c1.Id;
        t2.pse__Milestone__c = mlist[1].Id;
        t2.pse__Timecard_Header__c = tlist[1].Id;
        tclist.add(t2);
        
        insert tclist;
        
               
        PTOBalanceController controller = new PTOBalanceController();
        controller.getBarData();
        
        
        }
       
      }
        
        
     private static pse__Proj__c createProject(String name, Account acc,pse__Region__c region) {
            pse__Proj__c project = new pse__Proj__c();
            project.Name = name;
            project.pse__Account__c = acc.id;
            project.CurrencyIsoCode = 'USD';
            project.pse__Start_Date__c = date.today().addYears(-1);
            project.pse__Region__c = region.id;
            project.pse__Project_Type__c = 'Customer Project';
            project.pse__Project_Status__c = 'Green';
            project.pse__Is_Billable__c = true;
            project.pse__Is_Active__c = true;
            project.pse__Invoiced__c = 50000;
            project.pse__End_Date__c = date.today().addYears(1);
            project.pse__Closed_for_Time_Entry__c = false; 
            project.pse__Closed_for_Expense_Entry__c = false;
            project.pse__Billing_Type__c = 'Time and Materials';
            project.pse__Billed__c = 40000;
            project.pse__Allow_Timecards_Without_Assignment__c = true;
            project.pse__Allow_Expenses_Without_Assignment__c = true;
            insert project;
            return project;
        }
        
      public static User createTestUser(Id profID, String fName, String lName) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = fName,
                            lastName = lName,
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = profId
                            );
            return tuser;
        }
 }