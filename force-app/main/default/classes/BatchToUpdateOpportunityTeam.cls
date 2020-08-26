/***********************************************************************************************
Name : BatchToUpdateOpportunityTeam
Created Date : 15th January, 2019
Created By : Vikrant Nathawat
Description : S-601362
***********************************************************************************************/

global class BatchToUpdateOpportunityTeam implements Database.Batchable<sObject> {

    global String query;
    global static final String DELIMITER = ', ';
    global static final String SEPARATOR = ' - ';
    global static final String PRIMARY = 'PRIMARY';
    global static final String SECONDARY = 'SECONDARY';
    global static final String TERTIARY = 'TERTIARY';


    global BatchToUpdateOpportunityTeam(string q) {

        this.query=q;

    }

    global BatchToUpdateOpportunityTeam() {


    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        if (string.isBlank(query)) {

             query='select id,Opportunity_Team_Members__c from opportunity where Group2__c=\'SSA & Company\' AND CloseDate>2016-01-01 AND StageName=\'100 - Signed Contract\'';
             System.debug('inside if query value '+query);
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {


              Map<Id, Map<String,Set<String>>> teamMap = new Map<Id, Map<String, Set<String>>>();

    //Create a map of Id and set of string.
    /*for (Id parentId : parentIds) {
      teamMap.put(parentId, new Set<String>());
    }*/

    //Create a map of Opportunity id and set of Opportunity team member's names.
    for (OpportunityTeamMember oppTeam  : [Select User.Name, UserId, TeamMemberRole ,OpportunityId From OpportunityTeamMember where OpportunityId in :scope order by User.LastName ASC]) {

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
        List<Id> oppIds = new List<Id>();
        for (sobject op : scope){

                oppIds.add(op.Id);

        }

    for (Id parentId : oppIds) {
        if(teamMap.containsKey(parentId)){
            String partners = generateContcatTeamMembersNames(teamMap.get(parentId));
            oppsToUpdate.add(new Opportunity(Id = parentId, Opportunity_Team_Members__c = partners));
        }
        else{
            oppsToUpdate.add(new Opportunity(Id = parentId, Opportunity_Team_Members__c = ''));
        }


    }

    if (oppsToUpdate.size() > 0) {
      Database.update(oppsToUpdate,false);
    }



    }


     //return a comma seprated string .
  global static String generateContcatTeamMembersNames(Map<String,Set<String>> teamMembersMap) {
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

    global void finish(Database.BatchableContext BC) {

            //do nothing

    }

}