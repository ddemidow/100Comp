/*===========================================
* Class Name: EventAttendeeTriggerHandlerTest
* Description: Test Class for EventAttendeeTriggerHandler[S-553690]
* Created Date: 3 May 2018
* Created By: Anirudh Shandilya (Appirio) 
===========================================*/

@isTest
private class EventAttendeeTriggerHandlerTest{
    
    public static List<Event_Members__c> eventMemberList;
    public static Map<Id,Event_Members__c> eventMemberMap;
    
    static void testSetup(){
         
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
		
        opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.Participant_Contact__c = con.Id;
        opp.LeadSource = 'Other';
        opp.Group2__c = 'G100 Network';
        opp.CloseDate = System.today();
        opp.StageName = '100-Invoice Paid';
        opp.Amount=10000;
        opp.Membership_Type__c = 'NGL ($75K)';
        opp.Revenue_Recognition_1_Manually_Updated__c=false;
        opp.Revenue_Recognition_Begins__c = null;
     	insert opp;

        Event__c evt= new Event__c();
        evt.Name = 'Test Event';
        insert evt;
        Event_Members__c evm = new Event_Members__c();
        evm.Event__c = evt.id;
        evm.Contact__c = con.id;
        evm.Opportunity__c = opp.id;
        evm.Attending_As_NGL_Only__c ='New';
        insert evm;
        eventMemberList = new List<Event_Members__c>();
        eventMemberList.add(evm);
        eventMemberMap = new Map<Id,Event_Members__c>();
        eventMemberMap.put(evm.Id,evm);
    }
    @isTest
    static void testMethod1(){
        testSetup();
        Test.startTest();
        EventAttendeeTriggerHandler.onAfterInsertUpdate(eventMemberList,eventMemberMap);
        EventAttendeeTriggerHandler.updateOppRecognition(eventMemberList);
        Test.stopTest();
        System.assertNotEquals(eventMemberList,null);
        System.assertNotEquals(eventMemberMap,null);
    }
    
    //START - Added by Nitin on 27/11/2018 for S-586005
    @isTest
    static void testMethod2() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Map<Id,Event_Members__c> eventMemberMap = new Map<Id,Event_Members__c>();
        Integer index=0;
        List<Event__c> evtLst = new List<Event__c>();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        con.Number_of_meetings_Attended__c = 0;
        for(Integer i=0;i<3;i++) {
            Event__c evt= new Event__c();
            evt.Name = 'Test Event'+i;
            evt.End_Date__c = date.today() - (360+i);
            evtLst.add(evt);
        }
        
        if(evtLst.size()>0)
            insert evtLst;
        
        
        for(Event__c evt : evtLst) {
            Event_Members__c evm = new Event_Members__c();
            evm.Event__c = evt.id;
            evm.Contact__c = con.id;
            if(index==0) {
                evm.Day_1_Role__c = 'Advisor';
                evm.Day_2_Role__c = '';
                evm.Day_3_Role__c = '';
            } else if(index==1) {
                evm.Day_1_Role__c = '';
                evm.Day_2_Role__c = 'Advisor';
                evm.Day_3_Role__c = '';
            } else {
                evm.Day_1_Role__c = '';
                evm.Day_2_Role__c = '';    
                evm.Day_3_Role__c = 'Member';
            }
            insert evm;
            eventMemberMap.put(evm.Id,evm);
            index++;
        }
        
        
        for(Integer i=0;i<3;i++) {
            if(i==0)
                EventAttendeeTriggerHandler.updateCount(eventMemberMap,eventMemberMap,'afterInsert');
            else if(i==1)
                EventAttendeeTriggerHandler.updateCount(eventMemberMap,eventMemberMap,'afterUpdate');
            else
                EventAttendeeTriggerHandler.updateCount(eventMemberMap,eventMemberMap,'afterDelete');
            
            Contact conVal = [Select Id,Number_of_meetings_Attended__c FROM Contact where Id=:con.Id];
            System.assertEquals(conVal.Number_of_meetings_Attended__c,3,'The value is'+con.Number_of_meetings_Attended__c);
            
        }
        
        
        
    }
    //START - Added by Nitin on 27/11/2018 for S-586005
}