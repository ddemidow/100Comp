//
// (c) 2012 Appirio, Inc.
// AW_ImportExport_Controller_Test                                                     
// Test Class for to parse AdvanceAW_ImportExport_Controller
//
// 24 Apr 2013     Peter Babalis     Original
//  
//
 @isTest
 public with sharing class AW_ImportExport_Controller_Test {
 static Advance_Workflow__c plan;
 static Rule__c rule2;
  
 @isTest
 static void TestescapecharsToch() {
        
        String str = 'ciao&hola';
         AW_ImportExport_Controller.escapecharsTochars(str);
    
    }
 /**
    * Test Export methods
    */
    
   public static testMethod void testexport() {
   PageReference pageRef = Page.AW_ImportExport_VF;
        Advance_Workflow__c advanceWF = new Advance_Workflow__c(Name ='advancewf',Object__c  = 'Account', Enabled__c=True,Description__c = 'Test Desc');
        insert advanceWF;
        
        Rule__c rule    =   new Rule__c(Name = 'Rule test1',
                                        Status__c = 'Draft',
                                        Object__c = 'Account', 
                                        Version__c = 1,
                                        Description__c = 'Rule 1 Description',
                                        Evaluation_Rule__c='Record is created or edited'
                                        //,Advance_Workflow__c = advanceWF.id
                                        );
        insert rule;
         
        RuleCriteria__c ruleCriteria    =   new RuleCriteria__c(Rule__c = rule.id,
        Related_Object__c='Account',
        Matching_Type__c='Equals', 
        Matching_Value__c='Apparel', 
        Field_name__c='Industry',
        Field_API_Name__c='Industry',
        Field_Type__c='Picklist');
        insert  ruleCriteria;
        
        RuleAction__c ruleAction        =   new RuleAction__c(Rule__c = rule.id,
        Related_Object__c='Account',
        Reference_Id__c=Userinfo.getUserId(),
        Field_Name__c='Industry',
        Field_API_Name__c='Industry',
        Type__c='Update Field',
        Value__c='Apparel',
        Long_Value__c=null,
        Notify_User__c=False,
        Email_Template__c=null
        );
      
           
          
        insert ruleAction;
 
        Values_for_Action_Insert_Record__c va   =   new Values_for_Action_Insert_Record__c(Name='name1',Rule_Action__c=ruleAction.id);
        insert va;
        
         
        rule.Order__c=10;
        rule.Status__c = 'Active';
        rule.Execution_Behavior__c='Execute and Exit';
        rule.Advance_Workflow__c=advanceWF.id;
        update rule;

      //  PageReference pageRef = Page.AW_ImportExport_VF;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', advanceWF.id);
        
        AW_ImportExport_Controller controller = new AW_ImportExport_Controller(); 
        
        // Instantiate a new controller with all parameters in the page
        controller = new AW_ImportExport_Controller();  
        controller.option = '1';
        controller.ruleOpt = '1';
        controller.exportProcess();
        
        controller.option = '1';
        controller.ruleOpt = '2';
        controller.exportProcess();
        
        controller.option = '1';
        controller.ruleOpt = '3';
        controller.exportProcess();
        
        controller.option = '0';
        controller.ruleOpt = '2';
        controller.exportProcess(); 
   }   
  /**
    * Test Controller methods
    */
   public static testMethod void testController() {
 	    PageReference pageRef = Page.AW_ImportExport_VF;
   	 	Test.setCurrentPage(pageRef);
   		AW_ImportExport_Controller controller = new AW_ImportExport_Controller();
        controller.option = '0';
        controller.ruleOpt = '2';
        controller.cancel();
        controller.checkAction();
        controller.getRadioOptions();
        controller.getRuleOptions();
        controller.start();
        controller.importProcess();
        
}
  
  
    public static void MyTest() {
          
        Advance_Workflow__c advanceWF = new Advance_Workflow__c(Name ='advancewf',Object__c  = 'Account', Enabled__c=True,Description__c = 'Test Desc');
        insert advanceWF;
        
        Rule__c rule    =   new Rule__c(Name = 'Rule test1',
                                        Status__c = 'Draft',
                                        Object__c = 'Account', 
                                        Version__c = 1,
                                        Description__c = 'Rule 1 Description',
                                        Evaluation_Rule__c='Record is created or edited'
                                        //,Advance_Workflow__c = advanceWF.id
                                        );
        insert rule;
         
        RuleCriteria__c ruleCriteria    =   new RuleCriteria__c(Rule__c = rule.id,
        Related_Object__c='Account',
        Matching_Type__c='Equals', 
        Matching_Value__c='Apparel', 
        Field_name__c='Industry',
        Field_API_Name__c='Industry',
        Field_Type__c='Picklist');
        insert  ruleCriteria;
        
        RuleAction__c ruleAction        =   new RuleAction__c(Rule__c = rule.id,
        Related_Object__c='Account',
        Reference_Id__c=Userinfo.getUserId(),
        Field_Name__c='Industry',
        Field_API_Name__c='Industry',
        Type__c='Update Field',
        Value__c='Apparel',
        Long_Value__c=null,
        Notify_User__c=False,
        Email_Template__c=null
        );
      
           
          
        insert ruleAction;
 
        Values_for_Action_Insert_Record__c va   =   new Values_for_Action_Insert_Record__c(Name='name1',Rule_Action__c=ruleAction.id);
        insert va;
        
         
        rule.Order__c=10;
        rule.Status__c = 'Active';
        rule.Execution_Behavior__c='Execute and Exit';
        rule.Advance_Workflow__c=advanceWF.id;
        update rule;
        
        
        PageReference pageRef = Page.AW_ImportExport_VF;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', advanceWF.id);
        
        AW_ImportExport_Controller controller = new AW_ImportExport_Controller(); 
        
        // Instantiate a new controller with all parameters in the page
        controller = new AW_ImportExport_Controller();  
        controller.option = '1';
        controller.ruleOpt = '3';
        controller.checkAction();
        controller.getRadioOptions();
        controller.getRuleOptions();
        controller.importProcess();
        controller.exportProcess();
        controller.cancel();
        controller.start();
        
            
        
    }   
 

}