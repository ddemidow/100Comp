/***********************************************************************************************
Name : ContactTeamTriggerHandler
Created Date : 7th March , 2014
Created By : Jyoti Singh
Description : S-194517           
***********************************************************************************************/

public without sharing class ContactTeamTriggerHandler{
  private static final String DELIMITER = ', ';
 
  //Call Method on Delete
  public static void onAfterDelete(List<Contact_Team__c> oldMemberList) {
    populateTeamMebers(getContactIdsFromContactTeam(oldMemberList));
  }
  
  //Call Method on Insert
  public static void onAfterInsert(List<Contact_Team__c> newMemberList) {
    populateTeamMebers(getContactIdsFromContactTeam(newMemberList));
  }

  //Call Method on Undelete
  public static void onAfterUndelete(List<Contact_Team__c> newMemberList) {
    populateTeamMebers(getContactIdsFromContactTeam(newMemberList));
  }

  //Call Method on Update
  public static void onAfterUpdate(List<Contact_Team__c> oldMemberList,
    Map<Id, Contact_Team__c> newMemberMap) {

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
                           where Contact__c in :parentIds order by Role__c Asc]) {
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