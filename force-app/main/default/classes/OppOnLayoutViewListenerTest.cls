/***************************************************************************************************
Name       : OppOnLayoutViewListenerTest
Created    : S-438464 - Hemant [1/10/2017] 
Description: Test class for the class - OppOnLayoutViewListener  
***************************************************************************************************/
@isTest
private class OppOnLayoutViewListenerTest{

  private static Contact testContact1, testContact2;
  private static Opportunity testOpp;
  
  static{
    FFA_TestUtility testUtil = new FFA_TestUtility();
    User testUser = testUtil.newUserSysAdmin(true);
    User testUser2 = testUtil.newUserSysAdmin(true);
    Account testAccount = testUtil.newAccount(true);
    testContact1 = testUtil.newResource(true, testAccount.Id, testUser.Id);
    testContact2 = testUtil.newResource(true, testAccount.Id, testUser2.Id);
    
    testOpp = testUtil.newOpportunity(false, testAccount.Id, testContact1.Id);
    testOpp.Participant_Contact__c = testContact2.Id;
    //START -- Added by Shivani for S-637724 on 02/09/2019
    testOpp.SubGroup__c = 'NGL';	
    //END -- Added by Shivani for S-637724 on 02/09/2019
    insert testOpp;
  }
  
  public static testMethod void OppOnLayoutViewListener_Test() {
    
    List<OpportunityContactRole> testOppContactRole = new List<OpportunityContactRole>();
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id));
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id, Role = Constants.ROLE_PARTNER));
    
    ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
    OppOnLayoutViewListener OppOnLVLObj = new OppOnLayoutViewListener(sc);
    OppOnLVLObj.executeOnLayoutView();
    
    Test.startTest();
    OppOnLayoutViewListener.updateContactFuture(testOpp.Id);
    Test.stopTest();
  }
  
  public static testMethod void OppOnLayoutViewListener1_Test() {
    
    testOpp.StageName = '00 - Closed/Lost';
    testOpp.Reason_Lost__c = 'Lost to Competitor';
    update testOpp;
    
    List<OpportunityContactRole> testOppContactRole = new List<OpportunityContactRole>();
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id));
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id, Role = Constants.ROLE_PARTNER));
    
    ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
    OppOnLayoutViewListener OppOnLVLObj = new OppOnLayoutViewListener(sc);
    
    Test.startTest();
    OppOnLayoutViewListener.updateContactFuture(testOpp.Id);
    Test.stopTest();
  } 
  
  public static testMethod void OppOnLayoutViewListener2_Test() {
    
    testOpp.StageName = '00 - Closed/Lost';
    testOpp.Reason_Lost__c = 'Disqualified';
    update testOpp;
    
    List<OpportunityContactRole> testOppContactRole = new List<OpportunityContactRole>();
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id));
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id, Role = Constants.ROLE_PARTNER));
    
    ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
    OppOnLayoutViewListener OppOnLVLObj = new OppOnLayoutViewListener(sc);
    
    Test.startTest();
    OppOnLayoutViewListener.updateContactFuture(testOpp.Id);
    Test.stopTest();
  } 
  
  public static testMethod void OppOnLayoutViewListener3_Test() {
    
    testOpp.StageName = '100 - Signed Contract';
    update testOpp;
    
    testContact1.NGL_Status__c = 'Member: HR Sponsor';
    update testContact1;
    
    List<OpportunityContactRole> testOppContactRole = new List<OpportunityContactRole>();
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpp.Id, ContactId = testContact1.Id));
    //START -- Modified by Shivani for S-637724 on 02/09/2019
    testOppContactRole.add(new OpportunityContactRole(IsPrimary = false, OpportunityId = testOpp.Id, ContactId = testContact1.Id, Role = Constants.ROLE_PARTNER));
    //END -- Modified by Shivani for S-637724 on 02/09/2019
    
    ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
    OppOnLayoutViewListener OppOnLVLObj = new OppOnLayoutViewListener(sc);
    
    Test.startTest();
    OppOnLayoutViewListener.updateContactFuture(testOpp.Id);
    Test.stopTest();
  }   
    
}