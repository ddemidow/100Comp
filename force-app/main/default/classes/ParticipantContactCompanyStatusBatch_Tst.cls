@isTest
public class ParticipantContactCompanyStatusBatch_Tst {

    static testMethod void ParticipantContactCompanyStatusBatch(){

        Account acc = new Account();
        acc.name='TestAccount';//Added by Bhagya for case 254740
        insert acc;
        
        Contact c = new Contact(LastName='Test cont');
        c.AccountId = acc.Id;
        insert c;

        //START -- Modified by Shivani for S-637724 for 02/09/2019
        String stageName;
        Date closeDate;
        String CURRENCY_DEFAULT = 'USD';
        
        if(closeDate == null){
            closeDate = Date.today();
        }
        
        Opportunity rec = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Advisory_Services').getRecordTypeId(),
            Name = 'TestOpp',
            Amount = 1000.00,
            AccountId = acc.Id,
            Participant_Contact__c = c.id,
            StageName = '100 - Closed/Won',
            CloseDate = closeDate,
            Project_Start_Date__c = System.today(),
            Project_End_Date__c = System.today(),
            Project_Name__c = 'test',
            CurrencyIsoCode = CURRENCY_DEFAULT,
            Group2__c = 'Sub Group',
            probability = 100,
            Final_Client_Date__c = Date.today() + 5
            );
        insert rec; 

        rec = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Advisory_Services').getRecordTypeId(),
            Name = 'TestOpp',
            Amount = 1000.00,
            AccountId = acc.Id,
            Participant_Contact__c = c.id,
            StageName = '100 - Closed/Won',
            CloseDate = closeDate,
            Project_Start_Date__c = System.today(),
            Project_End_Date__c = System.today(),
            Project_Name__c = 'test',
            CurrencyIsoCode = CURRENCY_DEFAULT,
            Group2__c = 'Sub Group',
            probability = 100,
            Final_Client_Date__c = Date.today() - 5
            );
        insert rec; 

        rec = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Advisory_Services').getRecordTypeId(),
            Name = 'TestOpp',
            Amount = 1000.00,
            AccountId = acc.Id,
            Participant_Contact__c = c.id,
            StageName = '50 - Waiting On Decision',
            CloseDate = closeDate,
            Project_Start_Date__c = System.today(),
            Project_End_Date__c = System.today(),
            Project_Name__c = 'test',
            CurrencyIsoCode = CURRENCY_DEFAULT,
            Group2__c = 'Sub Group',
            probability = 50,
            Final_Client_Date__c = Date.today() + 5
            );
        insert rec; 

        Test.startTest();
        Database.executeBatch(new ParticipantContactCompanyStatusBatch());
        Test.stopTest();
        
        //END -- Modified by Shivani for S-637724 for 02/09/2019
    }
}