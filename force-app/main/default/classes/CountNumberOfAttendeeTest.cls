/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : Test Class for  CountNumberOfAttendee
*********************************************************************************/
@isTest
public class CountNumberOfAttendeeTest {
    static testMethod void testCountOfAttendee() {
        Event__c ev = new Event__c();
        ev.name = 'EventTest';
        ev.End_Date__c = Date.today()-150;
        insert ev;
        
        
        
        Contact c = new Contact();
        c.LastName = 'Test';
        insert c ;
        
        Event_Members__c evm = new Event_Members__c();
        evm.Day_1_Role__c = 'Staff';
        evm.Day_2_Role__c = 'Staff';
        evm.Day_3_Role__c = 'Member';
        evm.Contact__c = c.id;
        evm.Event__c = ev.id;
        insert evm;
        
        Account acc = new Account();
        acc.Name = 'AccTest';
        insert acc;
        
        c.AccountId = acc.id;
        update c;
        
        Event_Members__c evm1 = new Event_Members__c();
        evm1.Day_1_Role__c = 'Staff';
        evm1.Day_2_Role__c = 'Staff';
        evm1.Day_3_Role__c = 'Member';
        evm1.Contact__c = c.id;
        evm1.Event__c = ev.id;
        insert evm1;
        
        Test.startTest();
        CountNumberOfAttendee cnt = new CountNumberOfAttendee();
        Database.executeBatch(cnt);
        Test.stopTest();
        
    }
}