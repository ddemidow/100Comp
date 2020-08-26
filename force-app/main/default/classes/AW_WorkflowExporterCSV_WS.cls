global with sharing class AW_WorkflowExporterCSV_WS {
 webservice static list<Rule__c> WorkflowExportCSV(string soql){
 
 // system.debug('Akhilesh --> soql' + soql);
  
  soql += ' Limit 10000';
  
  list<Rule__c> lstrules = Database.query(soql);
  
  if(lstrules.size()>0){
    return lstrules;
  }
  
    return null;
 }
}