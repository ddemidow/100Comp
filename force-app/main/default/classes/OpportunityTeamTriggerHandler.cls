/***********************************************************************************************
Name : OpportunityTeamTriggerHandler
Created Date : 17th December, 2018
Created By : Nishant Singh
Description : S-592384      
***********************************************************************************************/

public without sharing class OpportunityTeamTriggerHandler{
  private static final String DELIMITER = ', ';
  private static final String SEPARATOR = ' - ';
  private static final String PRIMARY = 'PRIMARY';
  private static final String SECONDARY = 'SECONDARY';
  private static final String TERTIARY = 'TERTIARY';
  //Call Method on Delete
  public static void onAfterDelete(List<OpportunityTeamMember> oldMemberList) {
    populateTeamMebers(getOppIdsFromOppTeam(oldMemberList));
  }
  
  //Call Method on Insert
  public static void onAfterInsert(List<OpportunityTeamMember> newMemberList) {
    populateTeamMebers(getOppIdsFromOppTeam(newMemberList));
  }

  //Call Method on Undelete
  public static void onAfterUndelete(List<OpportunityTeamMember> newMemberList) {
    populateTeamMebers(getOppIdsFromOppTeam(newMemberList));
  }

  //Call Method on Update
  public static void onAfterUpdate(List<OpportunityTeamMember> oldMemberList,
    Map<Id, OpportunityTeamMember> newMemberMap) {

    Set<Id> parentIds = new Set<Id>();
     
    for (OpportunityTeamMember oldMember : oldMemberList) {
      Id newParent = newMemberMap.get(oldMember.Id).OpportunityId;
      Id newMember = newMemberMap.get(oldMember.Id).userId;
      String newRole = newMemberMap.get(oldMember.Id).TeamMemberRole;
        
      if (oldMember.OpportunityId != newParent) {
        if (oldMember.OpportunityId != null) {parentIds.add(oldMember.OpportunityId);
        }
        if (newParent != null) {parentIds.add(newParent);
        }
      }
      if (oldMember.userId != newMember) {
        if (oldMember.OpportunityId != null) {parentIds.add(oldMember.OpportunityId);
        }
        if (newMember != null) { parentIds.add(newParent);
        }        
      }
        if (oldMember.TeamMemberRole != newRole) {
            if (oldMember.OpportunityId != null) {
                parentIds.add(oldMember.OpportunityId);
            }   
        }
      
    }
    
    //Recalculate names
    populateTeamMebers(parentIds);
  }


  //Perform the logic
  private static void populateTeamMebers(Set<Id> parentIds) {
    Map<Id, Map<String,Set<String>>> teamMap = new Map<Id, Map<String, Set<String>>>();
    
    //Create a map of Id and set of string.
    /*for (Id parentId : parentIds) {
      teamMap.put(parentId, new Set<String>());
    }*/
    
    //Create a map of Opportunity id and set of Opportunity team member's names.
    for (OpportunityTeamMember oppTeam  : [Select User.Name, UserId, TeamMemberRole ,OpportunityId From OpportunityTeamMember where OpportunityId in :parentIds order by User.LastName ASC]) {
      
      if(oppTeam.OpportunityId != null && oppTeam.UserId!= null){
          if(teamMap.ContainsKey(oppTeam.OpportunityId)){
              if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(PRIMARY)){
                  if(teamMap.get(oppTeam.OpportunityId).ContainsKey(PRIMARY)){
                      teamMap.get(oppTeam.OpportunityId).get(PRIMARY).add(oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name);
                  }
                  else{
                      teamMap.get(oppTeam.OpportunityId).put(PRIMARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  }
              }
              else if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(SECONDARY)){
                  if(teamMap.get(oppTeam.OpportunityId).ContainsKey(SECONDARY)){
                      teamMap.get(oppTeam.OpportunityId).get(SECONDARY).add(oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name);
                  }
                  else{
                      teamMap.get(oppTeam.OpportunityId).put(SECONDARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  }
              }
              else if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(TERTIARY)){
                  if(teamMap.get(oppTeam.OpportunityId).ContainsKey(TERTIARY)){
                      teamMap.get(oppTeam.OpportunityId).get(TERTIARY).add(oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name);
                  }
                  else{
                      teamMap.get(oppTeam.OpportunityId).put(TERTIARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  }
              }
          }
          else{
              if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(PRIMARY)){
                  Map<String,Set<String>> primaryMap = new Map<String,Set<String>>();
                  primaryMap.put(PRIMARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  teamMap.put(oppTeam.OpportunityId, primaryMap);
              }
              else if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(SECONDARY)){
                  Map<String,Set<String>> secMap = new Map<String,Set<String>>();
                  secMap.put(SECONDARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  teamMap.put(oppTeam.OpportunityId, secMap);
              }
              else if(oppTeam.TeamMemberRole != NULL && oppTeam.TeamMemberRole.containsIgnoreCase(TERTIARY)){
                  Map<String,Set<String>> terMap = new Map<String,Set<String>>();
                  terMap.put(TERTIARY,new Set<String>{oppTeam.TeamMemberRole+SEPARATOR+oppTeam.User.Name});
                  teamMap.put(oppTeam.OpportunityId, terMap);
              }
          }
      }
    }
    
    //Create list of opportunities to update
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    for (Id parentId : parentIds) {
        if(teamMap.containsKey(parentId)){
            String partners = generateContcatTeamMembersNames(teamMap.get(parentId));
            oppsToUpdate.add(new Opportunity(Id = parentId, Opportunity_Team_Members__c = partners));
        }
        else{
            oppsToUpdate.add(new Opportunity(Id = parentId, Opportunity_Team_Members__c = ''));
        }
        
        
    }

    if (oppsToUpdate.size() > 0) {
      update oppsToUpdate;
    }
  }
 
  //return a comma seprated string .
  private static String generateContcatTeamMembersNames(Map<String,Set<String>> teamMembersMap) {
    String memberNames = '';
    if(teamMembersMap.ContainsKey(PRIMARY)){
        List<String> teamMemberList = new List<String>();
        teamMemberList.addAll(teamMembersMap.get(PRIMARY));
        memberNames = String.join(teamMemberList, DELIMITER);
    }
    if(teamMembersMap.ContainsKey(SECONDARY)){
        List<String> teamMemberList = new List<String>();
        teamMemberList.addAll(teamMembersMap.get(SECONDARY));
        memberNames = memberNames+DELIMITER+String.join(teamMemberList, DELIMITER);
    }
    if(teamMembersMap.ContainsKey(TERTIARY)){
        List<String> teamMemberList = new List<String>();
        teamMemberList.addAll(teamMembersMap.get(TERTIARY));
        memberNames = memberNames+DELIMITER+String.join(teamMemberList, DELIMITER);
    }
    if(memberNames.startsWith(DELIMITER)){
        memberNames = memberNames.substring(2);
    }
    
    return memberNames;
  }

 //Create a set of opportunity IDs
  private static Set<Id> getOppIdsFromOppTeam(List<OpportunityTeamMember> opportunityTeam) {
    Set<Id> parentIds = new Set<Id>();
    for (OpportunityTeamMember oppTeam : OpportunityTeam) {
      if (oppTeam.OpportunityId != null) {
        parentIds.add(oppTeam.OpportunityId);
      }
    }
    return parentIds;
  }
}