@isTest
public class OppTeamTriggerHandler_Test {

    static testMethod void testRecalculate() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User usr = testUtil.newUserSysAdmin(true);   
        Account acct = testUtil.newAccount(true);
        
        Contact c = testUtil.newResource(true, acct.Id, null);   
        
        Opportunity opp = testUtil.newOpportunity(true, acct.Id, c.Id);
        Opportunity opp1 = testUtil.newOpportunity(true, acct.Id, c.Id);
        User usr1 =testUtil.newUserFFAdmin(true);
        
        List<OpportunityTeamMember> opMemList = new List<OpportunityTeamMember>();
        OpportunityTeamMember opTeamMem1 = new OpportunityTeamMember(userId = usr.Id, TeamMemberRole='CEO Works Primary', OpportunityId=opp.Id, OpportunityAccessLevel='Read');
        OpportunityTeamMember opTeamMem2 = new OpportunityTeamMember(userId = usr1.Id, TeamMemberRole='CEO Works Secondary', OpportunityId=opp1.Id);
        opMemList.add(opTeamMem1);
        opMemList.add(opTeamMem2);
        insert opMemList;
        
        
        opTeamMem2.TeamMemberRole='SSA Tertiary';
       
        
        update opTeamMem2;
        
       //opTeamMem1= [SELECT Id,TeamMemberRole FROM OpportunityTeamMember WHERE TeamMemberRole='CEO Works Primary' ALL ROWS]; 

        delete opMemList;
        //opTeamMem1= [SELECT Id,TeamMemberRole FROM OpportunityTeamMember WHERE TeamMemberRole='CEO Works Primary' ALL ROWS]; 
        // Start code added by Gunjan sharma for case- 00268047
        try{undelete opMemList;}
        catch(Exception e){
            e.getStackTraceString();
        }
       // End code added by Gunjan sharma for case- 00268047
               	
        
    }
}