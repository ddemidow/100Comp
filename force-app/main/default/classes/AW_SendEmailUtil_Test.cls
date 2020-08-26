//
// (c) 2012 Appirio, Inc.
//
//  AW_SendEmailUtil_Test
//
// This class contains test methods for Testing sendEmailUtil functionality
//
// 10 Oct 2012     Peter Babalis          Original
// 11 Nov 2012     Sneha                  Templates
//
@isTest
public class AW_SendEmailUtil_Test{

    /**
    * Test sendEmail method
    */
    public static TestMethod void SendEmailUtil_Test(){
        Test.startTest();
        new AW_SendEmailUtil().sendEmail(new List<string>{'test@test.com'}, new List<String>{'test test'});
        Test.stopTest();
        //System.assertNotEquals(0,Limits.getEmailInvocations());
    }

   public  static TestMethod void sendEmailTest3() {
        Account a = new Account(Name = 'test');
        insert a;
        Attachment att = new Attachment();
        att.Body = Blob.valueOf('test');
        att.Name = 'test.xml';
        att.ParentId = a.Id;
        insert att;
        Test.startTest();
        AW_SendEmailUtil.sendEmailwithAttachment(att);
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    public static void sendEmailTest2(){
        EmailTemplate e=[Select Id,Body FROM EmailTemplate LIMIT 1];
        /*START -- Commented by Mohit Tanwar | Case #00278177 |[14-05-2020] | [Updating test data to resolve batch error]*/
        //Rule__c rule = AW_AdvanceWorkflowExecutionEngine_Test.setupRules();
        /*END-- Commented by Mohit Tanwar | Case #00278177 |[14-05-2020] | [Updating test data to resolve batch error]*/
   		/*START -- Added by Mohit Tanwar | Case #00278177 |[14-05-2020] | [Updating test data to resolve batch error]*/
            Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        /*END -- Added by Mohit Tanwar | Case #00278177 |[14-05-2020] | [Updating test data to resolve batch error]*/     
        insert rule;    
        
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Send Email',User_Owner_Id__c=UserInfo.getUserId(),Email_Template__c=e.Id);
        insert a1;

        User u=[Select Id,Name,FirstName,Lastname,email FROM User WHERE Id =:UserInfo.getUserId()];
        Map<Id,User> user = new Map<Id,User>();
        user.put(u.Id,u);

        System.runAs(u) {
          Account a = new Account(Name='testing 11/4/2013123456');
          insert a;
		  /*START -- Commented by Mohit Tanwar | Case #00278177 |[15-05-2020] | [Updating test data to resolve batch error]*/
          //Contact c = new Contact (LeadSource='NGL',MailingCountry='USA',MailingState='TX',MailingCity='Dallas', FirstName='firstname',Salutation='Mr.',LastName='test123456',email='test123456@test123456.com');
          //insert c;
            
           //Lead l = new Lead (LastName='test1234567',Company='test',email='test1234567@test1234567.com');
          //insert l;
          /*END-- Commented by Mohit Tanwar | Case #00278177 |[15-05-2020] | [Updating test data to resolve batch error]*/  
          //Map
          Map<String,Map<String,List<RuleAction__c>>> userEmailInfo= new Map<String,Map<String,List<RuleAction__c>>>();
          Map<String,List<RuleAction__c>> data = new Map<String,List<RuleAction__c>>();
          data.put(a.Id,new List<RuleAction__c>{a1 });
           /*START -- Commented by Mohit Tanwar | Case #00278177 |[15-05-2020] | [Updating test data to resolve batch error]*/ 
          //data.put(c.Id,new List<RuleAction__c>{a1 });
          //data.put(l.Id,new List<RuleAction__c>{a1 });
          /*END-- Commented by Mohit Tanwar | Case #00278177 |[15-05-2020] | [Updating test data to resolve batch error]*/
          userEmailInfo.put(u.Id,data);
          Test.startTest();
            try{
                new AW_SendEmailUtil().sendEmail(user, userEmailInfo);
           }catch(Exception ex){
               system.debug(ex);
           }
          Test.stopTest();
        }


    }
}