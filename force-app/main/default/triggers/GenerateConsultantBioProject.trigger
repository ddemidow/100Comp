/*************************************************************************
Name : GenerateConsultantBioProject 
Created By : Mohit Batwada
Created Date: 17th Feb, 2015
Descritpion: Trigger is used to generate a consultant bio project line item  
*************************************************************************/
trigger GenerateConsultantBioProject on pse__Assignment__c (after insert, after update) {
	
	GenerateConsultantBioProjectHandler.genrateConBioRecords(Trigger.new);  
	
}