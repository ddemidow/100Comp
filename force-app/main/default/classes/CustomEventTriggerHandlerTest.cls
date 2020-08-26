/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 2 Jan 2019
Purpose : it is a test class for CustomEventTriggerHandler 
*********************************************************************************/
@isTest
public class CustomEventTriggerHandlerTest {
    
    @isTest
    static void testMethod2() {
        
        FFA_TestUtility testUtil = new FFA_TestUtility();
        Map<Id,Event__c> eventMap = new Map<Id,Event__c>();
        Integer index=0;
        List<Event_Members__c> evtMemLst = new List<Event_Members__c>();
        Account acc = testUtil.newAccount(true);
        
        Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
        con.Number_of_meetings_Attended__c = 0;
        for(Integer i=0;i<3;i++) {
            Event__c evt= new Event__c();
            evt.Name = 'Test Event'+i;
            evt.End_Date__c = date.today() - (360+i);
            insert evt;
            eventMap.put(evt.id, evt);
        }
        
        
        
        
        for(Id evtId : eventMap.keySet()) {
            Event_Members__c evm = new Event_Members__c();
            evm.Event__c = evtId;
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
            
            evtMemLst.add(evm);
            index++;
        }
        
        if(evtMemLst.size() > 0) {
            insert evtMemLst;
        }
        
        for(Integer i=0;i<3;i++) {
            if(i==0)
                CustomEventTriggerHandler.updateCountForMeetingAttended(eventMap,eventMap,'afterUndelete');
            else if(i==1)
                CustomEventTriggerHandler.updateCountForMeetingAttended(eventMap,eventMap,'afterUpdate');
            else
                CustomEventTriggerHandler.updateCountForMeetingAttended(eventMap,eventMap,'afterDelete');
            
            Contact conVal = [Select Id,Number_of_meetings_Attended__c FROM Contact where Id=:con.Id];
            System.assertEquals(conVal.Number_of_meetings_Attended__c,3,'The value is'+con.Number_of_meetings_Attended__c);
            
        }
    }
    
}