/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossReportingDataScheduler
*          
* Created by L. Ichihashi: 11/01/2013:
*
* - Used to schedule the FFA_CreditNoteMatchingBatch
----------------------------------------------------------------------------------------------------- */
global class FFA_ProfitLossReportingDataScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        FFA_ProfitLossForecastRevenueBatch b = new FFA_ProfitLossForecastRevenueBatch();
        database.executebatch(b);
        FFA_ProfitLossActualRevenueBatch b2 = new FFA_ProfitLossActualRevenueBatch();
        database.executebatch(b2);
        FFA_ProfitLossForecastCostBatch b3 = new FFA_ProfitLossForecastCostBatch();
        database.executebatch(b3);
        FFA_ProfitLossActualLaborCostBatch b4 = new FFA_ProfitLossActualLaborCostBatch();
        database.executebatch(b4);
        FFA_ProfitLossActualExpenseCostBatch b5 = new FFA_ProfitLossActualExpenseCostBatch();
        database.executebatch(b5);
        
    }  
    
    /* Enter this script in an execute anonymous window to execute these jobs at 1 am every day
    String CRON_EXP = '0 0 1 * * ?';
    FFA_ProfitLossReportingDataScheduler sch = new FFA_ProfitLossReportingDataScheduler();
    System.schedule('FFA-Profit Loss Reporting Daily Data Capture Job', CRON_EXP, sch);  \
    */
}