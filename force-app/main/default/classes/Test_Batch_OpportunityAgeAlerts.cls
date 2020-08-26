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
private class Test_Batch_OpportunityAgeAlerts {
/**
 *  Purpose         :   This test class is for Batch_OpportunityAgeAlerts class.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   02/29/2015
 *
 *  Current Version :   V1.0
 *
 *  Revision Log    :   V1.0 - Created - S-374199
 *
 *  Coverage        :   V1.0 - 100%
 **/
    
    static void createTestData(String subGroup) {
    	
    	//Queyr result of current user
        UserRole role = new UserRole(name = 'Miles Group');
        
        //List of Users
        List<User> users = new List<User>();
        users.add(new User(alias = 'jsmtih', email='jsmith@acme.com', emailencodingkey='UTF-8', FirstName = 'Courtney', lastname='Hehre', languagelocalekey='en_US', 
                                localesidkey='en_US', profileid = Userinfo.getProfileId(), timezonesidkey='America/Los_Angeles', 
                                username='test'+ Math.random()+'@acme.com', UserRoleId = role.Id));
        
        //perform DML operations
        insert users;
        
        List<Email_Alert_Default__c> configDefaults = new List<Email_Alert_Default__c>();
        configDefaults.add(new Email_Alert_Default__c(Name = 'G100', FirstName__c ='Jess', Age__c = 0, Email__c = 'jrobison@g100.com'));
        configDefaults.add(new Email_Alert_Default__c(Name = 'Next', FirstName__c ='Irene', Age__c = 0, Email__c = 'ihartnett@g100.com'));
        configDefaults.add(new Email_Alert_Default__c(Name = 'NGL', FirstName__c ='Irene', Age__c = 0, Email__c = 'ihartnett@g100.com'));
        configDefaults.add(new Email_Alert_Default__c(Name = 'TC', FirstName__c ='Ruthy', Age__c = 0, Email__c = 'reffler@g100.com'));
        insert configDefaults;
        
        Account a = new Account();
        a.Name = 'New Test Account';
        insert a;
        
        Contact con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'Contact';
        con.AccountId = a.Id;
        insert con;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
  
        //Create a poject
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(Name = 'Test Opp 1', SubGroup__c = subGroup, accountId = a.id, Membership_Begins__c = Date.today(), 
                                                Membership_Expires__c = Date.today() + 365, Invoice_Date__c = Date.today(), Payment_Date__c = Date.today(), 
                                                amount = 100.00, StageName = '03 - No Response', Group2__c = 'High Lantern Group', 
                                                Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, 
                                                Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 186, 
                                                Project_Start_Date__c = Date.today(), Project_End_Date__c = Date.today().addmonths(9)));
        
        if(users.size() > 0) {
            opportunities.add(new Opportunity(Name = 'Test Opp 2', SubGroup__c = subGroup, accountId = a.id, Membership_Begins__c = Date.today(), 
                                                Membership_Expires__c = Date.today() + 365, Invoice_Date__c = Date.today(), Payment_Date__c = Date.today(), 
                                                amount = 100.00, StageName = '03 - No Response', Group2__c = 'High Lantern Group', 
                                                Participant_Contact__c = con.id, Parent_Account_Contact__c = con.id, 
                                                Project_Name__c = 'Test', Engagement_Type__c = 'Coaching', CloseDate = date.today() + 186, 
                                                Project_Start_Date__c = Date.today(), Project_End_Date__c = Date.today().addmonths(9),
                                                OwnerId = users[0].Id));
        }
        
        insert opportunities;
    }
    
    static testMethod void testNotificationFirst() {
        
        createTestData(Constants.OPPROTUNITY_SUBGROUP_G100);
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_OpportunityAgeAlerts bc = new Batch_OpportunityAgeAlerts(1);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
    }
    
    static testMethod void testNotificationSecond() {
        
        createTestData(Constants.OPPROTUNITY_SUBGROUP_NGL);
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_OpportunityAgeAlerts bc = new Batch_OpportunityAgeAlerts(2);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
    }
    
    static testMethod void testNotificationThird() {
        
        createTestData(Constants.OPPROTUNITY_SUBGROUP_NEXT);
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_OpportunityAgeAlerts bc = new Batch_OpportunityAgeAlerts(3);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
    }
    
    static testMethod void testNotificationFourth() {
        
        createTestData(Constants.OPPROTUNITY_SUBGROUP_TC);
        
        //Test starts here
        Test.startTest();
        
        //Batch isntances
        Batch_OpportunityAgeAlerts bc = new Batch_OpportunityAgeAlerts(4);
        
        //Execute the batch
        Database.executeBatch(bc, 200);
        
        //Test stops here
        Test.stopTest();
    }    
}