/*===========================================
* Class Name: updateAccountNameOnContactTest
* Description: Test Class for updateAccountNameOnContact [S-553690]
* Created Date: 4 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class updateAccountNameOnContactTest{
    
    public static list <Contact> contactList;
    static void testSetup(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        contactList = new list<Contact>();
        contactList.add(con);
    }
    @isTest	
    static void testMethod1(){
        testSetup();
        Database.BatchableContext BC;
        Test.startTest();
        UpdateAccountNameOnContact testBatch = new UpdateAccountNameOnContact();
        testBatch.start(BC);
        testBatch.execute(BC,contactList);
        testBatch.finish(bc);

        //START -- Added by Shivani for S-637724 on 03/09/2019
        UpdateAccountNameOnContact sh1 = new UpdateAccountNameOnContact();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        //END -- Added by Shivani for S-637724 on 03/09/2019

        Test.stopTest();
    	}
    }