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
@isTest
private class ActionPlansTaskTriggerUtilitiesTest {

    /**
     test trigger without skipweekends 
      method for testing Task  After Update trigger
         when updating task to status 'Completed'
    
    */    
     //Start code added by bhagya-case-00254740
      Public static User createTestUser(String username) {
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
    }//Stop bhagya-case-00254740    
    
    public static testMethod void testTrigger1() {
        //Start added by Bhagya case-00254740
        User testUser1=createTestUser('TestB1');
        insert testUser1;
        system.runAs(testUser1)
        { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 0 );
        List<Id> apTTaskIds         = new List<Id>();
        List<Task> apTask           = new List<Task>();
        List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
        
        Test.startTest();
            for( Integer i = 0; i < 4; i++ ){
                APTaskTemplate__c at = new APTaskTemplate__c();
                at.Action_Plan__c    = ap.Id;
                at.DaysFromStart__c  = 2.0;
                at.User__c           = ge.createTestUser().Id;
                if (i == 0){
                    at.SendEmail__c      = true;
                }else{
                    at.SendEmail__c      = false;
                }
                at.Subject__c        = 'Test '+ i;
                at.Type__c           = 'Email';
                at.Priority__c       = 'Low';
                at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
                insert at;
                aptt.add(at);
                apTTaskIds.add( at.Id );
                
                if( i == 0 ){
                    Task x              = new Task();
                    x.Priority          = at.Priority__c;
                    x.Status            = 'Open';
                    x.TaskTemplateId__c = at.Id;
                    x.Subject           = at.Subject__c;
                    //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
                    x.Type = 'Call';
                    insert x;
                }
            }
        
            apTask = [Select Status, Id from Task where TaskTemplateId__c IN : apTTaskIds]; 
            for( Task t : apTask ){ 
                t.Status = 'Completed';
            } 
        
            update apTask;
            apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[0] ];
            
