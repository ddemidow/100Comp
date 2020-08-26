/****************************************
 Created By : Kritika Bhati
 Description : Test class for MilestoneTriggerHandler(S-534163)
Created Date: 12/27/2017
 * ************************************/
@isTest
public class MilestoneTriggerHandlerTest {
   
      static testMethod void createData(){
        Id milRecordTypeId = fetchRecordTypeId('pse__Milestone__c', 'Billable Milestone');
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
        c1.ffpsai__ExpenseReimbursementAccount__c = acc.Id;
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
        vacStone.pse__Milestone_Amount__c = 2000;
        vacStone.Billable__c = true;   
        vacStone.RecordTypeId=  milRecordTypeId;
        mlist.add(vacStone);
        
        pse__Milestone__c sickStone = new pse__Milestone__c();
        sickStone.pse__Project__c = sickProj.Id;
        sickStone.pse__Target_Date__c = date.today() +10;
        mlist.add(sickStone);
        
        insert mlist;
        vacStone.pse__Milestone_Amount__c = 4000;
        update vacStone;
       pse__Proj__c newval = [Select Id, Total_Contract_Amount__c from pse__Proj__c where Name = 'Vacation' limit 1];
            System.assertEquals(newval.Total_Contract_Amount__c, 4000);
    }
          

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
    private static id fetchRecordTypeId(string sObj, string rt) {
        return Schema.getGlobalDescribe().get(sObj).getDescribe().getRecordTypeInfosByName().get(rt).getRecordTypeId();
    }

}