/*******************************************************************************
* @Class       : BatchUpdateContactTeamOnContactTest
* @author      : Rohit
* @description : Test Class of BatchUpdateContactTeamOnContact (S-635394)
*******************************************************************************/
@isTest
private class BatchUpdateContactTeamOnContactTest {
    
    static testMethod void Testmethod1() {
        
        List <Contact> conList = new List <Contact>();
        
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Contact' and Name = 'PSA Resource'];
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);   
        Account acct = testUtil.newAccount(true);
        pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
        pse__Region__c reg = testUtil.newRegionMaster(true);
        Contact c = testUtil.newResource(true, acct.Id, null);   
        Contact c1 = testUtil.newResource(false, acct.Id, usr.Id, reg.Id, cal.Id);
        c1.RecordTypeId =  RecType.ID;
        insert c1;
        conList.add(c);
        
        Contact_Team__c contteam = new Contact_Team__c(Contact__c = c.ID,Team_Member__c = c1.ID ) ;
        insert contteam ;
        
        Test.startTest();
        BatchUpdateContactTeamOnContact cb = new BatchUpdateContactTeamOnContact();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,conList);
        cb.Finish(null);
        Test.stopTest();
    }

}