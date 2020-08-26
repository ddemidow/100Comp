/***********************************************************************************************************
* Appirio, Inc
* Name         : TMGCoachingSlidesCreation_Test
* Created By   : Shivani Jain(Appirio)
* Purpose      : Test class for TMGCoachingSlidesCreation
* Created Date : 17/02/2019
* Date Modified                Modified By             Description of the update
* Updated By    : Lokesh Korani(Appirio)
* Purpose       : Create TMG Content View records for Email  received on coachingplans@miles-group.com
* Updated Date  : 12/07/2020
*
**********************************************************************************************************/
@isTest
private class TMGCoachingSlidesCreation_Test {
    //START, Changes updated by Lokesh Korani on 12/07/2020 for Story :S-665486 (Create TMG Content View records for Email)
    static testMethod void coachingSlidesCreationTest() {
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact(LastName='Test', Email='test@test.com');
        conList.add(con);
        
        con = new Contact(LastName='Test', Email='test@test1.com');
        conList.add(con);
        insert conList;
        Profile userPrf= [select id from profile where name='G100 User'];
        User testUser = new User();
        testUser.Email= 'test@test.com';
        testUser.Username='john@acmedefine.com';
        testUser.LastName= 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = userPrf.Id;
        testUser.LanguageLocaleKey   = 'en_US';
        testUser.LocaleSidKey= 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey= 'UTF-8';
        insert testUser;
        
        TMG_Coaching_Guide__c cng = new TMG_Coaching_Guide__c(name='201',TMG_Coaching_Guide_Name__c='201');
        insert cng;
        TMG_Content_Viewed__c cnt = new TMG_Content_Viewed__c(name='test',From_lu__c=testUser.id,Sent__c=true,To__c=con.id,Contact__c=con.id, TMG_Coaching_Guides__c=cng.id);
        insert cnt;
        

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Test Email';
        email.fromname = 'Test Name';
        email.toAddresses = new List<String>{'test@test.com','Test1@gmail.com'};
        env.fromAddress = 'test@test.com';
        email.plainTextBody='http://accelerate.miles-group.com/coaching-guide/100'+
            '\n http://accelerate.miles-group.com/coaching-guide/501'+
            '\n http://accelerate.miles-group.com/coaching-guide/404'+
            '\n http://accelerate.miles-group.com/coaching-guide/201'+
            '\n http://accelerate.miles-group.com/coaching-guide/511';
        
        TMGCoachingSlidesCreation emailProcess = new TMGCoachingSlidesCreation();
        emailProcess.handleInboundEmail(email, env);
        System.assert(email.plainTextBody.contains('accelerate.miles-group.com/coaching-guide'));
        //END, Changes updated by Lokesh Korani on 12/07/2020 for Story :S-665486 (Create TMG Content View records for Email)
   
   }


}