/************************************************************************************************************************
Name Author     :  ContactTriggerHandler
Created by      :  Hemant [Appirio JDC] - 2013/11/22
Related Story   :  S-158728
Description     :  To take action for all triggers of Contact
*************************************************************************************************************************/
public class ContactTriggerHandler {
    private static final String DELIMITER = ', ';
    public static Set<String> TMGRolesSet = new Set<String>{'TMG Primary', 'TMG Secondary', 'TMG Tertiary'};

  /************************************************************************
  Method : Call on Before Update on Contact
  *************************************************************************/
  public static void onBeforeUpdate(List<Contact> contactLstNew, Map<Id,Contact> contactOldMap) {

    preventTMGConfidentialToBeCheckd(contactLstNew, contactOldMap);
    populateContactTeam(contactLstNew);
    // Add method to update standard contact address fields Story -  S-208562 by Rahul Chitkara
    //updateContactAddress(contactLstNew,contactOldMap);
    // End  S-208562
  }
	// Added by Rahul Chitkara on 05/08/2014 for Story S-208562
  //START NSHARP CASE 00101929 12.11.14
   /*private static void updateContactAddress(List<Contact> contactLstNew, Map<Id,Contact> contactOldMap){
 	for(Contact contact : contactLstNew){
 		// for update
 		if(contactOldMap != null){
	 		if(contact.Mailing_City__c != contactOldMap.get(contact.Id).Mailing_City__c){
	 			contact.MailingCity = contact.Mailing_City__c;
	 		}
	 		if(contact.Mailing_Country__c != contactOldMap.get(contact.Id).Mailing_Country__c){
	 			contact.MailingCountry = contact.Mailing_Country__c;
	 		}
	 		if(contact.Mailing_State_Province__c != contactOldMap.get(contact.Id).Mailing_State_Province__c){
	 			contact.MailingState = contact.Mailing_State_Province__c;
	 		}
	 		if(contact.Mailing_Street__c != contactOldMap.get(contact.Id).Mailing_Street__c){
	 			contact.MailingStreet = contact.Mailing_Street__c;
	 		}
	 		if(contact.Mailing_Zip_Postal_Code__c != contactOldMap.get(contact.Id).Mailing_Zip_Postal_Code__c){
	 			contact.MailingPostalCode = contact.Mailing_Zip_Postal_Code__c;
	 		}
 		}
 		// for insert
 		else
 		{
 			if(contact.Mailing_City__c != ''){
 				contact.MailingCity = contact.Mailing_City__c;
 			}
 			if(contact.Mailing_Country__c != ''){
 				contact.MailingCountry = contact.Mailing_Country__c;
 			}
 			if(contact.Mailing_State_Province__c != ''){
 				contact.MailingState = contact.Mailing_State_Province__c;
 			}
 			if(contact.Mailing_Street__c != ''){
 				contact.MailingStreet = contact.Mailing_Street__c;
 			}
 			if(contact.Mailing_Zip_Postal_Code__c != ''){
 				contact.MailingPostalCode = contact.Mailing_Zip_Postal_Code__c;
 			}
 		}
 	}
 }*/
 //END NSHARP CASE 00101929 12.11.14
 // End  S-208562
 //Added By Akanksha for Story S-166333
  /************************************************************************
  Method : Call on Before Insert on Contact
  *************************************************************************/
  public static void onBeforeInsert(List<Contact> contactLstNew) {
      List<Id> accountIds = new List<Id>();
      Map<Id,String> accountIdAndName = new Map<Id,String>();
      system.debug('contactLstNew@@@'+contactLstNew);
        for(Contact con : contactLstNew)
        {
            system.debug('con.AccountId@@@'+con.AccountId);
            system.debug('con.Account.name@@@'+con.Account.name);
            if(con.AccountId != null)
            {
                accountIds.add(con.AccountId);
            }
        }
        for(Account acc: [select id,name from Account where id in: accountIds])
        {
            accountIdAndName.put(acc.id,acc.Name);
        }
        for(Contact con : contactLstNew)
        {
            if(con.AccountId != null && accountIdAndName.containsKey(con.AccountId))
            {
                con.Account_Name__c = accountIdAndName.get(con.AccountId);
            }
        }
        // Add method to update standard contact address for fields Story -  S-208562 by Rahul Chitkara
  		  //updateContactAddress(contactLstNew,null);
    	//End S-208562
      }
   //End By Akanksha for Story S-166333
  /*************************************************************************************
  Method : preventTMGConfidentialToBeCheckd
  Desc   : If there’s any data on these related objects, do not allow checkbox:
           Opportunities, Open Activities, Activity History, Speaking Engagements,
           Event Attendee, campaign Members, Class Enrollments, Contact Team where
           Team Member contact lookup does not belong to The Miles Group account
  ****************************************************************************************/
  private static void preventTMGConfidentialToBeCheckd(List<Contact> contactLstNew, Map<Id,Contact> contactOldMap) {
    List<Contact> contactsList = new List<Contact>();
    if(contactLstNew.size() > 0){
        Map<Id,Contact> contactNewMap = new Map<Id,Contact>([Select c.Id,TMG_Confidential__c,
                               (Select Id From OpportunityContactRoles),
                               (Select Id From OpenActivities),
                               (Select Id From ActivityHistories),
                               (Select Id From Speakers__r),
                               (Select Id From Contact_Teams__r where Role__c NOT IN:TMGRolesSet),
                               (Select Id From R00N40000001QAygEAG__r),
                               /*Start - Appirio Inc. (Jai Gupta) - May 21,2014 - S-214131*/
                               (Select Id From Event_Members__r),
                               (Select Id From CampaignMembers)
                               /*End - Appirio Inc. (Jai Gupta) - May 21,2014 - S-214131*/
                               From Contact c where Id IN: contactLstNew]);

        for(Contact cont : contactLstNew){
          if(cont.TMG_Confidential__c && !contactOldMap.get(cont.Id).TMG_Confidential__c &&
               contactNewMap.containsKey(cont.Id)
               && ( contactNewMap.get(cont.Id).OpportunityContactRoles.size() >  0
               || contactNewMap.get(cont.Id).OpenActivities.size() >  0
               || contactNewMap.get(cont.Id).ActivityHistories.size() >  0
               || contactNewMap.get(cont.Id).Speakers__r.size() >  0
               || contactNewMap.get(cont.Id).Contact_Teams__r.size() >  0
               // for Class Enrollments
               || contactNewMap.get(cont.Id).R00N40000001QAygEAG__r.size() >  0
                /*Start - Appirio Inc. (Jai Gupta) - May 21,2014 - S-214131*/
               || contactNewMap.get(cont.Id).Event_Members__r.size() > 0
               || contactNewMap.get(cont.Id).CampaignMembers.size() > 0
               /*End - Appirio Inc. (Jai Gupta) - May 21,2014 - S-214131*/
               )){

            cont.addError('TMG Confidential cannot be checked if there exists data in the related lists.');
            return;
          }
          //  Added By Akanksha for Story S-166333
          if(cont.accountId != null && cont.accountId != contactOldMap.get(cont.Id).AccountId)
          {
                contactsList.add(cont);
          }
          //  End By Akanksha for Story S-166333

        }//end for loop
        //Added By Akanksha for Story S-166333
        if(contactsList.size() > 0)
        {
            onBeforeInsert(contactsList);
        }
          //End By Akanksha for Story S-166333
    }//end if
  }//end method

