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
@isTest
private class TestClassTrainingAttendee {
    
    
    @isTest public static void myUnitTest() {//commented for case 254740
    //static void myUnitTest() { //Added for case 254740
    Test.startTest();//added for case -00257645
        //Commented by Himanshu Baghmar for Case #00266951
        //Contact c = new Contact (LeadSource='NGL',MailingCountry='USA',MailingState='TX',MailingCity='Dallas',FirstName='firstname',Salutation='Mr.',LastName='test',email='test@test.com');
        //insert c;
        
        //Start Code added by Himanshu Baghmar for Case #00266951
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        Contact c1 = new Contact();
        c1.AccountId = acc.Id;
        c1.Vacation_Beg_Bal__c = 100;
        c1.Sick_Begin_Balance__c = 50;
        // c1.pse__Salesforce_User__c = u.Id;
        c1.LastName = 'test Contact';
        c1.ffpsai__ExpenseReimbursementAccount__c = acc.Id;
        c1.LeadSource='NGL';
        c1.FirstName='firstname';
        c1.email='test@test.com';
        insert c1;
        //End Code added by Himanshu Baghmar for Case #00266951
        
        Opportunity cc = new Opportunity(Name='test');
        cc.StageName = 'Verbal Approval';
        cc.CloseDate = date.today().addDays(-10);
        //Start Nick Sharp Case 0060394
        cc.Parent_Account_Contact__c = c1.Id;
        //End Nick Sharp Case 0060394
        insert cc;
        
        Opportunity cc1 = new Opportunity(Name='test12');
        cc1.StageName = 'Verbal Approval';
        cc1.CloseDate = date.today().addDays(-10);
        //Start Nick Sharp Case 0060394
        cc1.Parent_Account_Contact__c = c1.Id;
        //End Nick Sharp Case 0060394
        insert cc1;

 Training_Attendee__c ta = new Training_Attendee__c();
        ta.Contact__c = c1.Id;
        ta.Opportunity__c = cc.Id;
        insert ta;
        
        Test.stoptest();//added for case -00257645
    }
}