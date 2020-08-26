/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossReportingBatch
*          
* Created by L. Ichihashi: 1/29/2014:
*
* - Abstract class that is superclass for profit and loss reporting data batch jobs (currently 5 of them)
* - Contains generic methods used by all batch jobs.
----------------------------------------------------------------------------------------------------- */
public abstract with sharing class FFA_ProfitLossReportingBatch {

	protected Datetime lastRunDate;	
	public void setLastRunDate(String className) {
		//find the last time this job was run.  this will be used in comparison
    	//with the forecast data's last updated date to determine if 
    	//an existing report record should be updated
    	//try {
	    	List<AggregateResult> lastJobResult = [SELECT MAX(CompletedDate) maxDate
					    						   FROM AsyncApexJob 
					    						   WHERE ApexClass.Name = :className];
	    	
	    	if (lastJobResult != null && lastJobResult.size() > 0) {
	    		for (AggregateResult row : lastJobResult) {
	    			lastRunDate = Datetime.valueOf(row.get('maxDate'));
	    		}
	    	} else {
	    		//if this job has not ever run, set the lastjob date to a very early date so that it will always trigger selection
	    		lastRunDate = Datetime.newInstance(1975,1,1);	 
	    	}	
    	//} catch (Exception e) {
    		
    	//}	
	}	    	
}