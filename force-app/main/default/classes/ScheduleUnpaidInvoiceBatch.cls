global class ScheduleUnpaidInvoiceBatch implements Schedulable{
    global void execute(SchedulableContext SC){
               
        BatchToDeleteUnpaidInvoices batch = new BatchToDeleteUnpaidInvoices ();
        database.executeBatch(batch ,200);             
    }
}