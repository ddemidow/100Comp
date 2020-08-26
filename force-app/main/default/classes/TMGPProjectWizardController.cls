/****************************************************************
Name : TMGPProjectWizardController
Created Date : 2/18/15
Created by : Reena Acharya    
Description : Class for TMGPProjectWizard component.
****************************************************************/

global class TMGPProjectWizardController {

//Properties
public Id milestoneId {get;set;}
public Milestone1_Project__c milestone {get;set;}
public List<Milestone1_Milestone__c> participants ;//{get;set;}
public string dataCollection {get;set;}
public string draftAssessment{get;set;}
public string finalAssessment{get;set;}
public string draftCoaching {get;set;}
public string Debrief {get;set;}
public string projectLink {get;set;}


public List<Milestone1_Milestone__c> getparticipants(){
    loadData();     
    return participants ;
}
public TMG_Category__c category {get;set;}

 
// Data Collection  : Query TMG_Category__c records where TMG_Project__c = Milestone1_Project__c.Id and record type = “Data Collection" and show its due date (Due_Date__c) here. 
//Draft Assessment , Final Assessment, Draft Coaching Plan :
//          Query TMG_Category__c records where TMG_Project__c = Milestone1_Project__c.Id and record type = “Written Deliverables" and show its Draft_Assessment__c ,Final_Assessment__c and Draft_Coaching_Plan__c respectively.
//Debrief : Query TMG_Category__c records where TMG_Project__c = Milestone1_Project__c.Id and record type = "Feedback" or "Manager Debriefs" and show its due date (Due_Date__c) here (Which ever is earliest).        
// Pull all related Deliverable records to the project where the Assessed Executive field is not blank. Show the “Assessed Executive” and the “Interview Date” fields in Participants related section

public void loadData(){
        milestone = new Milestone1_Project__c ();
        List<Milestone1_Project__c> milestones = new List<Milestone1_Project__c >([Select id ,Name,Account__c,Account__r.Name, Client__c ,Client__r.Name, Kickoff__c,Deadline__c,Description__c,Board_Dates__c, Project_Wizard__c ,Project_Wizard__r.Name
                      from Milestone1_Project__c where id =: milestoneId]);
        if(milestones.size() > 0)
            milestone = milestones.get(0);

        participants = new List<Milestone1_Milestone__c>([Select id , Interview_Date__c ,Assessed_Executive__c,Assessed_Executive__r.Name from Milestone1_Milestone__c where Assessed_Executive__c != null and Project__c =: milestoneId and RecordType.Name = 'Data Collection']);
       
       List<TMG_Category__c> categories = new List<TMG_Category__c>([Select id,Due_Date__c from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name = 'Data Collection' and Due_Date__c != null order by Due_Date__c asc limit 1]);                 
       if(categories.size() > 0)
           category.Due_Date__c = categories.get(0).Due_Date__c;
       
       categories = new List<TMG_Category__c>([Select id ,Draft_Assessment__c ,Final_Assessment__c ,Draft_Coaching_Plan__c 
                   from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name = 'Written Deliverables' and Draft_Assessment__c  != null order by Draft_Assessment__c asc limit 1]);                 
       if(categories.size() > 0){
           category.Draft_Assessment__c = categories.get(0).Draft_Assessment__c;
           category.Final_Assessment__c = categories.get(0).Final_Assessment__c;
           category.Draft_Coaching_Plan__c= categories.get(0).Draft_Coaching_Plan__c ;
       }
       categories = new List<TMG_Category__c>([Select id,Due_Date__c from TMG_Category__c where TMG_Project__c =: milestoneId and (recordType.Name ='Feedback' or recordType.Name = 'Manager Debriefs') order by Due_Date__c asc limit 1]);                 
       if(categories.size() > 0)
           category.Kick_Off__c = categories.get(0).Due_Date__c ;
           
       projectLink = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ milestoneId ;
}
        
//Constructor       
public TMGPProjectWizardController() {
    category = new TMG_Category__c();
     system.debug('===milestoneId  ==='+ milestoneId  );
    if(milestoneId  != null){   
        loadData();
    }
}


}