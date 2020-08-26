/*
 * Appirio, Inc
 * Name: AccountOverviewVFController
 * Description: [S-551675]
 * Created Date: 16 April 2018
 * Created By: Kumari Purnima (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 5/31/2018                    Jesse Brown                  C-00229840 removing unnecessary last_n_days: 365 for next steps widget
 * 6/13/2018                    Jesse Brown                  C-00229857 and C-00229860 : correcting query and adding early version of Description in Opportunity widget
 * 7/12/2018                    Jesse Brown                  S-560813 Adding IDs to queries/wrapper to use in outputlinks
 */

public class AccountOverviewVFController{
    public String account{get;set;}
    public List<Event_Members__c> eventAtt{get;set;}
    public List<SObject> lstObj{get;set;}
    public List<Contact> lstContact{get;set;}
    public List<CampaignMember> lstCam{get;set;}
    public List<OpportunityWrapper> lstWrap{get;set;}
    public List<Opportunity> lstPrograms{get;set;} // Added by Jai Gupta | S-582154 | Oct 27th 2018
    public boolean isRole{get;set;}
    public String messasge{get;set;}
    public Opportunity acct{get;set;}
    public String account_Id{get;set;}
    Map<String,User_Permission__c> custdata = User_Permission__c.getAll();

    public AccountOverviewVFController(ApexPages.StandardController controller){
      
        for(UserRole ur : [select Id, Name, ParentRoleId from UserRole WHERE Id=:UserInfo.getUserRoleId()]) {
            if(!custdata.isEmpty()){
                if(!custdata.containsKey(ur.Name)){
                    messasge = Label.Error_Message;
                    isRole = false;
                }
                else{
                    isRole = true;
                }
            }
        }
        
        String accountId = ApexPages.currentPage().getParameters().get('id');
        List<Account> accId = new List<Account>([SELECT Id, Name FROM Account WHERE Id =:accountId LIMIT 1]);
        if(accId.size()>0){
            account = accId[0].Name;
        }
        
        eventAtt = new List<Event_Members__c>();
        lstObj = new List<SObject>();
        lstContact = new List<Contact>();
        lstCam = new List<CampaignMember>();
        lstWrap = new List<OpportunityWrapper>();
        account_Id = accountId;
       
        if(accountId != null && accountId != ''){
            eventAtt = getEventAttendees(accountId);
            lstObj = getActivities(accountId);
            lstContact = getContacts(accountId);
            lstCam = getCampaignMember(accountId);
            lstWrap = getOpportunityWidget(accountId);
            lstPrograms = getProgramsEnrolledIn(accountId); // Added by Jai Gupta | S-582154 | Oct 27th 2018
        }
    }
    
