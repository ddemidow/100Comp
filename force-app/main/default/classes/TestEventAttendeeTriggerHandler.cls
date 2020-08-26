/************************************************
* Name           : EventAttendeeTriggerHandler
* Created By     : Nishank Jaisinghani
* Created Date   : 10th April 2015
* Story          : S-299883
* Modified by    : Nishank Jaisinghani for Case :- 00123248 (Replaced API of Associated Opportunity for RevRec with same as that of Production
to keep in Sync)
* Modified by    : Sanjeev Sharma for Case :- 00220942 [02-15-2018]
************************************************/

@isTest
private class TestEventAttendeeTriggerHandler{
 
    static testMethod void Testmethod1() {
          
      FFA_TestUtility testUtil = new FFA_TestUtility();
      Account acct = testUtil.newAccount(true);
      User partUsr = testUtil.newUserSysAdmin(true);
      Contact participant = testUtil.newResource(true, acct.Id, partUsr.Id);
      Opportunity opp = testUtil.newOpportunity(false, acct.Id, participant.Id);
      insert opp;
       
       opp.Revenue_Recognition_Begins__c=null; 
       opp.Revenue_Recognition_Ends__c=null; 
       opp.Revenue_Recognition_3__c=null; 
       opp.No_Response__c=true;
       opp.Payment_Date__c = System.today().addYears(-1); 
       opp.Membership_Type__c='NGL ($75K)';
       opp.Revenue_Recognition_1_Manually_Updated__c=false;
       opp.Revenue_Recognition_2_Manually_Updated__c=false;
       opp.Revenue_Recognition_3_Manually_Updated__c=false;
       opp.Participant_Contact__c = participant.Id;
       update opp;
      Test.startTest(); // added by jasvinder for case: 00204418
        Event__c Event = new Event__c(name = 'test');
        Event.start_date__c = system.today();
        insert event;
        List<Event_Members__c> em = new List<Event_Members__c>(); //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        Event_Members__c reg= new  Event_Members__c(Event__c = Event.id);
        reg.Opportunity__c=opp.Id;
        reg.Attending_As_NGL_Only__c = 'New';
        reg.Day_1_Role__c='Member';
        reg.Contact__c = participant.Id;
        em.add(reg); //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        //insert reg; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        Event_Members__c reg1= new  Event_Members__c(Event__c = Event.id);
        reg1.Opportunity__c=opp.Id;
        reg1.Attending_As_NGL_Only__c = 'Returning';
        reg1.Day_1_Role__c='Member';
        reg1.Contact__c = participant.Id;
        em.add(reg1); //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        //insert reg1; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        Event_Members__c reg2= new  Event_Members__c(Event__c = Event.id);
        reg2.Opportunity__c=opp.Id;
        reg2.Attending_As_NGL_Only__c = 'Graduating';
        reg2.Day_1_Role__c='Member';
        reg2.Contact__c = participant.Id;
        em.add(reg2); //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        //insert reg2; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        insert em;
        
        reg.Day_1_Role__c='Cancelled';
        //update reg; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg1.Day_1_Role__c='Cancelled';
        //update reg1; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg2.Day_1_Role__c='Cancelled';
        //update reg2; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        update em; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        reg.Day_1_Role__c='Member';
        //update reg; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg1.Day_1_Role__c='Member';
        //update reg1; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg2.Day_1_Role__c='Member';
        //update reg2; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        update em; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        Test.stopTest(); // added by jasvinder for case: 00204418
        Event_Members__c reg3= new  Event_Members__c(Event__c = Event.id);
        reg3.Opportunity__c=opp.Id;
        reg3.Attending_As_NGL_Only__c = 'New';
        reg3.Day_1_Role__c='Member';
        reg3.Contact__c = participant.Id;
        insert reg3;
        
        Event_Members__c reg4= new  Event_Members__c(Event__c = Event.id);
        reg4.Opportunity__c=opp.Id;
        reg4.Attending_As_NGL_Only__c = 'Returning';
        reg4.Day_1_Role__c='Member';
        reg4.Contact__c = participant.Id;
        insert reg4;
        
        Event_Members__c reg5= new  Event_Members__c(Event__c = Event.id);
        reg5.Opportunity__c=opp.Id;
        reg5.Attending_As_NGL_Only__c = 'Graduating';
        reg5.Day_1_Role__c='Member';
        reg5.Contact__c = participant.Id;
        insert reg5;
        
        reg.Attending_As_NGL_Only__c = '';
        //update reg; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg1.Attending_As_NGL_Only__c = '';
        //update reg1; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        reg2.Attending_As_NGL_Only__c = '';
        //update reg2; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        update em; //Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        EventAttendeeTriggerhandler.updateOppRecognition(em);//Sanjeev Sharma for Case :- 00220942 [02-15-2018]
        
        
      }
   }