// 
// (c) 2015 Appirio, Inc.
//
// Schedules the PaymentDateOnOpportunity batch
//
// 19 Aug 2015     Nick Sharp      Original    S-339373
//
global class PaymentDateOnOpportunity implements Schedulable {
	global void execute(SchedulableContext sc) {
		PaymentDateOnOpportunityBatch batch = new PaymentDateOnOpportunityBatch();
		database.executebatch(batch,100);
	}
}