        Test.stopTest();
        System.assert( !apTask.isEmpty() );
        }//Added by Bhagya Case-00254740
    }
    
    /**
    * test trigger AP Delete 
    */
    public static testMethod void testTrigger2() {
        //Start added by Bhagya case-00254740
       User testUser2=createTestUser('TestB2');
       insert testUser2;
       system.runAs(testUser2)
       { //Stop bhagya-case-00254740
       
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 0 );
        ap.SkipWeekends__c          = true;
        update ap;
        
        List<Id> apTTaskIds         = new List<Id>();
        List<Task> apTask           = new List<Task>();
        List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
        
        Test.startTest();
            for( Integer i = 0; i < 4; i++ ){
                APTaskTemplate__c at = new APTaskTemplate__c();
                at.Action_Plan__c    = ap.Id;
                at.DaysFromStart__c  = 2.0;
                at.User__c           = ge.createTestUser().Id;
                at.SendEmail__c      = false;
                at.Subject__c        = 'Test '+ i;
                at.Type__c           = 'Email';
                at.Priority__c       = 'Low';
                at.Comments__c       = 'My Coment';
                at.Reminder__c       = true;
                at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
                insert at;
                aptt.add(at);
                apTTaskIds.add( at.Id );
                
                if( i == 0 ){
                    Task x              = new Task();
                    x.Priority          = at.Priority__c;
                    x.Status            = 'Open';
                    x.TaskTemplateId__c = at.Id;
                    x.Subject           = at.Subject__c;
                    //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
                    x.Type = 'Call';
                    insert x;
                }
            }
            delete ap;
            apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[1] ];
            
        Test.stopTest(); 
        
        System.assert( apTask.isEmpty() );
        }//Added by Bhagya case-00254740
    }
    
    /**
    * test trigger  
    */
    public static testMethod void testTrigger3() {
        //Start added by Bhagya case-00254740
       User testUser3=createTestUser('TestB3');
       insert testUser3;
       system.runAs(testUser3)
       { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 0 );
        ap.SkipWeekends__c          = true;
        update ap;
        
        List<Id> apTTaskIds         = new List<Id>();
        List<Task> apTask           = new List<Task>();
        List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
        
        Test.startTest();
            for( Integer i = 0; i < 4; i++ ){
                APTaskTemplate__c at = new APTaskTemplate__c();
                at.Action_Plan__c    = ap.Id;
                at.DaysFromStart__c  = 2.0;
                at.User__c           = ge.createTestUser().Id;
                at.SendEmail__c      = false;
                at.Subject__c        = 'Test '+ i;
                at.Type__c           = 'Email';
                at.Priority__c       = 'Low';
                at.Comments__c       = 'My Coment';
                at.Reminder__c       = true;
                at.Minutes_Reminder__c = '510';
                at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
                insert at;
                aptt.add(at);
                apTTaskIds.add( at.Id );
                
                if( i == 0 ){
                    Task x              = new Task();
                    x.Priority          = at.Priority__c;
                    x.Status            = 'Open';
                    x.TaskTemplateId__c = at.Id;
                    x.Subject           = at.Subject__c;
                    //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18 
                    x.Type = 'Call';
                    insert x;
                }
            }
            
            
            apTask = [Select Status, Id from Task where TaskTemplateId__c IN : apTTaskIds]; 
            for( Task t : apTask ){
                t.Status = 'Completed';
            } 
            update apTask;
            apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[0] ];
            
        Test.stopTest(); 
        
        System.assert( !apTask.isEmpty() );
        }//Added by bhagya case-00254740
    }
    
   /**
    *   test ActionPlanTaskTemplateTrigger
    *   When the user undeletes an ActionPlan Task Template  
    */
    public static testMethod void testTrigger4() {
    //Start added by Bhagya case-00254740
       User testUser4=createTestUser('TestB4');
       insert testUser4;
       system.runAs(testUser4)
       { //Stop bhagya-case-00254740
        Test.startTest();
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 1 );
        ap.SkipWeekends__c          = true;
        update ap;
        
        // select the APTask Template
        APTaskTemplate__c at = [select id, Subject__c, Priority__c, User__c from APTaskTemplate__c where Action_Plan__c =: ap.id limit 1];
            
        // create the related Task
        Task t              = new Task();
        t.Subject           = at.Subject__c;
        t.Priority          = at.Priority__c;
        t.OwnerId           = at.User__c;
        t.TaskTemplateId__c = at.Id;
        //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
        t.Type = 'Call';
        insert t;
            
        // delete the APTask Template 
        delete at;
        delete t;
        List<APTaskTemplate__c> apttDel = [select id from APTaskTemplate__c where id =: at.Id];
        System.assert(apttDel.size() == 0); 
        
        // undelete task and APTask and get exception
        List <String> ids = new List <String>();
        ids.add(t.Id);
        ids.add(at.Id);
        try{
            database.undelete (ids);
        }catch(Dmlexception e){
            System.assert( e.getMessage().contains('BROKEN'),e.getMessage() );
        }
        
        // now undelete and trigger the code
        if ([select id from APTaskTemplate__c where id =: at.Id and isDeleted = true ].size() >0){
            undelete at;        
            List<APTaskTemplate__c> apttUnDel = [select id from APTaskTemplate__c where id =: at.Id];
            System.assert(apttUnDel.size() == 1);   
        }
        Test.stopTest(); 
        }//Added by Bhagya-Case-00254740
    }

    /**
    *   test ActionPlanTaskTemplateTrigger
    *   When the user undeletes an ActionPlan Task Template  
    */
    public static testMethod void testTrigger5() {
    //Start added by Bhagya case-00254740
       User testUser5=createTestUser('TestB5');
       insert testUser5;
       system.runAs(testUser5)
       { //Stop bhagya-case-00254740
        Test.startTest();
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 3 );
        ap.SkipWeekends__c          = true;
        update ap;
        
        // select the APTask Template
        APTaskTemplate__c at = [select id, Subject__c, Priority__c, User__c from APTaskTemplate__c where Action_Plan__c =: ap.id limit 1];
            
        // create the related Task
        Task t              = new Task();
        t.Subject           = at.Subject__c;
        t.Priority          = at.Priority__c;
        t.OwnerId           = at.User__c;
        t.TaskTemplateId__c = at.Id;
        //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
        t.Type = 'Call';
        insert t;
            
        // delete the APTask Template 
        delete at;
        delete t;
        Database.emptyRecycleBin(t);
        List<APTaskTemplate__c> apttDel = [select id from APTaskTemplate__c where id =: at.Id];
        System.assert(apttDel.size() == 0); 
        
        // undelete task and APTask and get exception
        List <String> ids = new List <String>();
        ids.add(at.Id);
        try{
            database.undelete (ids);
        }catch(Dmlexception e){
            System.assert( e.getMessage().contains('BROKEN'),e.getMessage() );
        }
            
        Test.stopTest(); 
        }//Added By Bhagya case-00254740
    }   
    /*
         method for testing Task  After Update trigger
         when updating task to status 'In progress'
    
    */
    public static testMethod void testTrigger6() {
    //Start added by Bhagya case-00254740
       User testUser6=createTestUser('TestB6');
       insert testUser6;
       system.runAs(testUser6)
       { //Stop bhagya-case-00254740
        
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 0 );
        
        
        List<Id> apTTaskIds         = new List<Id>();
        List<Task> apTask           = new List<Task>();
        List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
        
        Test.startTest();
            for( Integer i = 0; i < 4; i++ ){
                APTaskTemplate__c at = new APTaskTemplate__c();
                at.Action_Plan__c    = ap.Id;
                at.DaysFromStart__c  = 2.0;
                at.User__c           = ge.createTestUser().Id;
                if (i == 0){
                    at.SendEmail__c      = true;
                }else{
                    at.SendEmail__c      = false;
                }
                at.Subject__c        = 'Test '+ i;
                at.Type__c           = 'Email';
                at.Priority__c       = 'Low';
                at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
                insert at;
                aptt.add(at);
                apTTaskIds.add( at.Id );
                
                if( i == 0 ){
                    Task x              = new Task();
                    x.Priority          = at.Priority__c;
                    x.Status            = 'Open';
                    x.TaskTemplateId__c = at.Id;
                    x.Subject           = at.Subject__c;
                    //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
                    x.Type = 'Call';
                    insert x;
                }
            }
        
        apTask = [Select Status, Id from Task where TaskTemplateId__c IN : apTTaskIds]; 
        for( Task t : apTask ){ 
            t.Status = 'In Progress';
        } 
    
        update apTask;
        apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[0] ];
            
        Test.stopTest();
        System.assert( !apTask.isEmpty() );
        }//Added by Bhagya case-00254740
    }  
      
   /*
         method for testing Task  before delete trigger
    
    */
    public static testMethod void testTrigger7() {
        
        //Start added by Bhagya case-00254740
       User testUser7=createTestUser('TestB7');
       insert testUser7;
       system.runAs(testUser7)
       { //Stop Bhagya-case-00254740
        test.startTest();
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap            = ge.createNewActionPlan( 'accounts', 0 );
                
        //Task Template 1
        APTaskTemplate__c at = new APTaskTemplate__c();
        at.Action_Plan__c    = ap.Id;
        at.DaysFromStart__c  = 2.0;
        at.User__c              = ge.createTestUser().Id;
        at.SendEmail__c         = true;
        at.Subject__c           = 'Test ';
        at.Type__c              = 'Email';
        at.Priority__c          = 'Low';
        at.APTaskTemplate__c    = null; 
        at.taskIndex__c         =0;
        insert at;
        //Task Template 2
        APTaskTemplate__c at2 = new APTaskTemplate__c();
        at2.Action_Plan__c      = ap.Id;
        at2.DaysFromStart__c    = 2.0;
        at2.User__c             = ge.createTestUser().Id;
        at2.SendEmail__c        = true;
        at2.Subject__c          = 'Test2' ;
        at2.Type__c             = 'Email';
        at2.Priority__c         = 'Low';
        at2.APTaskTemplate__c   =at.Id;
        at2.taskIndex__c            =1;
        insert at2;
        
        //create task for task template 1               
        Task x              = new Task();
        x.Priority          = at.Priority__c;
        x.Status            = 'Open';
        x.TaskTemplateId__c = at.Id;
        x.Subject           = at.Subject__c;
        //Added by Anirudh to create data according to the validation rule on type field of task for story - S-553690 on 4/6/18
        x.Type = 'Call';
        insert x;

        ActionPlansTaskTriggerUtilities aptt = new ActionPlansTaskTriggerUtilities();
        ActionPlansTaskTriggerUtilities.generateActioPlanFeeds(new List<String>{ap.Id});
        
        //delete task 
        delete x;
            
        test.stopTest();
        //check if the dependet task was created
        
        List<Task> newTask = [Select Status, Id from Task where TaskTemplateId__c =: at2.Id ]; 
        System.assert( !newTask.isEmpty() );
        }//Added By Bhagya-Case-00254740
    }    
        
}