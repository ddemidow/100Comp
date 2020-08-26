/**********************************************
/* Name : TMGPProjectWizardCEOSuccessController_TC
/* Created By : Shubham
/* Case : 00138614
/*********************************************/
@isTest
private class TMGPProjectWizardCEOSuccessController_TC {

    static testMethod void myUnitTest() {
        RecordType RecType1 = [select Id from RecordType where SobjectType = 'Milestone1_Project__c' AND Name = 'CEO Succession'];
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('SampleProject');
        //SSANDHU 00224743 START
        proj.Status__c = 'Submitted'; 
        //SSANDHU 00224743 END
        proj.RecordTypeId = RecType1.Id;
        insert proj;
        Milestone1_Milestone__c parentMilestone = Milestone1_Test_Utility.sampleMilestone(proj);
        Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(proj.Id, parentMilestone.Id, 'SampleMilestone');
        insert milestone;
        
        Test.startTest();
        TMGPProjectWizardCEOSuccessController con = new TMGPProjectWizardCEOSuccessController();
        con.milestoneId = proj.Id;
        Milestone1_Project__c proj1 = con.milestone;
        List<Milestone1_Milestone__c> participants = con.participants;
        string projectLink = con.projectLink;
        Milestone1_Milestone__c inteviewDeliverable = con.inteviewDeliverable;
        Milestone1_Milestone__c debriefDeliverable = con.debriefDeliverable;
        
        RecordType RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Data Collection'];
        TMG_Category__c cat = new TMG_Category__c();
        cat.Name = 'Billing';
        cat.TMG_Project__c = proj.Id;
        cat.Due_Date__c = Date.today().addDays(14);
        cat.RecordTypeId = RecType.Id;
        insert cat;
        
        RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Written Deliverables'];
        TMG_Category__c cat1 = new TMG_Category__c();
        cat1.Name = 'Billing';
        cat1.TMG_Project__c = proj.Id;
        cat1.Due_Date__c = Date.today().addDays(14);
        cat1.RecordTypeId = RecType.Id;
        cat1.Draft_Assessment__c = Date.today().addDays(1);
        insert cat1;
        
        RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Feedback'];
        TMG_Category__c cat2 = new TMG_Category__c();
        cat2.Name = 'Billing';
        cat2.TMG_Project__c = proj.Id;
        cat2.Due_Date__c = Date.today().addDays(14);
        cat2.RecordTypeId = RecType.Id;
        insert cat2;
        
        RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'S&E Profile'];
        TMG_Category__c cat3 = new TMG_Category__c();
        cat3.Name = 'Billing';
        cat3.TMG_Project__c = proj.Id;
        cat3.Due_Date__c = Date.today().addDays(14);
        cat3.RecordTypeId = RecType.Id;
        insert cat3;
        
        TMG_Category__c cat10 = con.category;
        
        Test.stopTest();
    }
    
    // added for the story #S-362576 #START
    static testMethod void myUnitTest1() {
        
        RecordType RecType1 = [select Id from RecordType where SobjectType = 'Milestone1_Project__c' AND Name = 'CEO Succession'];
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('SampleProject');
        proj.RecordTypeId = RecType1.Id;
        //SSANDHU 00224743 START
        proj.Status__c = 'Submitted';
        //SSANDHU 00224743 END  
        insert proj;
        Milestone1_Milestone__c parentMilestone = Milestone1_Test_Utility.sampleMilestone(proj);
        
        TMGPProjectWizardCEOSuccessController con = new TMGPProjectWizardCEOSuccessController();
        con.milestoneId = proj.Id;
        Milestone1_Project__c proj1 = con.milestone;
        List<Milestone1_Milestone__c> participants = con.participants;
        string projectLink = con.projectLink;
        Milestone1_Milestone__c inteviewDeliverable = con.inteviewDeliverable;
        Milestone1_Milestone__c debriefDeliverable = con.debriefDeliverable;
        
        RecordType RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Data Collection'];
        TMG_Category__c cat = new TMG_Category__c();
        cat.Name = 'Billing';
        cat.TMG_Project__c = proj.Id;
        cat.Due_Date__c = Date.today().addDays(14);
        cat.RecordTypeId = RecType.Id;
        insert cat;
        
        Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(proj.Id, parentMilestone.Id, 'SampleMilestone');
        milestone.TMG_Category__c = cat.id;
        insert milestone;
        
        Test.startTest();
        
        Set<Id> setIds = new Set<Id>();
        setIds.add(cat.id);
        
        Milestone1_Milestone_Trigger_Utility.populateCategoryTasksfields(setIds);
        
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest2() {
        
        Profile profileUsed;

        String ret = 'word' + math.rint(math.random() * 100000);
        for( Profile p : [ Select Id, PermissionsModifyAllData, Name from Profile where PermissionsModifyAllData = false limit 1 ] ){
           profileUsed = p;
        }
        String namePrefix = ret;

        User testUser = new User();
        testUser.Email = 'test2@test2.com';
        testUser.Username = ret + '@testuser2.com';
        testUser.LastName = 'test2';
        testUser.Alias = 'test2';
        testUser.ProfileId = profileUsed.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;
        
        System.runAs(testUser) {
            
            RecordType RecType1 = [select Id from RecordType where SobjectType = 'Milestone1_Project__c' AND Name = 'CEO Succession'];
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('SampleProject');
            proj.RecordTypeId = RecType1.Id;
            proj.Status__c = 'Submitted';
            insert proj;
            Milestone1_Milestone__c parentMilestone = Milestone1_Test_Utility.sampleMilestone(proj);
            
            TMGPProjectWizardCEOSuccessController con = new TMGPProjectWizardCEOSuccessController();
            con.milestoneId = proj.Id;
            Milestone1_Project__c proj1 = con.milestone;
            List<Milestone1_Milestone__c> participants = con.participants;
            string projectLink = con.projectLink;
            Milestone1_Milestone__c inteviewDeliverable = con.inteviewDeliverable;
            Milestone1_Milestone__c debriefDeliverable = con.debriefDeliverable;
            
            RecordType RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Data Collection'];
            TMG_Category__c cat = new TMG_Category__c();
            cat.Name = 'Billing';
            cat.TMG_Project__c = proj.Id;
            cat.Due_Date__c = Date.today().addDays(14);
            cat.RecordTypeId = RecType.Id;
            insert cat;
            
            Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(proj.Id, parentMilestone.Id, 'SampleMilestone');
            milestone.TMG_Category__c = cat.id;
            //SSANDHU 00224743 START
            //insert milestone;
            //SSANDHU END   
        }
        
        Boolean perm = Milestone1_Milestone_Trigger_Utility.milestonePermissions('Account');
        system.assertEquals(perm,true);
        
        Test.startTest();
        
    }
    // added for the story #S-362576 #END
}