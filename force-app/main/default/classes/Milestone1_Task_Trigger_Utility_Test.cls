// 
// (c) 2015 Appirio, Inc.
//
// 
//
// 10 AUG 2015     Nick Sharp      Modified   S-340006
// 
/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.
* Neither the name of the salesforce.com, Inc. nor the names of its contributors 
may be used to endorse or promote products derived from this software 
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
/**
* This Class test Task Trigger functionality  
*/
//START -- Updated by komal | C-00277296 | 17/04/2020 | ['SeeAllData=true to false' inorder to fix the error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"]
@isTest(SeeAllData=false)
//END -- Updated by Komal | C-00277296 | 17/04/2020 |
private class Milestone1_Task_Trigger_Utility_Test {
    
    /**
* Test exceeded chatter suscription
*/
    static testMethod void chatterSubscriptionLimitExceeded() {
        // Create a poject
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Chatter Blow');
        insert proj;
        
        // Create a milestone
        Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
        insert mstone;
        
        // Add 600 tasks to the milestone to exceed chatter user subscription limit
        Test.startTest();
        List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();
        
        Milestone1_Task_Trigger_Utility.checkOWDPermissions(lTask); //added for the case #S-362576
        
        for(Integer j = 0; j < 6; j++){          
            for(Integer i = 0; i < 100; i++){
                lTask.add( Milestone1_Test_Utility.sampleTask(mstone.Id) );
            }
            
            try{
                insert lTask;
            }
            catch(Exception e){
                if( e.getMessage().contains( Milestone1_Task_Trigger_Utility.SUBSCRIPTION_LIMIT_EXCEEDED )){
                    system.assert(true);
                }
                else{
                    //system.assert(false, e.getMessage());
                }
            }
            
            lTask.clear();
        }
        //START NSHARP S-340006 8.10.15
        Milestone1_Task_Trigger_Utility.checkOWDPermissions(lTask);
        //END NSHARP S-340006 8.10.15
        Test.stopTest();
    }
    /* Start - Jai Gupta - S-559561 - Aug 30,2018 */
    static testmethod void populateOpportunityOnLastCoachingTest() {
        
        Milestone1_Task__c mt = getMileStoneTask();
        List<Milestone1_Milestone__c> idLst = [Select id from Milestone1_Milestone__c  WHERE Complete__c = false and Total_Open_Tasks__c = 2 and
                                               Main_Project_Debrief__r.Project_Milestone__r.RecordType.DeveloperName = null 
                                               AND RecordType.DeveloperName = 'Stakeholder_Debrief' ];
        mt.Name = 'taskName';
        mt.RecordType = [SELECT id FROM RecordType WHERE Name = 'Coaching Session' ];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Miles Group' limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User u = createTestUser(p.Id,r.Id,'test','user1');
        User runUser=[Select id from User where Name='Stephen Miles'];
        System.runAs(runUser){
            mt.Assigned_To__c = runUser.id ;
            mt.Complete__c = True;
            //mt.Project_Milestone__c = idLst.get(0).id;
            mt.Task_Stage__c  = 'Scheduled';
            mt.Scheduled_Date__c  = System.today().addDays(-7);
            mt.First_Chair_User__c = runUser.id;
            mt.Second_Chair_User__c = runUser.id;
        }
        //Milestone1_Task__c objNew=[Select id from Milestone1_Task__c limit 1];
        Test.startTest();
        update mt ;
        //START --Updated by Komal | C-00277296 | 17/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"]      
        Test.stopTest();
        //END -- Updated by Komal | C-00277296 | 17/04/2020 |     
        Milestone1_Task__c newmt = [Select Id,Last_Coaching_Session__c, Opportunity_Name__c From Milestone1_Task__c where Id = :mt.Id] ;
        //system.assertEquals(false,newmt.Last_Coaching_Session__c);
        //system.assertEquals(null,newmt.Opportunity_Name__c);
        
        mt.Last_Coaching_Session__c = true ;
        update mt ;
        
        //newmt = [Select Id,Last_Coaching_Session__c, Opportunity_Name__c From Milestone1_Task__c where Id = :mt.Id] ;
        //system.assertEquals(true,newmt.Last_Coaching_Session__c);
        //system.assertNotEquals(null,newmt.Opportunity_Name__c);
        
        //START --Commented by Komal | C-00277296 | 17/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"] 
        //Test.stopTest();
        //END -- Commented by Komal | C-00277296 | 17/04/2020 | 
    } 
    private static Milestone1_Task__c getMileStoneTask() {
        Account a = new Account();
        a.Name = 'New Test Account';
        insert a;
        
        Contact con = new Contact();
        con.FirstName = 'Test';   // Commented by Shalini Sati for case 00243902 on date 12/12/2018
        con.LastName = 'Contact';
        con.AccountId = a.Id;
        con.Account_Name__c = a.Id;
        insert con;
        //START --Added by Komal | C-00277296 | 17/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"  
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser2 = testUtil.newUserSysAdmin(true);
        Contact testContact2 = testUtil.newResource(true, a.Id, testUser2.Id);  
        //END -- Added by Komal | C-00277296 | 17/04/2020 |  
        Opportunity opp = New Opportunity();
        opp.accountId = a.id;
        opp.name = 'Test oppty';
        opp.Membership_Begins__c = date.today();
        opp.Membership_Expires__c = opp.Membership_Begins__c + 365;
        opp.Invoice_Date__c = date.today();
        opp.Payment_Date__c = date.today();
        opp.amount = 100.00;
        opp.StageName = '100 - Signed Contract';
        opp.Group2__c = 'The Miles Group';
        opp.Engagement_Type__c = 'Advisory';
        opp.Lead_Contact_Source__c = con.id;
        opp.Participant_Contact__c = con.id;
        opp.Parent_Account_Contact__c = con.id;
        opp.isRenewalOpportunity__c = true ;
        opp.recordTypeID = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Advisory Services').getRecordTypeId();
        opp.Project_Name__c = 'Test';
        opp.CloseDate = date.today() + 365;
        opp.Project_Start_Date__c = date.today();
        opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
        //START --added by Komal | C-00277296 | 17/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"]  
        opp.TMG_Primary__c=testContact2.id; 
        insert opp;
        //END -- added by Komal | C-00277296 | 17/04/2020 | 
        String taskName = 'Unit Test Email Notes 123';
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('proj');
        insert proj;
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj.Id, null, 'ms1');
        ms1.Alias__c = 'unit_test';
        insert ms1;
        List<Milestone1_Milestone__c> idLst = [Select id from Milestone1_Milestone__c  WHERE Complete__c = false and Total_Open_Tasks__c = 2 and
                                               Main_Project_Debrief__r.Project_Milestone__r.RecordType.DeveloperName = null 
                                               AND RecordType.DeveloperName = 'Stakeholder_Debrief'];
        
        Milestone1_Task__c msTask1 = Milestone1_Test_Utility.sampleTask(ms1.Id);
        msTask1.Name = taskName;
        msTask1.RecordType = [SELECT id FROM RecordType WHERE Name = 'Coaching Session'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Miles Group' limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        User u = createTestUser(p.Id,r.Id,'test','user1');
        User runUser=[Select id from User where Name='Stephen Miles'];
        System.runAs(runUser){
            msTask1.Assigned_To__c = runUser.id ;
            msTask1.Complete__c = True;
            //START --Commented by Komal | C-00277296 | 17/04/2020 | [in order to fix error "No more than one executeBatch can be called from within a test method. Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation. Create CMC Issue"]
            //msTask1.Project_Milestone__c = idLst.get(0).id;
            ////END -- Commented by Komal | C-00277296 | 17/04/2020 | 
            msTask1.Task_Stage__c  = 'Scheduled';
            msTask1.Scheduled_Date__c  = System.today().addDays(-7);
            msTask1.First_Chair_User__c = runUser.id;
            msTask1.Second_Chair_User__c = runUser.id;
            insert msTask1;
        }
        return msTask1;
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
    
    /* End - Jai Gupta - S-559561 */
}