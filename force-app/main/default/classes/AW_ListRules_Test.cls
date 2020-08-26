/**
     * This class contains unit tests for validating the behavior of Apex class InstallBase_1_AC
     
     */
    @isTest
    private class AW_ListRules_Test {
        static Id accountId;
        static Integer RuleRecCount = 15;
        static List<Rule__c> rules;
        static Advance_Workflow__c plan;


    static testMethod void testFiltercriteria() {
        rules = prepareTestData();         
        Test.startTest();
        PageReference pageRef = Page.AW_ListRules_VF;
        pageRef.getParameters().put('id', plan.id);
        Test.setCurrentPage(pageRef);

        //page open and result sorted by Name asc
        //AW_ListRules.CtrlId=plan.Id;
        AW_ListRules controller = new AW_ListRules();

        controller.resultsPerPage = 1;

        controller.getFilterCriteria();

    }
    static testMethod void checkApplyFilterAndPageNavigations() {
        rules = prepareTestData();         
        Test.startTest();
        PageReference pageRef = Page.AW_ListRules_VF;
        pageRef.getParameters().put('id', plan.id);
        Test.setCurrentPage(pageRef);

        //page open and result sorted by Name asc
        //AW_ListRules.CtrlId=plan.Id;
        AW_ListRules controller = new AW_ListRules();

        controller.resultsPerPage = 1;
        controller.sortField = 'Name';
        //controller.CtrlId=plan.Id;
        controller.applySorting();
        //verifying total result.It should be number of install base record created
        //system.assertEquals(RuleRecCount, controller.totalResults);

        //Sorting desc by name
        controller.applySorting();   

        //changed sortby field to Status__c 
        controller.sortField = 'Status__c';
        controller.applySorting(); 


        //Sorting desc by Asset_Category__c        
        controller.modifyView();

        //apply filter
        controller.dynamicSearch = controller.fixedSearch = 'Status__c.-~>STRING.-~>Active';
        controller.applyFilter();

        //verifying total result.It should be number of install base record created
        //system.assertEquals(RuleRecCount, controller.totalResults);

        //navigation methods 
        //system.assertEquals(false, controller.hasPrevPage);
        if(controller.hasNextPage){
        controller.nextPage();
        }
        if(controller.hasPrevPage){
        controller.prevPage();
        }

        controller.lastPage();

        if(controller.hasLastPage){
        controller.lastPage();
        }

        //system.assertEquals(false, controller.hasNextPage);

        if(controller.hasFirstPage){
        controller.firstPage();
        }

        controller.pageNumber = 1;
        controller.goToPage();

        if(controller.totalPage > 2){
        controller.pageNumber = 2;
        controller.goToPage();
        }

        //change page size
        controller.resultsPerPage = 2;
        controller.updatePageSize();

        //verify page size change
        //system.assertEquals(2,controller.lstInstallBaseWrapper.size());


        //change selectedAsset to All actionable
        controller.selectedAsset = 'All_Actionable_Assets';
        controller.applyFilter();

        //verify result.Should be 0 as we have not created any actionable assets
        //system.assertEquals(0,controller.totalResults);

        //clear filter
        controller.clearFilter();

        //apply filter
        //  controller.dynamicSearch = controller.fixedSearch = 'Hardware_Service_End_Date__c.-~>DATE.-~>01/20/2011~01/20/2012';
        // controller.applyFilter();

        //clear filter
        controller.clearFilter();

        //apply filter
        //controller.dynamicSearch = controller.fixedSearch = 'Hardware_Service_End_Date__c.-~>DATE.-~>~01/20/2012';
        controller.applyFilter();

        //apply filter
        //controller.dynamicSearch = controller.fixedSearch = 'SR_Created_Date__c.-~>DATETIME.-~>01/20/2011~01/20/2012';
        controller.applyFilter();

        //clear filter
        controller.clearFilter();

        //apply filter
        //controller.dynamicSearch = controller.fixedSearch = 'SR_Created_Date__c.-~>DATETIME.-~>~01/20/2012';
        controller.applyFilter();

        //clear filter
        controller.clearFilter();


        //controller.updateUsageAnalytics();


        //change selectedAsset to All actionable
        controller.selectedAsset = 'All_Assets';
        controller.applyFilter();

        controller.saveCurrentView();
        controller.deleteCurrentView();

        /*List<String> extraCols = new List<String>{'Installed_Product_Status__c.Asset_Category__c'};
        AW_ListRules.objectWrapper objectWrapper = new InstallBase_1_AC.objectWrapper(rules.get(0), extraCols);*/

        //added for the story #S-362576 #START
        controller.showAddRemove(); 
        String userType = controller.UserType;  
        list<Rule__c> lstAllIB = new list<Rule__c>();
        lstAllIB = controller.lstAllIB; 

        if(rules != null && rules[0] != null) {
        AW_ListRules.InstallBaseWrapper obj= new AW_ListRules.InstallBaseWrapper(rules[0]);

        List<String> str = new List<String>();
        str.add('test');

        obj.Execution = 'test';
        obj.DisplayActions = 'DA';

        String returnValue = AW_ListRules.getValue(rules[0], 'Id');


        }

        AW_ListRules.fieldWrapper obj1= new AW_ListRules.fieldWrapper('Account', 'Account', 'integer', 'help');
        obj1.Type = 'type';

        List<AW_ListRules.fieldWrapper> lstWrapper = new List<AW_ListRules.fieldWrapper>();
        lstWrapper.add(obj1);

        controller.modify_lstibdc(lstWrapper);

        Integer toNumber1 = controller.showingTo;
        Integer fromNumber1 = controller.showingFrom;
        Integer resultNumber1 = controller.totalResults;
        controller.prevPage();
        controller.nextPage();

        //added for the story #S-362576 #END 


        //controller.returnoppty();
        Test.stopTest();

    }

    //method to prepare test data records
    static List<Rule__c> prepareTestData(){
        plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        

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
            Field_name__c='ID',
            Field_API_Name__c='ID',
            Field_Type__c='STRING');
        insert  ruleCriteria;
        
        RuleCriteria__c ruleCriteria1    =   new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='32', 
            Field_name__c='Amount',
            Field_API_Name__c='Amount',
            Field_Type__c='INTEGER');
        insert  ruleCriteria1;
        
        RuleCriteria__c ruleCriteria2    =   new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='Amount',
            Field_API_Name__c='Amount',
            Field_Type__c='OTHER');
        insert  ruleCriteria2;

        RuleCriteria__c ruleCriteria3    =   new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='12/11/2014', 
            Field_name__c='Amount_Date__c',
            Field_API_Name__c='Amount_Date__c',
            Field_Type__c='DATETIME');
        insert  ruleCriteria3;

        RuleCriteria__c ruleCriteria4    =   new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='12/11/2014', 
            Field_name__c='Amount_Date__c',
            Field_API_Name__c='Amount_Date__c',
            Field_Type__c='DATE');
        insert  ruleCriteria4;


        
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

        rule.Order__c=10;
        rule.Status__c = 'Active';
        rule.Execution_Behavior__c='Execute and Exit';
        rule.Advance_Workflow__c=plan.id;
        update rule;
        
        Account acc = new Account(Name = 'TestAccount29102012',Industry='Agriculture');
        insert acc;

        List<Rule__c> ruleslist = new List<Rule__c>();
       /* for(Integer cnt = 0 ; cnt < RuleRecCount ; cnt ++){
            Rule__c rule = new Rule__c();
            rule.Name='test IB' + cnt;
            rule.Description__c='Isaac Quirke Major Account or Named AND Healthcare AND United States test';
            rule.Object__c='Lead';
            rule.Evaluation_Rule__c='Record is created';
            ruleslist.add(rule);            
            }*/
        //Rule__c rule = new Rule__c(Advance_Workflow__c=plan.Id,Name = 'Test Test Account',Object__c = 'Account', Status__c='Active',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');


        ruleslist.add(rule);
        update ruleslist;
        
        //Changes start here
        //Code modified - Padmesh Soni (03/04/2016) - S-387754
        //Uncommented code
        List<Workflow_DynamicColumns__c> dynCols = new List<Workflow_DynamicColumns__c>(); 
        Workflow_DynamicColumns__c dynCol = new Workflow_DynamicColumns__c(ApiName__c = 'Account__c', Type__c = 'Fixed');
        Workflow_DynamicColumns__c dynCol1 = new Workflow_DynamicColumns__c(ApiName__c = 'Account__r.City__c', Type__c = 'Dynamic');
        Workflow_DynamicColumns__c dynCol2 = new Workflow_DynamicColumns__c(ApiName__c = 'Name');
        dynCols.add(dynCol);
        dynCols.add(dynCol1);
        dynCols.add(dynCol2);
        insert dynCols;
        
        //Changes stop here

        return ruleslist;
    }

    //START -- Added by Shivani for S-637724 on 29/08/2019       
    static testMethod void testFiltercriteria_Extra() {
        Advance_Workflow__c plan = new Advance_Workflow__c(Name = 'Test Test Advance Workflow');
        plan.Object__c  = 'Account';
        plan.Description__c = 'Test Desc';
        plan.Enabled__c =True;
        insert plan;
        
        Rule__c rule    =   new Rule__c(Name = 'Rule test1',
            Status__c = 'Draft',
            Object__c = 'Account', 
            Version__c = 1,
            Description__c = 'Rule 1 Description',
            Evaluation_Rule__c='Execute Rule and Continue to Next Rule'
                                        //,Advance_Workflow__c = advanceWF.id
                                        );
        insert rule;
        
        RuleCriteria__c ruleCriteria = new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='ID',
            Field_API_Name__c='ID',
            Field_Type__c='OTHER');
        insert  ruleCriteria;
        
        List<Workflow_DynamicColumns__c> dynCols = new List<Workflow_DynamicColumns__c>(); 
        Workflow_DynamicColumns__c dynCol = new Workflow_DynamicColumns__c(ApiName__c = 'Account__c', Type__c = 'Fixed');
        Workflow_DynamicColumns__c dynCol1 = new Workflow_DynamicColumns__c(ApiName__c = 'Account__r.City__c', Type__c = 'Dynamic');
        Workflow_DynamicColumns__c dynCol2 = new Workflow_DynamicColumns__c(ApiName__c = 'Name');
        dynCols.add(dynCol);
        dynCols.add(dynCol1);
        dynCols.add(dynCol2);
        insert dynCols;
        
        Workflow_Console_ViewDetail__c v = new Workflow_Console_ViewDetail__c();
        v.View_Type__c = 'Account Console';
        v.Name  = '---Select View---';
        v.fixed_Search_Text__c = 'Status__c.-~>OTHER.-~>Active';
        insert v;
        
        PageReference pageRef = Page.AW_ListRules_VF;
        pageRef.getParameters().put('id', plan.id);
        Test.setCurrentPage(pageRef);
        
        AW_ListRules lRules = new AW_ListRules();
        lRules.dynamicSearch = lRules.fixedSearch = 'Status__c.-~>OTHER.-~>Active';
        lRules.showAddRemove();
        lRules.applySorting();
        
        RuleCriteria__c ruleCriteria1 = new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='CreatedDate',
            Field_API_Name__c='CreatedDate',
            Field_Type__c='DATE');
        insert  ruleCriteria1;
        
        Workflow_Console_ViewDetail__c v1 = new Workflow_Console_ViewDetail__c();
        v1.View_Type__c = 'Account Console';
        v1.Name  = '---Select View---';
        v1.fixed_Search_Text__c = 'CreatedDate.-~>DATE.-~>08/29T14:52:54.775+05:30/2019';
        insert v1;
        
        lRules = new AW_ListRules();
        lRules.dynamicSearch = lRules.fixedSearch = 'CreatedDate.-~>DATE.-~>08/29T14:52:54.775+05:30/2019';
        lRules.showAddRemove();
        lRules.applySorting();
        
        RuleCriteria__c ruleCriteria2 = new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='ID',
            Field_API_Name__c='ID',
            Field_Type__c='STRING');
        insert  ruleCriteria2;
        
        Workflow_Console_ViewDetail__c v2 = new Workflow_Console_ViewDetail__c();
        v2.View_Type__c = 'Account Console';
        v2.Name  = '---Select View---';
        v2.fixed_Search_Text__c = 'Status__c.-~>STRING.-~>Active';
        insert v2;
        
        lRules = new AW_ListRules();
        lRules.dynamicSearch = lRules.fixedSearch = 'Status__c.-~>STRING.-~>Active';
        lRules.showAddRemove();
        lRules.applySorting();
        
        RuleCriteria__c ruleCriteria3 = new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='ID',
            Field_API_Name__c='ID',
            Field_Type__c='INTEGER');
        insert  ruleCriteria3;
        
        Workflow_Console_ViewDetail__c v3 = new Workflow_Console_ViewDetail__c();
        v3.View_Type__c = 'Account Console';
        v3.Name  = '---Select View---';
        insert v3;
        
        lRules = new AW_ListRules();
        lRules.showAddRemove();
        lRules.applySorting();
        lRules.updatePageSize();
        
        RuleCriteria__c ruleCriteria4 = new RuleCriteria__c(Rule__c = rule.id,
            Related_Object__c='Account',
            Matching_Type__c='Equals', 
            Matching_Value__c='Apparel', 
            Field_name__c='CreatedDate',
            Field_API_Name__c='CreatedDate',
            Field_Type__c='DATETIME');
        insert  ruleCriteria4;
        
        Workflow_Console_ViewDetail__c v4 = new Workflow_Console_ViewDetail__c();
        v4.View_Type__c = 'Account Console';
        v4.Name  = '---Select View---';
        v4.fixed_Search_Text__c = 'CreatedDate.-~>DATETIME.-~>08/29/2019';
        insert v4;
        
        lRules = new AW_ListRules();
        lRules.dynamicSearch = lRules.fixedSearch = 'CreatedDate.-~>DATETIME.-~>08/29/2019';
        lRules.showAddRemove();
        lRules.applySorting();
    }
    //END -- Added by Shivani for S-637724 on 29/08/2019  
}