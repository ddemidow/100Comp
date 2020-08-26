// 
// (c) 2012 Appirio, Inc.
// AW_Advance_WorkflowScheduler                                                     
// This class is used to schedule bulk API calls
//
// 20 Apr 2013     Peter Babalis     Original
//  
//
global  with sharing class AW_Advance_WorkflowScheduler  implements Schedulable {
    
    DateTime dt = null;
    String sobjType = '';
    
    public AW_Advance_WorkflowScheduler(String sobjType, Datetime dt){
        this.dt = dt;
        this.sobjType = sobjType;
        //string query = 'Select id from ' + sobjType + '  ' + ' limit 1'; //where CreatedDate >=:dt
        string query = 'Select id from ' + sobjType + ' where CreatedDate >=:dt ' + ' limit 1';
       List<SObject> lstObj = Database.query(query);
        if(lstObj == null && lstObj.size() == 0){
            AdvanceWorkflowBatchStatus__c awBatchStatus = AdvanceWorkflowBatchStatus__c.getInstance(sobjType);
            if(awBatchStatus != null){
                delete awBatchStatus;
            }
        }        
    }
    
    global void execute(SchedulableContext shdCtx){    	
       // system.debug('--------->dt:' + dt);
          
        Integer batchSize;  
         
        AdvanceWorkflowConf__c conf = AdvanceWorkflowConf__c.getInstance('WorkflowConf');
    	 if(conf == null){
    		conf = new AdvanceWorkflowConf__c(name='WorkflowConf',Delay_Time__c=15,Batch_Size__c=100);
    		insert conf;
    	}
    	if(conf != null && conf.Delay_Time__c >= 0){
    	 	batchSize = Integer.valueOf(conf.Batch_Size__c);
    	}
        
         
        
        Database.executeBatch(new AW_Advance_WorkflowBatch(dt,sobjType),batchSize);       
         /**
         * We dont want a execute schedular record to be present in the schedule job queue
         */
         System.abortJob(shdCtx.getTriggerId());
    }
}