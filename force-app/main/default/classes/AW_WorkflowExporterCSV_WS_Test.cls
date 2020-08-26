// 
// (c) 2012 Appirio, Inc.
// Test Class for  AW_WorkflowExporterCSV_WS_Test                                                         
//  
// 26 Apr 2013    Peter Babalis      Original
//  
//  
// 
@isTest
private class AW_WorkflowExporterCSV_WS_Test {
  @isTest
  private static void unitTest(){
         List<Workflow_DynamicColumns__c> dynCols = new List<Workflow_DynamicColumns__c>(); 
         Workflow_DynamicColumns__c dynCol = new Workflow_DynamicColumns__c(ApiName__c = 'Account__c',Type__c = 'Dynamic');
         Workflow_DynamicColumns__c dynCol1 = new Workflow_DynamicColumns__c(ApiName__c = 'Account__r.Country__c',Type__c = 'Dynamic');
         Workflow_DynamicColumns__c dynCol2 = new Workflow_DynamicColumns__c(ApiName__c = 'Account__r.City__c',Type__c = 'Fixed');
          insert dynCols; 
       
          List<Rule__c> rules = new List<Rule__c>();
         for(Integer cnt = 0 ; cnt < 1 ; cnt ++){
           //Rule__c base = new Rule__c(Name = 'test IB' + cnt, Installed_Product_Status__c = 'Active',Account__c = acc.Id, Asset_Category__c = 'New',Opportunity_ID__c=testOpp.Opportunity_Number__c);
           Rule__c rule= new Rule__c(Name = 'Test Test Account',Object__c = 'Account', Status__c='Draft',Evaluation_Rule__c='Record is created or edited',Description__c='Rule 1 Description');
         
           rules.add(rule);
         }
         insert rules;
         
         String soql='Select  id,Name From Rule__c Where Id=\'' +rules[0].id + '\'';    
         AW_WorkflowExporterCSV_WS.WorkflowExportCSV(soql);
          
  }
}