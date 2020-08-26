/**********************************************
/* Name : ContactNewOverrideController_Test
/* Created By : Shubham
/* Case : 00138614
/*********************************************/
@isTest
private class ContactNewOverrideController_Test {

    static testMethod void myUnitTest() {
        Contact c = new Contact();
        c.LastName = 'Test';
        insert c ;
        
        //START -- Added by Shivani for S-637724 on 02/09/2019
        Contact_Address_field__c cAddress = new Contact_Address_field__c();
        cAddress.Name = 'Address';
        cAddress.Mailing_Zip_Postal_Code__c = '12345';
        cAddress.Mailing_City__c = 'TestCity';
        cAddress.Mailing_Country__c = 'TestCountry';
        cAddress.Mailing_State_Province__c = 'TestState';
        cAddress.Mailing_Street__c = 'TestStreet';
        insert cAddress;
        //END -- Added by Shivani for S-637724 on 02/09/2019

        Account acc = new Account();
        acc.Name = 'AccTest';
        insert acc;
        
        c.AccountId = acc.id;
        update c;
        
        //START -- Added by Shivani for S-637724 on 02/09/2019
        Test.setCurrentPageReference(new PageReference('Page.ContactEditOverride')); 
        System.currentPageReference().getParameters().put('accid', acc.Id);
        System.currentPageReference().getParameters().put('RecordType', [SELECT id,Name FROM RecordType where SobjectType='Contact' and Name='PSA Resource'][0].Name);
        System.currentPageReference().getParameters().put('retURL', '/003/e');
        //END -- Added by Shivani for S-637724 on 02/09/2019

        ContactNewOverrideController controller = new ContactNewOverrideController(new Apexpages.Standardcontroller(c));
        controller.redirect();
    }
}