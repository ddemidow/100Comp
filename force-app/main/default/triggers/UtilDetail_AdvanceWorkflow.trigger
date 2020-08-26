/*************************************************************************
Name : UtilDetail_AdvanceWorkflow 
Created By : Reena Acharya(Appirio JDC)
Created Date: 7th April , 2014
Descritpion: Trigger is used to Send that list of created or updated object to the Rule Engine class for evaluation  
*************************************************************************/
trigger UtilDetail_AdvanceWorkflow on pse__Utilization_Detail__c (after insert,after update){

    // Commented for the case #00138614 #START
    /*
    
    for(SkipTriggers__c strig: SkipTriggers__c.getAll().values()){
        if(strig.name == userinfo.getUserID().subString(0,15)){
            return;
        }
    }

    //Send that list of created or updated account to the Rule Engine class for evaluation
    system.debug('--- AW_AdvanceWorkflowExecutionEngine Future method already called? '+AW_AdvanceWorkflowExecutionEngine.EvaluationIsRunning);
    if (AW_AdvanceWorkflowExecutionEngine.EvaluationIsRunning==false){
        if(Trigger.isUpdate)
                AW_AdvanceWorkflowExecutionEngine.oldListMap = Trigger.oldMap;
         
           AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(Trigger.Newmap.keyset(),'pse__Utilization_Detail__c',Trigger.isInsert);    
    }    
    */
    // Commented for the case #00138614 #END
}