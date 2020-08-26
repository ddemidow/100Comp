public with sharing class projectBenefitTriggerHandler {
    
    public projectBenefitTriggerHandler (){
        
    }
    
   public void OnBeforeInsert(Project_Benefit__c [] newlist){
       
       updateLogo(newList);
    }
    
    public void OnBeforeUpdate(Project_Benefit__c[] oldList, Project_Benefit__c[] newList, Map<ID, Project_Benefit__c> newMap){
        updateLogo(newList);
        
        
    }
    
    public void updateLogo(Project_Benefit__c [] newlist){
    
    list<Project_Benefit__c> pbList = new list<Project_Benefit__c>();
    Map<Id,String> projBenMap = new Map<id,String>();    
    for(Project_Benefit__c pb: newlist){
        projBenMap.put(pb.Project_Closeout__c,'');
    }
        
    for(Project_Closeout__c pc: [Select id,Project__r.pse__Account__r.Logo__c from Project_Closeout__c where Id in :projBenMap.keyset()]){
        projBenMap.put(pc.id,pc.Project__r.pse__Account__r.Logo__c);
    }
        
    for(Project_Benefit__c pb: newlist){
        
        if( pb.Client_logo__c == null || pb.Client_logo__c == '' ){
            
            pb.Client_logo__c = projBenMap.get(pb.Project_Closeout__c);
        }
    }
    }    
    
}