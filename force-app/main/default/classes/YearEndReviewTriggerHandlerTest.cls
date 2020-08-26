@isTest
private class YearEndReviewTriggerHandlerTest {
    static testmethod void testTriggerHandler() {
        Mid_Year_Review__c myr = new Mid_Year_Review__c();
        insert myr;
        //START -- Added by Shivani for S-637724 on 03/09/2019
        Mid_Year_Review__c myr1 = new Mid_Year_Review__c();
        insert myr1;
        //END -- Added by Shivani for S-637724 on 03/09/2019
        Year_end_Review__c yer = new Year_end_Review__c(Mid_Year_Review__c=myr.Id);
        insert yer;
        yer.Manager__c = 'Ashcroft, Paul';
        update yer;
        //START -- Added by Shivani for S-637724 on 03/09/2019
        yer.Mid_Year_Review__c = myr1.Id;
        update yer;

        YearEndReviewTriggerHandler y = new YearEndReviewTriggerHandler();
        y.YearEndReviewTriggerHandler();
        //END -- Added by Shivani for S-637724 on 03/09/2019
    }
}