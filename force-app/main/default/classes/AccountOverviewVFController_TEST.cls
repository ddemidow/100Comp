/*
 * Appirio, Inc
 * Name: AccountOverviewVFController_TEST
 * Description: [S-551675]
 * Created Date: 16 April 2018
 * Created By: Kumari Purnima (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 */

@isTest
private class AccountOverviewVFController_TEST{
    static testMethod void myUnitTest() {
        //START -- Added by Shivani for S-637724 on 03/09/2019
        User_Roles__c u = new User_Roles__c(Name = 'G100 Companies', Activities__c = true, CampaignMember__c = true, Contacts__c = true, 
                                                Event_Attendee__c = true,Opportunities__c = true);
        insert u;
        //END -- Added by Shivani for S-637724 on 03/09/2019
        User_Permission__c user = new User_Permission__c();
        user.Name = 'G100';
        insert user;
        
        User_Roles__c us = new User_Roles__c();
        us.Name = 'G100 Network';
        us.Activities__c = true;
        us.CampaignMember__c = true;
        us.Contacts__c = true;
        us.Event_Attendee__c = true;
        us.Opportunities__c  = true;
        insert us;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.AccountId = acc.Id;
        insert con;

        //START -- Added by Shivani for S-637724 on 03/09/2019
        Contact con1 = new Contact();
        con1.LastName = 'Test Contact';
        con1.AccountId = acc.Id;
        insert con1;
        //END -- Added by Shivani for S-637724 on 03/09/2019
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = system.today();
        opp.AccountId = acc.Id;
        opp.Participant_Contact__c = con.Id;
        opp.Group2__c = 'G100 Network';
        opp.Amount = 10;
        opp.Membership_Type__c = 'NGL ($75K)';
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Opportunity';
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = system.today();
        opp1.AccountId = acc.Id;
        opp1.Participant_Contact__c = con.Id;
        opp1.Group2__c = 'G100';
        opp1.Amount = 10;
        opp1.Membership_Type__c = 'NGL ($75K)';
        opp1.Description__c = 'Test desc'; //Added by Jai Gupta | S-565584 | Oct 27th 2018
        insert opp1;

        // Start by Jai Gupta | S-565584 | Oct 27th 2018
        opp1.Description__c = 'Test desc 123' ;
        //START -- Added by Shivani for S-637724 on 03/09/2019
        opp1.Participant_Contact__c = con1.Id;
        //END -- Added by Shivani for S-637724 on 03/09/2019
        update opp1;
        // End by Jai Gupta | S-565584 | Oct 27th 2018
        Event__c event = new Event__c();
        event.Groups__c = 'G100 Companies';
        //START -- Added by Shivani for S-637724 on 03/09/2019
        event.Start_Date__c = Date.today() - 5;
        //END -- Added by Shivani for S-637724 on 03/09/2019
        insert event;
        
        Event_Members__c ev = new Event_Members__c();
        ev.Event__c = event.Id;
        ev.Contact__c = con.Id;
        insert ev;
        
        //START -- Added by Shivani for S-637724 on 03/09/2019
        Task tk = new Task();
        tk.WhatId = opp1.id;
        tk.status = 'New';
        tk.ActivityDate = Date.today() + 5;
        tk.Type = 'Call';
        insert tk;
        tk = new Task();
        tk.WhatId = opp1.id;
        tk.status = 'CompletedS';
        tk.ActivityDate = Date.today() + 5;
        tk.Type = 'Call';
        insert tk;
        Event e = new Event();
        e.WhatID = opp1.Id;
        e.ActivityDate = Date.today() + 5;
        e.DurationInMinutes = 1;
        e.ActivityDateTime =System.now().addDays(5);
        insert e;
        Campaign cc = new Campaign(Name='test');
        insert cc;
        CampaignMember ta = new CampaignMember();
        ta.ContactId = con.Id;
        ta.CampaignId = cc.Id;
        insert ta;
        //END -- Added by Shivani for S-637724 on 03/09/2019

        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        AccountOverviewVFController controller = new AccountOverviewVFController(std);
        
        PageReference pageRef = Page.AccountOverviewVF; 
        pageRef.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pageRef);
        
        controller.account_Id = acc.Id;
        controller.searchValues();
        controller.goBack();
        
        AccountOverviewVFController controller1 = new AccountOverviewVFController(std);
        
        PageReference pageRef1 = Page.AccountOverviewVF; 
        pageRef1.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pageRef1);
        
        controller1.searchValues();
        controller1.goBack();

        //START -- Added by Shivani for S-637724 on 03/09/2019
        pageRef1.getParameters().put('id', '');
        controller1.goBack();

        AccountOverviewVFController.OpportunityWrapper o = new AccountOverviewVFController.OpportunityWrapper('Test',System.now(), 'Test', opp.Id);
        //END -- Added by Shivani for S-637724 on 03/09/2019
    }
}