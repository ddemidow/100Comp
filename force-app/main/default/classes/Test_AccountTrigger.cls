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
private class Test_AccountTrigger {

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
       
       testAccount.Name = 'TestAccountNew';
       update testAccount;
       Test.stopTest();
       
       Contact con = [Select Id, Account_Name__c from Contact where Id = :testContact.Id];
       system.assertEquals(con.Account_Name__c, 'TestAccountNew');
    }
    
    static testMethod void mergeUnitTest(){
    	Account testMaster = new Account();
    	testMaster.Name = 'Master Account';
    	
    	Account testMerge = new Account();
    	testMerge.Name = 'Merge Account';
    	
    	Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        
        Test.startTest();
    	
    	insert testMaster;
    	insert testMerge;
    	
    	testContact.AccountId = testMerge.Id;
    	insert testContact;
    	
    	merge testMaster testMerge;
    	
    	Test.stopTest();
    	
    	Contact con = [Select Id, Account_Name__c from Contact where Id = :testContact.Id];
        system.assertEquals(con.Account_Name__c, 'Master Account');
    	
    }
}