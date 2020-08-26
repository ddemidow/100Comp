/*
 * Appirio, Inc
 * Name: CustomLookupPageController_TEST
 * Description: [S-551675]
 * Created Date: 16 April 2018
 * Created By: Kumari Purnima (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 */

@isTest
private class CustomLookupPageController_TEST{
    
    static testMethod void myUnitTest(){
    
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        CustomLookupPageController sc = new CustomLookupPageController();
        
        PageReference pageRef = Page.CustomLookupPage; 
        pageRef.getParameters().put('parentid', acc.Id);
        pageRef.getParameters().put('parentid', acc.Name);
        Test.setCurrentPage(pageRef);
        
        sc.searchvalue = acc.Name;
        sc.getRecords();
        sc.onkeyupAction();
        sc.searchAction();
    }
}