/*******************************************************************************
* @Class       : EstActualTriggerHandler 
* @author      : Hemlata Mandowara (Appirio JDC)
* @date        : Oct 2014
* @description : Trigger Handler Class of pse__Est_Vs_Actuals__c (S-262884)
*******************************************************************************/
public class EstActualTriggerHandler {
    public static void beforeInsertOfEstActual(List<pse__Est_Vs_Actuals__c> newEstActualList) {
        populateForecaseTemplate(newEstActualList);      
    }
    
    // To populate Forecast_Template__c  with template lookup field on EVA project
    private static void populateForecaseTemplate(List<pse__Est_Vs_Actuals__c> newEstActualList) {
        Set<Id> projectIds = new Set<Id>();
        for (pse__Est_Vs_Actuals__c  estObj : newEstActualList ) {
            if (estObj.pse__Project__c != null) {
                projectIds.add(estObj.pse__Project__c);
            }
        } //for
        if (projectIds.size() > 0) {
            Map<Id,pse__Proj__c> projectMap = new Map<Id,pse__Proj__c>([Select Id, Name, EVA_Forecast_Template__c from pse__Proj__c where Id in :projectIds]);
            for (pse__Est_Vs_Actuals__c  estObj : newEstActualList ) {
                if (estObj.pse__Project__c != null && projectMap.containsKey(estObj.pse__Project__c)) {
                   estObj.ffrr_fcst_template__c = projectMap.get(estObj.pse__Project__c).EVA_Forecast_Template__c;
                }
            } // for 
        }
     }   
}