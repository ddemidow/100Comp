/*******************************************************************************
* @Class       : PopulateMiscAdjustAmountController
* @author      : Hemlata Mandowara (Appirio JDC)
* @date        : Aug 2014
* @description : Controller for PopulateMiscAdjustAmount, used to calculate and updae Miscelleanus Adjust Amount.
*******************************************************************************/
public without sharing class PopulateMiscAdjustAmountController {
    // Apexpages.Standardcontroller stdController;
    String projectID;
    pse__Proj__c projRec;
    Public pse__Milestone__c milestone{get;set;} // To get Milestone CutOff Date  (Start Date)
    Public pse__Timecard__c timecard{get;set;} // To get Timecard CutOff Date    (End Date)
    public boolean projectAligibility{get;set;}
    // public Date MileStone_CutOff_Date {get;set;}
    //public Date Timecard_CutOff_Date {get;set;}
    public pse__Miscellaneous_Adjustment__c newPMAObj {get;set;} //PMA project Miscellaneous Adjustment     
    public PopulateMiscAdjustAmountController(){
        milestone = new pse__Milestone__c (pse__Actual_Date__c =null);
        timecard = new pse__Timecard__c (pse__End_Date__c =null);
        projRec = new pse__Proj__c();
        initProject();
    }
    
    private void initProject() {
        newPMAObj = new pse__Miscellaneous_Adjustment__c(); 
        projectID = ApexPages.currentPage().getParameters().get('id');
        // projectID = stdController.getId();
        successMessage = false ;
        if(projectID != null) {
            //  ,pse__Billing_Type__c,pse__Start_Date__c,Reporting_End_Date__c,CurrencyIsoCode // added by jyotirmaya  Rath 10-27-2015 S-344890
            for (pse__Proj__c proj : [select Id,Apply_Indirect_Expense__c,Misc_Adjustment_Amount__c,Indirect_Expense_Rate__c
                                      ,pse__Billing_Type__c,pse__Start_Date__c,Reporting_End_Date__c,CurrencyIsoCode 
                                      from pse__Proj__c  where id = :projectID]) {
                                          projRec = proj;
                                      }          
        }   
        if(projRec != null && projRec.Apply_Indirect_Expense__c == true ){
            projectAligibility = true ;
        }
        else{
            projectAligibility = false ;
        }
    }
  /* // Commented By Jyotirmaya   S-344890
    public Pagereference updateMiscAmount() {
        Decimal milestoneAmount = 0.0;
        Decimal timeCardAmount = 0.0;
        Decimal totalAmount = 0.0; 
        if (projectID != null && projRec != null) {
            if (projRec.Apply_Indirect_Expense__c == true && projRec.Indirect_Expense_Rate__c != null) {
                if (milestone.pse__Actual_Date__c != null) {
                    for (pse__Milestone__c milestoneObj : [select Id,pse__Actual_Date__c,pse__Milestone_Amount__c,pse__Project__c,pse__Eligible_for_Billing__c from pse__Milestone__c where pse__Project__c = :projectID
                                                           and pse__Eligible_for_Billing__c = 'Yes' and pse__Actual_Date__c <= :milestone.pse__Actual_Date__c]) {
                                                               system.debug('milestoneObj ***'+milestoneObj );
                                                               if (milestoneObj.pse__Milestone_Amount__c != null) {                                                                    
                                                                   milestoneAmount = milestoneAmount + milestoneObj.pse__Milestone_Amount__c;
                                                               }   
                                                           }                                               
                }
                if (timecard.pse__End_Date__c != null) {
                    for (pse__Timecard__c timeCardObj : [select Id,pse__End_Date__c,pse__Total_Billable_Amount__c,pse__Project__c,pse__Eligible_for_Billing__c from pse__Timecard__c where pse__Project__c = :projectID
                                                         and pse__Eligible_for_Billing__c = 'Yes' and pse__End_Date__c <= :timecard.pse__End_Date__c]) {
                                                             system.debug('timeCardObj ***'+timeCardObj );
                                                             if (timeCardObj.pse__Total_Billable_Amount__c != null) {                                                                   
                                                                 timeCardAmount = timeCardAmount + timeCardObj.pse__Total_Billable_Amount__c;
                                                             }   
                                                         }   // for                                          
                }   
                totalAmount = (milestoneAmount + timeCardAmount) * (projRec.Indirect_Expense_Rate__c/100);
                projRec.Misc_Adjustment_Amount__c = totalAmount;
                update projRec;
                
            }
        }
        return null;
    }
*/
    // Added byjyotirmaya Rath 10-27-2015 (S-344890)
    public void  insertProjMiscellaneousAdjustment(){
        System.debug('projRec jr' + projRec);
        if (projRec.Apply_Indirect_Expense__c == true && projRec.Indirect_Expense_Rate__c != null && projRec.Indirect_Expense_Rate__c != 0) {
            
            double totalAmount ;
            newPMAObj.Name = 'Indirect Expenses' ; 
            newPMAObj.pse__Project__c = projRec.id ; 
            newPMAObj.pse__Transaction_Category__c = 'Indirect Expenses' ; 
            newPMAObj.ffpsai__MiscAdjGLACode__c = 'a1dF0000000BXfc' ; 
            newPMAObj.ffpsai__BalancingGLACode__c = 'a1dF0000000BXeK' ; 
            newPMAObj.ffpsai__ServicesProduct__c = '01tF00000031iRa' ; 
            newPMAObj.pse__Status__c = 'Approved' ; 
            // newPMAObj.pse__Amount__c = 1 ; 
            newPMAObj.CurrencyIsoCode = projRec.CurrencyIsoCode; 
            if(projRec.pse__Billing_Type__c == 'Time and Materials'){
                totalAmount = 0;
                for(pse__Timecard__c TCHeader: [SELECT Id,pse__Total_Billable_Amount__c FROM pse__Timecard__c
                                                WHERE pse__Project__c =: projRec.id AND
                                                pse__Start_Date__c >=: milestone.pse__Actual_Date__c AND                                    
                                                pse__End_Date__c <=: timecard.pse__End_Date__c AND
                                                pse__Billable__c = TRUE AND
                                                pse__Exclude_from_Billing__c = FALSE AND 
                                                pse__Billed__c = false ] ){ 
                                                    totalAmount = totalAmount + TCHeader.pse__Total_Billable_Amount__c ;                                         
                                                }                 
                try{
                    if(totalAmount != 0){
                        newPMAObj.pse__Amount__c = (projRec.Indirect_Expense_Rate__c/100) * totalAmount ;
                        Insert newPMAObj;
                        successMessage = true ;
                    }    
                }
                catch(Exception e){
                    
                }                
            }
            else if(projRec.pse__Billing_Type__c == 'Fixed Price'){
                totalAmount = 0;
                for(pse__Milestone__c projMilestone: [SELECT Id,pse__Milestone_Amount__c FROM pse__Milestone__c
                                          WHERE pse__Project__c =:projRec.id AND  pse__Billed__c = FALSE 
                                          //AND pse__Actual_Date__c <=: milestone.pse__Actual_Date__c 
                                          AND pse__Actual_Date__c >=: milestone.pse__Actual_Date__c
                                          AND pse__Actual_Date__c <=: timecard.pse__End_Date__c] ){                                              
                                              totalAmount = totalAmount + projMilestone.pse__Milestone_Amount__c ;   
                                              System.debug('projMilestone' + projMilestone);                             
                                          }                
                try{
                    if(totalAmount != 0){
                        newPMAObj.pse__Amount__c = (projRec.Indirect_Expense_Rate__c/100) * totalAmount  ;
                        Insert newPMAObj;
                        successMessage = true ;
                    }
                }
                catch(Exception e){
                    system.debug('Error' + e.getmessage());                    
                }                
            }
            if(!successMessage){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'No record found plese refine your search criteria'));
            }
        }
        
        //   return null; 
    }
    public  boolean successMessage {get;set;}
    // Jyotirmaya Code Ended S-344890
}