/***************************************************************************************************
Name       : OppOnLayoutViewListener
Created    : S-438464 - Hemant [1/10/2017] 
VF Page    : OppOnLayoutView
Description: Update the contact fields from the contact roles on the opportunity view 
***************************************************************************************************/
public with sharing class OppOnLayoutViewListener {
  
  public Opportunity opp;
  
  public OppOnLayoutViewListener(ApexPages.StandardController stdController){
    opp = (Opportunity)stdController.getRecord();        
  }
  
  public void executeOnLayoutView(){
    OppOnLayoutViewListener.updateContactFuture(opp.Id); 
  }
  
  @future public static void updateContactFuture(Id oppId){
    
    Opportunity opp;
    
    for(Opportunity oppty : [SELECT Id, SubGroup__c, StageName, Reason_Lost__c,
                      (Select Id, OpportunityId, ContactId, Role, IsPrimary From OpportunityContactRoles order by IsPrimary)
                      FROM Opportunity 
                      WHERE Id = :oppId
                      AND SubGroup__c IN: Constants.SUBGROUP_FIELDNAME_MAP.keySet()
                      AND StageName != null]){
      opp = oppty;  
    }
    
    if(opp == null){
      return;
    }
    
    List<OpportunityContactRole> oppContRolesLst = new List<OpportunityContactRole>();
    Set<Id> contIdSet = new Set<Id>();
    
    for(OpportunityContactRole ocr : opp.OpportunityContactRoles){
      oppContRolesLst.add(ocr);
      contIdSet.add(ocr.ContactId);
    }
    
    if(contIdSet.size() > 0){
      Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id, NGL_Status__c, Vanguard_Status__c, WLA_Status__c 
                                        From Contact
                                        Where Id IN: contIdSet]);
      
      Map<Id,Sobject> contactMapToUpdate = new Map<Id,Sobject>();
      
      String fldNameToUpdate = Constants.SUBGROUP_FIELDNAME_MAP.get(opp.SubGroup__c);
      
      for(OpportunityContactRole oppContRole : oppContRolesLst){
        
		    //Sobject cont = new Contact(Id = oppContRole.ContactId);
		    Sobject cont = contactMap.get(oppContRole.ContactId);
		    
		    String fldStatusVal = (String) cont.get(fldNameToUpdate);
		    
		    if(fldStatusVal == null || (fldStatusVal != null && !fldStatusVal.startsWithIgnoreCase(Constants.ROLE_MEMBER))){
		    
			    //Stage not equal to 00 or 100
	        if(!Constants.STAGE_SET_00.contains(opp.StageName) && !Constants.STAGE_SET_100.contains(opp.StageName)){
	            
		        if(oppContRole.IsPrimary || String.isBlank(oppContRole.Role) || oppContRole.Role == Constants.ROLE_MEMBER || oppContRole.Role == Constants.ROLE_ADVISOR){
		          cont.put(fldNameToUpdate, Constants.NGL_STATUS_PROSPECT_CURRENT_OPP);
		          contactMapToUpdate.put(oppContRole.ContactId, cont);
		        }
		        else if(oppContRole.Role == Constants.ROLE_PARTNER || oppContRole.Role == Constants.ROLE_SPONSOR || oppContRole.Role == Constants.ROLE_DECISION_MAKER || oppContRole.Role == Constants.ROLE_INFLUENCER || oppContRole.Role == Constants.ROLE_MANAGER){
		          cont.put(fldNameToUpdate, Constants.NGL_STATUS_PROSPECT_SPONSOR_CURRENT_OPP);
		          contactMapToUpdate.put(oppContRole.ContactId, cont);
		        }
	        }
	        
	        //Stage changes to 00
	        else if(Constants.STAGE_SET_00.contains(opp.StageName)){
	        
	          if(Constants.REASON_LOST_SET_00_NON_BLANK_ROLES.contains(opp.Reason_Lost__c)){
	          
	            if(oppContRole.IsPrimary && (String.isBlank(oppContRole.Role) || oppContRole.Role == Constants.ROLE_ADVISOR || oppContRole.Role == Constants.ROLE_MEMBER)){
	              
	              cont.put(fldNameToUpdate, Constants.NGL_STATUS_TARGET_POTENTIAL_OPP);
	              contactMapToUpdate.put(oppContRole.ContactId, cont);
	            }else if(oppContRole.Role == Constants.ROLE_PARTNER || oppContRole.Role == Constants.ROLE_SPONSOR || oppContRole.Role == Constants.ROLE_OTHER || oppContRole.Role == Constants.ROLE_DECISION_MAKER || oppContRole.Role == Constants.ROLE_INFLUENCER || oppContRole.Role == Constants.ROLE_MANAGER){
	              
	              cont.put(fldNameToUpdate, Constants.NGL_STATUS_TARGET_SPONSOR_POTENTIAL_OPP);
	              contactMapToUpdate.put(oppContRole.ContactId, cont);
	            }
	          }
	          else if (Constants.REASON_LOST_SET_00_BLANK_ROLES.contains(opp.Reason_Lost__c)){cont.put(fldNameToUpdate, null);
	            contactMapToUpdate.put(oppContRole.ContactId, cont);
	          }
	        }
	        //Stage changes to 100
	        else if(Constants.STAGE_SET_100.contains(opp.StageName)){
	          
	          if(contactMap.containsKey(oppContRole.ContactId) && String.isNotBlank(fldStatusVal) && !Constants.NGL_STATUS_SET_FOR_BLANK_ROLES.contains(fldStatusVal)){
	            
	            cont.put(fldNameToUpdate, null);
	            contactMapToUpdate.put(oppContRole.ContactId, cont);
	          }}}//end if  
      }//end for
      
      //update contacts
      if(contactMapToUpdate.size() > 0){
        update contactMapToUpdate.values();
      }                                     
    }
  }
}