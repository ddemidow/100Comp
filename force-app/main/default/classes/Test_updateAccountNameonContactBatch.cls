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
private class Test_updateAccountNameonContactBatch {

    static testMethod void myUnitTest() {
       Account testAccount = new Account();
       testAccount.Name = 'TestAccount';
       
       Contact testContact = new Contact();
       testContact.FirstName = 'Test';
       testContact.LastName = 'Contact';
       
       Test.startTest();
       insert testAccount;
       
       testContact.AccountId = testAccount.Id;
       insert testContact;
       
       testContact.Account_Name__c = 'TestAccountNew';
       update testContact;
       
       Database.executeBatch(new updateAccountNameonContact_Batch());
       Test.stopTest();
       
       Contact con = [Select Id, Account_Name__c from Contact where Id = :testContact.Id];
       system.assertEquals(con.Account_Name__c, 'TestAccount');
    }
    
    static testMethod void myUnitTestSchedule(){
    	Test.startTest();
    	String CRON_EXP = '0 0 0 * * ?';
        System.schedule('scheduleContactAccountNameBatch', CRON_EXP, new updateAccountNameonContact_Batch());
    	Test.stopTest();
    } 
}