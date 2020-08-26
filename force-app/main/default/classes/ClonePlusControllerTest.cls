/************************************************************************************************************************
Name            :  ClonePlusControllerTest
Created by      :  Shivani Jain [Appirio JDC] 
Related Story   :  S-637724
Description     :  Test class for the class "ClonePlusController"
*************************************************************************************************************************/
@isTest
private class ClonePlusControllerTest {
    
    static testMethod void initialiseObjectsForCloningTest(){
        Account testAccount = new Account();
        testAccount.Name='Test Account';
        insert testAccount;
       
        Contact cont = new Contact();
        cont.LastName ='Test';
        cont.FirstName ='Test';
        cont.accountid = testAccount.id;
        insert cont;
        
        Test.StartTest(); 

        ApexPages.currentPage().getParameters().put('id', String.valueOf(testAccount.Id));
        ApexPages.currentPage().getParameters().put('childobjecttypes', 'Account,Contact');
        ClonePlusController  cpContr = new ClonePlusController();
        cpContr.initialiseObjectsForCloning();
        PageReference pg = cpContr.doClone();
        sObject sObj = testAccount;
        ClonePlusController.relatedObjectRow  t = new ClonePlusController.relatedObjectRow(sObj);
        String objValue = t.getValue();
        String objName = t.getName();
        cpContr.cloneSelectedObjects();
        Test.StopTest();
        
        System.assertEquals(objName, 'Test Account');
        System.assertEquals(objValue, '');
    }
    
}