/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 17 Dec 2015
Purpose : Test Class for  DueDateTaskUpdatedBatchTest
*********************************************************************************/
@isTest
public class DueDateTaskUpdatedBatchTest {
   
    static testMethod  void  testTaskDueDate(){
      
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
         UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Miles Group' limit 1]; 
         User u = createTestUser(p.Id, role.id, 'test','user1');
         System.runAs ( u ){
         
         //RecordType rt = [select id,Name from RecordType where SobjectType='Milestone1_Task__c' and Name='Highlight & Summarize' Limit 1]; //Updated by Jasvinder for case: 00204418
         Id rtId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('All Functions').RecordTypeId;

         String taskName = 'Unit Test Email Notes 123';
         Test.StartTest();//Added for case 254740
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
            insert proj;

            Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
            ms1.Alias__c = 'unit_test';
            insert ms1;

            Milestone1_Task__c msTask1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
            msTask1.recordTypeId = rtId;
            msTask1.Name = taskName;
       
            msTask1.Assigned_To__c = u.id ;
            msTask1.Task_Stage__c  = 'Scheduled';
            msTask1.Due_Date__c = System.today().addDays(-7);
            insert msTask1;
            // START ADDED BY Rohit for S-635394
            List <Milestone1_Task__c> milList = new List <Milestone1_Task__c>();
             milList.add(msTask1);
         //} Commented by Jasvinder for case: 00204418
        //Test.startTest();//commented for case 254740
         //Id BatchId = DataBase.executeBatch(new DueDateTaskUpdatedBatch(), 200);     
            DueDateTaskUpdatedBatch btch = new DueDateTaskUpdatedBatch();
            Database.QueryLocator ql = btch.start(null);
            btch.execute(null,milList);
            btch.Finish(null);
             // END ADDED BY Rohit for S-635394
        test.stopTest(); 
        } //Added by Jasvinder for case: 00204418 
     }
     
     static testMethod  void  testTaskScheduler(){
       Test.StartTest();
       DueDateTaskUpdatedBatchScheduler sh1 = new DueDateTaskUpdatedBatchScheduler();
       String sch = '0 0 6 * * ?';
       system.schedule('Test check', sch, sh1);
       Test.stopTest();
     }
    // create User
    static User createTestUser(Id profID, Id roleId, String fName, String lName) {
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
                            ProfileId = profId,
                            UserRoleId = roleId
                            );
            insert tuser;                
            return tuser;
        }
}