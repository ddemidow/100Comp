@isTest
private class Test_MiscAdjustment_AdvanceWorkflow {
    static  Date todayDate ;
    static  ID userId ;
    
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
        
       

        pse__Proj__c project = new pse__Proj__c();
        project.Name = 'TestProject';
        project.pse__Account__c = acc.id;
        project.CurrencyIsoCode = 'USD';
        project.pse__Start_Date__c = date.today().addYears(-1);
        project.pse__Region__c = region.id;
        project.pse__Project_Type__c = 'Customer Project';
        project.pse__Project_Status__c = 'Green';
        project.pse__Is_Billable__c = true;
        project.pse__Is_Active__c = true;
        project.pse__Invoiced__c = 50000;
        project.pse__End_Date__c = date.today().addYears(1);
        project.pse__Closed_for_Time_Entry__c = false; 
        project.pse__Closed_for_Expense_Entry__c = false;
        project.pse__Billing_Type__c = 'Time and Materials';
        project.pse__Billed__c = 40000;
        project.pse__Allow_Timecards_Without_Assignment__c = true;
        project.pse__Allow_Expenses_Without_Assignment__c = true;
        insert project;
        
               
        pse__Miscellaneous_Adjustment__c  ma = new pse__Miscellaneous_Adjustment__c ();
        ma.pse__Project__c = project.id;
        ma.pse__Effective_Date__c = date.today();
        ma.pse__Amount__c = 100;
        ma.pse__Transaction_Category__c = 'test';
           insert ma;
      
        skipTriggers__c sk = new SkipTriggers__c(Name = userinfo.getUserId());
        insert sk;
        
        update ma; 
       
        
        }
        }