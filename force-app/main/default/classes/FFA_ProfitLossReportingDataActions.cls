/* ----------------------------------------------------------------------------------------------------
*  Class: FFA_ProfitLossReportingDataActions
*          
* Created by L. Ichihashi: 11/29/2013:
*
* - Contains methods called by batch jobs to create profit and loss data for reporting purposes
* - There are two types of data = Forecast and Actual.  In addition, there are two categories of data = 
* - revenue and cost (split amongst time and expense).  
----------------------------------------------------------------------------------------------------- */
public with sharing class FFA_ProfitLossReportingDataActions {
 
	//records passed in all require either a new report row, or updates to an existing one
	public static void processRevenueActuals(List<ffrr__RevenueRecognitionTransactionLine__c> revList) {	
		//get record type for Profit Loss Reporting Data for actuals
		Id recTypeId = [select Id from RecordType Where SOBjectType = 'Profit_Loss_Reporting_Data__c' and Name = 'Actual' limit 1].Id;
		
		//first get existing report Ids so that those records can be retrieved for updating
		Set<Id> existingReportIds = new Set<Id>();
		for (ffrr__RevenueRecognitionTransactionLine__c revRow : revList) {
			if (revRow.Profit_Loss_Reporting_Data__r != null && revRow.Profit_Loss_Reporting_Data__r.size() > 0) {
				for (Profit_Loss_Reporting_Data__c reportDataRow : revRow.Profit_Loss_Reporting_Data__r) {
					existingReportIds.add(reportDataRow.Id);
				}	  
			}
		}
		//put existing report data in a map so that it can be retrieved via the rev. rec. transaction line id
		Map<Id, Profit_Loss_Reporting_Data__c> transIdToRptDataMap = new Map<Id, Profit_Loss_Reporting_Data__c>();
		if (existingReportIds.size() > 0) {
			List<Profit_Loss_Reporting_Data__c> reportDataList = [Select Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
																  Revenue_Recognition_Transaction_Line__c
																  From Profit_Loss_Reporting_Data__c 
																  Where Id in :existingReportIds];
			for (Profit_Loss_Reporting_Data__c dataRow : reportDataList) {
				transIdToRptDataMap.put(dataRow.Revenue_Recognition_Transaction_Line__c, dataRow);
			}													  
		}
		
		List<Profit_Loss_Reporting_Data__c> dataList = new List<Profit_Loss_Reporting_Data__c>();
		Profit_Loss_Reporting_Data__c dataRow;
		for (ffrr__RevenueRecognitionTransactionLine__c revRow : revList) {
			//check to see if an existing data row exists in the map... if so we will update some fields on it
			dataRow = transIdToRptDataMap.get(revRow.Id);
			if (dataRow != null) {
				//update existing row - only the fields that could chang over time
				dataRow.Amount__c = revRow.ffrr__AmountRecognized__c;
				dataRow.Reporting_Month__c = revRow.ffrr__RecognizedDate__c.month();
				dataRow.Reporting_Year__c = revRow.ffrr__RecognizedDate__c.year();	
			} else {
				//create and insert new row
				dataRow = new Profit_Loss_Reporting_Data__c();
				dataRow.CurrencyISOCode = revRow.CurrencyISOCode;
				dataRow.Account__c = revRow.ffrr_exp__Project__r.pse__Account__c;
				dataRow.Amount__c = revRow.ffrr__AmountRecognized__c;
				dataRow.Category__c = 'Revenue';
				dataRow.Subcategory__c = 'Revenue';
				dataRow.Type__c = 'Actual';
				dataRow.Reporting_Month__c = revRow.ffrr__RecognizedDate__c.month();
				dataRow.Reporting_Year__c = revRow.ffrr__RecognizedDate__c.year();
				dataRow.Project__c =  revRow.ffrr_exp__Project__c;
				dataRow.Reference_Id__c = revRow.Id;
				dataRow.Reference_Type__c = 'Revenue Recognition';
				dataRow.Revenue_Recognition_Transaction_Line__c = revRow.Id;
				dataRow.RecordTypeId = recTypeId;
			}	
			dataList.add(dataRow);
			revRow.Report_Data_Capture_Date__c = System.Now();
		}	
		upsert dataList;	
		update revList;
	}
	
	public static void processRevenueForecasts(List<pse__Forecast__c> forecastList) {		
		Map<String, pse__Time_Period__c> periodMap = new Map<String, pse__Time_Period__c>([select Id, Name, pse__End_Date__c, pse__Start_Date__c From pse__Time_Period__c]);
		Id recTypeId = [select Id from RecordType Where SOBjectType = 'Profit_Loss_Reporting_Data__c' and Name = 'Forecast' limit 1].Id;
		
		//first get existing report Ids so that those records can be retrieved for updating
		Set<Id> existingReportIds = new Set<Id>();
		for (pse__Forecast__c dataRow : forecastList) {
			if (dataRow.Profit_Loss_Reporting_Data__r != null && dataRow.Profit_Loss_Reporting_Data__r.size() > 0) {
				for (Profit_Loss_Reporting_Data__c reportDataRow : dataRow.Profit_Loss_Reporting_Data__r) {
					existingReportIds.add(reportDataRow.Id);
				}	
			}
		}
		//put existing report data in a map so that it can be retrieved via the forecast id + category
		Map<String, Profit_Loss_Reporting_Data__c> forecastCategoryToRptDataMap = new Map<String, Profit_Loss_Reporting_Data__c>();
		if (existingReportIds.size() > 0) {
			List<Profit_Loss_Reporting_Data__c> reportDataList = [Select Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
																  Forecast__c,CurrencyISOCode, Account__c, Category__c, 
																  Subcategory__c, Type__c, Time_Period__c, Project__c,
																  Reference_Id__c, Reference_Type__c, RecordTypeId
																  From Profit_Loss_Reporting_Data__c 
																  Where Id in :existingReportIds];
			for (Profit_Loss_Reporting_Data__c dataRow : reportDataList) {
				forecastCategoryToRptDataMap.put(dataRow.Forecast__c+dataRow.Category__c, dataRow);
			}													  
		}
		
		System.debug('forecastCategoryToRptDataMap='+forecastCategoryToRptDataMap);
		
		List<Profit_Loss_Reporting_Data__c> dataList = new List<Profit_Loss_Reporting_Data__c>();
		List<Profit_Loss_Reporting_Data__c> expenseDataList = new List<Profit_Loss_Reporting_Data__c>();
		Profit_Loss_Reporting_Data__c dataRow;
		Profit_Loss_Reporting_Data__c expenseDataRow;
		for (pse__Forecast__c forecastRow : forecastList) {			
			pse__Time_Period__c period = periodMap.get(forecastRow.pse__Time_Period__c);
			//check to see if an existing data row exists in the map... if so we will update some fields on it
			dataRow = forecastCategoryToRptDataMap.get(forecastRow.Id+'Revenue');
			if (dataRow == null) {
				dataRow = new Profit_Loss_Reporting_Data__c();
			}	
			System.debug('dataRow='+dataRow);	
			dataRow.CurrencyISOCode = forecastRow.CurrencyISOCode;
			dataRow.Account__c = forecastRow.pse__Project__r.pse__Account__c;
			dataRow.Amount__c = forecastRow.pse__Entered_Forecast__c;
			dataRow.Category__c = 'Revenue'; 
			dataRow.Subcategory__c = 'Revenue';
			dataRow.Type__c = 'Forecast';
			dataRow.Time_Period__c = forecastRow.pse__Time_Period__c;	
			if (period != null) {
				dataRow.Reporting_Month__c = period.pse__End_Date__c.month();
				dataRow.Reporting_Year__c = period.pse__End_Date__c.year();
			}	
			dataRow.Project__c =  forecastRow.pse__Project__c;
			dataRow.Reference_Id__c = forecastRow.Id;
			dataRow.Reference_Type__c = 'Project Forecast';
			dataRow.RecordTypeId = recTypeId;
			dataRow.Forecast__c = forecastRow.Id;
			dataList.add(dataRow);
			if (forecastRow.Expense_Cost_Forecast__c > 0) {
				expenseDataRow = forecastCategoryToRptDataMap.get(forecastRow.Id+'Cost');		
				if (expenseDataRow == null) {
					expenseDataRow = dataRow.clone(false);
				}
				System.debug('expenseDataRow='+expenseDataRow);
				expenseDataRow.Category__c = 'Cost';
				expenseDataRow.Subcategory__c = 'Other Costs';	
				expenseDataRow.Amount__c = forecastRow.Expense_Cost_Forecast__c;	
				dataList.add(expenseDataRow);
			}
			forecastRow.Report_Data_Capture_Date__c = System.Now(); 
		}	
		System.debug('dataList.size()='+dataList.size());
		System.debug('dataList='+dataList);
		upsert dataList;
		update forecastList;
	}

	public static void processLaborCostForecasts(List<pse__Est_Vs_Actuals__c> costList) {	
		Map<String, pse__Time_Period__c> periodMap = new Map<String, pse__Time_Period__c>([select Id, Name,  pse__End_Date__c, pse__Start_Date__c From pse__Time_Period__c]);   
		Id recTypeId = [select Id from RecordType Where SOBjectType = 'Profit_Loss_Reporting_Data__c' and Name = 'Forecast' limit 1].Id;		
		
		//first get existing report Ids so that those records can be retrieved for updating
		Set<Id> existingReportIds = new Set<Id>();
		for (pse__Est_Vs_Actuals__c dataRow : costList) {
			if (dataRow.Profit_Loss_Reporting_Data__r != null && dataRow.Profit_Loss_Reporting_Data__r.size() > 0) {
				for (Profit_Loss_Reporting_Data__c reportDataRow : dataRow.Profit_Loss_Reporting_Data__r) {
					existingReportIds.add(reportDataRow.Id);
				}	
			}
		}
		//put existing report data in a map so that it can be retrieved via the forecast id + category
		Map<String, Profit_Loss_Reporting_Data__c> recIdToRptDataMap = new Map<String, Profit_Loss_Reporting_Data__c>();
		if (existingReportIds.size() > 0) {
			List<Profit_Loss_Reporting_Data__c> reportDataList = [Select Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
																  Est_Vs_Actual__c,CurrencyISOCode, Account__c, Category__c, 
																  Subcategory__c, Type__c, Time_Period__c, Project__c,
																  Reference_Id__c, Reference_Type__c, RecordTypeId
																  From Profit_Loss_Reporting_Data__c 
																  Where Id in :existingReportIds];
			for (Profit_Loss_Reporting_Data__c dataRow : reportDataList) {
				recIdToRptDataMap.put(dataRow.Est_Vs_Actual__c + dataRow.Category__c, dataRow);
			}													  
		}
		
		List<Profit_Loss_Reporting_Data__c> dataList = new List<Profit_Loss_Reporting_Data__c>();
		Profit_Loss_Reporting_Data__c costDataRow;
		Profit_Loss_Reporting_Data__c revDataRow;
		for (pse__Est_Vs_Actuals__c costRow : costList) {
			costDataRow = recIdToRptDataMap.get(costRow.Id+'Cost');
			if (costDataRow == null) {
				costDataRow = new Profit_Loss_Reporting_Data__c();
			}	
			costDataRow.CurrencyISOCode = costRow.CurrencyISOCode;
			costDataRow.Account__c = costRow.pse__Project__r.pse__Account__c;
			costDataRow.Amount__c = costRow.pse__Estimated_Hours__c * costRow.pse__Assignment__r.pse__Cost_Rate_Amount__c;	
			costDataRow.Hours__c = costRow.pse__Estimated_Hours__c;
			costDataRow.Cost_Rate__c = costRow.pse__Assignment__r.pse__Cost_Rate_Amount__c;
			costDataRow.Category__c = 'Cost';
			if (costRow.pse__Resource__r.pse__External_Resource__c) {
				costDataRow.Subcategory__c = 'Labor - Subcontractors';
			} else {
				costDataRow.Subcategory__c = 'Labor - Employees';
			}	
			costDataRow.Type__c = 'Forecast';
			costDataRow.Reporting_Month__c = costRow.pse__Start_Date__c.month();
			costDataRow.Reporting_Year__c = costRow.pse__Start_Date__c.year();
			costDataRow.Resource__c = costRow.pse__Resource__c;	
			costDataRow.Project__c =  costRow.pse__Project__c;
			costDataRow.Reference_Id__c = costRow.Id;
			costDataRow.Reference_Type__c = 'Estimate vs. Actuals';
			costDataRow.RecordTypeId = recTypeId;
			costDataRow.Est_Vs_Actual__c = costRow.Id;
			dataList.add(costDataRow);
			if (costRow.pse__Project__r.pse__Billing_Type__c == 'Time and Materials' &&
			    costRow.pse__Assignment__r.pse__Is_Billable__c == true) {
				revDataRow = recIdToRptDataMap.get(costRow.Id+'Revenue');
				if (revDataRow == null) {
					revDataRow = costDataRow.clone(false);
				}
				revDataRow.Category__c = 'Revenue';
				revDataRow.Subcategory__c = 'Revenue';
				if (costRow.pse__Assignment__r.pse__Suggested_Bill_Rate_Number__c > 0) {
					revDataRow.Amount__c = costRow.pse__Estimated_Hours__c * costRow.pse__Assignment__r.pse__Suggested_Bill_Rate_Number__c;
				}
				dataList.add(revDataRow);
			}
			costRow.Report_Data_Capture_Date__c = System.Now(); 
		}	
		upsert dataList;
		update costList;
		
	}
	
	public static void processLaborCostActuals(List<pse__Timecard__c> timeList) {		    
		Id recTypeId = [select Id from RecordType Where SOBjectType = 'Profit_Loss_Reporting_Data__c' and Name = 'Actual' limit 1].Id;
		
		//first get existing report Ids so that those records can be retrieved for updating
		Set<Id> existingReportIds = new Set<Id>();
		for (pse__Timecard__c dataRow : timeList) {
			if (dataRow.Profit_Loss_Reporting_Data__r != null && dataRow.Profit_Loss_Reporting_Data__r.size() > 0) {
				for (Profit_Loss_Reporting_Data__c reportDataRow : dataRow.Profit_Loss_Reporting_Data__r) {
					existingReportIds.add(reportDataRow.Id);
				}	
			}
		}
		//put existing report data in a map so that it can be retrieved via the forecast id + category
		Map<Id, Profit_Loss_Reporting_Data__c> recIdToRptDataMap = new Map<Id, Profit_Loss_Reporting_Data__c>();
		if (existingReportIds.size() > 0) {
			List<Profit_Loss_Reporting_Data__c> reportDataList = [Select Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
																  Timecard__c,CurrencyISOCode, Account__c, Category__c, 
																  Subcategory__c, Type__c, Time_Period__c, Project__c,
																  Reference_Id__c, Reference_Type__c, RecordTypeId
																  From Profit_Loss_Reporting_Data__c 
																  Where Id in :existingReportIds];
			for (Profit_Loss_Reporting_Data__c dataRow : reportDataList) {
				recIdToRptDataMap.put(dataRow.Timecard__c, dataRow);
			}													  
		}
		
		List<Profit_Loss_Reporting_Data__c> dataList = new List<Profit_Loss_Reporting_Data__c>();
		Profit_Loss_Reporting_Data__c dataRow;
		for (pse__Timecard__c timeRow : timeList) {
			dataRow = recIdToRptDataMap.get(timeRow.Id);
			if (dataRow == null) {
				dataRow = new Profit_Loss_Reporting_Data__c();
			}	
			dataRow.CurrencyISOCode = timeRow.CurrencyISOCode;
			dataRow.Account__c = timeRow.pse__Project__r.pse__Account__c;
			if (timeRow.pse__Assignment__r.pse__Cost_Rate_Amount__c != null) {
				if (timeRow.Is_Daily_Bill_Rate__c == 'yes') {
					dataRow.Amount__c = timeRow.pse__Total_Hours__c/8 * timeRow.pse__Assignment__r.pse__Cost_Rate_Amount__c;
				} else {
					dataRow.Amount__c = timeRow.pse__Total_Hours__c * timeRow.pse__Assignment__r.pse__Cost_Rate_Amount__c;
				
				}	
			}
			dataRow.Hours__c = timeRow.pse__Total_Hours__c;
			dataRow.Cost_Rate__c = timeRow.pse__Assignment__r.pse__Cost_Rate_Amount__c;
			dataRow.Category__c = 'Cost';
			dataRow.Type__c = 'Actual';
			if (timeRow.pse__Resource__r.pse__External_Resource__c) {
				dataRow.Subcategory__c = 'Labor - Subcontractors';
			} else {
				dataRow.Subcategory__c = 'Labor - Employees';
			}	
			dataRow.Reporting_Month__c = timeRow.pse__End_Date__c.month();
			dataRow.Reporting_Year__c = timeRow.pse__End_Date__c.year();
			dataRow.Resource__c = timeRow.pse__Resource__c;	
			dataRow.Project__c =  timeRow.pse__Project__c;
			dataRow.Reference_Id__c = timeRow.Id;
			dataRow.Reference_Type__c = 'Timecard';
			dataRow.Timecard__c = timeRow.Id;
			dataRow.RecordTypeId = recTypeId;
			dataList.add(dataRow);
			timeRow.Report_Data_Capture_Date__c = System.Now();
		}	  
		upsert dataList;	
		update timeList; 
	}  
	
	public static void processExpenseCostActuals(List<pse__Expense__c> expList) {		    
		Id recTypeId = [select Id from RecordType Where SOBjectType = 'Profit_Loss_Reporting_Data__c' and Name = 'Actual' limit 1].Id;
		
		//first get existing report Ids so that those records can be retrieved for updating
		Set<Id> existingReportIds = new Set<Id>();
		for (pse__Expense__c dataRow : expList) {
			if (dataRow.Profit_Loss_Reporting_Data__r != null && dataRow.Profit_Loss_Reporting_Data__r.size() > 0) {
				for (Profit_Loss_Reporting_Data__c reportDataRow : dataRow.Profit_Loss_Reporting_Data__r) {
					existingReportIds.add(reportDataRow.Id);
				}	
			}
		}
		//put existing report data in a map so that it can be retrieved via the forecast id + category
		Map<Id, Profit_Loss_Reporting_Data__c> recIdToRptDataMap = new Map<Id, Profit_Loss_Reporting_Data__c>();
		if (existingReportIds.size() > 0) {
			List<Profit_Loss_Reporting_Data__c> reportDataList = [Select Id, Amount__c, Reporting_Month__c, Reporting_Year__c, 
																  Expense__c,CurrencyISOCode, Account__c, Category__c, 
																  Subcategory__c, Type__c, Time_Period__c, Project__c,
																  Reference_Id__c, Reference_Type__c, RecordTypeId
																  From Profit_Loss_Reporting_Data__c 
																  Where Id in :existingReportIds];
			for (Profit_Loss_Reporting_Data__c dataRow : reportDataList) {
				recIdToRptDataMap.put(dataRow.Expense__c, dataRow);
			}													  
		}
			
		List<Profit_Loss_Reporting_Data__c> dataList = new List<Profit_Loss_Reporting_Data__c>();
		Profit_Loss_Reporting_Data__c dataRow;
		for (pse__Expense__c expRow : expList) {
			dataRow = recIdToRptDataMap.get(expRow.Id);
			if (dataRow == null) {
				dataRow = new Profit_Loss_Reporting_Data__c();
			}	
			dataRow.CurrencyISOCode = expRow.CurrencyISOCode;
			dataRow.Account__c = expRow.pse__Project__r.pse__Account__c;	
			dataRow.Amount__c = expRow.pse__Non_Billable_Amount__c;
			dataRow.Category__c = 'Cost';
			dataRow.Type__c = 'Actual';	
			dataRow.Subcategory__c = 'Other Costs';	
			dataRow.Reporting_Month__c = expRow.pse__Expense_Date__c.month();
			dataRow.Reporting_Year__c = expRow.pse__Expense_Date__c.year();
			dataRow.Resource__c = expRow.pse__Resource__c;	
			dataRow.Project__c =  expRow.pse__Project__c;
			dataRow.Reference_Id__c = expRow.Id;
			dataRow.Reference_Type__c = 'Expense';
			dataRow.Expense__c = expRow.Id;
			dataRow.RecordTypeId = recTypeId;
			dataList.add(dataRow);
			expRow.Report_Data_Capture_Date__c = System.Now();
		}	
		upsert dataList;	
		update expList;  
	}  
}