  //Added by Jyoti for Case 00082028
  public static void populateContactTeam(List<Contact> contactLstNew) {
    Set<Id> masterRecordId = new Set<Id>();
    List<ContactMasterRecord__c> cmrList = ContactMasterRecord__c.getAll().values();
    for(ContactMasterRecord__c cmr: cmrList){
        masterRecordId.add(cmr.Name);
    }
    system.debug('**masterRecordId**'+masterRecordId);
    if(masterRecordId.size()>0){
        Map<Id, Set<String>> teamMap = new Map<Id, Set<String>>();

        //Create a map of Id and set of string.
        for (Id parentId : masterRecordId) {
          teamMap.put(parentId, new Set<String>());
        }

        //Create a map of Contact id and set of contact team member's names.
        for (Contact_Team__c contTeam  : [Select Team_Member__r.Name, Team_Member__c, Role__c,Contact__c From Contact_Team__c
                               where Contact__c in :masterRecordId and Contact__c in :contactLstNew order by Role__c Asc]) {
          if(contTeam.Contact__c != null && contTeam.Team_Member__c != null && teamMap.ContainsKey(contTeam.Contact__c)){
              teamMap.get(contTeam.Contact__c).add(contTeam.Team_Member__r.Name);
                }
        }


        for(Contact con: contactLstNew){
            if(teamMap.containsKey(con.ID)){
                String partners = generateContactTeamMembersNames(teamMap.get(con.Id));
                con.Contact_Team_Members__c = partners;
            }
        }
        delete cmrList;
    }

  }
  //return a comma seprated string .
  private static String generateContactTeamMembersNames(Set<String> teamMembers) {
    List<String> teamMemberList = new List<String>();
    teamMemberList.addAll(teamMembers);
    if(teamMemberList.size() > 0)
        return String.join(teamMemberList, DELIMITER);
    return '';
  }
 // End by Jyoti for Case 00082028

