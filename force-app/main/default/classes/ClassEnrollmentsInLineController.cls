/***************************************
Author        : Appirio India [Hitesh Pareek]
Date          : Feb 20, 2017
Purpose       : S-467680
***************************************/
public with sharing class ClassEnrollmentsInLineController {
    public List<Class_Enrollment__c> enrollments {get; set;}
    public string newEnrollURL {get;set;}
    public string enrollmentToBedeleted {get;set;}
    public SFDC_Class__c classRecord {get;set;}
    public ClassEnrollmentsInLineController(ApexPages.StandardController sc){
        if(!Test.isRunningTest())
            sc.addFields(new List<String>{'name'});
        classRecord = (SFDC_Class__c )sc.getRecord();
        if(classRecord != null){
        enrollments = new List<Class_Enrollment__c>();
        for(Class_Enrollment__c enrollment :[select Name,Class__c,Contact__r.Name,Certificate_Issued__c,Certified__c,Status__c,Plaque_Issued__c,Test_Result__c,Other__c,Class_Type__c 
                                                    from Class_Enrollment__c 
                                                        where Class__c =:classRecord.id]){
                enrollments.add(enrollment );
           }            
            newEnrollURL = URL.getSalesforceBaseUrl().toExternalForm()+'/a4w/e?CF00NF0000008uppY='+classRecord.name+'&CF00NF0000008uppY_lkid='+classRecord.id+'&retURL=/'+classRecord.id+'&save_new_url=/'+classRecord.id;
        }
    }
        
    
    public PageReference SaveEnrollments(){
        if(enrollments != null && !enrollments.isempty()){
            update enrollments;
        }
        return null;
    }       
    
    public void deleteEnrollmentRecord(){        
        if(enrollmentToBedeleted != null){
            delete new List<Class_Enrollment__c>{new Class_Enrollment__c(id=enrollmentToBedeleted)};            
        }                
    }        
}