/*************************************************************************
Name : MiscAdjustment_AdvanceWorkflow 
Created By : Reena Acharya(Appirio JDC)
Created Date: 7th April , 2014
Descritpion: Trigger is used to Send that list of created or updated object to the Rule Engine class for evaluation  
*************************************************************************/
trigger MiscAdjustment_AdvanceWorkflow on pse__Miscellaneous_Adjustment__c (after insert,after update){
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
         
           AW_AdvanceWorkflowExecutionEngine.startRulesProcessing(Trigger.Newmap.keyset(),'pse__Miscellaneous_Adjustment__c',Trigger.isInsert);    
    }    
}