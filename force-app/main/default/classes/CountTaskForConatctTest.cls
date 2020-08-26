/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : Test Class for  CountTaskForConatct
*********************************************************************************/
@isTest
public class CountTaskForConatctTest {
    static testMethod void testCountTaskForContact() {
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
        tk.subject = 'CN: ahead';
        tk.Status = 'Completed';
        tk.ActivityDate = Date.today() - 30;
        tk.WhoId = c.id;
        tk.type = 'meeting';
        
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
            CountTaskForConatct ct = new CountTaskForConatct();
            Database.executeBatch(ct);
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