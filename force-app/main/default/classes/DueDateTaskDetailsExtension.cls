/*********************************************************************************
Name : Jyotirmaya Rath
Created By : Appirio  
Created Date : 03 Nov 2015
Purpose : VF page Controller to display all Due date task
 *********************************************************************************/
public without sharing class DueDateTaskDetailsExtension {
    
    // Page Variables
    public Milestone1_Task__c dueTask{get;set;}
    public String taskId{get;set;}
    public Boolean showQuestion{get;set;}
    public boolean ansNo{get;set;}
    public Date taskDueDate{get;set;}
    public string comments {get;set;}
    public String stage{get;set;}
    public List<Selectoption> taskStage {get;set;}
    // Controller of the class
    Public DueDateTaskDetailsExtension(ApexPages.StandardController con){
        init();
    }
    
    //initial all Page Variables
    private void init(){
        showQuestion = true ;
        ansNo = false ;
        taskId = ApexPages.currentPage().getParameters().get('Id');  
        taskStage = new List<SelectOption>();

        for(Schema.PicklistEntry ple : Milestone1_Task__c.Task_Stage__c.getDescribe().getPicklistValues()){
            taskStage.add(new Selectoption(ple.getLabel(),ple.getLabel()));        
        }
        if(!String.isBlank(taskId)){
          //S-369108 added harendra recordType.name in query
            for(Milestone1_Task__c t: [SELECT First_Chair_User__c, id,Name,recordType.name, Assigned_To__c,Assigned_To__r.name,Project_Name__c,
                                       Scheduled_Date__c,Task_Stage__c,Description__c,Due_Date__c 
                                       FROM Milestone1_Task__c WHERE id=:taskId ]){
                dueTask = t;     
            }
        }
    }
     
    // If Tassk Is completed
    public pageReference  answerYes(){
        String ans = ApexPages.currentPage().getParameters().get('ans'); 
        if(ans.toLowerCase() == 'yes'){
            system.debug(' yes');
            try{
                dueTask.Task_Stage__c = 'Complete';
                update dueTask;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,'Thank You'));
                showQuestion = false ;
            }
            catch(Exception e){
                System.debug('Failed To update');
            }
        }    
        Else  if(ans.toLowerCase() == 'no'){
            showQuestion = true ;
        }
        return null;
    }
    
 
    // submit Task Is not completed
    public pageReference submitTask(){
        try{    

            update dueTask ;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm,'Thank You'));
            showQuestion = false ;
            }
        catch(Exception e){
            System.debug('Failed To update->'+e.getMessage());
        }        
        return null;
    }
}