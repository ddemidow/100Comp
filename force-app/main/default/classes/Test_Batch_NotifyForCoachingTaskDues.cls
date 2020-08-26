/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class Test_Batch_NotifyForCoachingTaskDues {
/**
 *  Purpose         :   This test class is for Batch_NotifyForCoachingTaskDues class.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   12/4/2015
 *
 *  Current Version :   V1.1
 *
 *  Revision Log    :   V1.0 - Created - S-358685
 *                      V1.1 - Modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
 *
 *  Coverage        :   V1.0 - 99%
 *                      V1.1 - 99%
 **/
    
    //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
    //query result of current user
    public static User currentUser = [SELECT Id FROM User WHERE Id =: Userinfo.getUserId()];
        
    static testMethod void testNotificationFirst() {
        
        Schema.DescribeSObjectResult taskObj = Milestone1_Task__c.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapRecordsType = taskObj.getRecordTypeInfosByName();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //Queyr result of current user
        UserRole role = new UserRole(name = 'Miles Group');
        
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
            insert role;       
        }
        
        List<User> users = new List<User>();
        users.add(new User(alias = 'jsmtih', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        users.add(new User(alias = 'jsmti', email='jsmit1h@acme.com', emailencodingkey='UTF-8', lastname='Smith1', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
        System.debug('line ### 69');
            insert users;
        }
        
        // Create a poject
        
        List<Milestone1_Project__c> projects = new List<Milestone1_Project__c>();
        projects.add(new Milestone1_Project__c(Name = 'Test Project', Status__c = 'Submitted'));
        insert projects;
    
        // Create a Deliverable
        List<Milestone1_Milestone__c> deliverables = new List<Milestone1_Milestone__c>();
        deliverables.add(new Milestone1_Milestone__c(Name = 'Test'  + Datetime.now().getTime(), Project__c = projects[0].id, Complete__c = false,
                                                            Description__c = 'Description for Test 1',
                                                            Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100, 
                                                            Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100,
                                                            Status__c = 'approved'));
        System.debug('line ### 84');
        insert deliverables;
        
        //Create Coaching Tasks
        List<Milestone1_Task__c> coachingTasks = new List<Milestone1_Task__c>();
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, RecordTypeId = mapRecordsType.get('All Functions').getRecordTypeId(), //Updated by Jasvinder for case: 00204418
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, RecordTypeId = mapRecordsType.get('All Functions').getRecordTypeId(), //Updated by Jasvinder for case: 00204418
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, RecordTypeId = mapRecordsType.get('All Functions').getRecordTypeId(),  //Updated by Jasvinder for case: 00204418
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, RecordTypeId = mapRecordsType.get('All Functions').getRecordTypeId(),  //Updated by Jasvinder for case: 00204418
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, RecordTypeId = mapRecordsType.get('All Functions').getRecordTypeId(), //Updated by Jasvinder for case: 00204418
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        
        insert coachingTasks;
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_NotifyForCoachingTaskDues bc = new Batch_NotifyForCoachingTaskDues(1);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
 
        //Test stops here
        Test.stopTest();
    }
    
   //Below method added by Shreya for case#00273279 Start
    public static Boolean runningInASandbox() {

            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        return runningInASandbox;
        }
    //Above method added by Shreya for case#00273279 End
    
    // JesseB Commenting out this method
    static testMethod void testNotificationSecond() {
        
        Schema.DescribeSObjectResult taskObj = Milestone1_Task__c.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapTaskRecordsType = taskObj.getRecordTypeInfosByName();
        Schema.DescribeSObjectResult deliverableObj = Milestone1_Milestone__c.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapDeliverableRecordsType = deliverableObj.getRecordTypeInfosByName();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile p1;
        
        //If condition and Query added by Shreya for case#00273279
        if(runningInASandbox()){
        p1 = [SELECT Id FROM Profile WHERE Name='Miles Group Platform User']; 
        }
        //Else condition added by Shreya for case#00273279
        else{
        p1 = [SELECT Id FROM Profile WHERE Name='Miles Group Admin User'];//Code Modified By Gunjan Sharma for case - 00269646
        }
        UserRole role = new UserRole(name = 'Miles Group');
        
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
            insert role;       
        } 
        
        List<User> users = new List<User>();
        users.add(new User(alias = 'jsmtih', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        users.add(new User(alias = 'jsmti', email='jsmit1h@acme.com', emailencodingkey='UTF-8', lastname='Smith1', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        users.add(new User(alias = 'lBrown', email='lBrown@acme.com', emailencodingkey='UTF-8', firstname='LaKenya',lastname='Brown', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p1.Id, timezonesidkey='America/Los_Angeles', username='USERNAME_JAN_STOE'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
            insert users;
        }
        
        // Create a poject
        List<Milestone1_Project__c> projects = new List<Milestone1_Project__c>();
        projects.add(new Milestone1_Project__c(Name = 'Test Project', Status__c = 'Active'));//Modified By Saurabh S-640524
        insert projects;
    
        // Create a Deliverable
        List<Milestone1_Milestone__c> deliverables = new List<Milestone1_Milestone__c>();
        deliverables.add(new Milestone1_Milestone__c(Name = 'Test'  + Datetime.now().getTime(), Project__c = projects[0].id, Complete__c = false,
                                                            Description__c = 'Description for Test 1',
                                                            Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100, 
                                                            Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100, Deadline__c = Date.today().addDays(-30),
                                                            RecordTypeId = mapDeliverableRecordsType.get('Executive Coaching').getRecordTypeId(),
                                                            Status__c = 'approved'));
        
        insert deliverables;
        
        //Create Coaching Tasks
        List<Milestone1_Task__c> coachingTasks = new List<Milestone1_Task__c>();
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, 
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(),
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(),
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_TO_BE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        
        insert coachingTasks;
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_NotifyForCoachingTaskDues bc = new Batch_NotifyForCoachingTaskDues(2);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
    }
     //JesseB END */
    static testMethod void testNotificationThird() {
        
        Schema.DescribeSObjectResult taskObj = Milestone1_Task__c.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapTaskRecordsType = taskObj.getRecordTypeInfosByName();
        Schema.DescribeSObjectResult deliverableObj = Milestone1_Milestone__c.sObjectType.getDescribe();
        Map<String,Schema.recordTypeInfo> mapDeliverableRecordsType = deliverableObj.getRecordTypeInfosByName();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        UserRole role = new UserRole(name = 'Miles Group');
        
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
            insert role;       
        }
        
        List<User> users = new List<User>();
        users.add(new User(alias = 'jsmtih', email='jsmith@acme.com', emailencodingkey='UTF-8', lastname='Smith', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        users.add(new User(alias = 'jsmti', email='jsmit1h@acme.com', emailencodingkey='UTF-8', lastname='Smith1', languagelocalekey='en_US', localesidkey='en_US', 
                            profileid = p.Id, timezonesidkey='America/Los_Angeles', username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        
        //Code modified - Ankush Bhatia (Appirio Offshore - 12/8/2015) - Case #: 00143291
        //Fix the context to pervent Mixed DML operation exception
        System.runAs(currentUser) {
            insert users;
        }
        
        // Create a poject
        List<Milestone1_Project__c> projects = new List<Milestone1_Project__c>();
        projects.add(new Milestone1_Project__c(Name = 'Test Project', Status__c = 'Submitted'));
        insert projects;
    
        // Create a Deliverable
        List<Milestone1_Milestone__c> deliverables = new List<Milestone1_Milestone__c>();
        deliverables.add(new Milestone1_Milestone__c(Name = 'Test'  + Datetime.now().getTime(), Project__c = projects[0].id, Complete__c = false,
                                                            Description__c = 'Description for Test 1',
                                                            Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100, 
                                                            Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100, Deadline__c = Date.today().addDays(-30),
                                                            RecordTypeId = mapDeliverableRecordsType.get('Executive Coaching').getRecordTypeId(),
                                                            Status__c = 'approved'));
        
        insert deliverables;
        System.debug('line ### 286'+deliverables);
        //Create Coaching Tasks
        List<Milestone1_Task__c> coachingTasks = new List<Milestone1_Task__c>();
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id, 
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(),
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', Scheduled_Date__c = Date.today().addDays(-1),
                                                    Task_Stage__c = Label.TASK_STAGE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(),
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', Scheduled_Date__c = Date.today().addDays(-1), 
                                                    Task_Stage__c = Label.TASK_STAGE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', Scheduled_Date__c = Date.today().addDays(-1), 
                                                    Task_Stage__c = Label.TASK_STAGE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', Scheduled_Date__c = Date.today().addDays(-1), 
                                                    Task_Stage__c = Label.TASK_STAGE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        coachingTasks.add(new Milestone1_Task__c(Project_Milestone__c = deliverables[0].Id, Assigned_To__c = users[0].Id,
                                                    RecordTypeId = mapTaskRecordsType.get('Coaching Session').getRecordTypeId(), 
                                                    Name = 'MS ' + deliverables[0].Id + ' task ' + Datetime.now().getTime(), 
                                                    Complete__c = true, Description__c   = 'test description ' + Datetime.now().getTime(), 
                                                    Start_Date__c   = Date.today().addDays(1), Due_Date__c   = Date.today().addDays(-25), Scheduled_Date__c = Date.today().addDays(-1), 
                                                    Estimated_Expense__c = 100.00, Estimated_Hours__c = 110.00, Priority__c = '0', 
                                                    Task_Stage__c = Label.TASK_STAGE_SCHEDULED, Class__c = 'Ad Hoc', First_Chair_User__c = users[1].Id,
                                                    Last_Email_Received__c = Datetime.now()));
        
        insert coachingTasks; 
        Test.starttest();//Bhagya case 00257645
        for(Milestone1_Task__c task : coachingTasks) {
            
            task.Due_Date__c = Date.today();
        }
        
        update coachingTasks; //commented by Shreya for case#00273279
        //Test.stoptest();//Bhagya case 00257645
        //Test starts here
        //Test.startTest();
        
        //Batch isntances
        Batch_NotifyForCoachingTaskDues bc = new Batch_NotifyForCoachingTaskDues(3);
        
        //Execute the batch
       // Database.executeBatch(bc, 200); //case 00257645
         Database.executeBatch(bc, 20);
        //Test stops here
        Test.stopTest(); //modified by Himanshu Baghmar for Case #00266951
    }
}