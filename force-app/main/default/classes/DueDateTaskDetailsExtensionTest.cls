/*********************************************************************************
Name : Jyotirmaya Rath
Created By : Appirio  
Created Date : 03 Nov 2015
Purpose : Test Class For DueDateTaskDetailsExtension
 *********************************************************************************/
@isTest
public class DueDateTaskDetailsExtensionTest {
    @isTest public static void testTaskDueDate(){
        String taskName = 'Unit Test Email Notes 123';
        Test.startTest(); //added for case 254740      
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
            insert proj;

            Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
            ms1.Alias__c = 'unit_test';
            insert ms1;

            Milestone1_Task__c msTask1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
            msTask1.Name = taskName;
       
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1]; 
            User u = createTestUser(p.Id,'test','user1');
            msTask1.Assigned_To__c = u.id ;
      //      msTask1.Email_GUID__c = 'UNIQUE_TEST123' + Date.today();
            insert msTask1;
        //Test.startTest();//commented for case 254740       
           PageReference pageRef = Page.DueDateTaskdetails;                        
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id', msTask1.id);  
           ApexPages.currentPage().getParameters().put('ans', 'yes');
           DueDateTaskDetailsExtension Ext = new DueDateTaskDetailsExtension(new ApexPages.StandardController(msTask1));
                                          
           Ext.answerYes();
         ApexPages.currentPage().getParameters().put('ans', 'no');
        Ext = new DueDateTaskDetailsExtension(new ApexPages.StandardController(msTask1));
        Ext.answerYes();
        ext.submitTask();
           
           Test.stopTest();
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