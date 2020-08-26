/*********************************************************************************
Name : Nitin Vyas
Created By : Appirio  
Created Date : 27 Nov 2018
Purpose : it is a test class for ActionPlanTaskTriggerHandler
*********************************************************************************/
@isTest
public class ActionPlanTaskTriggerHandlerTest {
    
    @isTest
    static void testMethod2() {
        
        String uniqueUserName = 'kevinKeegan' + DateTime.now().getTime() + '@testorg.com';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'kevin', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='kevin', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            FFA_TestUtility testUtil = new FFA_TestUtility();
            Account acc = testUtil.newAccount(true);
            
            Contact con = testUtil.newResource(true,acc.id,UserInfo.getUserId());
            con.G100_N_Calls__c = 0;
            con.G100_N_Meetings__c = 0;
            Map<Id,Task> eventMemberMap = new Map<Id,Task>();
            
            List<Task> tkLst = new List<Task>();
            
            for(Integer i=0;i<5;i++) {
                Task tk = new Task();
                tk.WhoId = con.id;
                tk.status = 'Completed';
                tk.ActivityDate = Date.today()-(340+i);
                tk.Type = 'Call';
                if(i==0) {
                    
                    tk.Subject = 'Hotel room Check-in';
                }	
                else if(i==1) {
                    
                    tk.Subject = 'Call Notes are available';
                } else if(i==2) {
                    
                    tk.Subject = 'The task is CN:3590';
                } else if(i==3) {
                    tk.Type = 'E-Packet';
                    tk.Subject = 'Test in-person interview';
                } else {
                    tk.Type = 'E-Packet';
                    tk.Subject = 'Test inperson event';
                }
                tkLst.add(tk);
                eventMemberMap.put(con.id,tk);
            }
            
            if(tkLst.size() > 0)
                insert tkLst;
            
            for(Integer i=0;i<3;i++) {
                if(i==0)
                    ActionPlanTaskTriggerHandler.updateCountForEvent(eventMemberMap,eventMemberMap,'afterInsert');
                else if(i==1)
                    ActionPlanTaskTriggerHandler.updateCountForEvent(eventMemberMap,eventMemberMap,'afterUpdate');
                else
                    ActionPlanTaskTriggerHandler.updateCountForEvent(eventMemberMap,eventMemberMap,'afterDelete');
                
                
                
                
                Contact conCallVal = [Select Id,G100_N_Calls__c,G100_N_Meetings__c FROM Contact where Id=:con.Id];
                System.assertEquals(conCallVal.G100_N_Calls__c,3,'The value is'+conCallVal.G100_N_Calls__c);
                System.assertEquals(conCallVal.G100_N_Meetings__c,2,'The value is'+conCallVal.G100_N_Meetings__c);
                
                
                
            }
        }  
    }
}