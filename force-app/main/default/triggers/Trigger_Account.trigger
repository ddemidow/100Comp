// Created by Shashank Singhal for Case no. 00091435 on 05-08-2014
/*
    Name            History         Author          Date            Description
-------------------------------------------------------------------------------------------------------------------------------------------------------
AccountTrigger      Created     Shashank Singhal    5-8-2014        This is an After update trigger on Account. This calls a method in the helper class
                                                                    which updates the Account_Name__c on the associtaed Contacts if the Account Name is 
                                                                    modified.
*/
trigger Trigger_Account on Account (after update, after delete) {
    
    if(!UpdateFinalClientDateAndG100Status.isbatchrunning){ //Added By Arihant For CASE#00223036 - Adding th Check to Bypass The Trigger if UpdateFinalClientDateAndG100Status batch is running
    
        // If it is an After trigger
        if(Trigger.isAfter )
        {
            // If it is an Update trigger
            if(Trigger.isUpdate)
            {
                // Call the method onAfterUpdateofAccount in Helper Class AccountTriggerHandler. Pass on the old map and new map as the parameters.
                AccountTriggerHandler.onAfterUpdateofAccount(Trigger.oldMap, Trigger.newMap);
            }
            
            // If it is an Delete trigger
            if(Trigger.isDelete)
            {
                // Call the method onAfterDeleteofAccount in Helper Class AccountTriggerHandler. Pass on the old map as the parameters.
                AccountTriggerHandler.onAfterDeleteofAccount(Trigger.oldMap);
            }
        }
    }	//Added By Arihant For CASE#00223036
}