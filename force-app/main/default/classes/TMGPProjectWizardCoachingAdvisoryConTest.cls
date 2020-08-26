/**********************************************
/* Name : TMGPProjectWizardCoachingAdvisoryConTest
/* Created By : Shubham
/* Case : 00138614
/*********************************************/
@isTest
private class TMGPProjectWizardCoachingAdvisoryConTest {

    static testMethod void myUnitTest() {
        RecordType RecType1 = [select Id from RecordType where SobjectType = 'Milestone1_Project__c' AND Name = 'Advisory'];
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('SampleProject');
        proj.RecordTypeId = RecType1.Id;
        proj.Status__c = 'Submitted'; //Added By Arihant for CASE#00222502
        insert proj;
        Milestone1_Milestone__c parentMilestone = Milestone1_Test_Utility.sampleMilestone(proj);
        Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(proj.Id, parentMilestone.Id, 'SampleMilestone');
        insert milestone;
        RecordType RecType = [select Id from RecordType where SobjectType = 'TMG_Category__c' AND Name = 'Coaching'];
        TMG_Category__c cat = new TMG_Category__c();
        cat.Name = 'Billing';
        cat.TMG_Project__c = proj.Id;
        cat.Due_Date__c = Date.today().addDays(14);
        cat.RecordTypeId = RecType.Id;
        insert cat;
        
        Test.startTest();
        TMGPProjectWizardCoachingAdvisoryCont con = new TMGPProjectWizardCoachingAdvisoryCont();
        con.milestoneId = proj.Id;
        Milestone1_Project__c proj1 = con.milestone;
        List<Milestone1_Milestone__c> deliverables = con.deliverables;
        TMG_Category__c cat1 = con.category;
        Test.stopTest();
    }
}