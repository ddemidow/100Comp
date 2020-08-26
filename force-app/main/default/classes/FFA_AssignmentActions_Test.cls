@isTest(SeeAllData=true)
/**************************************************************************************************
Description:      This class contains methods that test FFA_Assignment_Trigger
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
12/01/2013              Liz Ichihashi                   Created new class.
**************************************************************************************************/
private class FFA_AssignmentActions_Test {  

    /* Commented for the case #00138614 #START

    public static testMethod void testInsertAssignment() {
            FFA_TestUtility testUtil = new FFA_TestUtility();
            pse__Region__c reg = testUtil.newRegionMaster(true);
            Account acct = testUtil.newAccount(true);    
            User partUsr = testUtil.newUserSysAdmin(true);
            Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
            User usr = testUtil.newUserSysAdmin(true);        
            pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
            Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);
            Opportunity opp = testUtil.newOpportunity(true,acct.Id, participant.Id, '0=Plan', System.today());
            pse__Proj__c proj = testUtil.newProject(true,reg.id,null,true,'One-Time: Fixed Price', resource.Id, acct.Id);   
               
            pse__Schedule__c sched = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
            
            pse__Assignment__c assign;
            pse__Permission_Control__c pc = testUtil.newPermissionControl(true, usr.Id, reg.Id);
            System.runAs(usr) {
                assign = testUtil.newAssignment(true, proj.Id, resource.Id, sched.Id);
            }   
            assign = [select Id, OwnerId from pse__Assignment__c where id = :assign.Id limit 1];
            // Assert that the owner id is set to that of the contact's salesforce user 
            System.assert(assign.OwnerId == resource.pse__Salesforce_User__c);
    }
    
    public static testMethod void testInsertUpdate() {
            FFA_TestUtility testUtil = new FFA_TestUtility();
            pse__Region__c reg = testUtil.newRegionMaster(true);
            Account acct = testUtil.newAccount(true);  
            User partUsr = testUtil.newUserSysAdmin(true);
            Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
            User usr = testUtil.newUserSysAdmin(true);        
            User usr2 = testUtil.newUserSysAdmin(true);        
            pse__Work_Calendar__c cal = testUtil.newWorkCalender(true);
            Contact resource = testUtil.newResource(true, acct.Id, usr.Id, reg.Id, cal.Id);
            Contact resource2 = testUtil.newResource(true, acct.Id, usr2.Id, reg.Id, cal.Id);
            Opportunity opp = testUtil.newOpportunity(true,acct.Id, participant.Id, '0=Plan', System.today());
            pse__Proj__c proj = testUtil.newProject(true,reg.id,null,true,'One-Time: Fixed Price', resource.Id, acct.Id);   
               
            pse__Schedule__c sched = testUtil.newSchedule(true, System.today(), System.today().addDays(6));
            
            pse__Assignment__c assign;
            pse__Permission_Control__c pc = testUtil.newPermissionControl(true, usr.Id, reg.Id);
            System.runAs(usr) {
                assign = testUtil.newAssignment(true, proj.Id, resource.Id, sched.Id);
                assign.OwnerId = usr2.Id;
                update assign;
            }   
            assign = [select Id, OwnerId from pse__Assignment__c where id = :assign.Id limit 1];
            // Assert that the owner id is set to that of the contact's salesforce user 
            System.assert(assign.OwnerId == resource2.pse__Salesforce_User__c);
    }
    
    Commented for the case #00138614 #STOP */
}