    public PageReference searchValues(){
        
        if(account != null && account != '' && account_Id != null && account_Id != ''){
            
            eventAtt = getEventAttendees(account_Id);
            lstObj = getActivities(account_Id);
            lstContact = getContacts(account_Id);
            lstCam = getCampaignMember(account_Id);
            lstWrap = getOpportunityWidget(account_Id);
            lstPrograms = getProgramsEnrolledIn(account_Id); // Added by Jai Gupta | S-582154 | Oct 27th 2018
        }
        else{
            
            eventAtt = new List<Event_Members__c>();
            lstObj = new List<SObject>();
            lstContact = new List<Contact>();
            lstCam = new List<CampaignMember>();
            lstWrap = new List<OpportunityWrapper>();
            lstPrograms = new List<Opportunity>(); // Added by Jai Gupta | S-582154 | Oct 27th 2018
        }
        
        return null;
    }

// Start by Jai Gupta | S-582154 | Oct 27th 2018
    public List<Opportunity> getProgramsEnrolledIn(String accId ) {
        Set<String> stageIn = new Set<String>{'75 - Member Invoice','100 - Invoice Paid','100 - Closed/Won'};
        Set<String> subgroup1In = new Set<String>{'G100','TC','G100 Network','WLN'};
        Set<String> subgroup2In = new Set<String>{'BX','WLA'};
        Set<String> subgroup3In = new Set<String>{'NGL'};
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = new List<Opportunity>([SELECT Id,SubGroup__c,Participant_Contact__c, Participant_Contact__r.Name,Participant_Contact__r.Title 
            FROM Opportunity 
            WHERE AccountId = :accId 
            AND Group2__c = 'G100 Network'
            AND StageName IN :stageIn
            AND ( 
                (SubGroup__c IN :subgroup1In AND Membership_Expires__c > TODAY)
                OR (Revenue_Recognition_Begins__c = THIS_YEAR AND SubGroup__c IN :subgroup2In)
                OR (Revenue_Recognition_3__c > TODAY AND SubGroup__c IN :subgroup3In)
            )]);

        return oppList ;
    }
// End by Jai Gupta | S-582154 | Oct 27th 2018
    //Return records for Event Attendence Timeline Widget
    public static List<Event_Members__c> getEventAttendees(String accId){
        
        List<Event_Members__c> lstEve = new List<Event_Members__c>();
        Event_Members__c temp = new Event_Members__c();
        Map<String,User_Roles__c> custdataRoles = User_Roles__c.getAll();
        
        if(!custdataRoles.isEmpty()){
            for(Event_Members__c ev: [SELECT Id, Event__r.Name, Event__r.Id, Event__r.Groups__c , Day_1_Role__c, Day_2_Role__c, Day_3_Role__c, Dinner_Role__c, Attending_As_NGL_Only__c,  //JesseB S-560813 Converting to ID to use lookup
                                 Event__r.Start_Date__c, Contact__r.Name, Contact__r.Id FROM Event_Members__c WHERE Contact__r.AccountId =: accId AND (Day_1_Role__c != 'CHRO - Not Attending' OR Day_2_Role__c != 'CHRO - Not Attending' OR Dinner_Role__c != 'CHRO - Not Attending') 
                                 AND Event__r.Start_Date__c = Last_n_Days:365
                                 Order by Event__r.Start_Date__c DESC NULLS LAST]){
                if(custdataRoles.containsKey(ev.Event__r.Groups__c) && custdataRoles.get(ev.Event__r.Groups__c).Event_Attendee__c == true){
                    lstEve.add(ev);
                }
            }
        }
        return lstEve;
    }
    
    //Return records for Next Steps Widget
    public static List<SObject> getActivities(String accId){
        
        set<Id> oppId = new set<Id>();
        oppId.add(accId);
        List<SObject> sobjectList = new List<SObject>();
        Map<String,User_Roles__c> custdataRoles = User_Roles__c.getAll();
        
        for(Opportunity opp: [SELECT Id FROM Opportunity WHERE AccountId =: accId]){
            oppId.add(opp.Id);
        }
        
        if(!custdataRoles.isEmpty()){
            for(Task t: [SELECT Id, Status, Subject, ActivityDate, Owner.UserRole.Name, OwnerId, Owner.Name FROM Task WHERE WhatId IN:oppId AND Status !=: Constants.STATUS_COMPLETED  
                    AND ActivityDate > TODAY 
                    //JesseB commenting out unnecessary query limit C-00229840 AND ActivityDate = Last_n_Days:365 
                    order by ActivityDate DESC NULLS LAST]){
                if(custdataRoles.containsKey(t.Owner.UserRole.Name) && custdataRoles.get(t.Owner.UserRole.Name).Activities__c == true){
                    sobjectList.add(t);
                }    
            }    

            for(Event a : [SELECT Id, ActivityDate, Subject, OwnerId, Owner.UserRole.Name, Owner.Name FROM Event WHERE WhatId IN:oppId AND ActivityDate > TODAY
             //JesseB commenting out unnecessary query limit C-00229840 AND ActivityDate = Last_n_Days:365 
             order by ActivityDate DESC NULLS LAST]){
                if(custdataRoles.containsKey(a.Owner.UserRole.Name) && custdataRoles.get(a.Owner.UserRole.Name).Activities__c == true){
                    sobjectList.add(a);
                }
            }
        }
        
        return sobjectList;
    }
    
