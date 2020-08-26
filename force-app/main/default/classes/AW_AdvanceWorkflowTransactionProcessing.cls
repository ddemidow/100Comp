// 
// (c) 2012 Appirio, Inc.
// AW_AdvanceWorkflowTransactionProcessing                                                     
//
// This class is  helper class for the RuleExecution class
// and performs the associated actions
//
// 08  Feb 2013     Peter Babalis     Original
//  
//  

public class AW_AdvanceWorkflowTransactionProcessing {
     public static   boolean performDMLOperations(Map<Id,SObject> toupdateSobj,List<SObject> insertrelatedobj ){
                     
        Savepoint sp = Database.setSavepoint();
        if (insertrelatedobj.size()>0 ){
           try {
            
               system.debug('--BEGIN INSERT TRANSACTION ....');
               system.debug('--Number of Record to Be  INSERTED :'+ insertrelatedobj.size());
               system.debug('-- Record to Be  INSERTED : '+ insertrelatedobj );
               insert insertrelatedobj; 
               system.debug('--END  INSERT TRANSACTION .... ');  
                   
            }
            catch(DMLException e) {

            Database.rollback(sp);
            return false;
            }  
         }
        if (toupdateSobj.size()>0 ){
            // Create a savepoint  
            try {
               
               system.debug('--BEGIN UPDATE TRANSACTION ....');
               system.debug('--Number of Record to Be  Updated :'+ toupdateSobj.size());
               system.debug('-- Record to Be UPDATED : '+ toupdateSobj );
               update toupdateSobj.values();
               system.debug('--END  UPDATE TRANSACTION .... ');  
               return true;    
            }
            catch(DMLException e) {

            Database.rollback(sp);
            return false;
            }  
            
         } 
         return true;      
    }
    
     
                            
    public static boolean addRecordstoExecutionHistory(Map<Id,List<SObject>> validRecords){
               //finally add that these records are processed in a history object
                List<Rule_Execution_History__c> history = new List<Rule_Execution_History__c>();
                for(Id ruleId : validRecords.keySet()){
                    if(validRecords.get(ruleId)!=null){
                        for(SObject o:validRecords.get(ruleId)){
                            Rule_Execution_History__c h = new Rule_Execution_History__c();
                            String externalid = ruleId+'-'+string.valueof(o.get('id'));
                            h.Rule_ID__c=externalid;
                            h.Rule__c =ruleId;    
                            h.Record_ID__c=string.valueof(o.get('id'));
                            history.add(h);
                        }
                    }                           
                }
              
                if(history.size()>0){
                    try{
                        upsert history Rule_ID__c;
                    }catch(Exception e){
                       handleError(e);
                       return false;
                    }
                }
                return true;      

    }
      public static void processLookupUpdatesAndBulkAPi(List<Object_Action_Execution__c> records){
    	 //insert the records in DB & fire batch process :- 
    	 			 
    	 insert records;
    	 
    	 AW_AdvanceWorkflowExecutionHelper.StartAWSchedular(System.now(),'Object_Action_Execution__c');
       	 AdvanceWorkflowBatchStatus__c awBatchStatus = new AdvanceWorkflowBatchStatus__c(Name='Object_Action_Execution__c',Is_Batch_Running__c = true);
         insert awBatchStatus;    
    }
     
    public static void processBulkAPiTransactions(List<Object_Action_Execution__c> records){
    	 //insert the records in DB & fire batch process :- 
    	 			 
    	 insert records;
    	 
    	 AW_AdvanceWorkflowExecutionHelper.StartAWSchedular(System.now(),'Object_Action_Execution__c');
       	 AdvanceWorkflowBatchStatus__c awBatchStatus = new AdvanceWorkflowBatchStatus__c(Name='Object_Action_Execution__c',Is_Batch_Running__c = true);
         insert awBatchStatus;    
    }
    
    public static void handleError(Exception e){
        String msg = string.valueOf(e);
        List<User> usr = [select email  from user where username=:UserInfo.getUsername()];
        AW_ErrorUtil.Handler(e, 'Async', usr[0].email, 'AW_AdvanceWorkflowTransactionProcessing.cls','addRecordstoExecutionHistory','AW_AdvanceWorkflowTransactionProcessing.cls','LogEmail','Rule_Execution_History__c');
    }
    
    static testmethod void testHandleError(){
         Opportunity o= new Opportunity();
         try{ insert o;}
         catch(Exception e){
              handleError(e);
         }
    }
    
}