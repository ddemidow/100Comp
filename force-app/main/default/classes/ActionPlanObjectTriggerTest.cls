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

public with sharing class ActionPlanObjectTriggerTest {

    public static Boolean isTest = false;
    
    public @isTest static void testAccountTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser1 = new User();
       testUser1.Email         = 'testuser1@test.com';
       testUser1.Username       = 'testu1@test1231.com';
       testUser1.LastName       = 'testB1';
       testUser1.Alias         = 'testB1';
       testUser1.ProfileId       = userProfile .Id;
       testUser1.LanguageLocaleKey   = 'en_US';
       testUser1.LocaleSidKey     = 'en_US';
       testUser1.TimeZoneSidKey   = 'America/Chicago';
       testUser1.EmailEncodingKey   = 'UTF-8';
       insert testUser1;
        
       system.runAs(testUser1)
       {
      //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'accounts', 1 );
        Account a = [select id from Account where id =:ap.Account__c]; 
        System.debug('***'+a);        
        // Verifies that action plans are deleted when removing related object
        test.startTest();
        delete a;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete a;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        //test.startTest(); //Commented For case 254740
        ids.add(a.Id);
        ids.add(ap.Id);
        undelete a;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        //test.stopTest();//Commented For case 254740
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete a;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Account__c =: a.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
        }//added by Bhagya case-00254740
    }
    
    public static testmethod void testCampaignTrigger(){
      //Start added by Bhagya case-00254740
       Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
       User testUser2 = new User();
       testUser2.Email         = 'testuser2@test.com';
       testUser2.Username       = 'testu2@test1231.com';
       testUser2.LastName       = 'testB2';
       testUser2.Alias         = 'testB2';
       testUser2.ProfileId       = userProfile.Id;
       testUser2.LanguageLocaleKey   = 'en_US';
       testUser2.LocaleSidKey     = 'en_US';
       testUser2.TimeZoneSidKey   = 'America/Chicago';
       testUser2.EmailEncodingKey   = 'UTF-8';
       insert testUser2;
         system.runAs(testUser2)
         {
        //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'campaigns', 1 );
        Campaign c = [select id from Campaign where id =:ap.Campaign__c];
        System.debug('***'+c);
        // Verifies that action plans are deleted when removing related object
        test.startTest();
        delete c;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        //System.assert(lAp.size() == 0);

        // Verifies catch is working fine
        isTest = true;
        try{
            undelete c;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(c.Id);
        ids.add(ap.Id);
        undelete(c);
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1); 
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete c;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Campaign__c =: c.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
        }//added by Bhagya case-00254740
    }
    
    public static testmethod void testCaseTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser3 = new User();
       testUser3.Email         = 'testuser3@test.com';
       testUser3.Username       = 'testu3@test1231.com';
       testUser3.LastName       = 'testB3';
       testUser3.Alias         = 'testB3';
       testUser3.ProfileId       = userProfile.Id;
       testUser3.LanguageLocaleKey   = 'en_US';
       testUser3.LocaleSidKey     = 'en_US';
       testUser3.TimeZoneSidKey   = 'America/Chicago';
       testUser3.EmailEncodingKey   = 'UTF-8';
       insert testUser3;
    
         system.runAs(testUser3)
         {
     //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'cases', 1 );
        Case c = [select id from Case where id =:ap.Case__c];
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete c;
        test.stopTest(); 
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete c;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(c.Id);
        ids.add(ap.Id);
        undelete c;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete c;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Case__c =: c.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
        }//Added by Bhagya case-00254740
    }
    
    public static testmethod void testContactTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser4 = new User();
       testUser4.Email         = 'testuser4@test.com';
       testUser4.Username       = 'testu4@test1231.com';
       testUser4.LastName       = 'testB4';
       testUser4.Alias         = 'testB4';
       testUser4.ProfileId       = userProfile.Id;
       testUser4.LanguageLocaleKey   = 'en_US';
       testUser4.LocaleSidKey     = 'en_US';
       testUser4.TimeZoneSidKey   = 'America/Chicago';
       testUser4.EmailEncodingKey   = 'UTF-8';
       insert testUser4;
    
         system.runAs(testUser4)
         {
       //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'contacts', 1 );
        Contact c = [select id from Contact where id =:ap.Contact__c ]; 
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete c;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete c;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(c.Id);
        ids.add(ap.Id);
        undelete c;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete c;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Contact__c =: c.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
    }//added by Bhagya case-00254740
    }
    
    public static testmethod void testContractTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser5 = new User();
       testUser5.Email         = 'testuser5@test.com';
       testUser5.Username       = 'testu5@test1231.com';
       testUser5.LastName       = 'testB5';
       testUser5.Alias         = 'testB5';
       testUser5.ProfileId       = userProfile.Id;
       testUser5.LanguageLocaleKey   = 'en_US';
       testUser5.LocaleSidKey     = 'en_US';
       testUser5.TimeZoneSidKey   = 'America/Chicago';
       testUser5.EmailEncodingKey   = 'UTF-8';
       insert testUser5;
    
        system.runAs(testUser5)
        {
        //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'contracts', 1 );
        Contract c = [select id from Contract where id =:ap.Contract__c];
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete c;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete c;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(c.Id);
        ids.add(ap.Id);
        undelete c;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete c;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Contract__c =: c.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
        }//added by Bhagya case-00254740
    }

    public static testmethod void testLeadTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser6 = new User();
       testUser6.Email         = 'testuser6@test.com';
       testUser6.Username       = 'testu6@test1231.com';
       testUser6.LastName       = 'testB6';
       testUser6.Alias         = 'testB6';
       testUser6.ProfileId       = userProfile.Id;
       testUser6.LanguageLocaleKey   = 'en_US';
       testUser6.LocaleSidKey     = 'en_US';
       testUser6.TimeZoneSidKey   = 'America/Chicago';
       testUser6.EmailEncodingKey   = 'UTF-8';
       insert testUser6;
         system.runAs(testUser6)
         {
    //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'leads', 1 );
        Lead l = [select id from Lead where id =:ap.Lead__c];
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete l;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete l;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(l.Id);
        ids.add(ap.Id);
        undelete l;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete l;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Lead__c =: l.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
        }//added by Bhagya case-00254740
    }
    
    public static testmethod void testOpportunityTrigger(){
    //Start added by Bhagya case-00254740
    Profile userProfile = [SELECT Id FROM Profile WHERE Name='G100 User'];
     User testUser7 = new User();
       testUser7.Email  = 'testuser7@test.com';
       testUser7.Username       = 'testu7@test1231.com';
       testUser7.LastName       = 'testB7';
       testUser7.Alias         = 'testB7';
       testUser7.ProfileId       = userProfile.Id;
       testUser7.LanguageLocaleKey   = 'en_US';
       testUser7.LocaleSidKey     = 'en_US';
       testUser7.TimeZoneSidKey   = 'America/Chicago';
       testUser7.EmailEncodingKey   = 'UTF-8';
       insert testUser7;
         system.runAs(testUser7)
         {
         //Stop added by Bhagya case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'opportunitys', 1 );
        Opportunity o = [select id from Opportunity where id =:ap.Opportunity__c ];
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete o;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete o;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        List <String> ids = new List <String>();
        ids.add(o.Id);
        ids.add(ap.Id);
        undelete o;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete o;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Opportunity__c =: o.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
    }//Added by Bhagya case-00254740
    }

}