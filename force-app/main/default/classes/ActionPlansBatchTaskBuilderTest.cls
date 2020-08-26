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
public with sharing class ActionPlansBatchTaskBuilderTest {

    //Start code added by bhagya-case-00254740
    private static User createTestUser(String username) {
    Profile userPrf= [select id from profile where name='G100 User'];       
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
    
    private static testMethod void runBatchAccount(){
        //Start code added by bhagya-case-00254740
        User user1=createTestUser('TestB1');
        insert user1;
        system.runAs(user1)
        { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        Test.startTest();
            ActionPlansBatchTaskBuilder testBatch = new ActionPlansBatchTaskBuilder( ge.batchIds( 'accounts' ) );
            ID batchID = Database.executeBatch(testBatch, 20);
        Test.stopTest();
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);  
        }   // Added by Bhagya case-00254740
    }
    
    private static testMethod void runBatchContact(){
        //Start code added by bhagya-case-00254740
        User user2=createTestUser('TestB2');
        insert user2;
        system.runAs(user2)
        { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        
        Test.startTest();
            ActionPlansBatchTaskBuilder testBatch = new ActionPlansBatchTaskBuilder( ge.batchIds( 'contacts' ) );
            ID batchID = Database.executeBatch(testBatch, 20);
        Test.stopTest();
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);
        } //Added by Bhagya case-00254740
    }
    
    
    private static testMethod void runBatchOpportunity(){
        //Start code added by bhagya-case-00254740
        User user3=createTestUser('TestB3');
        insert user3;
        system.runAs(user3)
        { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        
        Test.startTest();
            ActionPlansBatchTaskBuilder testBatch = new ActionPlansBatchTaskBuilder( ge.batchIds( 'opportunitys' ) );
            ID batchID = Database.executeBatch(testBatch, 20);
        Test.stopTest();
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);
        }//Added by Bhagya case-00254740
    }
   
    private static testMethod void runBatchLeed(){
        //Start code added by bhagya-case-00254740
        User user4=createTestUser('TestB4');
        insert user4;
        system.runAs(user4)
        { //Stop bhagya-case-00254740
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        
        Test.startTest();
            ActionPlansBatchTaskBuilder testBatch = new ActionPlansBatchTaskBuilder( ge.batchIds( 'leads' ) );
            ID batchID = Database.executeBatch(testBatch, 20);
        Test.stopTest();
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
        System.AssertEquals('Completed', a.status);
        System.AssertEquals(0, a.NumberOfErrors);
        }//Added by Bhagya case-00254740
    }
}