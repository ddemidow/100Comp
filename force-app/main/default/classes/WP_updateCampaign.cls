@RestResource(urlMapping='/WP_updateCampaign/*')
global without sharing class WP_updateCampaign{


    @HttpPost
    global static Resp doGet( String campaignId, String mpId,String regId,String email,String badgeName ,
                             String dietary ,String attending,String comments, String companyAffiliation, String siteSelection
                              )
    {
        
        Resp Res = new Resp();

        // item 1
        Contact con = new Contact(Id = mpId,Dietary__c = dietary ,website_user__c = true );
        update con ;
        
        // item 2
        CampaignMember  campMem = new CampaignMember (id = regId);
       
        //campMem.CampaignId =  campaignId;
        //campMem.ContactId = mpId;
        campMem.Badge_Name__c = badgeName;
        campMem.Status = attending;
        campMem.RSVP_Comments__c = comments;
        campMem.RSVP_Submitted_Email__c = email;
        campMem.Company_Affiliation__c = companyAffiliation;
        // item 3
        update campMem;
        res.MemberId = campMem.id;
        
        return res;
        
    }


    global class Resp 
    {
        Public boolean Succses {get ; set ;}
        Public String  ErrorMsg {get ; set ;}
        public Id MemberId = null;
        
        
        public Resp()
        {
            Succses   = true;
        }
         
    }

}