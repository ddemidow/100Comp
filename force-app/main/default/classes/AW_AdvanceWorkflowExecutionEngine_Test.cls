// (c) 2012 Appirio, Inc.
//
//  AW_AdvanceWorkflowExecutionEngine_Test                                                    
//
// This class contains test methods for AW_AdvanceWorkflowExecutionEngine class
//
// 10 Oct 2012     Peter Babalis     Original
// 07 Feb 2013     Peter Babalis     Added Cross Fields, tasks and emails
// 
@IsTest
public class AW_AdvanceWorkflowExecutionEngine_Test{

    //updated by SH
    static testmethod void testStringComparsionMethod(){
        Boolean result ;       
        Test.startTest();

        result= AW_AdvanceWorkflowExecutionHelper.isValid('test','test', 'equals', 'string');                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('test','test', 'not equal to', 'string');                      
        system.assertEquals(false, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid('test','es', 'Contains', 'string');                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy','es', 'Does Not Contain', 'string');                   
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy','du', 'Starts With', 'string');                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy','my', 'Ends With', 'string');                  
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy','[a-z]+', 'Regular Expression', 'string');                 
        system.assertEquals(true, result);     

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy2','dummy2', 'includes', 'picklist');                   
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid('dummy2','dummy2', 'excludes', 'multipicklist');                  
        system.assertEquals(false, result);    


        Test.stopTest();   
    }

