/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 22 Dec. 2015
Purpose : Trigger Handler test class
Updated: Jesse Brown S-550868 cover new functionality in OpportunityTriggerHandler
Updated: Himanshu Matharu C-00240137 9/24/2018 Added additional test data
*********************************************************************************/
@IsTest
private with sharing class OpportunityTriggerHandlerTest {
  static testMethod void AfterUpdateMethod (){
  RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Advisory Services' Limit 1];
  RecordType contract = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' and Name='Membership Management (Contract)' Limit 1]; //JesseB S-550868 adding recordtype to use in test below
  Test.startTest();
    Account a = new Account();
    a.Name = 'New Test Account';
    insert a;
    
    Contact con = new Contact();
    Con.FirstName = 'Test';
    Con.LastName = 'Contact';
    con.AccountId = a.Id;
    insert con;
    
    Opportunity opp = New Opportunity();
    opp.accountId = a.id;
    opp.name = 'Test oppty';
    opp.Membership_Begins__c = date.today();
    opp.Membership_Expires__c = opp.Membership_Begins__c + 365;
    opp.Invoice_Date__c = date.today();
    opp.Payment_Date__c = date.today();
    opp.amount = 100.00;
    opp.StageName = '100 - Signed Contract';
    opp.Group2__c = 'High Lantern Group';
    opp.Engagement_Type__c = 'Advisory';
    opp.Lead_Contact_Source__c = con.id;
    opp.Participant_Contact__c = con.id;
    opp.Parent_Account_Contact__c = con.id;
    opp.recordTypeID = rt.id;
    opp.Project_Name__c = 'Test';
    opp.CloseDate = date.today() + 365;
    opp.Project_Start_Date__c = date.today();
    opp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
    
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    opp.Revenue_Recognition_Begins__c = date.today().addDays(20);
    opp.Revenue_Recognition_Ends__c = date.today().addDays(25);
    opp.Revenue_Recognition_3__c = date.today().addDays(15);
    //S-429731 ---END--- Hitesh[Sept 14, 2016]
    insert opp;
    
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    //Connor Flynn S-447295 Start
    Opportunity opp_updated = [select  Final_Client_Date__c, Revenue_Recognition_3__c, CloseDate from Opportunity where id =:opp.id limit 1];
    Contact partContact = [Select Id, G100_Companies_Status__c From Contact Where Id = :con.Id limit 1];
    system.assertEquals(partContact.G100_Companies_Status__c, 'High Lantern Group - Client');
    system.assertEquals(opp_updated.Final_Client_Date__c, opp_updated.CloseDate);
    //S-429731 ---END--- Hitesh[Sept 14, 2016]
    
    
    opp.Engagement_Type__c = 'Coaching';
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    opp.Revenue_Recognition_Begins__c = date.today().addDays(25);
    opp.Revenue_Recognition_Ends__c = date.today().addDays(10);
    opp.Revenue_Recognition_3__c = date.today().addDays(15);
    opp.StageName = '95 - Booked Not Yet Scheduled';
    //S-429731 ---END--- Hitesh[Sept 14, 2016]
    update opp;
    
    //S-429731 ---START--- Hitesh[Sept 14, 2016]
    opp_updated = [select Final_Client_Date__c, Revenue_Recognition_Ends__c, CloseDate from Opportunity where id =:opp.id limit 1];
    system.assertEquals(opp_updated.Final_Client_Date__c, opp_updated.CloseDate);
    //S-429731 ---END--- Hitesh[Sept 14, 2016]

    //JesseB S-550868 START
    Opportunity parentOpp = New Opportunity();
    parentOpp.accountId = a.id;
    parentOpp.name = 'Test oppty';
    parentOpp.Membership_Begins__c = date.today();
    parentOpp.Membership_Expires__c = opp.Membership_Begins__c + 365;
    parentOpp.Invoice_Date__c = date.today();
    parentOpp.Payment_Date__c = date.today();
    parentOpp.amount = 1000.00;
    //Modified below 1 line HMATHARU 9/24/2018 C-00240137 Added additional test data
    parentOpp.G100N_Opp_Type__c='Renewal';
    // Updated Start by Lokesh for S-654680 [11-May-2020] start Reason-Add-60 in place of 70 in criteria for renwel
    parentOpp.StageName = '60 - Renewal Pending';
    // Updated Start by Lokesh for S-654680 [11-May-2020] start Reason-Add-60 in place of 70 in criteria for renwel
    parentOpp.Group2__c = 'G100 Network';
    //Start--added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
    parentOpp.Renewal__c = True ;
    //END--added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
    parentOpp.SubGroup__c = 'G100 Network Enterprise';
    parentOpp.LeadSource = 'Casual Interaction';
    parentOpp.Participant_Contact__c = con.id;
    parentOpp.Parent_Account_Contact__c = con.id;
    parentOpp.recordTypeID = contract.id;
    parentOpp.Project_Name__c = 'Test';
    parentOpp.CloseDate = date.today() + 365;
    parentOpp.Project_Start_Date__c = date.today();
    parentOpp.Project_End_Date__c =opp.Project_Start_Date__c.addmonths(9);
    parentOpp.Membership_Type__c = 'G100 Network ($200K)';
    parentOpp.Participant_Contact__c = con.id;
    insert parentOpp;

    Opportunity childOpp = New Opportunity();
    childOpp.accountId = a.Id;
    childOpp.name = 'Child Test Opp';
    childOpp.amount = 500.00;
    childOpp.StageName = '33 - Call/Meeting';
    childOpp.Group2__c = 'G100 Network';
    childOpp.SubGroup__c = 'G100 Network Enterprise';
    childOpp.LeadSource = 'Inherited Membership';
    //childOpp.G100N_Opp_Type__c = 'New Business';
    childOpp.Parent_Opportunity__c = parentOpp.Id;
    childOpp.Membership_Type__c = 'G100 Network ($200K)';
    childOpp.Participant_Contact__c = con.id;
    childOpp.CloseDate = date.today() + 360;
    insert childOpp;

    Opportunity parentTest = [SELECT Id, Amount FROM Opportunity WHERE id = : parentOpp.Id LIMIT 1];
    system.assertEquals(parentTest.Amount, 500.00);

    parentOpp.Amount = 250.00;
    parentOpp.Description__c = 'New test desc';
    parentOpp.Lead_Contact_Source__c = con.id;
    parentOpp.G100N_Opp_Type__c = 'New Business';
    parentOpp.Reason_Lost__c = 'Disqualified';

      //update parentOpp; // Commented by Himanshu M, No need of updating parentOpp, updated values never used. [2 Feb 2019]

    Opportunity parentTest2 = [SELECT Id, Amount FROM Opportunity WHERE id = : parentOpp.Id LIMIT 1];
    system.assertEquals(parentTest2.Amount, 500.00);

    Opportunity childTest = [SELECT Id, LeadSource FROM Opportunity WHERE id =: childOpp.Id LIMIT 1];
    //system.assertEquals(childTest.LeadSource, 'Inherited Membership');


    //Opportunity updateParent = New Opportunity([SELECT id, Name, LeadSource, CampaignId])
  Test.stopTest();
  }

  static testMethod void testRenewOppty (){
    Account a = new Account();
    a.Name = 'New Test Account';
    insert a;
    
    Contact con = new Contact();
    Con.FirstName = 'Test';
    Con.LastName = 'Contact';
    con.AccountId = a.Id;
    insert con;

    Id rt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Management').getRecordTypeId();

    Opportunity testOppToRenew = new Opportunity();
    testOppToRenew.accountId = a.id;
    testOppToRenew.name = 'Test oppty';
    testOppToRenew.Membership_Begins__c = date.today();
    testOppToRenew.Membership_Expires__c = testOppToRenew.Membership_Begins__c + 365;
    testOppToRenew.Invoice_Date__c = date.today();
    testOppToRenew.Payment_Date__c = date.today();
    testOppToRenew.amount = 100.00;
    testOppToRenew.StageName = '50 - Waiting On Decision';
    testOppToRenew.Group2__c = 'High Lantern Group';
    testOppToRenew.Engagement_Type__c = 'Advisory';
    testOppToRenew.Lead_Contact_Source__c = con.id;
    testOppToRenew.Participant_Contact__c = con.id;
    testOppToRenew.Parent_Account_Contact__c = con.id;
    testOppToRenew.recordTypeID = rt;
    testOppToRenew.Project_Name__c = 'Test';
    testOppToRenew.CloseDate = date.today() + 365;
    testOppToRenew.Project_Start_Date__c = date.today();
    testOppToRenew.Project_End_Date__c =testOppToRenew.Project_Start_Date__c.addmonths(9);
    testOppToRenew.Revenue_Recognition_Begins__c = date.today().addDays(20);
    testOppToRenew.Revenue_Recognition_Ends__c = date.today().addDays(25);
    testOppToRenew.Revenue_Recognition_3__c = date.today().addDays(15);
    testOppToRenew.SubGroup__c = 'G100';
    insert testOppToRenew;

    testOppToRenew.StageName = '100 - Invoice Paid';
    update testOppToRenew;
    system.assert(true,testOppToRenew.isWon);
    system.assert(true,testOppToRenew.hasBeenRenewed__c);

  }
    /*Start - Jai Gupta - S-506188 - Sep 06,2017 - Create Renewal Opportunity*/
    public static final String GROUP_G100 = 'G100 Network';
    public static final String WLN_SUBGROUP = 'WLN';
    public static final String INVOICE_PAID = '100 - Invoice Paid';
    public static final String MEMBERSHIP_TYPE = 'BX Member ($12.5K)';
    public static final String WAITING_ON_DECISION = '50 - Waiting on Decision';
    public static final String RENEWAL_LEADSOURCE = 'Renewal';
    
    static testMethod void updateDateFieldsOnRenewalOpptyTest() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        
        test.startTest();
        testOpp.Participant_Contact__c = testContact2.Id;
        testOpp.Group2__C = GROUP_G100 ;
        testOpp.SubGroup__C = WLN_SUBGROUP ;
        testOpp.StageName = WAITING_ON_DECISION ;
        testOpp.Renewal__c = true ;
        testOpp.LeadSource = RENEWAL_LEADSOURCE ;
        testOpp.G100_Network_Enterprise_Sale__c = false ;
        testOpp.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp.Membership_Begins__c = date.today();
        testOpp.CloseDate = date.today();
        testOpp.Membership_Expires__c = date.today();
        insert testOpp;
        test.StopTest();
        
    }
    /*End - Jai Gupta - S-506188 - Sep 06,2017 - Create Renewal Opportunity*/
    
    /* Start - Jai Gupta - S-506189 - 12 Sep, 2017 */
    public static final String CLOSED_LOST = '00 - Closed/Lost';
    public static final string REASON_LOST_BR = 'Budgetary Restrictions' ;
    public static final string REASON_LOST_DIS = 'Disqualified' ;
    public static final string TARGET_POTENTIAL_OPP = 'Target (Potential Opp)' ;
    public static final string PROSPECT_CURRENT_OPP = 'Prospect (Current Opp)' ;
    
    static testMethod void syncWLNStatus1() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        
        test.startTest();
        testOpp.Participant_Contact__c = testContact2.Id;
        testOpp.Group2__C = GROUP_G100 ;
        //Start--added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
        testOpp.Renewal__c = True ;
        //END--added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
        testOpp.SubGroup__C = WLN_SUBGROUP ;
        testOpp.StageName = CLOSED_LOST ; 
        testOpp.G100_Network_Enterprise_Sale__c = false ;
        testOpp.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp.Membership_Begins__c = date.today();
        testOpp.CloseDate = date.today();
        testOpp.Membership_Expires__c = date.today();
        testOpp.Reason_Lost__c = REASON_LOST_BR;
        insert testOpp;
        test.StopTest();
        
        Contact con = [Select Id,WLN_STATUS__C from COntact where Id = :testContact2.id] ;
        system.assertEquals(TARGET_POTENTIAL_OPP,con.WLN_Status__c) ;
    }
    
    static testMethod void syncWLNStatus2() {
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        
        test.startTest();
        testOpp.Participant_Contact__c = testContact2.Id;
        testOpp.Group2__C = GROUP_G100 ;
       //Start--Added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
        testOpp.Renewal__c = True ; 
       //END--Added by Komal | C-00279945 | 10/08/2020 | to fix test class failure
        testOpp.SubGroup__C = WLN_SUBGROUP ;
        testOpp.StageName = CLOSED_LOST ;
        testOpp.G100_Network_Enterprise_Sale__c = false ;
        testOpp.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp.Membership_Begins__c = date.today();
        testOpp.CloseDate = date.today();
        testOpp.Membership_Expires__c = date.today();
        testOpp.Reason_Lost__c = REASON_LOST_DIS;
        insert testOpp;
        test.StopTest();
        
        Contact con = [Select Id,WLN_STATUS__C from COntact where Id = :testContact2.id] ;
        system.assertEquals(null,con.WLN_Status__c) ;
    }
    /* End - Jai Gupta - S-506189 - 12 Sep, 2017 */
    
    //START Himanshu Matharu S-647270
    @isTest
    public static void createNewRenewalOppTest(){
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        
        test.startTest();
        testOpp.Participant_Contact__c = testContact2.Id;
        testOpp.Group2__C = GROUP_G100 ;
        //Start--updated by Komal | C-00279945 | 10/08/2020 | to fix test class failure[change value false to true]
        testOpp.Renewal__c = true; //Code Added by Himanshu Baghmar for Case #00269040
        //END--updated by Komal | C-00279945 | 10/08/2020 | to fix test class failure[change value false to true]
        testOpp.SubGroup__C = WLN_SUBGROUP ;
        testOpp.StageName = CLOSED_LOST ;
        testOpp.G100_Network_Enterprise_Sale__c = false ;
        testOpp.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp.LeadSource = 'Other';
        testOpp.Membership_Begins__c = date.today();
        testOpp.CloseDate = date.today();
        testOpp.Membership_Expires__c = date.today();
        testOpp.Reason_Lost__c = REASON_LOST_DIS;
        insert testOpp;
        
        //update opp
        testOpp.SubGroup__C = 'BX';
        testOpp.StageName = '100 - Closed/Won';
        testOpp.Membership_Type__c = 'BX Individual Annual Membership ($15K)';
        testOpp.LeadSource = 'G100 Companies Staff Referral';
        testOpp.Invoicing_Status__c = 'To Send';
        testOpp.Invoice_Date__c = System.today();
        update testOpp;
        
        test.StopTest();
    }
    //END Himanshu Matharu S-647270
    //Start- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
    @isTest
    public static void testSendEmail(){
        sendEmailOnMultipleOpportunities__c sendEmailDetails = new sendEmailOnMultipleOpportunities__c();
        sendEmailDetails.body__c = 'The following contact has multiple opportunities open with the sub group = Exec Network, please manually update.<BR />Contact Name: {!contactname}<BR />Account Id: {!accountid}<BR />Opportunity Id: {!opportunityid}<BR />';
        sendEmailDetails.Subject__c = 'Multiple Exec Network Opps';
        sendEmailDetails.sendToEmailAddress__c = 'test@test.com';
        sendEmailDetails.senderDisplayName__c = 'Multiple Exec Network Opps';
        sendEmailDetails.processBuilderName__c = 'Name Of Process Builder: Opportunity- Update Exec Network Status of Contact';
        sendEmailDetails.SetupOwnerId = UserInfo.getOrganizationId();
        System.debug('sendEmailDetailsTest1>> '+sendEmailDetails);
        upsert sendEmailDetails;
        System.debug('sendEmailDetailsTest2>> '+sendEmailDetails);
        FFA_TestUtility testUtil = new FFA_TestUtility();
        User testUser = testUtil.newUserSysAdmin(true);
        User testUser2 = testUtil.newUserSysAdmin(true);
        Account testAccount = testUtil.newAccount(true);
        Contact testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
        Contact testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
        Opportunity testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        test.startTest();
        testOpp.Participant_Contact__c = testContact2.Id;
        testOpp.Group2__C = GROUP_G100 ;
        //Start--updated by Komal | C-00279945 | 10/08/2020 | to fix test class failure-false to true
        testOpp.Renewal__c = True ;  
        //END--updated by Komal | C-00279945 | 10/08/2020 | to fix  test class failure 
        testOpp.SubGroup__C = 'Exec Network' ;
        testOpp.StageName = CLOSED_LOST ;
        testOpp.G100_Network_Enterprise_Sale__c = false ;
        testOpp.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp.LeadSource = 'Other';
        testOpp.Membership_Begins__c = date.today();
        testOpp.CloseDate = date.today();
        testOpp.Membership_Expires__c = date.today();
        testOpp.Reason_Lost__c = REASON_LOST_DIS;
        insert testOpp;
        Opportunity testOpp2 = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
        testOpp2.Participant_Contact__c = testContact2.Id;
        testOpp2.Group2__C = GROUP_G100 ;
        testOpp2.Renewal__c = false ; 
        testOpp2.SubGroup__C = 'Exec Network' ;
        testOpp2.StageName = CLOSED_LOST ;
        testOpp2.G100_Network_Enterprise_Sale__c = false ;
        testOpp2.Membership_Type__c = MEMBERSHIP_TYPE ;
        testOpp2.LeadSource = 'Other';
        testOpp2.Membership_Begins__c = date.today();
        testOpp2.CloseDate = date.today();
        testOpp2.Membership_Expires__c = date.today();
        testOpp2.Reason_Lost__c = REASON_LOST_DIS;
        insert testOpp2;
        System.assertEquals(testOpp.Participant_Contact__c, testContact2.Id);
    }
    //End- Added By Saurabh S-666331 |22/07/2020| Send an email when multiple opportunities created
}