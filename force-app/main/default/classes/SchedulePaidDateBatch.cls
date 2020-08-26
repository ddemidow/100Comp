/* Created By :  Paras Dhingra
   Created Date :6/15/2015
   Description: Schedule Job to schedule Batch Jobs which updates 'Paid Date' Sales Invoice and Payable Invoice Objects     
   Story : S-320698 

*/
global class SchedulePaidDateBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchUpdatePaidDatePI paidDateBatchPI = new BatchUpdatePaidDatePI();
        database.executebatch(paidDateBatchPI,100);
        BatchUpdatePaidDateSI paidDateBatchSI = new BatchUpdatePaidDateSI();
        database.executebatch(paidDateBatchSI,100);
    }
}