    static testmethod void testNumberComparsionMethod(){
        Boolean result ;       
        Test.startTest();

        result= AW_AdvanceWorkflowExecutionHelper.isValid(10.0,10.0, 'equals', 'decimal',null);                  
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(10.0,10.0, 'not equal to', 'decimal',null);                        
        system.assertEquals(false, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(14.0,10.0, 'Greater Than', 'decimal',null);                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(10.0,14.0, 'Less Than', 'decimal',null);                   
        system.assertEquals(true, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(15.0,14.0, 'Greater or Equal', 'decimal',null);                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(14.0,14.0, 'Less or Equal', 'decimal',null);                   
        system.assertEquals(true, result); 

        RuleCriteria__c c = new RuleCriteria__c();
        c.Maximum_Value__c='100';
        c.Minimum_Value__c='50';

        result= AW_AdvanceWorkflowExecutionHelper.isValid(60.0,14.0, 'between', 'decimal',c);                    
        system.assertEquals(true, result); 

        Test.stopTest();   
    }

    static testmethod void testDateComparsionMethod(){
        Boolean result ;

        Date d = date.today();


        Test.startTest();           
        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,d, 'equals', 'date',null);                   
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,d, 'not equal to', 'date',null);                     
        system.assertEquals(false, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,date.parse('12/27/2009'), 'Greater Than', 'date',null);                  
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,date.parse('12/27/2009'), 'Less Than', 'date',null);                 
        system.assertEquals(false, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,date.parse('12/27/2009'), 'Greater or Equal', 'date',null);                  
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,date.parse('12/27/2009'), 'Less or Equal', 'date',null);                 
        system.assertEquals(false, result);


        RuleCriteria__c c = new RuleCriteria__c();
        //Start Nick Sharp Case00060394 1-15-14
        //c.Maximum_Value__c='12/27/2013';
        c.Maximum_Value__c='12/27/3000';
        //End Nick Sharp Case00060394 1-15-14
        c.Minimum_Value__c='12/27/2009';

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,d, 'between', 'date',c);                 
        system.assertEquals(true, result); 

        Test.stopTest();    
    }

    static testmethod void testDateTimeComparsionMethod(){
        Boolean result ;

        //  Contact a = new Contact(LastName='test',MailingCountry='USA',MailingState='TX',MailingCity='Dallas');
        // insert a

        //    a =[Select Id,CreatedDate FROM Contact WHERE Id =:a.Id];

        //  Datetime d = Datetime.valueOf(string.valueof(a.get('CreatedDate')));

        Date d = date.today();

        Datetime dt = DateTime.parse('10/14/2011 11:46 AM'); 

        Test.startTest();           
        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'equals', 'datetime',null);                   
        system.assertEquals(false, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'not equal to', 'datetime',null);                     
        system.assertEquals(true, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'Greater Than', 'datetime',null);                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'Less Than', 'datetime',null);                   
        system.assertEquals(false, result);

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'Greater or Equal', 'datetime',null);                    
        system.assertEquals(true, result); 

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'Less or Equal', 'datetime',null);                   
        system.assertEquals(false, result);


        RuleCriteria__c c = new RuleCriteria__c();
        c.Maximum_Value__c='10/14/2100 11:46 AM';
        c.Minimum_Value__c='10/14/2011 11:46 AM';

        result= AW_AdvanceWorkflowExecutionHelper.isValid(d,dt, 'between', 'datetime',c);                    
        system.assertEquals(true, result); 

        Test.stopTest();    
    }
       
       
    static testmethod void testRuleExecutionTrue(){
        Rule__c rule = setupRules();

        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture');

        Test.startTest();
        insert a;    
        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);

        //this will not evaluate rule as it has already been executed once
        a.AnnualRevenue = 500.0;
        update a; 

        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);
        //system.assertNotEquals(0, [select id from contact where accountid =: a.Id].size());                                             
        Test.stopTest();

    }
    
    //static testmethod void testRuleExecutionCondition2(){ //commented for case -00259042 
         static void testRuleExecutionCondition2(){
        Rule__c rule = setupRules();

      
        RuleCriteria__c c1 = new RuleCriteria__c(rule__c=rule.id);
        c1.Field_API_Name__c='FirstName';
        c1.Field_Type__c='String';
        c1.Matching_Type__c='Equals';
        c1.Matching_Value__c='test';
        c1.Related_Object__c='Contact';

        insert c1;

        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='FirstName',Type__c='Update Field',Value__c='TestUpdate');

        insert a1;

        rule.Filter_Logic__c='1 AND (2 OR 3) AND 4';
        update rule;


        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Mining');
        insert a;

        Contact c = new Contact(LeadSource='NGL',MailingCountry='USA',MailingState='TX',MailingCity='Dallas', FirstName='test', Salutation='Mr.',LastName='contact',AccountId=a.Id);
        //Below line commented by Gunjan Sharma for case - 00269646
      //  insert c;



        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue); 
        Test.startTest(); 
        //this will not evaluate rule as it has already been executed once
        a.Industry = 'Agriculture';
        update a; 

        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        //system.assertEquals('Test', a.Name);
        // system.assertEquals(2000, a.AnnualRevenue);
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);
		
        //Below code commented by Gunjan Sharma for case - 00269646
       // c =[Select Id,FirstName FROM Contact WHERE Id=:c.Id];
        //       system.assertEquals('TestUpdate', c.FirstName);
       // system.assertEquals('test', c.FirstName);

        Test.stopTest();

    }

    //static testmethod void testRuleExecutionCrossFormula(){//commented for case -00259042 
         static void testRuleExecutionCrossFormula(){        Rule__c rule =setupRules();
        
    

        RuleCriteria__c c1 = new RuleCriteria__c(rule__c=rule.id);
        c1.Field_API_Name__c='CrossFormula';
        c1.CrossFormula__c='Account.Industry';
        c1.Field_Type__c='String';
        c1.Matching_Type__c='Equals';
        c1.Matching_Value__c='Agriculture';
        c1.Related_Object__c='Contact';

        insert c1;

        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='FirstName',Type__c='Update Field',Value__c='TestUpdate');

        insert a1;

        RuleAction__c a2 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='Description',Type__c='Update Field',Value__c='\'Merge Field Update\'&{!Account.Name}');

        insert a2;

        rule.Filter_Logic__c='1 AND (2 OR 3) AND 4';
        update rule;

        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture');
        insert a;

        Contact c = new Contact(LeadSource='NGL', Salutation='Mr.',FirstName='test',LastName='contact',AccountId=a.Id,MailingCountry='USA',MailingState='TX',MailingCity='Dallas');
      //Below line commented by Gunjan Sharma for case - 00269646
      //  insert c;

        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue); 
        Test.startTest(); 
        //this will not evaluate rule as it has already been executed once
        a.Industry = 'Agriculture';
        update a; 

        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);

        //Below code commented by Gunjan Sharma for case - 00269646
      //  c =[Select Id,FirstName,Description FROM Contact WHERE Id=:c.Id];
      //  system.assertEquals('test', c.FirstName);
        //system.assertEquals('Merge Field Update shuld be test', c.Description );                           
        Test.stopTest();

    } 
              
    static testmethod void testRuleExecutionCrossObjectFieldUpdate(){
        Rule__c rule =setupRules();

        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Update Field',Value__c='Prospect');

        insert a1;


        rule.Filter_Logic__c='1 AND (2 OR 3)';
        update rule;


        Test.startTest(); 
        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture',Type='Customer');
        insert a;                        
        Test.stopTest();

    }  
    @IsTest
    static void testRuleExecutionSendEmailAction(){
        Rule__c rule =setupRules();

        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Send Email',User_Owner_Id__c=UserInfo.getUserId(),Email_Template__c='1111111');

        insert a1;
        //Below code modified by Gunjan Sharma for case - 00269646
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u = new User(alias = 'jsmtih', email='jsmith@acme.com', 
        emailencodingkey='UTF-8', lastname='Smith', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Los_Angeles', 
        username='5589243470@acme.com');
        insert u;
        system.runAs(u){
            Group g=new Group(name='test');
            insert g;

            GroupMember gm=new GroupMember (UserorGroupId=UserInfo.getUserId(),GroupId=g.Id);
            insert gm;

            RuleAction__c a2 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
            field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Send Email',User_Owner_Id__c=g.Id,Email_Template__c='1111111');

            insert a2;

            rule.Filter_Logic__c='1 AND (2 OR 3)';
            update rule;

            Test.startTest(); 
            //now create account :-
            Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture',Type='Customer');
            insert a;                        
            Test.stopTest();
        }
    }  


    static testmethod void testRuleExecutionFalse(){
        setupRules();

        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Mining');

        Test.startTest();
        insert a;    
        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);                              
        Test.stopTest();

    }

    static testmethod void testSort(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('US','US'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO','Mexico'));
        AW_AdvanceWorkflowExecutionHelper.sortSelectListOnLabel(options );
    }

    static testmethod void testConvertDateMethod(){
        AW_AdvanceWorkflowExecutionHelper.convertToDate('2/11/2012');
        AW_AdvanceWorkflowExecutionHelper.convertToDate('21/11/2012');
        AW_AdvanceWorkflowExecutionHelper.convertToDate('2021/11/20');
    }

         //updated SH
    public  static Rule__c setupRules(){

        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
        insert rule; 

        List<RuleCriteria__c> criteria = new List<RuleCriteria__c>();
        RuleCriteria__c c1 = new RuleCriteria__c(rule__c=rule.id);
        c1.Field_API_Name__c='Industry';
        c1.Field_Type__c='Picklist';
        c1.Matching_Type__c='Equals';
        c1.Matching_Value__c='Agriculture';
        c1.Related_Object__c='Account';
        criteria.add(c1);

        RuleCriteria__c c2 = new RuleCriteria__c(rule__c=rule.id);
        c2.Field_API_Name__c='AnnualRevenue';
        c2.Field_Type__c='Currency';
        c2.Matching_Type__c='Greater Than';
        c2.Matching_Value__c='1000';
        c2.Related_Object__c='Account';
        criteria.add(c2);

        RuleCriteria__c c3 = new RuleCriteria__c(rule__c=rule.id);
        c3.Field_API_Name__c='CreatedDate';
        c3.Field_Type__c='Datetime';
        c3.Matching_Type__c='Greater Than';
        c3.Matching_Value__c='6/12/2011';
        c3.Related_Object__c='Account';
        criteria.add(c3);

        insert criteria;

        //create action
        List<RuleAction__c> actions = new List<RuleAction__c>();

        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',
        field_name__c='Name',Type__c='Update Field',Value__c='Test');

        actions.add(a1);

        RuleAction__c a2 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',
        field_name__c='AnnualRevenue',Type__c='Update Field',Value__c='2000');
        actions.add(a2);

        // By CC
        RuleAction__c a3 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',
        field_name__c='OwnerId',Type__c='Update Field',Value__c=userinfo.getUserId(),Notify_User__c = true);
        actions.add(a3);

        RuleAction__c a4 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        Type__c='Insert Related Object');
        actions.add(a4);

        RuleAction__c a5 = new RuleAction__c(rule__c=rule.id,related_object__c='Attachment',
        Type__c='Insert Related Object');
        actions.add(a5);

        RuleAction__c a6 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',
        field_name__c='Phone',Type__c='Update Field',Value__c='Owner.Phone');
        actions.add(a6);

        RuleAction__c a7 = new RuleAction__c(rule__c=rule.id,related_object__c='Account',
        field_name__c='Description',Type__c='Update Field',Long_Value__c='Test content');
        actions.add(a7);
        insert actions;

        List<Values_for_Action_Insert_Record__c> infos = new List<Values_for_Action_Insert_Record__c>();

        Values_for_Action_Insert_Record__c info = new Values_for_Action_Insert_Record__c(Value__c = 'LastName', Rule_Action__c = a4.Id, Name = 'LastName');

        infos.add(info);

        Values_for_Action_Insert_Record__c info2 = new Values_for_Action_Insert_Record__c(Value__c = 'Account.Name', Rule_Action__c = a4.Id, Name = 'FirstName');

        infos.add(info2);

        Values_for_Action_Insert_Record__c info3 = new Values_for_Action_Insert_Record__c(Value__c = '12345', Rule_Action__c = a5.Id, Name = 'Body');

        infos.add(info3);

        Values_for_Action_Insert_Record__c info4 = new Values_for_Action_Insert_Record__c(Value__c = 'test.txt', Rule_Action__c = a5.Id, Name = 'Name');

        infos.add(info4);

        insert infos;

        rule =[Select Id,  Status__c,Filter_Logic__c FROM Rule__c WHERE Id=:rule.Id];
        //rule.Enabled__c=true;
        //By CC
        //rule.Available__c  = true;
        rule.Status__c='Active';
        rule.Evaluation_Rule__c='Record is created or edited and did not previously meet the rule criteria';
        rule.Filter_Logic__c='1 AND (2 OR 3)';
        update rule;

        List<Advance_Workflow__c> wfplan=[Select Id FROM Advance_Workflow__c WHERE Object__c='Account'];
        Advance_Workflow__c plan;
        if(wfplan.size()==0){
            plan= new Advance_Workflow__c(Name = 'Test Test Plan');
            plan.Object__c  = 'Account';
            plan.Description__c = 'Test Desc';
            plan.Enabled__c = true;
            plan.CountRulesassociatedtoAdvanceWorkflow__c=1;
            insert plan;
        } else plan=wfplan[0];

        rule.Advance_Workflow__c = plan.id;
        update rule;

        //plan.Enabled__c = true;
        //update plan;

        return rule;
    }
        
    static testmethod void testRuleExecutionTrueIsChanged(){
        Rule__c rule = setupRules();
        RuleCriteria__c c3 = new RuleCriteria__c(rule__c=rule.id);
        c3.Field_API_Name__c='Name';
        c3.Field_Type__c='String';
        c3.Matching_Type__c='ChangedFromTo';
        c3.Matching_Value__c = 'shuld be test,test';
        c3.Related_Object__c='Account';
        insert c3;         

        rule.Filter_Logic__c += 'AND 4';
        update rule;

        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture');

        Test.startTest();
        insert a;    
        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);

        //this will not evaluate rule as it has already been executed once
        a.AnnualRevenue = 500.0;
        a.Name = 'test';
        update a; 

        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);
        //system.assertNotEquals(0, [select id from contact where accountid =: a.Id].size());                                             
        Test.stopTest();

    }
             
    static testmethod void testRuleExecutionTrueChangedFromTo(){
        Rule__c rule = setupRules();
        RuleCriteria__c c3 = new RuleCriteria__c(rule__c=rule.id);
        c3.Field_API_Name__c='Name';
        c3.Field_Type__c='String';
        c3.Matching_Type__c='IsChanged';
        c3.Matching_value__c='oldvalue,newvalue';
        c3.Related_Object__c='Account';
        insert c3;         

        rule.Filter_Logic__c += 'AND 4';
        update rule;

        //now create account :-
        Account a = new Account(Name='shuld be test',AnnualRevenue=500.0,Industry='Agriculture');

        Test.startTest();
        insert a;    
        //get the account:-
        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('shuld be test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);

        //this will not evaluate rule as it has already been executed once
        a.AnnualRevenue = 500.0;
        a.Name = 'test';
        update a; 

        a=[Select Id,AnnualRevenue,Name,Industry FROM Account WHERE Id=:a.Id];
        system.assertEquals('test', a.Name);
        system.assertEquals(500, a.AnnualRevenue);
        //system.assertNotEquals(0, [select id from contact where accountid =: a.Id].size());                                             
        Test.stopTest();

    }
    
    // Start of Below Code added by Gunjan Sharma for case - 00269646

     static testmethod void testStringComparsionMethod1() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='Record is created or edited and did not previously meet the rule criteria',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='FirstName',Type__c='Update Field',Value__c='TestUpdate');
    
        insert a1;
        rule.Status__c = 'Active';
        update rule;
        

        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;

        Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        //AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
       //AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
    }

    static testmethod void testStringComparsionMethod2() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='FirstName',Type__c='Update Field',Value__c='TestUpdate');
    
        insert a1;
        rule.Status__c = 'Active';
        update rule;
        
        rule.Evaluation_Rule__c='On Click Event';
        update rule; 
       
       RuleAction__c a2 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Execute an Apex Job',User_Owner_Id__c=UserInfo.getUserId(),Apex_Job_Class__c = '1111111',Email_Template__c='1111111');
    
        insert a2;
        //rule.Status__c = 'Active';
        update rule;
        

        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;

        Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
        
    }
    
    static testmethod void testStringComparsionMethod3() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='Record is created or edited and did not previously meet the rule criteria',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Send Email',User_Owner_Id__c=UserInfo.getUserId(),Email_Template__c='1111111');    
        insert a1;
        rule.Status__c = 'Active';
        update rule;
        
        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;
        
		//a1.Type__c='Apex Callout-HTTP';
        //update a1;
		Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
        
        
    }
    
    static testmethod void testStringComparsionMethod4() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='Record is created or edited and did not previously meet the rule criteria',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
        RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='FirstName',Type__c='Apex Callout-HTTP',Value__c='TestUpdate');
    
        insert a1;
        rule.Status__c = 'Active';
        update rule;
        
        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;
        
		Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
        

        
    }
    
     static testmethod void testStringComparsionMethod5() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
         
         
		
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='On Click Event',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
       RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
                                                            field_name__c='FirstName',Type__c='Insert Related Object',Value__c='TestUpdate');

        insert a1;
        rule.Status__c = 'Active';
        update rule;
        
        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;
       Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
        
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
        

        
    }
    
     static testmethod void testStringComparsionMethod6() {
        AW_AdvanceWorkflowExecutionEngine engine = new AW_AdvanceWorkflowExecutionEngine();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule = new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='On Click Event',Description__c='Rule 1 Description', Advance_Workflow__c = plan.Id);
        insert rule;
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(rule__c=rule.id,related_object__c='Account',
                                                           Matching_Type__c='Equals', Matching_Value__c='Test', field_name__c='Name',field_API_Name__c='Name',Field_Type__c='Text');
        insert ruleCriteria ;
       RuleAction__c a1 = new RuleAction__c(rule__c=rule.id,related_object__c='Contact',
        field_name__c='CrossObject',CrossObjectField__c='Account.Type',Type__c='Execute an Apex Job',User_Owner_Id__c=UserInfo.getUserId(),Apex_Job_Class__c = '1111111',Email_Template__c='1111111');
    
        insert a1;
        rule.Status__c = 'Active';
        update rule;
        

        Rule_Execution_History__c  rHistory = new Rule_Execution_History__c  ();
        rHistory.Rule__c = rule.Id;
        rHistory.Record_ID__c = acc.id;
        rHistory.Rule_ID__c = rule.Id;
        insert rHistory;

        Set<Id> recordIds = new Set<Id>();
        recordIds.add(acc.Id);
        //AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', true);
        AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(recordIds, 'Account', false);
       //AW_AdvanceWorkflowExecutionEngine.startRulesProcessingOnClick(recordIds, 'Account');
    }
    
	// End of Below Code added by Gunjan Sharma for case - 00269646

}