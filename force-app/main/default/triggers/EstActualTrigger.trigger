/*******************************************************************************
* @Class       : EstActualTrigger 
* @author      : Hemlata Mandowara (Appirio JDC)
* @date        : Oct 2014
* @description : Trigger of pse__Est_Vs_Actuals__c (S-262884)
*******************************************************************************/
trigger EstActualTrigger on pse__Est_Vs_Actuals__c (before insert) {
    if (Trigger.isInsert && Trigger.isBefore) {
       EstActualTriggerHandler.beforeInsertOfEstActual(Trigger.new); 
    }
}