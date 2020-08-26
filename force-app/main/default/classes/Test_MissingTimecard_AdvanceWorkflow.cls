@isTest
private class Test_MissingTimecard_AdvanceWorkflow {
    
    static testMethod void triggerAdvanceWorkflow() {
       pse__Missing_Timecard__c mt = new pse__Missing_Timecard__c(Name = 'test',pse__End_Date__c = date.today() , pse__Start_Date__c = date.today());
       insert mt;       
       
       skipTriggers__c sk = new SkipTriggers__c(Name = userinfo.getUserId());
        insert sk;
        
        update mt; 
        }
        }