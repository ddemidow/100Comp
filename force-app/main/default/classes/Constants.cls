/**
 *  Purpose         :   This class is used for holding org wide constant values in literals.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   02/29/2016
 *
 *  Current Version :   V_1.0
 *
 *  Revision Log    :   V_1.0 - Created - S-374199
 **/
public class Constants {
    
    //Constants variable for User Sobject 
    public static final String USER_NAME_COURTNEY_HEHRE = 'Courtney Hehre';
    
    //Constants variable for Opprotunity Sobject 
    public static final String OPPROTUNITY_SUBGROUP_G100 = 'G100';
    public static final String OPPROTUNITY_SUBGROUP_NGL = 'NGL';
    public static final String OPPROTUNITY_SUBGROUP_NEXT = 'Next';
    public static final String OPPROTUNITY_SUBGROUP_TC = 'TC';
    
    //Start Story# S-408902 added email template name
    public static final String REMINDER_TEMPLATE_NAME = 'Resource_Planner_Reminder';
    //End Story# S-408902
    
    //START S-438464 Hemant [1/9/2017]
    //NGL Status values
    public static final String NGL_STATUS_TARGET_POTENTIAL_OPP = 'Target (potential opp)';
    public static final String NGL_STATUS_TARGET_SPONSOR_POTENTIAL_OPP = 'Target - Sponsor (Potential Opp)';
    
    public static final String NGL_STATUS_PROSPECT_CURRENT_OPP = 'Prospect (Current Opp)';
    public static final String NGL_STATUS_PROSPECT_SPONSOR_CURRENT_OPP = 'Prospect - Sponsor (Current Opp)';
    
    //contact role values
    public static final String ROLE_MEMBER = 'Member';
    public static final String ROLE_ADVISOR = 'Advisor';
    public static final String ROLE_PARTNER = 'Partner';
    public static final String ROLE_SPONSOR = 'Sponsor';
    public static final String ROLE_OTHER = 'Other';
    public static final String ROLE_DECISION_MAKER = 'Decision Maker';
    public static final String ROLE_INFLUENCER = 'Influencer';
    public static final String ROLE_MANAGER = 'Manager';
    
    
    public static final Set<String> STAGE_SET_00 = new Set<String>{'00 - Hard No', '00 - Closed/Lost'};
    public static final Set<String> STAGE_SET_100 = new Set<String>{'100 - Invoice Paid', '100 - Signed Contract'};
    
    public static final Set<String> REASON_LOST_SET_00_NON_BLANK_ROLES = new Set<String>{'Budgetary Restrictions', 'Lost to Competitor', 'No Reason Given', 
        'No response', 'Schedule Conflicts'};
    public static final Set<String> REASON_LOST_SET_00_BLANK_ROLES = new Set<String>{'Disqualified', 'Inherited Membership', 'Value Proposition', 'Job change', 
        'Organizational or Structural Change'};    
    public static final Set<String> NGL_STATUS_SET_FOR_BLANK_ROLES = new Set<String>{'Member: Stakeholder', 'Member: HR Sponsor', 'Member: CEO Active Sponsor', 
        'Member: Secondary Sponsor', 'Member: Manager'};
    public static final map<String, String> SUBGROUP_FIELDNAME_MAP = new map<String, String>{'NGL'=> 'NGL_Status__c', 'WLA' => 'WLA_Status__c', 'Vanguard' => 'Vanguard_Status__c'};    
    //END S-438464
    
    //START : Added by Purnima for Story S-551675
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String GROUP_NETWORK = 'G100 Network';
    //END : Added by Purnima for Story S-551675
}