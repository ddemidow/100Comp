//Start Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage

@isTest
public class AW_AdvWorkflowTransactionProcessingTest {

   @isTest
    Public static void Test12(){
        
        Account acc=new Account(name='test');
        insert acc;
        
        Map<id,Account> testAc= new Map<id,Account>();
        testAc.put (acc.id,acc);
        List<Contact> con = new List<Contact>{New Contact(Lastname='Tes',Accountid=acc.id)};
		boolean testAw =  AW_AdvanceWorkflowTransactionProcessing.performDMLOperations(testAc,con);
        acc.name=null;
        con[0].lastname=null;
        boolean testAws =  AW_AdvanceWorkflowTransactionProcessing.performDMLOperations(testAc,con);
    }
    public static testmethod void testHandleError(){
         Opportunity o= new Opportunity();
         try{ insert o;}
         catch(Exception e){
              AW_AdvanceWorkflowTransactionProcessing.handleError(e);
         }
    }
    public static testmethod void testHandle(){
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Apparel', field_name__c='Industry',field_API_Name__c='Name',Field_Type__c='Picklist');
        insert ruleCriteria ;
        RuleAction__c ruleaction1 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',Bulk_API__c=True,
                                                            field_name__c='Type',Type__c='Update Field',Value__c='TestUpdate');
    
        insert ruleaction1;
       Account acc1 = new Account(Name='Test123');
       Account acc2 = new Account(Name='Test321');
       insert new List<Account>{acc1,acc2};     
    
        Object_Action_Execution__c ObjActionExec1 = new  Object_Action_Execution__c() ;
        Object_Action_Execution__c ObjActionExec2 = new  Object_Action_Execution__c() ;
       
        ObjActionExec1.Record_Id__c=acc1.id;
        ObjActionExec1.Status__c='New';
        ObjActionExec1.Type__c='Bulk API';
        ObjActionExec1.Value__c=acc1.Name;
        ObjActionExec1.Action__c=ruleaction1.id;
        
         
        
        ObjActionExec2.Record_Id__c=acc2.id;
        ObjActionExec2.Status__c='New';
        ObjActionExec2.Type__c='Bulk API';
        ObjActionExec2.Value__c=acc2.Name;
        ObjActionExec2.Action__c=ruleaction1.id;
        
        List<Object_Action_Execution__c> Obj1 =new List<Object_Action_Execution__c>{ObjActionExec1};
        List<Object_Action_Execution__c> Obj2 =new List<Object_Action_Execution__c>{ObjActionExec2};
        AW_AdvanceWorkflowTransactionProcessing.processLookupUpdatesAndBulkAPi(obj1);
        
        
    }
    
}
 //END Lokesh Korani S-656938 6-05-2020 Reason-Increasing code coverage