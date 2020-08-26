// 
// (c) 2012 Appirio, Inc.
//
// Opportunity_aInsertaUpdate                                                     
//
// Trigger is used to Send that list of created or updated account to the Rule Engine class for evaluation  
//
// 18 Nov 2012     Peter Babalis     Original
//
trigger Opportunity_aInsertaUpdate on Opportunity (after insert,after update) {
    
    if(!UpdateFinalClientDateAndG100Status.isbatchrunning){ //Added By Arihant For CASE#00223036 - Adding th Check to Bypass The Trigger if UpdateFinalClientDateAndG100Status batch is running
    
        Set<Id> Ids=new Set<Id>();
        
        //add all the accountids in the set
        for (Opportunity a:trigger.new){
            Ids.add(a.Id);
        }//for
    
        //Send that list of created or updated account to the Rule Engine class for evaluation
        system.debug('--- AW_AdvanceWorkflowExecutionEngine Future method already called? '+AW_AdvanceWorkflowExecutionEngine.EvaluationIsRunning);
        if (AW_AdvanceWorkflowExecutionEngine.EvaluationIsRunning==false){
            //Integer limit1 = Limits.getLimitFutureCalls() - Limits.getFutureCalls();
            //if (limit1>0){//don't call the method if the limit is reached            
              if(Trigger.isUpdate)
                    AW_AdvanceWorkflowExecutionEngine.oldListMap = Trigger.oldMap;
            if(!Test.isRunningTest()){
              AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(Ids,'Opportunity',Trigger.isInsert);       
            }
              
            //}    
        } 
        
      //added by harendra for S-369112 start after update 
      //if(Trigger.isAfter && Trigger.isUpdate){
      //  OpportunityTriggerHandler.onAfterUpdate(Trigger.new, trigger.oldMap);
      //}   
      //S-369112  end 
    
   } //Added By Arihant For CASE#00223036
    
}