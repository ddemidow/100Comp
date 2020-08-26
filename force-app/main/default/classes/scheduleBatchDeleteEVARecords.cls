/** @author : Paras Dhingra(Appirio)
  * @Created Date : 6/4/2015
  * @Description : Cleaning up EVA Records to save Data Storage 
  * @Story : S-306218
*/
global class scheduleBatchDeleteEVARecords implements Schedulable {
	global void execute(SchedulableContext sc) {
		batchDeleteEVARecords createBatch = new batchDeleteEVARecords();
		database.executebatch(createBatch,200);
	}
}