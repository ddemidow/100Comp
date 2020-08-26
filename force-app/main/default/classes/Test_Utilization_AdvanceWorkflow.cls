@isTest
private class Test_Utilization_AdvanceWorkflow {
    
    static testMethod void triggerAdvanceWorkflow() {
       Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
       //Insert region 
        pse__Region__c region = new pse__Region__c();
        region.Name = 'test region';
        region.CurrencyIsoCode = 'USD';
        region.ffpsai__OwnerCompany__c = comp.id;
        insert region ;
        
       pse__Utilization_Calculation__c uc = new pse__Utilization_Calculation__c(name = 'test' , pse__Region__c = region.id);
       insert uc;       
       
       pse__Utilization_Detail__c ud = new pse__Utilization_Detail__c(pse__Region__c = region.id);
       ud.pse__Utilization_Calculation__c = uc.id;
       insert ud;
       
       skipTriggers__c sk = new SkipTriggers__c(Name = userinfo.getUserId());
        insert sk;
        
        update ud; 
        }
        }