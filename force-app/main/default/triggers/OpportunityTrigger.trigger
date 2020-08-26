trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after undelete, before delete) {    //S-429731 - Hitesh[Sept 14, 2016]

    if(!UpdateFinalClientDateAndG100Status.isbatchrunning){ //Added By Arihant For CASE#00223036 - Adding th Check to Bypass The Trigger if UpdateFinalClientDateAndG100Status batch is running
  	  //Connor Flynn S-409479 
      OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
      
      system.debug('trigger :: ' + trigger.new);//aditya
      //S-429731 ---START---- Hitesh[Sept 14, 2016]
      if(Trigger.isBefore && Trigger.isInsert){
          handler.onBeforeInsert();
      }else if(Trigger.isBefore && Trigger.isUpdate){
          handler.onBeforeUpdate();
      }else if(Trigger.isAfter && Trigger.isInsert){
        //S-429731 ---END---- Hitesh[Sept 14, 2016]
        handler.onAfterInsert();
      }else if (Trigger.isAfter && Trigger.isUpdate){
        handler.onAfterUpdate();
      }else {
        set<ID>         cIds    = new set<ID>();
        List<String>    apIds   = new List<String>();
        List<ActionPlan__c> deletePermantently_apIds= new List<ActionPlan__c>();        
        //Delete related action plans
        if ( trigger.isdelete ){
            for( Opportunity o : trigger.old ){
                cIds.add( o.Id );
                } 
                
            /* GET Action Plans to delete from recycle bin */
                deletePermantently_apIds = [ select Id, Name , LastModifiedDate from ActionPlan__c where Opportunity__c in : cIds and isDeleted = true ALL ROWS ];
                
                if ( deletePermantently_apIds.size() >0 ){          
                Database.emptyRecycleBin(deletePermantently_apIds);
                }
                        
            List<ActionPlan__c> apList =  [ select Id from ActionPlan__c where Opportunity__c in : cIds ];
            for( ActionPlan__c ap : [ select Id from ActionPlan__c where Opportunity__c in : cIds ] ){
                apIds.add( ap.Id );
                }
                if ( apIds.size() >0 ){         
                ActionPlansBatchDelete aPBatch = new ActionPlansBatchDelete(apIds, Userinfo.getUserId());
                Database.ExecuteBatch( aPBatch );   
                }       
        }
        
        //Undelete related action plans
        if ( trigger.isUnDelete ){
            for( Opportunity o : trigger.new ){
                cIds.add( o.Id );
                }
                list <ActionPlan__c> aPs = [ select Id from ActionPlan__c where Opportunity__c in : cIds ALL ROWS ];
                
                try{
                    if(ActionPlanObjectTriggerTest.isTest){
                        //throw dmlException
                        insert new Contact();   
                    }
                    //undelete aPs;
                    Database.undelete( aPs,false);
                } catch ( Dmlexception e ){
                    for (Opportunity o: trigger.new){
                    o.addError('You can not undelete an action plan whose related object is deleted.');
                }
                }
        }
      }
    } // Added By Arihant For CASE#00223036
}