    //Return records for Key Contacts Widget
    public static List<Contact> getContacts(String accId){
        
        set<Id> conId = new set<Id>();
        List<Contact> lstCon = new List<Contact>();
        Map<String,User_Roles__c> custdataRoles = User_Roles__c.getAll();
      
        if(!custdataRoles.isEmpty()){  
            for(Opportunity opp: [SELECT Id, Participant_Contact__c, Group2__c FROM Opportunity WHERE AccountId =:accId AND Participant_Contact__c != null]){
                if(custdataRoles.containsKey(opp.Group2__c) && custdataRoles.get(opp.Group2__c).Contacts__c == true){
                    conId.add(opp.Participant_Contact__c);    
                }
            }
        }
        
        for(Contact con: [SELECT Id, Name, Title FROM Contact WHERE Id IN:conId]){
            lstCon.add(con);
        }
        
        return lstCon;
    }
    
    //Return records for Campaign Timeline Widget
    public static List<CampaignMember> getCampaignMember(String accId){
        
        List<CampaignMember> lstMember = new List<CampaignMember>();
        Map<String,User_Roles__c> custdataRoles = User_Roles__c.getAll();
        
        if(!custdataRoles.isEmpty()){
            /** Start by Jai Gupta | S-565584 | Oct 27th 2018 | Added Status in the Query*/
            for(CampaignMember cm : [SELECT Id,CampaignId,Status, Campaign.Name, LastModifiedDate, Contact.Name, Contact.Id, Campaign.Group__c FROM CampaignMember WHERE Contact.AccountId =:accId AND LastModifiedDate = Last_n_Days:365 order by LastModifiedDate DESC NULLS LAST]){ //JesseB S-560813 Converting to ID to use lookup
            /** End by Jai Gupta | S-565584 | Oct 27th 2018 */
                if(custdataRoles.containsKey(cm.Campaign.Group__c) && custdataRoles.get(cm.Campaign.Group__c).CampaignMember__c == true){
                    lstMember.add(cm);
                }
            }
        }
        
        return lstMember;
    }
    
