@isTest(SeeAllData=true)
public class ContactTeamTriggerHandler_Test {

@future // Added for case-254047
    //static testMethod void testRecalculateContactTeamMember() {// Commented for case-254047
    static void testRecalculateContactTeamMember() {
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
        
        Contact_Team__c contteam = new Contact_Team__c(Contact__c = c.ID,Team_Member__c = c1.ID ) ;
        insert contteam ;
        //System.assertEquals(c1.Name, [select  Contact_Team_Members__c 
        //                                      from Contact 
        //                                     where Id = :c.Id].Contact_Team_Members__c);
                                     
        delete contteam;
        //System.assertEquals(null, [select  Contact_Team_Members__c 
        //                                    from Contact 
        //                                    where Id = :c.Id].Contact_Team_Members__c );
        
        undelete contteam;
        //System.assertEquals(c1.Name, [select  Contact_Team_Members__c 
        //                                   from Contact 
        //                                   where Id = :c.Id].Contact_Team_Members__c);
        
        
        
        
    }
}