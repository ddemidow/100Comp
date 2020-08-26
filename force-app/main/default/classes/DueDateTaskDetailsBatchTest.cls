/*********************************************************************************
Name : Jyotirmaya Rath
Created By : Appirio  
Created Date : 03 Nov 2015
Updated: 15 Jan 2018 JesseB Case 00215311
Purpose : Test Class for  DueDateTaskDetailsBatchTest
*********************************************************************************/
@isTest(SeeAllData=true) //Lokesh Korani Case 00248710
public class DueDateTaskDetailsBatchTest {
     @isTest (SeeAllData=true)//Lokesh Korani Case 00248710
    public static void testTaskDueDate(){
         String taskName = 'Unit Test Email Notes 123';
         
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
            insert proj;
            Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
            ms1.Alias__c = 'unit_test';
            //test.startTest();//added for case 254740
            insert ms1;
            //Start Lokesh Korani Case 00248710
            List<Milestone1_Milestone__c> idLst = [Select id from Milestone1_Milestone__c  WHERE Complete__c = false and Total_Open_Tasks__c = 2 and
                                                   Main_Project_Debrief__r.Project_Milestone__r.RecordType.DeveloperName = null 
                                                   AND RecordType.DeveloperName = 'Stakeholder_Debrief'];
            //End Lokesh Korani Case 00248710
            Milestone1_Task__c msTask1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
            msTask1.Name = taskName;
            msTask1.RecordType = [SELECT id FROM RecordType WHERE Name = 'Coaching Session'];
            UserRole r = [SELECT Id FROM UserRole WHERE Name='Miles Group' limit 1];
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            User u = createTestUser(p.Id,r.Id,'test','user1');
         //Start Lokesh Korani Case 00248710
             User runUser=[Select id from User where Name='Stephen Miles'];
            System.runAs(runUser){
            msTask1.Assigned_To__c = runUser.id ;
                msTask1.Complete__c = True;
            msTask1.Project_Milestone__c = idLst.get(0).id;
            msTask1.Task_Stage__c  = 'Scheduled';
            msTask1.Scheduled_Date__c  = System.today().addDays(-7);
            msTask1.First_Chair_User__c = runUser.id;
            msTask1.Second_Chair_User__c = runUser.id;
            insert msTask1;
         }          
         //End Lokesh Korani Case 00248710
         //test.startTest();//commented for case -254740
         Id BatchId = DataBase.executeBatch(new DueDateTaskDetailsBatch(), 200);
         
         //test.stopTest();

       //  test.startTest();    
     }
    // create User
    public static User createTestUser(Id profID, Id roleId, String fName, String lName) {
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
            // START JWEBB C-00228360 05/14/2018
            // insert tuser;
            // END JWEBB C-00228360 05/14/2018
            return tuser;
        }
}