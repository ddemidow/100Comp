/************************************************************************************************************************
Name Author     :  ContactTriggerHandler_Test
Modified by		:  Rohit for S-635394
Created by      :  Hemant [Appirio JDC] - 2013/11/22
Related Story   :  S-158728
Description     :  Test class for the class "ContactTriggerHandler" and trigger "ContactTrigger" on Contact object
*************************************************************************************************************************/
@isTest
private class ContactTriggerHandler_Test {

    static testMethod void ContactTriggerTest() {
        
        Contact c = new Contact();
        c.LastName = 'Test';
        c.Recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
        insert c ;
        Contact cont = new Contact ();
        cont.Recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PSA Resource').getRecordTypeId();    
        cont.LastName = 'TestName';
        insert cont;
        
        Account acc = new Account();
        acc.Name = 'AccTest';
        insert acc;
        
        c.AccountId = acc.id;
        update c;
        
        Speaker__c s = new Speaker__C();
        s.Contact__c = c.id ;
        insert s ;
        
        c.LastName = 'TestLastName';
        
        //c.TMG_Confidential__c = true ;
        
        try {
            update c ;
        } catch(Exception e) {
            boolean contains = e.getMessage().contains('TMG Confidential cannot be checked if there exists data in the related lists');
            system.assertEquals(true,contains);
        }
        
        c.TMG_Confidential__c = true;
        
        try {
            update c;
        } catch (Exception e){
            boolean contain = e.getMessage().contains('TMG Confidential cannot be checked if there exists data in the related lists.');
            system.assertEquals(true, contain);
        }
        
        ContactMasterRecord__c cmr = new ContactMasterRecord__c();
        cmr.Name = c.id;
        insert cmr;
        test.startTest();
        Contact_Team__c  ct = new Contact_Team__c();
        ct.Contact__c = c.Id;
        //ct.Team_Member__c = c.Id;
        //Start added for case 254750
        Contact cont1 = new Contact ();
        cont1.Recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PSA Resource').getRecordTypeId();    
        cont1.LastName = 'TestName';
        insert cont1;
        //stop added for case 254750
        ct.Team_Member__c = cont1.Id; //Added for case 254750
        insert ct;
        test.stopTest();
        ct.Role__c= 'Test Role';
        //ct.Contact__c = cont.Id;
        update ct;
        delete ct;
        undelete ct;
        
        Contact_Team__c cteam = new Contact_Team__c();       
        //cteam.Contact__c = cont.Id;//Commented for case 254740
        cteam.Contact__c = cont1.Id;// Added for case 254740
        cteam.team_Member__c = cont1.Id;
        cteam.Role__c = 'Role';
        insert cteam;
        Contact co = new Contact();
        co.LastName = 'Test Update';
        co.Recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
        insert co;
        //cteam.Contact__c = co.Id;
        //cteam.Role__c = 'New Role';
        //update cteam;
        
        Contact_Team__c cteam2 = new Contact_Team__c();       
        cteam2.Contact__c = c.Id;
        cteam2.team_Member__c = c.Id;
        cteam2.Role__c = 'New Role';
        cteam2.Id = cteam.Id;
        
        List <Contact_Team__c> teamList = new List <Contact_Team__c>();
        teamList.add(cteam);
        
        Map<Id, Contact_Team__c> newMemberMap = new Map<Id, Contact_Team__c>();
        newMemberMap.put(cteam2.Id, cteam2);
        
        ContactTriggerHandler.onAfterUpdate(teamList, newMemberMap);        
    }
}