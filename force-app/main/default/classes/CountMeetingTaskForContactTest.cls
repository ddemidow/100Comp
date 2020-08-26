/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : it is a test class for CountMeetingTaskForContact
*********************************************************************************/
@isTest
public class CountMeetingTaskForContactTest {
    static testMethod void testCountMeetingTask() {
        
        User userToCreate = initTestUser('kevin');
        insert userToCreate;
        
        Contact c = new Contact();
        c.LastName = 'Test';
        insert c ;
        
        Account acc = new Account();
        acc.Name = 'AccTest';
        insert acc;
        
        c.AccountId = acc.id;
        update c;
        
        Task tk = new Task();
        tk.subject = 'in-person';
        tk.Status = 'Completed';
        tk.ActivityDate = Date.today() - 30;
        tk.WhoId = c.id;
        tk.type = 'Nonmeeting';
        
        Task tk1 = new Task();
        tk1.subject = 'meeting';
        tk1.Status = 'Completed';
        tk1.ActivityDate = Date.today() - 30;
        tk1.WhoId = c.id;
        tk1.type = 'Call';
        
        Test.startTest();
        System.runAs(userToCreate) {
            insert tk;
            insert tk1;
            CountMeetingTaskForContact cm = new CountMeetingTaskForContact();
            Database.executeBatch(cm);
        }
        
        
        Test.stopTest();
    } 
    
    Public Static user initTestUser(String userName){
        Profile userPrf         = [select id from profile where name='System Administrator'];
        User    userCrt         = new User(emailencodingkey     = 'UTF-8',
                                           languagelocalekey   = 'en_US',
                                           localesidkey        = 'en_US',
                                           timezonesidkey      = 'America/Los_Angeles',
                                           alias               = 'Tstr', 
                                           lastname            = userName,
                                           email               = userName + '@testorg.com',
                                           profileid           = userPrf.Id, 
                                           username            = userName + '@testorg.com');
        return userCrt;
    }
}