/*******************************************************************************
Name            :  EditContactBioController
Created by      :  Connor Flynn
Created Date    :  May 03, 2016
Story           :  S-408904 
Description     :  Controller for Edit Contact Bio page, goes in home page layout and opens up the users associated contact to the edit page
*******************************************************************************/
public with sharing class EditContactBioController {
	public EditContactBioController() {
	}
	public PageReference redirectToBio(){
		List<Contact> userContact = new List<Contact>([Select Id From Contact Where pse__Salesforce_User__c = :UserInfo.getUserId() limit 1]);
		PageReference ref;
		if(userContact != null && userContact.size() > 0 && userContact.get(0) != null){
			ref = new ApexPages.StandardController(userContact.get(0)).edit();
			ref.getParameters().put('RetUrl',  (String)userContact.get(0).Id);
		}else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sorry, there is no contact associated with your Salesforce User'));
		}
		return ref;
	}
}