    //Return records of Opportunity Timeline Widget
    public static List<OpportunityWrapper> getOpportunityWidget(String accId){
        
        set<Id> oppId = new set<Id>();
        List<OpportunityWrapper> lstWrapper = new List<OpportunityWrapper>();
        Map<String,User_Roles__c> custdataRoles = User_Roles__c.getAll();
        
        for(Opportunity op: [SELECT Id FROM Opportunity WHERE AccountId=:accId AND Group2__c =: Constants.GROUP_NETWORK]){
            oppId.add(op.Id);
        }
        
        /* JesseB commenting out incorrect logic START
        for(Opportunity opp: [SELECT Id, Name, CreatedDate, Participant_Contact__r.Name FROM Opportunity WHERE Id IN:oppId AND CreatedDate = Last_n_Days:365 ORDER BY CreatedDate DESC]){
            lstWrapper.add(new OpportunityWrapper(opp.Name, opp.CreatedDate, 'Changed Participant Name to ' +opp.Participant_Contact__r.Name));
        }
        JesseB commenting out incorrect logic END */

        //JesseB new replacement logic Note for future: could get OldValue, find Name from ID, and print "Changed name from X to Y" START
        for (OpportunityFieldHistory ofh :[SELECT Id, CreatedDate, OpportunityId, Opportunity.Name, Opportunity.Participant_Contact__r.Name, Field, OldValue, NewValue FROM OpportunityFieldHistory WHERE OpportunityId IN:oppId AND CreatedDate = Last_n_Days:365 AND Field = 'Participant_Contact__c' ]){
            system.debug('JJJ name '+ofh);
            if (!String.valueOf(ofh.NewValue).startsWith('00') && ofh.Field == 'Participant_Contact__c') {
                lstWrapper.add(new OpportunityWrapper(ofh.Opportunity.Name, ofh.CreatedDate, 'Changed Participant Name to ' +ofh.NewValue, ofh.Opportunity.Id )); //JesseB S-560813 Updating to include ID for links
            //} else if (ofh.Field == 'Description__c' && ofh.newValue != null){
            //    lstWrapper.add(new OpportunityWrapper(ofh.Opportunity.Name, ofh.CreatedDate, 'Changed Description to ' +ofh.NewValue ));
            }
        }
        //JesseB new replacement logic END
/** Start by Jai Gupta | S-565584 | Oct 27th 2018 */
        /*for (OpportunityFieldHistory ofh : [SELECT Id, CreatedDate, CreatedBy.Name, OpportunityId, Opportunity.Name, Field, OldValue, NewValue FROM OpportunityFieldHistory WHERE OpportunityId IN:oppId AND CreatedDate = Last_n_Days:365 AND Field = 'Description__c']){
            system.debug('JJJ desc ' +ofh);
            lstWrapper.add(new OpportunityWrapper(ofh.Opportunity.Name, ofh.CreatedDate, ofh.CreatedBy.Name +' changed Description field', ofh.Opportunity.Id)); //JesseB S-560813 Updating to include ID for links
            lstWrapper.add(new OpportunityWrapper(oh.Opportunity__r.Name, oh.CreatedDate, oh.CreatedBy.Name +' changed Description field to '+oh.New_Value__c, oh.Opportunity__c)); //JesseB S-560813 Updating to include ID for links
        }*/
        // Added Edited_By__c and Edited_Date__c by Jai Gupta | S-589952 - Jai Gupta - Nov 15,2018
        for (OpportunityHistory__c oh : [SELECT Id, Edited_Date__c, Edited_By__r.Name,CreatedDate, CreatedBy.Name, Opportunity__c, Opportunity__r.Name, Name, Old_Value__c, New_Value__c FROM OpportunityHistory__c WHERE Opportunity__c IN:oppId AND Edited_Date__c = Last_n_Days:365 AND Field_Api_Name__c = 'Description__c']){
            //lstWrapper.add(new OpportunityWrapper(oh.Opportunity__r.Name, oh.CreatedDate, 'Description changed: '+oh.New_Value__c, oh.Opportunity__c)); //JesseB S-560813 Updating to include ID for links
            lstWrapper.add(new OpportunityWrapper(oh.Opportunity__r.Name, oh.Edited_Date__c, 'Description changed: '+oh.New_Value__c, oh.Opportunity__c)); //JesseB S-560813 Updating to include ID for links
            
        }
/** End by Jai Gupta | S-565584 | Oct 27th 2018 */
        /* JesseB S-560813 Removing Stage Changes from widget START
        for(OpportunityHistory oh : [SELECT Id,CreatedDate,StageName, Opportunity.Description__c, Opportunity.Name
                                     FROM OpportunityHistory WHERE OpportunityId IN:oppId AND CreatedDate = Last_n_Days:365 order by CreatedDate DESC NULLS LAST]){
            
            lstWrapper.add(new OpportunityWrapper(oh.Opportunity.Name, oh.CreatedDate, 'Changed Stage to ' +oh.StageName));
            //lstWrapper.add(new OpportunityWrapper(oh.Opportunity.Name, oh.CreatedDate, 'Changed Description to '+oh.Opportunity.Description__c));
        }
        JesseB S-560813 Removing Stage Changes from widget END
        */

        
        if(!custDataRoles.isEmpty()){
            for(Task ts : [SELECT Id, Subject, CreatedDate, Owner.UserRole.Name, What.Name FROM Task WHERE WhatId IN:oppId AND Status =:Constants.STATUS_COMPLETED AND CreatedDate = Last_n_Days:365]){
                if(custDataRoles.containsKey(ts.Owner.UserRole.Name) && custDataRoles.get(ts.Owner.UserRole.Name).Opportunities__c == true){
                    lstWrapper.add(new OpportunityWrapper(ts.What.Name, ts.CreatedDate, ts.Subject, ts.What.Id)); //JesseB S-560813 Updating to include ID for links
                }
            }
        }
        
        return lstWrapper;
    }
    
    public PageReference goBack(){
    
        String accountId = ApexPages.currentPage().getParameters().get('id');
        if(accountId != null && accountId != ''){
            PageReference rPage = new PageReference('/'+accountId);
            rPage.setRedirect(true);
            return rPage;
        }
        else{
            PageReference rPage = new PageReference('/home/home.jsp');
            rPage.setRedirect(true);
            return rPage;
        }
    }
    
    public class OpportunityWrapper{
        public String oppName{get;set;}
        public Datetime oppDate{get;set;}
        Public String oppString{get;set;}
        Public Id oppId{get;set;} //JesseB S-560813 adding Ids to wrapper for links
        
        public OpportunityWrapper(String n, Datetime dt, String op, Id opId){
            oppName = n;
            oppDate = dt;
            oppString = op;
            oppId = opId; //JesseB S-560813 Adding IDs to wrapper for links
        }
    }
}