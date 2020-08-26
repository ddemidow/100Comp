/*-----------------------------------------------------
Created By - Rahul Chitkara (JDC)
Story - S-208562
Usage - Controller of ContactEditOverride page
------------------------------------------------------*/

public with sharing class ContactNewOverrideController {
private ApexPages.StandardController controller;
public String retURL {get; set;}
public String saveNewURL {get; set;}
public String rType {get; set;}
public String cancelURL {get; set;}
public String ent {get; set;}
public String confirmationToken {get; set;}
public String accountID {get; set;}


public ContactNewOverrideController(ApexPages.StandardController controller) {
    this.controller = controller;
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    rType = ApexPages.currentPage().getParameters().get('RecordType');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    accountID = ApexPages.currentPage().getParameters().get('accid');
}

  public PageReference redirect() {
    PageReference returnURL;
    returnURL = new PageReference('/003/e');
    returnURL.getParameters().put('retURL', retURL);
    if(rType != null){
        returnURL.getParameters().put('RecordType', rType);
    }
    returnURL.getParameters().put('cancelURL', cancelURL);
    returnURL.getParameters().put('ent', ent);
    //returnURL.getParameters().put('save_new_url', saveNewURL);
    returnURL.getParameters().put('nooverride', '1');
    // If contact is created from account page then shipping address of account are populated into contact custom address fields
    If(accountID != null){
        returnURL.getParameters().put('accid', accountID);
        list<Account> account = new list<Account>([Select a.Id,a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity From Account a where Id =:accountID limit 1]);
        list<Contact_Address_field__c> contactAddressField = new list<Contact_Address_field__c>([select name,Mailing_City__c,Mailing_Country__c,
        																	Mailing_State_Province__c,Mailing_Street__c,Mailing_Zip_Postal_Code__c from Contact_Address_field__c
        																	where name = 'Address' limit 1]);
		if(contactAddressField.size() > 0) {
	        returnURL.getParameters().put(contactAddressField[0].Mailing_Zip_Postal_Code__c, account[0].ShippingPostalCode);
	        returnURL.getParameters().put(contactAddressField[0].Mailing_City__c, account[0].ShippingCity);
	        returnURL.getParameters().put(contactAddressField[0].Mailing_Country__c, account[0].ShippingCountry);
	        returnURL.getParameters().put(contactAddressField[0].Mailing_State_Province__c, account[0].ShippingState);
	        returnURL.getParameters().put(contactAddressField[0].Mailing_Street__c, account[0].ShippingStreet);
	   }
    }
    returnURL.setRedirect(true);
    return returnURL;
  }

}