 //Call Method on Update
    public static void onAfterUpdate(List<Contact_Team__c> oldMemberList,Map<Id, Contact_Team__c> newMemberMap) {
    Set<Id> parentIds = new Set<Id>();

    for (Contact_Team__c oldMember : oldMemberList) {
      Id newParent = newMemberMap.get(oldMember.Id).Contact__c;
      Id newMember = newMemberMap.get(oldMember.Id).Team_Member__c;
      if (oldMember.Contact__c != newParent) {
        if (oldMember.Contact__c != null) {
          parentIds.add(oldMember.Contact__c);
        }
        if (newParent != null) {
          parentIds.add(newParent);
        }
      }
      if (oldMember.Team_Member__c != newMember) {
        if (oldMember.Contact__c != null) {
          parentIds.add(oldMember.Contact__c);
        }
        if (newMember != null) {
          parentIds.add(newParent);
        }
      }

    }

    //Recalculate names
    populateTeamMebers(parentIds);
  }


  //Perform the logic
  private static void populateTeamMebers(Set<Id> parentIds) {
    Map<Id, Set<String>> teamMap = new Map<Id, Set<String>>();

    //Create a map of Id and set of string.
    for (Id parentId : parentIds) {
      teamMap.put(parentId, new Set<String>());
    }

    //Create a map of Contact id and set of contact team member's names.
    for (Contact_Team__c contTeam  : [Select Team_Member__r.Name, Team_Member__c, Role__c,Contact__c From Contact_Team__c
                           where Contact__c in :parentIds order by Role__c ASC]) {
      if(contTeam.Contact__c != null && contTeam.Team_Member__c != null && teamMap.ContainsKey(contTeam.Contact__c)){
          teamMap.get(contTeam.Contact__c).add(contTeam.Team_Member__r.Name);
            }
    }

    //Create list of contacts to update
    List<Contact> contactsToUpdate = new List<Contact>();
    for (Id parentId : teamMap.keySet()) {
        String partners = generateContcatTeamMembersNames(teamMap.get(parentId));
        contactsToUpdate.add(new Contact(Id = parentId,Contact_Team_Members__c = partners));
    }

    if (contactsToUpdate.size() > 0) {
      update contactsToUpdate;
    }
  }

  //return a comma seprated string .
  private static String generateContcatTeamMembersNames(Set<String> teamMembers) {
    List<String> teamMemberList = new List<String>();
    teamMemberList.addAll(teamMembers);
    if(teamMemberList.size() > 0)
        return String.join(teamMemberList, DELIMITER);
    return '';
  }

 //Create a set of contact IDs
  private static Set<Id> getContactIdsFromContactTeam(List<Contact_Team__c> contactTeam) {
    Set<Id> parentIds = new Set<Id>();
    for (Contact_Team__c contTeam : contactTeam) {
      if (contTeam.Contact__c != null) {
        parentIds.add(contTeam.Contact__c);
      }
    }
    return parentIds;
  }

}