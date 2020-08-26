@isTest
private class WPCampaignTest{
  static testMethod void WPCampaignTestWebServices(){     

    // Set up the Account record.
    Account a = new Account(Name='Test Account');
    insert a;

    Contact Con = new contact(Accountid = a.id , lastname = 'test name ' ,firstname = 'test name' , email = 'test@testing.abc');
    insert con;
    
    Campaign camp = new Campaign(IsActive = true , name = 'test');
    insert camp;
     
     WP_insertCampaign.resp r =  WP_insertCampaign.doGet( camp.id,  Con.id,   'test@testtest.test', 'Jane Member','Vegetarian', 'Yes', 'commments','test@testtest.test','test@testtest.test'); 
     WP_updateCampaign.doGet( camp.id,  Con.id,r.MemberId   , 'test@testtest.test', 'Jane Member','Vegetarian', 'Yes', 'commments','test@testtest.test', 'test@testtest.test' );
  }
}