/*
Action Plans v3
Force.com Labs
http://appexchange.salesforce.com/listingDetail?listingId=a0N30000003HcINEA0

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class ActionPlanDetailController{
    
    
    public ActionPlan__c            actionPlan      { get; set; }
    public ActionPlansUtilities     actionPlanUtil  { get; set; }
    public String                   actionPlanId    { get; set; }
    
    /**
    * Constructor
    */
     //Start code added by bhagya-case-00254740
      private static User createTestUser(String username) {
      Profile userPrf= [select id from profile where name='System Administrator'];       
      User testUser = new User();
      testUser.Email= 'test@test.com';
      testUser.Username= username +'@testuser12.com';
      testUser.LastName= 'test';
      testUser.Alias = 'test';
      testUser.ProfileId = userPrf.Id;
      testUser.LanguageLocaleKey   = 'en_US';
      testUser.LocaleSidKey= 'en_US';
      testUser.TimeZoneSidKey = 'America/Chicago';
      testUser.EmailEncodingKey= 'UTF-8';
      //insert testUser;
      return testUser;
    }
    //Stop bhagya-case-00254740
    
    public ActionPlanDetailController( ApexPages.StandardController stdController ){
        
        this.actionPlan = ( ActionPlan__c) stdController.getRecord();
        
        if( System.currentPageReference().getParameters().get( 'id' ) != null ){
            this.actionPlanId = System.currentPageReference().getParameters().get( 'id' );
             //Add your Custom object in the SOQL Query
            this.actionPlan = [ select a.Id, a.Name, a.CreatedById, a.StartDate__c, a.Action_Plan_Template__r.Name, 
                                    a.Action_Plan_Template__r.Id, a.Action_Plan_Template__c, a.Account__c, a.Contact__c, 
                                    a.Lead__c, a.Opportunity__c,  a.Contract__c, a.Case__c, a.Campaign__c ,
                                    a.SkipWeekends__c, a.SkipDay__c, a.Owner.Name, 
                                    a.CreatedDate, a.LastModifiedById, a.LastModifiedDate,
                                    
                                    //Code added - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701 - Start
                                    //new field Project__c added
                                    a.Project__c
                                    //Code added - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701 - end
                                
                                    from ActionPlan__c a  
                                    Where a.Id =: this.actionPLanId limit 1 ];
        }
        
        this.actionPlanUtil = new ActionPlansUtilities( this.actionPlan );
        
    }
    
    /**
    * Deletes current actionplan
    */
    public Pagereference deletePlan(){
        
        return this.actionPlanUtil.deletePlan();
    }
    
    /**
    * Gets all tasks for a given ActionPlan
    */
    public List<APTaskTemplate__c> getTasks(){
        
        return this.actionPlanUtil.getTasks();
    }
    
    /**
    * Retrieves size of APT Template Tasks List.
    * @return apTasks
    */
    public Integer getTaskSize(){
        
        return this.actionPlanUtil.getTaskSize(); 
    }
    
    /**
    * Returns number of completed tasks
    */
    public Integer getCompleted(){
        
        return this.actionPlanUtil.getCompleted();
    }
    
    /**
    * Checks if Action Plan Template has been changed since the creation of the Action Plan.
    * @return Boolean
    */
    public Boolean getVersion(){
        
        return this.actionPlanUtil.getVersion();
    }
    
    public String getRelatedObjectName(){
        
        String objName='';
        
        if( this.actionPlan.Account__c != null ){
            Account a = [select Name from Account where id =: this.actionPlan.Account__c limit 1]; 
            objName = a.Name;   
        }
        else if( this.actionPlan.Campaign__c != null ){
            Campaign c = [select Name from Campaign where id =: this.actionPlan.Campaign__c limit 1];
            objName = c.Name;
        }
        else if( this.actionPlan.Case__c != null ){
            Case c = [select Subject, CaseNumber from Case where id =: this.actionPlan.Case__c limit 1];
            objName = (c.Subject != null) ?  c.CaseNumber + ': ' + c.Subject : c.CaseNumber; 
        }
        else if( this.actionPlan.Contact__c != null ){
            Contact c = [select FirstName, LastName from Contact where id =: this.actionPlan.Contact__c limit 1];
            objName = (c.FirstName != null) ? c.FirstName + ' ' + c.LastName : c.LastName;
        }
        else if( this.actionPlan.Contract__c != null ){
            Contract c = [select ContractNumber from Contract where id =: this.actionPlan.Contract__c limit 1];
            objName = 'Contract Number :'+ c.ContractNumber;
        }
        else if( this.actionPlan.Lead__c != null ){
            Lead l = [select FirstName, LastName, Company from Lead where id =: this.actionPlan.Lead__c limit 1];
            objName = (l.FirstName != null) ? l.FirstName + ' ' + l.LastName + ', ' + l.Company : l.LastName + ', ' + l.Company;
        }
        else if( this.actionPlan.Opportunity__c != null ){
            Opportunity o = [select Name from Opportunity where id =: this.actionPlan.Opportunity__c limit 1];
            objName = o.Name;
        }
        
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
        //Changes start here
        else if( this.actionPlan.Project__c != null ){
            
            //Query result of Project
            List<pse__Proj__c> projects = [select Name from pse__Proj__c where id =: this.actionPlan.Project__c limit 1];
            
            //Check for size
            if(projects.size() > 0) {
                
                //populate name
                objName = projects[0].Name;
            }
        }
        //Changes stop here
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
        
        return objName;
    }
    
    public String getCreatedBy(){
        
        User u = [select Name from User where id =: actionPlan.CreatedById limit 1];
        return u.Name;
    }

    public String getLastModifiedBy(){
    
        User u = [select Name from User where id =: actionPlan.LastModifiedById limit 1];
        return u.Name;
    }

    public static testMethod void constructorTests(){
        //Start added by Bhagya case-00254740
       User testUser5=createTestUser('TestB5');
       insert testUser5;
       system.runAs(testUser5)
       { 
      //Stop bhagya-case-00254740
        
        //Test.StartTest();//commented by bhagya
        
        System.currentPageReference().getParameters().put( 'id', null );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 1 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController2 = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );
        
        //Test.StopTest();
    }
    }//Added by Bhagya case -00254740
    public static testMethod void checkTasks(){
        //Start added by Bhagya case-00254740
       User testUser3=createTestUser('TestB3');
       insert testUser3;
       system.runAs(testUser3)
       { 
      //Stop bhagya-case-00254740
    
        //Test.StartTest();
        
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 3 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        List<APTaskTemplate__c> apTasks = apDetailController.getTasks();
        
        //Checks to see that list of tasks is not empty
        System.assert( !apTasks.isEmpty(), 'task list is empty' );
        
        //Test.StopTest();
    }//Added by bhagya case -00254740
    }
    
    public static testMethod void checkTaskSize(){
    
     //Start added by Bhagya case-00254740
       User testUser1=createTestUser('TestB1');
       insert testUser1;
       system.runAs(testUser1)
       { 
      //Stop bhagya-case-00254740
        //Test.StartTest();
        
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 3 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        
        List<APTaskTemplate__c> apTasks = apDetailController.getTasks();
        Integer numTasks                = apDetailController.getTaskSize();
        
        //Checks to see that list of tasks is not empty
        System.assert( !apTasks.isEmpty(), 'task list is empty' );      
        
        //check that both methods return correct number of task objects
        System.assertEquals( numTasks, apTasks.size() );
        
        //Test.StopTest();
    }
    }
    
    public static testMethod void checkCompletedTasks(){
        //Start added by Bhagya case-00254740
       User testUser4=createTestUser('TestB4');
       insert testUser4;
       system.runAs(testUser4)
       { 
      //Stop bhagya-case-00254740  
    
        //Test.StartTest();
        
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 3 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        Integer completedTasks = apDetailController.getCompleted();
        
        //verifies number of completed tasks
        System.assertEquals( 0, completedTasks );
        
        //Test.StopTest();
    }//Added by Bhagya case -00254740
    }
    
    public static testMethod void checkActionPlanTemplateVersion(){
    
        //Start added by Bhagya case-00254740
       User testUser6=createTestUser('TestB6');
       insert testUser6;
       system.runAs(testUser6)
       { 
      //Stop bhagya-case-00254740  
       //Test.StartTest();
        ActionPlansTestUtilities testUtil   = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan            = testUtil.createNewActionPlan( 'accounts', 2 );
        ActionPlanTemplate__c apTemplate    = testUtil.createNewActionPlanTemplate( 2 );
        
        actionPlan.Action_Plan_Template__c = apTemplate.Id;
        update actionPlan;
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        boolean versionName = apDetailController.getVersion();
        
        //Checks if Action Plan Template has not been changed since the creation of the Action Plan.
        //System.assert( !versionName );        
        
        apTemplate.Name = 'new name';
        update apTemplate;
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
         Test.startTest();//Added by Bhagya case -254740
        apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( actionPlan ) );   
         Test.stopTest();//Added by Bhagya case -254740   
        versionName = apDetailController.getVersion();
        
        //Checks if Action Plan Template has been changed since the creation of the Action Plan.
        //System.assert( versionName ); 
        
        //Test.StopTest();
    }//added by Bhagya case -00254740
    }
    
    public static testMethod void checkDeleteActionPlan(){
       //Start added by Bhagya case-00254740
       User testUser7=createTestUser('TestB7');
       insert testUser7;
       system.runAs(testUser7)
       { 
       //Stop bhagya-case-00254740
        //Test.StartTest();
        
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 2 );
        
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController apDetailController = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) );      
        apDetailController.deletePlan();
        
        List<ActionPlan__c> actionPlanList = [ select Id from ActionPlan__c where Id =: actionPlan.Id limit 1];
        
        //Checks if Action Plan Template has been changed since the creation of the Action Plan.
        System.assert( actionPlanList.isEmpty(), 'Action Plan was not deleted' );       
        
        //Test.StopTest();
    }//Added by Bhagya case -00254740
    }
    
    //GS
   /* public static testMethod void checkGetRelatedObjectName(){
    
        //Start added by Bhagya case-00254740
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { 
      //Stop bhagya-case-00254740      
        ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
        
        ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        ActionPlanDetailController APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        String name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'campaigns', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        Test.startTest();//Added by Bhagya case -254740
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'cases', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'contacts', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'contracts', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'leads', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        actionPlan = testUtil.createNewActionPlan( 'opportunitys', 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
        //Changes start here
        Test.stopTest();//Added by Bhagya Case -00254740
        actionPlan = testUtil.createNewActionPlan(Label.PSE_PROJECT, 0 );
        System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
        
        APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
        
        name = APDC.getRelatedObjectName();
        System.assert(name != null);
        //Changes stop here
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
    }
    }//Added by Bhagya Case -00254740

*/
    //Start Below Code modified by Gunjan Sharma for case - 00269646
    public static testMethod void checkGetRelatedObjectName()
    {
    
        //Start added by Bhagya case-00254740
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { 
          //Stop bhagya-case-00254740      
            ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
            
            ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            ActionPlanDetailController APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            String name = APDC.getRelatedObjectName();
            System.assert(name != null);
            
            actionPlan = testUtil.createNewActionPlan( 'campaigns', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            Test.startTest();//Added by Bhagya case -254740
            APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            
            name = APDC.getRelatedObjectName();
            System.assert(name != null);
        }
    }//Added by Bhagya Case -00254740
    
    public static testMethod void checkGetRelatedObjectName2()
    {

       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { 
             
            ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
            ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'cases', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            ActionPlanDetailController APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            String name = APDC.getRelatedObjectName();
            System.assert(name != null);
            
            actionPlan = testUtil.createNewActionPlan( 'contacts', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            name = APDC.getRelatedObjectName();
            System.assert(name != null);
        }
    }
    
    public static testMethod void checkGetRelatedObjectName3()
    {
        Test.startTest();
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       {      
            ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
            
            ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'contracts', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            ActionPlanDetailController APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            String name = APDC.getRelatedObjectName();
            System.assert(name != null);
            
            actionPlan = testUtil.createNewActionPlan( 'leads', 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            name = APDC.getRelatedObjectName();
            System.assert(name != null);
            Test.stopTest();

        }
    }
    
    public static testMethod void checkGetRelatedObjectName4()
    {
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       {     
            
            //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
            //Changes start here
            //Test.stopTest();//Added by Bhagya Case -00254740
            Test.startTest();
            ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
            ActionPlan__c actionPlan = testUtil.createNewActionPlan(Label.PSE_PROJECT, 0 );
            System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
            ActionPlanDetailController APDC = new ActionPlanDetailController( new ApexPages.StandardController( new ActionPlan__c() ) ); 
            String name = APDC.getRelatedObjectName();
            System.assert(name != null);
            Test.stopTest();
            //Changes stop here
            //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701

        }
    }
    
     //End of Code modified by Gunjan Sharma for case - 00269646
}