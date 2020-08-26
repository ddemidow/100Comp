/************************************************
Name : Test_Project_AdvanceWorkflow
Created By : Reena Acharya(Appirio JDC)
Created Date : 9/4/2014
Description : Test coverage of trigger Project_AdvanceWorkflow 
************************************************/
@isTest
private class Test_Project_AdvanceWorkflow {
    static  Date todayDate ;
    static  ID userId ;
    
    static testMethod void triggerAdvanceWorkflow() {
        userId = UserInfo.getUserId();
        todayDate = Date.today();
        
        c2g__codaCompany__c comp = new c2g__codaCompany__c(Name = 'test');
        insert comp;
        
        //Insert Account
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.CurrencyIsoCode = 'USD';
        insert testAccount;
        system.assert(testAccount.Id != null);
        
         //Insert region 
        pse__Region__c pse_region = new pse__Region__c();
        pse_region.Name = 'test region';
        pse_region.CurrencyIsoCode = 'USD';
        pse_region.ffpsai__OwnerCompany__c = comp.id;
        insert pse_region;
        system.assert(pse_region.Id != null);
        
        //Insert Practice
        pse__Practice__c pse_practice = new pse__Practice__c(Name = 'test practice');
        pse_practice.CurrencyIsoCode = 'USD';
        insert pse_practice;
        system.assert(pse_practice.Id != null);
        
        //Insert Group
        pse__Grp__c  pse_group = new pse__Grp__c(name='test Group');
        pse_group.CurrencyIsoCode = 'USD';
        insert pse_group;
        system.assert(pse_group.Id!=null);
          
       
        Set<String> userProfile = new Set<String>();
        userProfile.add('PSE Manager');
        userProfile.add('PSE User');
        userProfile.add('System Administrator');
       
        Map<String,ID> userProfileMap = new Map<String,ID>();
       
        for(Profile profile : [Select Id,Name from Profile where Name in : userProfile]){
         userProfileMap.put(profile.Name,profile.Id);
        }
       
        //Insert User
        User u = new User();
        u.Username = math.random()+'123@test.com';
        u.LastName = 'User Manager';
        u.Email = 'a@b.com';
        u.Alias = 'tes12';
        u.CommunityNickname = 'tuser31';
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        if(userProfileMap.containsKey('PSE Manager')){
         u.ProfileId = userProfileMap.get('PSE Manager');
        }else{
         u.ProfileId = userProfileMap.get('System Administrator');
        }
        u.LanguageLocaleKey = 'en_US';
        u.ManagerId = UserInfo.getUserId();
        insert u;
        system.assert(u.Id != null);
       
         //Insert User
        User u1 = new User();
        u1.Username = math.random()+'1234@test.com';
        u1.LastName = 'User';
        u1.Email = 'a@b.com';
        u1.Alias = 'tes123';
        u1.CommunityNickname = 'tuser311';
        u1.TimeZoneSidKey = 'America/New_York';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'ISO-8859-1';
        if(userProfileMap.containsKey('PSE User')){
            u1.ProfileId = userProfileMap.get('PSE User');
        }else{
            u1.ProfileId = userProfileMap.get('System Administrator');
        }
        u1.LanguageLocaleKey = 'en_US';
        u1.ManagerId = UserInfo.getUserId();
        insert u1;
        system.assert(u1.Id != null);
       
        
        List<contact> contacts = new List<Contact>();
        //Insert Contact
        Contact xpm = new Contact();
        xpm.LastName = 'Test';
        xpm.AccountId = testAccount.Id;
        xpm.CurrencyIsoCode = 'USD';
        xpm.pse__Is_Resource_Active__c = true;
        xpm.pse__Is_Resource__c = true;    
        xpm.pse__Resource_Role__c ='Consultant';
        xpm.pse__Default_Cost_Rate__c = 25.0;
        xpm.pse__Region__c = pse_region.Id;
        xpm.pse__Salesforce_User__c = u.Id;  
        xpm.Email = 'a@b.com';  
        contacts.add(xpm);
        
        //Insert Contact
        Contact xresource = new Contact();
        xresource.LastName = 'Test';
        xresource.AccountId = testAccount.Id;
        xresource.CurrencyIsoCode = 'USD';
        xresource.pse__Is_Resource_Active__c = true;
        xresource.pse__Is_Resource__c = true;    
        xresource.pse__Resource_Role__c ='Consultant';
        xresource.pse__Default_Cost_Rate__c = 25.0;
        xresource.pse__Region__c = pse_region.Id;
        xresource.pse__Salesforce_User__c = u1.Id;  
        xresource.Email = 'a@b.com';  
        contacts.add(xresource);
        insert contacts;
        
        system.assert(xresource.Id != null);
         
        List<pse__Proj__c> projects = new List<pse__Proj__c>();
        /* create the project, set the PM and Owner to be the Manager resource */
        pse__Proj__c project = new pse__Proj__c(Name='test_project');
        project.pse__Is_Billable__c = true;
        project.pse__Is_Active__c = true;
        project.pse__Project_Status__c = 'Green';
        project.pse__Allow_Timecards_Without_Assignment__c = false; 
        project.pse__Start_Date__c = todayDate.addMonths(-1);
        project.pse__End_Date__c = todayDate.addMonths(4);
        project.pse__Region__c = pse_region.Id;     
        project.pse__Practice__c = pse_practice.Id; 
        project.pse__Group__c = pse_group.Id; 
        
        project.CurrencyIsoCode ='USD';
        project.pse__Billing_Type__c = 'Administrative';
        project.pse__Project_Manager__c = xpm.id;
        project.OwnerId = u.id;
        project.pse__Project_Type__c = 'Sales';
        projects.Add(project); 
        //system.assert(project.Id != null);
        
        pse__Proj__c project1 = new pse__Proj__c(Name='test_project');
        project1.pse__Is_Billable__c = false;
        project1.pse__Is_Active__c = true;
        project1.pse__Project_Status__c = 'Green';
        project1.pse__Allow_Timecards_Without_Assignment__c = false; 
        project1.pse__Start_Date__c = todayDate.addMonths(-1);
        project1.pse__End_Date__c = todayDate.addMonths(4);
        project1.pse__Region__c = pse_region.Id;     
        project1.pse__Practice__c = pse_practice.Id; 
        project1.pse__Group__c = pse_group.Id; 
        project1.CurrencyIsoCode ='USD';
        project1.pse__Project_Type__c = 'Sales';
        project1.pse__Billing_Type__c = 'Administrative';
        project1.pse__Project_Manager__c = xpm.id;
        project1.OwnerId = u.id;
        projects.Add(project1); 
        system.runas(u){
            insert projects;
            
            skipTriggers__c st = new SkipTriggers__c(Name = userinfo.getUserId());
            insert st;
            
            update projects;
        }
    }
}