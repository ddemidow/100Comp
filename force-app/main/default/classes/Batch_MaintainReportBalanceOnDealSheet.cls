/**
 *  Purpose         :   This class is used to create or delete the Reporting Balances on Deal Sheets.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   11/05/2015
 *
 *  Current Version :   V_1.1
 *
 *  Revision Log    :   V_1.0 - Created - S-361837
                        V_1.1 - Modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977
 **/
global class Batch_MaintainReportBalanceOnDealSheet implements Database.Batchable<sObject> {

    //All Code uncommented - Padmesh Soni (11/06/2015 - Appirio Offshore) - S-361837
    public final String RB_TYPE_DIRECT_SALARY_STAFF = 'Direct Salary Staff';
    public final String RB_TYPE_DIRECT_IC_EXPENSE = 'Direct Independent Contractor Expense';
    public final String RB_TYPE_REVENUE_INDIRECT_EXPENSE_FEE = 'Revenue Indirect Expense Fee';
    public final String RB_TYPE_REVENUE_PROF_SERVICES_FEES = 'Revenue Professional Services';
    public final String COMPANY_SSA_COMPANY_LLC = 'SSA & Company, LLC';

    public final String LINE_TYPE_RESOURCE = 'Resource';
    public final String LEVEL_INDEPENDENT_CONTRACTOR = 'Independent Contractor';

    public Map<String, Id> RBTYPE_GEN_LEDGER_ACC_MAP = new Map<String, Id>{RB_TYPE_REVENUE_PROF_SERVICES_FEES => 'a1dF0000000BXfX', RB_TYPE_DIRECT_SALARY_STAFF => 'a1dF0000000BXfi',
    RB_TYPE_DIRECT_IC_EXPENSE  => 'a1dF0000000BXfm', RB_TYPE_REVENUE_INDIRECT_EXPENSE_FEE => 'a1dF0000000BXfc'};

    //Start method definition of Batchable interface abstract method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #Start
        //Getting query result from Deal Sheet sobject
        return Database.getQueryLocator([SELECT Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, Managing_Director__c,
                                            Project__r.Dimension4__c, Create_Delete_Reporting_Balance__c FROM Deal_Sheet__c
                                            WHERE Create_Delete_Reporting_Balance__c = true AND Prevailing_Version__c = true]);
        //Code modified - Shubham Paboowal (Appirio Offshore - 12/15/2015) - Case #: 00143977 #End
    }

    //Execute method definition of Batchable interface abstract method
    global void execute(Database.BatchableContext BC, List<Deal_Sheet__c> scope) {

        //Call method from trigger handler to process further updates
        populateRptBalanceRecords(scope);

        //Loop through scope results
        for(Deal_Sheet__c dealSheet : scope) {

            dealSheet.Create_Delete_Reporting_Balance__c = false;
        }

        //Perform DML Operation on list of Deal Sheet
        update scope;
    }

    //Finish method definition of Batchable interface abstract method
    global void finish(Database.BatchableContext BC) {

        //TBD: Need to uncomment after QA/UAT done
        //Execute the batch to delete the orphan Report Balances'
        Database.executeBatch(new Batch_DelReportBalanceWithoutDealSheet(), 200);
    }

    public void populateRptBalanceRecords(List<Deal_Sheet__c> DealSheets){

        deleteOldRptBalanceRecords(DealSheets);

        Set<String> allPeriodsSet = new Set<String>();
        Map<Id, Set<String>> dsPrdsSetMap = new Map<Id, Set<String>>();

        for(Deal_Sheet__c ds : DealSheets){

            if(ds.Start_Date__c != null && ds.End_Date__c != null){

                Set<String> prdSet = getPeriods(ds.Start_Date__c, ds.End_Date__c);

                allPeriodsSet.addAll(prdSet);

                if(!dsPrdsSetMap.containsKey(ds.Id)){
                  dsPrdsSetMap.put(ds.Id, prdSet);
                }
            }
        }

        Map<String,List<c2g__codaPeriod__c>> periodRecordsMap = getperiodMap(allPeriodsSet);

        List<c2g__ReportingBalance__c> rptBalanceLstToInsert = new List<c2g__ReportingBalance__c>();

        for(Deal_Sheet__c ds : [Select Id, Start_Date__c, End_Date__c, Bill_Indirect_Expenses__c, Indirect_Expenses__c, Client__c, Managing_Director__c, Project__r.Dimension4__c,
                               (Select Id, Total_Cost__c, Total_Revenue__c, Line_Type__c, Role__c, Start_Date__c, End_Date__c
                                 From Deal_Sheet_Line_Items__r)
                               From Deal_Sheet__c
                               WHERE Id IN: DealSheets]){
            
            //Code moved from outer loop to inner loop
            List<Deal_Sheet_Line_Item__c> indepContractorDSLILst = new List<Deal_Sheet_Line_Item__c>();
        
            if(ds.Start_Date__c == null || ds.End_Date__c == null){
                continue;
            }

            Set<String> periodsSet = getPeriods(ds.Start_Date__c, ds.End_Date__c);

            Decimal directLabourCost = 0;
            Decimal indepContractorCost = 0;
            Decimal profServicesRevenueTotal = 0;
            Decimal indirectExpenseTotal = 0;
            Date ICStartDate, ICEndDate;

            for(Deal_Sheet_Line_Item__c dsli : ds.Deal_Sheet_Line_Items__r){

                //Direct Labor records values = Total of 'Total Cost' field values of all the find records / difference number that we find in the point #2.b
                //(Line type = Resource) and (Level != Independent Contractor)
                if(dsli.Total_Cost__c != null && dsli.Line_Type__c == LINE_TYPE_RESOURCE && dsli.Role__c != LEVEL_INDEPENDENT_CONTRACTOR){
                  directLabourCost += dsli.Total_Cost__c;
                }

                //Independent Contractor records values = Total of 'Total Cost' field values of all the find records / difference number that we find in the point #2.b
                //(Line type = Resource) and (Level == Independent Contractor)
                if(dsli.Total_Cost__c != null && dsli.Start_Date__c != null && dsli.End_Date__c != null && dsli.Line_Type__c == LINE_TYPE_RESOURCE && dsli.Role__c == LEVEL_INDEPENDENT_CONTRACTOR){

                    if(ICStartDate == null || ICStartDate > dsli.Start_Date__c){
                        ICStartDate = dsli.Start_Date__c;
                    }

                    if(ICEndDate == null || ICEndDate < dsli.End_Date__c){
                        ICEndDate = dsli.End_Date__c;
                    }

                    indepContractorDSLILst.add(dsli);
                }

                //Revenue records values = Total of 'Revenue' field values of all the find records / difference number that we find in the point #2.b
                if(dsli.Total_Revenue__c != null){
                    profServicesRevenueTotal += dsli.Total_Revenue__c;
                }
            }

            //Indirect records values = value that we got on point #2.h * Deal_sheet__c.Indirect_Expense_Rate__c
            if(ds.Bill_Indirect_Expenses__c && ds.Indirect_Expenses__c != null){
                indirectExpenseTotal = ds.Indirect_Expenses__c;
            }

            Integer repBalanceCount = periodsSet.size();

            for(String prdName : periodsSet){

                if(repBalanceCount != 0) {

                    if(directLabourCost != 0 ) {
                        rptBalanceLstToInsert.add(createRptBalanceRecords(ds, directLabourCost/repBalanceCount, RB_TYPE_DIRECT_SALARY_STAFF, periodRecordsMap.get(prdName)));
                    }

                    if(indirectExpenseTotal != 0 ) {
                        rptBalanceLstToInsert.add(createRptBalanceRecords(ds, -indirectExpenseTotal/repBalanceCount, RB_TYPE_REVENUE_INDIRECT_EXPENSE_FEE, periodRecordsMap.get(prdName)));
                    }

                    if(profServicesRevenueTotal != 0 ) {
                        rptBalanceLstToInsert.add(createRptBalanceRecords(ds, -profServicesRevenueTotal/repBalanceCount, RB_TYPE_REVENUE_PROF_SERVICES_FEES, periodRecordsMap.get(prdName)));
                    }
                }
            }
            if(indepContractorDSLILst.size() > 0){

                  rptBalanceLstToInsert.addAll(createRBforDirectIC(ds, indepContractorDSLILst, ICStartDate, ICEndDate, periodRecordsMap));
            }
        }
      
        //ADDED by Rohit For S-635394
        try{
            if(rptBalanceLstToInsert.size() > 0){
              insert rptBalanceLstToInsert;
            }
        }
        catch(DmlException e) {
            system.debug('exception'+e.getDmlFields(0));
        }
        
    }

    private List<c2g__ReportingBalance__c> createRBforDirectIC(Deal_Sheet__c ds, List<Deal_Sheet_Line_Item__c> dsliLst, Date StartDate, Date EndDate, Map<String,List<c2g__codaPeriod__c>> periodRecordsMap){

        Set<String> periodsSet = getPeriods(StartDate, EndDate);
        Map<Id, Set<String>> dsliPeriodsSetMap = new Map<Id, Set<String>>();

        List<c2g__ReportingBalance__c> rptBalanceLst = new List<c2g__ReportingBalance__c>();

        for(Deal_Sheet_Line_Item__c dsli : dsliLst){
          dsliPeriodsSetMap.put(dsli.Id, getPeriods(dsli.Start_Date__c, dsli.End_Date__c));
        }
        
        System.debug('dsliPeriodsSetMap ::::'+  dsliPeriodsSetMap);
        System.debug('periodsSet ::::'+  periodsSet);
        
        for(String prdName : periodsSet){
            Decimal totalCost = 0;
            Set<String> prdSet;

            for(Deal_Sheet_Line_Item__c dsli : dsliLst){



                prdSet = dsliPeriodsSetMap.get(dsli.Id);

                if(prdSet.contains(prdName)){
                    totalCost += prdSet.size() != 0 ? dsli.Total_Cost__c/prdSet.size() : 0;
                }
            }

            if(totalCost != 0) {
                rptBalanceLst.add(createRptBalanceRecords(ds, totalCost, RB_TYPE_DIRECT_IC_EXPENSE, periodRecordsMap.get(prdName)));
            }
        }
        return rptBalanceLst;
    }

    //delete existing c2g__ReportingBalance__c records for the DealSheets
    private void deleteOldRptBalanceRecords(List<Deal_Sheet__c> DealSheets){

        Set<Id> setDealShetIds = new Set<Id>();

        for(Deal_Sheet__c ds : DealSheets) {
            setDealShetIds.add(ds.id);
        }

        List<c2g__ReportingBalance__c> rptBalLstToDel = new List<c2g__ReportingBalance__c>([Select Id From c2g__ReportingBalance__c WHERE Deal_Sheet__c IN: setDealShetIds]);

        if(rptBalLstToDel.size() > 0){
            delete rptBalLstToDel;
        }
    }

    //Method to create c2g__ReportingBalance__c record from passed parameters
    private c2g__ReportingBalance__c createRptBalanceRecords(Deal_Sheet__c crntDS, Decimal dualAmt, String rbType, List<c2g__codaPeriod__c> prd){

        c2g__ReportingBalance__c reportingBalance = new c2g__ReportingBalance__c(

        Deal_Sheet__c = crntDS.Id,
        c2g__Account__c = crntDS.Client__c,
        Managing_Director__c = crntDS.Managing_Director__c,
        c2g__Dimension4__c = crntDS.Project__r.Dimension4__c,
        c2g__OwnerCompany__c = (crntDS.Managing_Director__c == '005F0000002tkLm' ? 'a1LF00000016UGO' : 'a1LF00000016UGJ'),
        c2g__Dimension1__c = (crntDS.Managing_Director__c == '005F0000002tkLm' ? 'a1UF0000000GQMl' : 'a1UF0000000EzzB'),
        c2g__Dimension2__c = 'a1VF00000026Vgv',
        c2g__Type__c = 'Deal Sheet',
        c2g__DualValue__c = dualAmt,
        c2g__GeneralLedgerAccount__c = RBTYPE_GEN_LEDGER_ACC_MAP.get(rbType),
        c2g__Product__c = (RBTYPE_GEN_LEDGER_ACC_MAP.get(rbType) == 'a1dF0000000BXfc' ? '01tF00000031iRa' : null),
        OwnerId = '005F0000002bcZm');  //DAN HERRERO user
        //c2g__Period__c = prdId);
        system.debug('prd'+prd);
        
        if(crntDS.Managing_Director__c == '005F0000002tkLm' && prd!=null) {		//MODIFIED by Rohit For S-635394
            for(c2g__codaPeriod__c p : prd) {
                if(p.c2g__OwnerCompany__c == 'a1LF00000016UGO') {
                    reportingBalance.c2g__Period__c = p.id ;
                }
            }
        } else if(prd!=null){		//MODIFIED by Rohit For S-635394
            for(c2g__codaPeriod__c p : prd) {
                if(p.c2g__OwnerCompany__c == 'a1LF00000016UGJ') {
                    reportingBalance.c2g__Period__c = p.id ;
                }
            }
        }
        return reportingBalance;
    }

    private Map<String, List<c2g__codaPeriod__c>> getPeriodMap(Set<String> allPeriodsSet){

        Map<String,List<c2g__codaPeriod__c>> periodMap = new Map<String, List<c2g__codaPeriod__c>>();
        for(c2g__codaPeriod__c prd : [Select Id, Name, c2g__OwnerCompany__c
                                      From c2g__codaPeriod__c
                                      WHERE Name IN: allPeriodsSet
                                      AND (c2g__OwnerCompany__c = 'a1LF00000016UGO' or c2g__OwnerCompany__c = 'a1LF00000016UGJ')]){

          if(!periodMap.containsKey(prd.Name)) {
            periodMap.put(prd.Name, new List<c2g__codaPeriod__c>());
          }

          periodMap.get(prd.Name).add(prd);
        }
        return periodMap;
    }

    private Set<String> getPeriods(Date startDate, Date endDate){

        Set<String> prdSet = new Set<String>();

        if(startDate != null && endDate != null){

            Integer monthCount = startDate.monthsBetween(endDate) +1;

            Integer yr = startDate.year();
            Integer month = startDate.month();
            String prd;

            for(Integer i = 1; i<= monthCount; i++){

              prd = yr + '/0' + (month < 10 ? '0' + String.valueOf(month) : String.valueOf(month));
              month++;

              if(month ==  13){
                month = 1;
                yr++;
              }
              prdSet.add(prd);
            }
        }
        return prdSet;
    }
}