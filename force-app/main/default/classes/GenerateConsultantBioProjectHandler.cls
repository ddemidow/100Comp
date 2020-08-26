/*************************************************************************
Name : GenerateConsultantBioProjectHandler 
Created By : Mohit Batwada
Created Date: 19th Feb, 2015
Descritpion: Handler is used to generate a consultant bio project line item  
*************************************************************************/
public with sharing class GenerateConsultantBioProjectHandler {
    
    public static void genrateConBioRecords(List<pse__Assignment__c> lstPSEAssignment) { 
        
        List<Id> lstAssignmentIds = new List<Id>();
        List <Consultant_Bio_Project_Item__c> consultantBPILst = new List <Consultant_Bio_Project_Item__c> ();
        Map<Id, List<Id>> mapConsultantBio = new Map<Id, List<Id>>();
        
        // Get the assignment records ids
        for(pse__Assignment__c assignment : lstPSEAssignment) {
        System.debug('===assignment.Eligible_for_Bio__c==='+assignment.Eligible_for_Bio__c);
            if(assignment.Eligible_for_Bio__c == true) {
                lstAssignmentIds.add(assignment.id);
            }
        }
        
        if(lstAssignmentIds.size() > 0){
        // Get the field values for the eligible records
        List<pse__Assignment__c> lstPSEAssignmmentRecords = new List<pse__Assignment__c>([select id, pse__Project__r.pse__Account__c, pse__Resource__c, pse__Project__c, Eligible_for_Bio__c from pse__Assignment__c where id in :lstAssignmentIds]);
        
        // Get the Consultant_Bio_Project_Item__c records where updated assignment records linked to them
        List<Consultant_Bio_Project_Item__c> lstConsultantBio = new List<Consultant_Bio_Project_Item__c>([select id, Assignment__c from Consultant_Bio_Project_Item__c where Assignment__c in :lstAssignmentIds]);
        
        // Create the Map of Assignment Id with List Consultant_Bio_Project_Item__c ids
        for(Consultant_Bio_Project_Item__c conBio : lstConsultantBio) {
            if(!mapConsultantBio.containsKey(conBio.Assignment__c)) {
                mapConsultantBio.put(conBio.Assignment__c, new List<Id>());
            }
            mapConsultantBio.get(conBio.Assignment__c).add(conBio.id);
        }
    
        // Insert or update the Consultant_Bio_Project_Item__c reocrds
        for(pse__Assignment__c assignment : lstPSEAssignmmentRecords) {
            
            if(mapConsultantBio.containsKey(assignment.id)){
                
                // If Consultant_Bio_Project_Item__c record is already exists for the Assignment record then update it with refined values
                Consultant_Bio_Project_Item__c consultantBPI = new Consultant_Bio_Project_Item__c(id = mapConsultantBio.get(assignment.id)[0]);
                if(consultantBPI.Assignment__c != assignment.Id || 
                    consultantBPI.Client__c != assignment.pse__Project__r.pse__Account__c ||
                        consultantBPI.Project__c != assignment.pse__Project__c) {
                    
                    consultantBPI.Assignment__c = assignment.Id;
                    consultantBPI.Client__c = assignment.pse__Project__r.pse__Account__c;
                    
                    // No need to verify its value on update because it can not be change
                    //consultantBPI.Consultant__c = assignment.pse__Resource__c;
                    
                    consultantBPI.Project__c = assignment.pse__Project__c;
                    consultantBPILst.add(consultantBPI);
                }    
            
                
            } else  {
                
                // If Consultant_Bio_Project_Item__c record is not exists for the Assignment record then insert it
                Consultant_Bio_Project_Item__c consultantBPI = new Consultant_Bio_Project_Item__c();
                consultantBPI.Assignment__c = assignment.Id;
                consultantBPI.Client__c = assignment.pse__Project__r.pse__Account__c;
                consultantBPI.Consultant__c = assignment.pse__Resource__c;
                consultantBPI.Project__c = assignment.pse__Project__c;
                consultantBPILst.add(consultantBPI);
            }
        }
        
        try {
            if(consultantBPILst.size() > 0){
                upsert consultantBPILst;
            }    
        } catch (Exception e) {
                
        }
    }
    }
}