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
public with sharing class ActionPlansUtilitiesTest {

    private static testMethod void APUtestSaveMethod() {
        //Start added by Bhagya case-00254740
       User testUser11=createTestUser('TestB11');
       insert testUser11;
       system.runAs(testUser11)
       { //Stop bhagya-case-00254740
        test.startTest();
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        
        ApexPages.currentPage().getParameters().put( 'refType', 'Account' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Account__c);
        
        ActionPlansUtilities apu = new ActionPlansUtilities( ap );          
        apu.apTasks = new List<APTaskTemplate__c>();
        apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
        String str = apu.getRelatedObjName();
        System.assert(apu.hasRelatedObject(), 'Should be a related object Account');
        List<String>strl         = apu.relatedObjIds();
        List<ActionPlan__c> apl  = apu.getActionPlans();    
            
        apu.save();
        
        ActionPlan__c rap = [select Id from ActionPlan__c where Id =: ap.Id];
        System.assert( rap != null ); 
        test.stopTest();
    }//Added by Bhagya case - 00254740
    }
    private static testMethod void APUtestSaveMultiple() {
       //Start added by Bhagya case-00254740
       User testUser5=createTestUser('TestB5');
       insert testUser5;
       system.runAs(testUser5)
       { //Stop bhagya-case-00254740
        Test.startTest();       
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ap.SkipWeekends__c  = true;
        ap.SkipDay__c = Label.ap_Friday;
        update ap;
        ApexPages.currentPage().getParameters().put( 'refType', 'Account' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Account__c);
        ActionPlansUtilities apu = new ActionPlansUtilities( ap );
        apu.apTasks = new List<APTaskTemplate__c>();
        apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
        apu.saveMultiple();
        ActionPlan__c rap = [select Id, Account__c from ActionPlan__c where Id =: ap.Id];
        System.assert( rap.Account__c == ap.Account__c );
        test.stopTest();
        }//Added by bhagya for case-00254740
    }
    
    
    private static testMethod void APUtestSaveMasiveContact() {
        //Start added by Bhagya case-00254740
        User testUser7=createTestUser('TestB7');
        insert testUser7;
        system.runAs(testUser7)
        { //Stop bhagya-case-00254740
        test.startTest();   
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        
        ActionPlan__c ap = ge.createNewActionPlan( 'contacts', 0 );
        ap.SkipWeekends__c  = true;
        ap.SkipDay__c = Label.ap_Friday;
        update ap;
        
        ApexPages.currentPage().getParameters().put( 'refType', 'Contact' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Contact__c);
        
        ActionPlansUtilities apu = new ActionPlansUtilities( ap );
        apu.apTasks = new List<APTaskTemplate__c>();
        apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
        
        apu.save();
        
        ActionPlanTemplate__c apt = ge.createNewActionPlanTemplate( 5 );
        ApexPages.currentPage().getParameters().put( 'templateId', apt.Id );
        ActionPlansUtilities apu2 = new ActionPlansUtilities( new ActionPlan__c() );
        apu2.apTasks = apu2.getTasks();
        
        System.assert( !apu2.apTasks.isEmpty() );
        test.stopTest();        
        }//Added by Bhagya case -00254740
    }     
    private static testMethod void APUtestSaveMasiveMethodOpportunities() {
        //Start added by Bhagya case-00254740
        User testUser8=createTestUser('TestB8');
        insert testUser8;
        system.runAs(testUser8)
        { //Stop bhagya-case-00254740
        test.startTest();    
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys', 0 );
        ap.SkipWeekends__c  = true;
        ap.SkipDay__c = 'Monday';
        update ap;
        ApexPages.currentPage().getParameters().put( 'refType', 'Opportunity' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Opportunity__c);
        ActionPlansUtilities apu = new ActionPlansUtilities( ap );
        apu.apTasks = new List<APTaskTemplate__c>();
        apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
        apu.save();
        ActionPlanTemplate__c apt = ge.createNewActionPlanTemplate( 5 );
        ApexPages.currentPage().getParameters().put( 'templateId', apt.Id );
        apu = new ActionPlansUtilities( new ActionPlan__c() );
        apu.apTasks = apu.getTasks();
        System.assert( !apu.apTasks.isEmpty() );
        test.stopTest();
        }//Added by bhagya case-00254740        
    }   
    
    
    private static testMethod void APUtestSaveMasiveMethodPart1() {
        //Start added by Bhagya case-00254740
         User testUser9=createTestUser('TestB9');
        insert testUser9;
        system.runAs(testUser9)
        { //Stop bhagya-case-00254740
        Map<String,String> objectDetails = new Map<String,String>();
        objectDetails.put('cases','Case');
        objectDetails.put('contacts','Contact');
        objectDetails.put('leads','Lead');//
        test.startTest();
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = null;        
        for(String k : objectDetails.keySet()){
            ap = ge.createNewActionPlan( k, 0 );
            ap.SkipWeekends__c  = true;
            ap.SkipDay__c = 'Monday';
            update ap;
            
            ApexPages.currentPage().getParameters().put( 'refType', objectDetails.get(k) );  
            ActionPlansUtilities apu = new ActionPlansUtilities( ap );
            apu.apTasks = new List<APTaskTemplate__c>();
            apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
            apu.save();
            
            ActionPlanTemplate__c apt = ge.createNewActionPlanTemplate( 5 );
            ApexPages.currentPage().getParameters().put( 'templateId', apt.Id );
            apu = new ActionPlansUtilities( new ActionPlan__c() );
            apu.apTasks = apu.getTasks();
            System.assert( !apu.apTasks.isEmpty() );
        }       
                
        test.stopTest();  
        }//Added by bhagya case- 00254740      
    }
    private static testMethod void APUtestSaveMasiveMethodPart2() {
    
        //Start added by Bhagya case-00254740
         User testUser10=createTestUser('TestB10');
        insert testUser10;
        system.runAs(testUser10)
        { //Stop bhagya-case-00254740
        Map<String,String> objectDetails = new Map<String,String>();
        objectDetails.put('contracts','Contract');
        objectDetails.put('campaigns','Campaign');
        objectDetails.put('opportunitys','Opportunity');
        test.startTest();
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = null;        
        for(String k : objectDetails.keySet()){
            ap = ge.createNewActionPlan( k, 0 );
            ap.SkipWeekends__c  = true;
            ap.SkipDay__c = 'Monday';
            update ap;
            
            ApexPages.currentPage().getParameters().put( 'refType', objectDetails.get(k) );
            ActionPlansUtilities apu = new ActionPlansUtilities( ap );
            apu.apTasks = new List<APTaskTemplate__c>();
            apu.apTasks.add( ActionPlansUtilitiesTest.apptask( ap ) );
    
            apu.save();
            
            ActionPlanTemplate__c apt = ge.createNewActionPlanTemplate( 5 );
            ApexPages.currentPage().getParameters().put( 'templateId', apt.Id );
            apu = new ActionPlansUtilities( new ActionPlan__c() );
            apu.apTasks = apu.getTasks();
            
            System.assert( !apu.apTasks.isEmpty() );
        }             
        test.stopTest();        
        }//Added by Bhagya for case-00254740
    }
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
    //Start Below Code Modified by Gunjan Sharma for case - 00269646
    private static testMethod void APUtestCancel() {
    //Start added by Bhagya case-00254740
       User testUser1=createTestUser('TestB1');
        Test.startTest();
       insert testUser1;
       system.runAs(testUser1)
       { 
        //Test.startTest();//Stop bhagya-case-00254740
        ActionPlansUtilities apu = new ActionPlansUtilities();
        PageReference page = apu.cancel();
        System.assert( page!= null );
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Account' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Account__c + ',' + ge.createNewAccount().id);
        page = apu.cancel();
        System.assert( page!= null );
        
        
        Test.stopTest();//commented by Bhagya for case -00254740
    }
    }
        
         private static testMethod void APUtestCancel1() {
 
       User testUser1=createTestUser('TestB1');
        Test.startTest();
       insert testUser1;
       system.runAs(testUser1)
       { 
        //Test.startTest();//Stop bhagya-case-00254740
        ActionPlansUtilities apu = new ActionPlansUtilities();
        PageReference page = apu.cancel();
        System.assert( page!= null );
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ge.createNewActionPlan( 'contacts', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Contact' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Contact__c + ',' + ge.createNewContact().id);
        page = apu.cancel();
        System.assert( page!= null );
        
        ge.createNewActionPlan( 'leads', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Lead' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Lead__c + ',' + ge.createNewLead().id);
        page = apu.cancel();
        System.assert( page!= null );
        
        Test.stopTest();
    }
 }
  private static testMethod void APUtestCancel2() {
    
       User testUser1=createTestUser('TestB1');
        Test.startTest();
       insert testUser1;
       system.runAs(testUser1)
       { 
       
        ActionPlansUtilities apu = new ActionPlansUtilities();
        PageReference page = apu.cancel();
        System.assert( page!= null );
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
       ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 ); 
        ge.createNewActionPlan( 'leads', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Lead' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Lead__c + ',' + ge.createNewLead().id);
        page = apu.cancel();
        System.assert( page!= null );
        
        /*ge.createNewActionPlan( 'opportunitys', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Opportunity' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Opportunity__c + ',' + ge.createNewOpportunity().id);
        page = apu.cancel();
        System.assert( page!= null );
        */
       
        Test.stopTest();
    }
 }
    
     private static testMethod void APUtestCancel3() {
    
       User testUser1=createTestUser('TestB1');
        Test.startTest();
       insert testUser1;
       system.runAs(testUser1)
       { 
      
        ActionPlansUtilities apu = new ActionPlansUtilities();
        PageReference page = apu.cancel();
        System.assert( page!= null );
        
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ge.createNewActionPlan( 'accounts', 0 );
        ApexPages.currentPage().getParameters().put( 'refType', 'Account' );
        ApexPages.currentPage().getParameters().put( 'refId' ,  ap.Account__c);
        page = apu.cancel();
        System.assert( page!= null );
        
        ActionPlanTemplate__c apt = ge.createNewActionPlanTemplate( 0 );
        ApexPages.currentPage().getParameters().put( 'templateId', apt.Id );
        page = apu.cancel();
        System.assert( page!= null );
        Test.stopTest();
    }
 }
    //End Code Modified by Gunjan Sharma for case - 00269646
    private static testMethod void APUtestRelatedObjectId() {
        //Start added by Bhagya case-00254740
        User testUser11=createTestUser('TestB24');
        insert testUser11;
        system.runAs(testUser11)
        { //Stop bhagya-case-00254740
        test.startTest();            
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ActionPlansUtilities apu = new ActionPlansUtilities(ap);
        String id = apu.relatedObjectId();
        System.assert( ap.Account__c == id);
        
        ap = ge.createNewActionPlan( 'contacts', 0 );
        apu = new ActionPlansUtilities(ap);
        id = apu.relatedObjectId();
        System.assert( ap.Contact__c == id);
        
        ap = ge.createNewActionPlan( 'leads', 0 );
        apu = new ActionPlansUtilities(ap);
        id = apu.relatedObjectId();
        System.assert( ap.Lead__c == id);
        
        ap = ge.createNewActionPlan( 'opportunitys', 0 );
        apu = new ActionPlansUtilities(ap);
        id = apu.relatedObjectId();
        System.assert( ap.Opportunity__c == id);
    }//Added by Bhagya case 00254740.
    }
    private static testMethod void APUtestHoursOption() {
        test.startTest();
            
        ActionPlansUtilities apu = new ActionPlansUtilities();
        List<selectOption>options = new List<selectOption>();
        options = apu.getHoursOption();
        System.assert( !options.isEmpty() );
        test.stopTest();
    }    

    private static testMethod void APUtestGetRecordOwnerId() {
    //Start added by Bhagya case-00254740
       User testUser4=createTestUser('TestB4');
       insert testUser4;
       system.runAs(testUser4)
       { //Stop bhagya-case-00254740
        test.startTest();
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        List<String>oIds = new List<String>();
        
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ActionPlansUtilities apu = new ActionPlansUtilities(ap);
        Account a = [select Id, OwnerId from Account where id =:ap.Account__c]; 
        oIds.add(a.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Account');
        String owner = apu.getRecordOwnerId(ap);
        System.assertEquals(a.OwnerId, owner);
        
        ap = ge.createNewActionPlan( 'cases', 0 );
        apu = new ActionPlansUtilities(ap);
        Case c = [select Id, OwnerId from Case where id =:ap.Case__c];
        oIds = new List<String>(); 
        oIds.add(c.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Case');
        owner = apu.getRecordOwnerId(ap);
        System.assertEquals(c.OwnerId, owner);
        
        ap = ge.createNewActionPlan( 'contacts', 0 );
        apu = new ActionPlansUtilities(ap);
        Contact contact = [select Id, OwnerId from Contact where id =:ap.Contact__c];
        oIds = new List<String>(); 
        oIds.add(contact.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Contact');
        owner = apu.getRecordOwnerId(ap);
        System.assertEquals(contact.OwnerId, owner);
        
        ap = ge.createNewActionPlan( 'contracts', 0 );
        apu = new ActionPlansUtilities(ap);
        Contract contract = [select Id, OwnerId from Contract where id =:ap.Contract__c];
        oIds = new List<String>(); 
        oIds.add(contract.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Contract');
        owner = apu.getRecordOwnerId(ap);
        System.assertEquals(contract.OwnerId, owner);
        
        ap = ge.createNewActionPlan( 'leads', 0 );
        apu = new ActionPlansUtilities(ap);
        Lead l = [select Id, OwnerId from Lead where id =:ap.Lead__c];
        oIds = new List<String>(); 
        oIds.add(l.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Lead');
        owner = apu.getRecordOwnerId(ap);
        System.assertEquals(l.OwnerId, owner);
        
        ap = ge.createNewActionPlan( 'opportunitys', 0 );
        apu = new ActionPlansUtilities(ap);
        Opportunity o = [select Id, OwnerId from Opportunity where id =:ap.Opportunity__c];
        oIds = new List<String>(); 
        oIds.add(o.Id);
        apu.retrieveOwnersDataRelatedObject(oIds, 'Opportunity');
        owner = apu.getRecordOwnerId(ap);
        System.assertEquals(o.OwnerId, owner);
        
        test.stopTest();
    }//Added by bhagya-case-00254740
    }

    private static testMethod void APUtestGenerateObjectFeed() {
    //Start added by Bhagya case-00254740
       User testUser3=createTestUser('TestB3');
       insert testUser3;
       system.runAs(testUser3)
       { //Stop bhagya-case-00254740

        //test.startTest();//commented by Bhagya case-00254740
                
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();

        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 0 );
        ActionPlansUtilities apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        ap = ge.createNewActionPlan( 'campaigns', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        
        ap = ge.createNewActionPlan( 'cases', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        
        ap = ge.createNewActionPlan( 'contacts', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        
        ap = ge.createNewActionPlan( 'contracts', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        
        ap = ge.createNewActionPlan( 'leads', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        
        ap = ge.createNewActionPlan( 'opportunitys', 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
        //Changes start here
        test.startTest();//Added by Bhagya case-00254740
        ap = ge.createNewActionPlan(Label.PSE_PROJECT, 0 );
        apu = new ActionPlansUtilities(ap);
        apu.generateObjectFeed(ap.Id);
        //Changes stop here
        //Code modified - Padmesh Soni (02/25/2015 - Appirio Offshore) - S-373701
        
        test.stopTest();
    }
    }//added bhagya-case-00254740
    public static testMethod void APUtestDeleteActionPlans() {
    //Start added by Bhagya case-00254740
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        ActionPlan__c ap    = ge.createNewActionPlan( 'accounts', 0 );
        ActionPlan__c ap2   = ge.createNewActionPlan( 'accounts', 0 );
        List<ActionPlan__c> lAp = new List<ActionPlan__c>();
        lAp.add(ap);
        lAp.add(ap2);
        String url = 'testURL';
        String records = ap.Id + ',' + ap2.id;
        
        ActionPlansUtilities apu = new ActionPlansUtilities(ap);
        ApexPages.currentPage().getParameters().put('retURL', url);
        ApexPages.currentPage().getParameters().put('records', records);
        test.startTest();
        Pagereference page = apu.deleteActionPlans();
        test.stopTest();
        
        List<ActionPlan__c> lAp2 = [select Id from ActionPlan__c where Id in : lAp];
        System.assert(lAp2.size() == 0);
        System.assertEquals(page.getUrl(), url);
    }//Added by Bhagya for case 00254740
    }

    public static APTaskTemplate__c apptask ( ActionPlan__c ap ){
                
        ActionPlansTestUtilities ge =  new ActionPlansTestUtilities();
        APTaskTemplate__c at = new APTaskTemplate__c();
        at.Action_Plan__c    = ap.Id;
        at.Dependent__c      = 'None';
        at.DaysFromStart__c  = 2.0;
        at.User__c           = ge.createTestUser().Id;
        at.SendEmail__c      = false;
        at.Subject__c        = 'Test ';
        at.Type__c           = 'Email';
        at.Priority__c       = 'Low';
        at.Comments__c       = 'Test';
        at.Reminder__c       = true;
        at.Minutes_Reminder__c = '510';
        upsert at;
        return at;
    }
    
}