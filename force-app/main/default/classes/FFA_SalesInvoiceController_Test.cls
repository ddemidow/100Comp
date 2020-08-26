/**************************************************************************************************
Description:      This class contains methods that test FFA_SalesInvoiceController
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
12/01/2013              Liz Ichihashi                  Created new class.
28/08/2019              Shivani Jain                   Modified the whole Class for Code Coverage S-637724
**************************************************************************************************/
//START -- Modified by Shivani for S-637724 on 28/08/2019
@isTest
private class FFA_SalesInvoiceController_Test {
        
    @isTest
    private static void testInvoicePDFWithBE() {
        Test.startTest();
        pse__Billing_Event__c billEvent;
        //START -- Commented by komal | C-00277396 | 24/04/2020 |in order to fix CPU time limit error
        //pse__Proj__c project;
        //END -- Commented by komal | C-00277396 | 24/04/2020 |
        pse__Proj__c proj;
        Opportunity opp;
        c2g__codaInvoice__c inv;
        pse__Billing_Event_Item__c bEventItem;
         //Create Parent Group
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', FirstName = 'FF The Miles', LastName='Group, LLC', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123345@testorg.com');
        insert u;
        Group grp = new Group();
        QueuesObject testQueue = new QueuesObject();
        System.runAs(u) {

            grp.Name = 'FF The Miles Group, LLC';
            grp.Type = 'Queue'; 
            Insert grp; 
            System.debug(grp.Name);
            testQueue = new QueueSObject(QueueID = grp.id, SobjectType = 'c2g__codaInvoice__c');
            insert testQueue;

        }
        
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acct = testUtil.newAccount(true);
        acct.c2g__CODAAccountTradingCurrency__c = 'USD';
        acct.c2g__CODATaxCalculationMethod__c = 'Gross';
        update acct;
        Contact c1 = new Contact();
        c1.AccountId = acct.Id;
        c1.Vacation_Beg_Bal__c = 100;
        c1.Sick_Begin_Balance__c = 50;
        c1.pse__Salesforce_User__c = UserInfo.getUserId();
        c1.LastName = 'test Contact';
        c1.ffpsai__ExpenseReimbursementAccount__c = acct.Id;
        insert c1;

        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs(thisUser) {
            c2g__codaCompany__c comp = c2g.CODAAPICompany_2_0.CreateTestCompany( 'name',  'taxMode',  '$');
            pse__Region__c reg = new pse__Region__c(
                Name = 'Region1',
                ffpsai__OwnerCompany__c = comp.Id,
                Timecard_Approval__c = 'One Step',
                Expense_Approval__c = 'One Step'
                );

            insert reg;
            //START -- Commented by komal | C-00277396 | 24/04/2020 |in order to fix CPU time limit error
            /*project = new pse__Proj__c();
            project.Name = 'Vacation';
            project.pse__Account__c = acct.id;
            project.CurrencyIsoCode = 'USD';
            project.pse__Start_Date__c = date.today().addYears(-1);
            project.pse__Region__c = reg.id;
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
            insert project;*/
            //END -- Commented by komal | C-00277396 | 24/04/2020 |

            User usr = testUtil.newUserSysAdmin(true);  
            Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);  
            opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.StageName = 'Prospecting';
            opp.CloseDate = system.today();
            opp.AccountId = acct.Id;
            opp.Participant_Contact__c = resource.Id;
            opp.Group2__c = 'G100 Network';
            opp.Amount = 10;
            opp.Membership_Type__c = 'NGL ($75K)';
            opp.Membership_Expires__c = System.today();
            insert opp;
            pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
            pse__Practice__c pr = new pse__Practice__c(Name='Test');
            insert pr;
            Id practId = pr.Id;
            //START -- Modified by komal | C-00277396 | 24/04/2020 |replace 'Project.id' with 'Proj.id' in order to fix CPU time limit error
            proj = testUtil.newProject(true,reg.id,practId,true,'One-Time: Fixed Price', resource.Id, acct.Id);
            billEvent = testUtil.newBillingEvent(true, proj.Id) ;
            bEventItem= testUtil.newBillingEventItem(true, billEvent.Id, acct.Id, 'Expense', proj.Id); 
            pse__Miscellaneous_Adjustment__c  misAdjus = testUtil.newMiscellaneousAdjustment(false, proj.Id, 'Other Cost', 120);
            misAdjus.pse__Billing_Event_Item__c = bEventItem.Id;
            insert misAdjus;
               // c2g__codaTransaction__c ctrans = [select Id from c2g__codaTransaction__c limit 1];
        }
            inv = new c2g__codaInvoice__c();    
            inv.ffpsai__BillingEvent__c = billEvent.Id;
            inv.c2g__InvoiceDescription__c  = 'test desc';
            inv.c2g__InvoiceDate__c = System.today();
            inv.c2g__DueDate__c = System.today();
            inv.Project__c = proj.Id;
            inv.c2g__Opportunity__c = opp.Id;
            inv.c2g__Account__c = acct.Id;
            insert inv;
        
           
            Product2 prod = new Product2(Name = 'Laptop X200',
            Family = 'Hardware', isActive=true);
            insert prod;


            c2g__codaInvoiceLineItem__c c = new c2g__codaInvoiceLineItem__c ();
            c.c2g__Invoice__c = inv.Id;
            c.c2g__Product__c = prod.Id;
            c.c2g__UnitPrice__c = 12;
            c.ffpsai__BillingEventItem__c = bEventItem.Id;
            insert c;

            pse__Milestone__c vacStone = new pse__Milestone__c();
            vacStone.pse__Billing_Event_Item__c = bEventItem.Id;
            vacStone.pse__Project__c = proj.Id;
            vacStone.pse__Target_Date__c = date.today() +10;
            insert vacStone;
            pse__Timecard_Header__c th1= new pse__Timecard_Header__c();
            th1.pse__Start_Date__c = date.today(); 
            th1.pse__End_Date__c = date.today()+6;
            th1.pse__Project__c = proj.Id;
            th1.pse__Resource__c = c1.Id;
            th1.pse__Milestone__c = vacStone.Id;
            insert th1;
         
        
            pse__Timecard__c t1 = new pse__Timecard__c();
            t1.pse__Start_Date__c = date.today(); 
            t1.pse__End_Date__c = date.today() +6;
            t1.pse__Project__c = proj.Id;
            t1.pse__Total_Hours__c = 16;
            t1.pse__Resource__c = c1.Id;
            t1.pse__Milestone__c = vacStone.Id;
            t1.pse__Timecard_Header__c= th1.Id;
            t1.pse__Status__c = 'Approved';
            t1.pse__External_Resource__c = TRUE;
            t1.pse__Billable__c = TRUE;
            t1.pse__Billing_Event_Item__c = bEventItem.Id;
            insert t1;
           
            FFA_SalesInvoiceController invController = new FFA_SalesInvoiceController();
            ApexPages.StandardController sc = new ApexPages.StandardController(inv);
            invController = new FFA_SalesInvoiceController(sc);
            invController.getLogo();
            invController.createDisplayFromLine(c, 'Description');
            inv.ffpsai__BillingEvent__c = null;
            update inv;
            invController = new FFA_SalesInvoiceController(sc);
            
            inv = new c2g__codaInvoice__c();    
            inv.ffpsai__BillingEvent__c = billEvent.Id;
            inv.c2g__InvoiceDescription__c  = 'test desc';
            inv.c2g__InvoiceDate__c = System.today();
            inv.c2g__DueDate__c = System.today();
            inv.c2g__Opportunity__c = opp.Id;
            inv.c2g__Account__c = acct.Id;
            inv.Project__c = proj.Id;
            inv.OwnerId = grp.Id;
            insert inv;
            System.debug(inv.Owner.Name);
            sc = new ApexPages.StandardController(inv);
            invController = new FFA_SalesInvoiceController(sc);
            //END -- Modified by komal | C-00277396 | 24/04/2020 |replace 'Project.id' with 'Proj.id' 
        Test.stopTest();
    }

    @isTest
    private static void testInvoicePDFWithBE1() {
        Test.startTest();
        pse__Billing_Event__c billEvent;
        pse__Proj__c project;
        pse__Proj__c proj;
        Opportunity opp;
        c2g__codaInvoice__c inv;
        pse__Billing_Event_Item__c bEventItem;
         //Create Parent Group
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', FirstName = 'FF The Miles', LastName='Group, LLC', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123345@testorg.com');
        insert u;
        Group grp = new Group();
        QueuesObject testQueue = new QueuesObject();
        System.runAs(u) {

            grp.Name = 'FF The Miles Group, LLC';
            grp.Type = 'Queue'; 
            Insert grp; 
            System.debug(grp.Name);
            testQueue = new QueueSObject(QueueID = grp.id, SobjectType = 'c2g__codaInvoice__c');
            insert testQueue;

        }
        
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acct = testUtil.newAccount(true);
        acct.c2g__CODAAccountTradingCurrency__c = 'USD';
        acct.c2g__CODATaxCalculationMethod__c = 'Gross';
        update acct;
        Contact c1 = new Contact();
        c1.AccountId = acct.Id;
        c1.Vacation_Beg_Bal__c = 100;
        c1.Sick_Begin_Balance__c = 50;
        c1.pse__Salesforce_User__c = UserInfo.getUserId();
        c1.LastName = 'test Contact';
        c1.ffpsai__ExpenseReimbursementAccount__c = acct.Id;
        insert c1;

        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Insert account as current user
        System.runAs(thisUser) {
            c2g__codaCompany__c comp = c2g.CODAAPICompany_2_0.CreateTestCompany( 'name',  'taxMode',  '$');
            pse__Region__c reg = new pse__Region__c(
                Name = 'Region1',
                ffpsai__OwnerCompany__c = comp.Id,
                Timecard_Approval__c = 'One Step',
                Expense_Approval__c = 'One Step'
                );

            insert reg;
            project = new pse__Proj__c();
            project.Name = 'Vacation';
            project.pse__Account__c = acct.id;
            project.CurrencyIsoCode = 'USD';
            project.pse__Start_Date__c = date.today().addYears(-1);
            project.pse__Region__c = reg.id;
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
            project.Billing_Resource_Rate_Type__c = 'All';
            insert project;

            User usr = testUtil.newUserSysAdmin(true);  
            Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);  
            opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.StageName = 'Prospecting';
            opp.CloseDate = system.today();
            opp.AccountId = acct.Id;
            opp.Participant_Contact__c = resource.Id;
            opp.Group2__c = 'G100 Network';
            opp.Amount = 10;
            opp.Membership_Type__c = 'NGL ($75K)';
            opp.Membership_Expires__c = System.today();
            insert opp;
            pse__Permission_Control__c pc = testUtil.newPermissionControl(true,usr.Id,reg.Id);  
            pse__Practice__c pr = new pse__Practice__c(Name='Test');
            insert pr;
            Id practId = pr.Id;
            billEvent = testUtil.newBillingEvent(true, project.Id) ;
            bEventItem= testUtil.newBillingEventItem(true, billEvent.Id, acct.Id, 'Expense', project.Id); 
            pse__Miscellaneous_Adjustment__c  misAdjus = testUtil.newMiscellaneousAdjustment(false, project.Id, 'Other Cost', 120);
            misAdjus.pse__Billing_Event_Item__c = bEventItem.Id;
            insert misAdjus;
        }
            inv = new c2g__codaInvoice__c();    
            inv.ffpsai__BillingEvent__c = billEvent.Id;
            inv.c2g__InvoiceDescription__c  = 'test desc';
            inv.c2g__InvoiceDate__c = System.today();
            inv.c2g__DueDate__c = System.today();
            inv.c2g__Opportunity__c = opp.Id;
            inv.c2g__Account__c = acct.Id;
            insert inv;
        
           
            Product2 prod = new Product2(Name = 'Laptop X200',
            Family = 'Hardware', isActive=true);
            insert prod;


            c2g__codaInvoiceLineItem__c c = new c2g__codaInvoiceLineItem__c ();
            c.c2g__Invoice__c = inv.Id;
            c.c2g__Product__c = prod.Id;
            c.c2g__UnitPrice__c = 12;
            c.ffpsai__BillingEventItem__c = bEventItem.Id;
            insert c;

            pse__Milestone__c vacStone = new pse__Milestone__c();
            vacStone.pse__Billing_Event_Item__c = bEventItem.Id;
            vacStone.pse__Project__c = project.Id;
            vacStone.pse__Target_Date__c = date.today() +10;
            insert vacStone;
            pse__Timecard_Header__c th1= new pse__Timecard_Header__c();
            th1.pse__Start_Date__c = date.today(); 
            th1.pse__End_Date__c = date.today()+6;
            th1.pse__Project__c = project.Id;
            th1.pse__Resource__c = c1.Id;
            th1.pse__Milestone__c = vacStone.Id;
            insert th1;

            pse__Timecard__c t1 = new pse__Timecard__c();
            t1.pse__Start_Date__c = date.today(); 
            t1.pse__End_Date__c = date.today() +6;
            t1.pse__Project__c = project.Id;
            t1.pse__Total_Hours__c = 16;
            t1.pse__Resource__c = c1.Id;
            t1.pse__Milestone__c = vacStone.Id;
            t1.pse__Timecard_Header__c= th1.Id;
            t1.pse__Status__c = 'Approved';
            t1.pse__External_Resource__c = TRUE;
            t1.pse__Billable__c = TRUE;
            t1.pse__Billing_Event_Item__c = bEventItem.Id;
            insert t1;

            FFA_SalesInvoiceController invController = new FFA_SalesInvoiceController();
            ApexPages.StandardController sc = new ApexPages.StandardController(inv);
            invController = new FFA_SalesInvoiceController(sc);
            invController.getLogo();
            invController.createDisplayFromLine(c, 'Description');
            inv.ffpsai__BillingEvent__c = null;
            update inv;
            invController = new FFA_SalesInvoiceController(sc);
            
            inv = new c2g__codaInvoice__c();    
            inv.ffpsai__BillingEvent__c = billEvent.Id;
            inv.c2g__InvoiceDescription__c  = 'test desc';
            inv.c2g__InvoiceDate__c = System.today();
            inv.c2g__DueDate__c = System.today();
            inv.c2g__Opportunity__c = opp.Id;
            inv.c2g__Account__c = acct.Id;
            inv.OwnerId = grp.Id;
            insert inv;
            System.debug(inv.Owner.Name);
            sc = new ApexPages.StandardController(inv);
            invController = new FFA_SalesInvoiceController(sc);

        Test.stopTest();
    }
//END -- Modified by Shivani for S-637724 on 28/08/2019
}