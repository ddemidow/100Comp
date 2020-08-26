@isTest
private class Test_Rate_Card_AdvanceWorkflow {
    static  Date todayDate ;
    static  ID userId ;
    
    static testMethod void triggerAdvanceWorkflow() {
       pse__Rate_Card__c rc = new pse__Rate_Card__c(pse__Suggested_Bill_Rate__c = 10 , pse__Average_Cost_Rate__c =10);
       insert rc;       
       
       skipTriggers__c sk = new SkipTriggers__c(Name = userinfo.getUserId());
        insert sk;
        
        update rc; 
        }
        }