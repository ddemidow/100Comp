/**************************************************************************************************
Description:      This Class is used for the Sales Invoice PDF.
                  It retrieves all of the data needed and summarizes as needed.
                  There are two basic types of invoices - Those created from PSA Projects 
Change History: 
Date(MM/DD/YYYY)        Person Responsible              Details 
11/01/2013              Liz Ichihashi                   Created new class.
**************************************************************************************************/
global class FFA_SalesInvoiceController {
    global c2g__codaInvoice__c invoice;  
    global List<SalesInvoiceLineDisplay> lines {get; set;}   
    global String invId {get; set;}
    global Integer rowNum {get; set;}
    global Map<Id, c2g__codaInvoiceLineItem__c> beiIdToInvLineMap = new Map<Id, c2g__codaInvoiceLineItem__c>();    
    global String displayInvName {get; set;}
    global List<pse__Miscellaneous_Adjustment__c> expenseAdjustments;
    global boolean detailsLoaded = false;
     // S-257530 - By Hemlata 
    global String taxCode1Value {get; set;} 
    
    global String getLogo() {
        String retLogo;
        FFA_Invoice_Logo_Setting__c config;
        if (invoice.c2g__Opportunity__c !=  null) {         
            if (invoice.c2g__Opportunity__r.SubGroup__c != null) {
                config = FFA_Invoice_Logo_Setting__c.getInstance(invoice.c2g__Opportunity__r.SubGroup__c);
            } else {
                if (invoice.c2g__Opportunity__r.Group2__c != null) {
                    config = FFA_Invoice_Logo_Setting__c.getInstance(invoice.c2g__Opportunity__r.Group2__c);    
                }
            }
        }   
        if (config != null) {
            retLogo = config.Logo_URL__c;
        }   
        return retLogo;
    }
    
    global with sharing class SalesInvoiceLineDisplay {
        global Integer lineNumber {get; set;}
        global String description {get; set;}   
        global String description2 {get; set;}      
        global Decimal quantity {get; set;}
        global Decimal unitPrice {get; set;}
        global String taxCode {get; set;}
        global Decimal taxValue {get; set;}  
        global String taxRate {get; set;}
        global Decimal netValue {get; set;}
        global String currencyCode {get; set;}
    }  
  
    public FFA_SalesInvoiceController() {
    } 
    
    global FFA_SalesInvoiceController(ApexPages.StandardController stdController) {
        this.invoice = (c2g__codaInvoice__c)stdController.getRecord();
        invId = this.Invoice.Id;
        this.invoice = getInvoice();
        taxCode1Value = Label.SI_Tax_Total;
    }  

    public SalesInvoiceLineDisplay createDisplayFromLine(c2g__codaInvoiceLineItem__c lineRow, String desc2) {
        SalesInvoiceLineDisplay display = new SalesInvoiceLineDisplay();
        display.lineNumber = rowNum;
        if (desc2 != null) {
            display.description2 = desc2;
        }
        display.description = lineRow.c2g__LineDescription__c;  
        display.quantity = lineRow.c2g__Quantity__c;
        display.unitPrice = lineRow.c2g__UnitPrice__c;
        display.netValue = lineRow.c2g__NetValue__c;
        display.taxValue = lineRow.c2g__TaxValueTotal__c;
        display.taxRate = lineRow.c2g__TaxCode1__r.Name + ' at ' + lineRow.c2g__TaxRate1__c;
        lines.add(display);
        rowNum++;
        return display;
    }
    
    global c2g__codaInvoice__c getInvoice() {   
        System.debug('getInvoice().. detailsLoaded='+detailsLoaded);
        List<c2g__codaInvoiceLineItem__c> invLines = new List<c2g__codaInvoiceLineItem__c>();
        if (!detailsLoaded) {
            lines = new List<SalesInvoiceLineDisplay>();
            rowNum = 1;       
            // Added Display_Project_Name_on_Invoice__c in the query by Rahul For Story S-212569
             
            invoice = [Select Name, Owner.Name, 
                        Project__r.Display_Project_Name_on_Invoice__c,
                        c2g__Opportunity__r.Group2__c,
                        c2g__Opportunity__r.SubGroup__c,
                        c2g__Opportunity__r.Discount_Amount__c,
                        c2g__Opportunity__r.Amount,  
                        c2g__Opportunity__r.Participant_Contact__r.Name,
                        c2g__Opportunity__r.Membership_Expires__c,
                        c2g__Opportunity__r.Inv_Desc_Prefix__c,
                        Project__r.Name, 
                        Project__r.Billing_Resource_Rate_Type__c,
                        Payment_Terms__c,
                        c2g__InvoiceDate__c,  
                        c2g__CustomerReference__c, 
                        c2g__DueDate__c,   
                        c2g__NetTotal__c,
                        c2g__InvoiceDescription__c,
                        Billing_Event_Description__c,
                        ffpsai__BillingEvent__c,
                        ffpsai__BillingEvent__r.Name,
                        ffpsai__BillingEvent__r.pse__Project__r.Name,
                        ffpsai__BillingEvent__r.pse__Project__r.pse__Start_Date__c,
                        ffpsai__BillingEvent__r.pse__Project__r.pse__End_Date__c,
                        ffpsai__BillingEvent__r.pse__Project__c, 
                        ffpsai__BillingEvent__r.pse__Billing_Contact__r.Name,
                        c2g__Account__r.c2g__CODAVATRegistrationNumber__c, 
                        c2g__Account__r.Name,
                        c2g__Account__r.BillingStreet, 
                        c2g__Account__r.BillingCity, 
                        c2g__Account__r.BillingState,
                        c2g__Account__r.BillingPostalCode,  
                        c2g__Account__r.BillingCountry, 
                        c2g__Account__r.ShippingStreet, 
                        c2g__Account__r.ShippingCity, 
                        c2g__Account__r.ShippingState,
                        c2g__Account__r.ShippingPostalCode,  
                        c2g__Account__r.ShippingCountry, 
                        c2g__Account__r.c2g__CODADescription1__c,
                        c2g__Account__r.c2g__CODAECCountryCode__c,
                        c2g__InvoiceCurrency__r.Remit_To__c,        
                        c2g__InvoiceCurrency__r.Remit_To_Additional__c,                     
                        c2g__TaxTotal__c,
                        c2g__TaxCode2__c,
                        c2g__Transaction__c,
                        c2g__InvoiceTotal__c,
                        c2g__PaymentSchedule__c,  
                        c2g__InvoiceGroup__r.Name,
                        c2g__InvoiceCurrency__r.Name,
                        c2g__PrintedText1Heading__c,
                        c2g__PrintedText1Text__c,
                        c2g__PrintedText2Heading__c,
                        c2g__PrintedText2Text__c,
                        c2g__PrintedText3Heading__c,
                        c2g__PrintedText3Text__c,
                        c2g__PrintedText4Heading__c,
                        c2g__PrintedText4Text__c,
                        c2g__PrintedText5Heading__c,
                        c2g__PrintedText5Text__c,
                        c2g__OwnerCompany__r.c2g__VATRegistrationNumber__c,
                        c2g__OwnerCompany__r.c2g__ECCountryCode__c ,
                        Invoice_Footer__c,
                        c2g__OwnerCompany__r.Name,
                        c2g__OwnerCompany__r.RecordType.Name,
                        c2g__OwnerCompany__r.c2g__LogoURL__c, 
                        c2g__OwnerCompany__r.c2g__Street__c,
                        c2g__OwnerCompany__r.c2g__City__c,
                        c2g__OwnerCompany__r.c2g__StateProvince__c,
                        c2g__OwnerCompany__r.c2g__ZipPostCode__c,
                        c2g__OwnerCompany__r.c2g__Country__c,
                        c2g__OwnerCompany__r.c2g__Phone__c,
                        c2g__OwnerCompany__r.c2g__Fax__c,                                    
                        c2g__OwnerCompany__r.c2g__Website__c,
                        c2g__OwnerCompany__r.c2g__ContactEmail__c,
                        c2g__Dimension1__r.Name,
                        c2g__Dimension2__r.Name         
                    From c2g__codaInvoice__c where id = :invId]; //Added Owner Name in query KRITIKA BHATI for S-546709 on 03/19/2018
             system.debug('invoice **'+invoice );       
            if (invoice == null) { 
                return null;
            } else {
                invLines = [select Id, 
                        c2g__LineNumber__c,
                        c2g__Product__r.Name,
                        c2g__Product__r.ProductCode,
                        c2g__LineDescription__c,
                        c2g__Quantity__c,
                        c2g__UnitPrice__c,
                        c2g__NetValue__c,
                        c2g__TaxValueTotal__c,
                        c2g__TaxValue1__c,
                        c2g__TaxValue2__c,
                        c2g__TaxValue3__c ,
                        c2g__TaxRate1__c,
                        c2g__TaxCode1__r.Name,
                        ffpsai__BillingEventItem__c                                      
                        from c2g__codaInvoiceLineItem__c
                        where c2g__Invoice__c = :invoice.Id
                        ORDER BY c2g__LineNumber__c];       
            }            
            // S-267219 - Hitesh [Dec 07, 2014] - Start
            displayInvName = invoice.Name.replace('SIN', '');
            boolean allZero = true;
            for(integer i=0; i<=displayInvName.length()-1; i++){
                if(displayInvName.subString(i,i+1).equals('0'))
                    continue;
                else{
                    displayInvName = '#' + displayInvName.subString(i);
                    allZero = false;
                    break;
                }
            }
            if(allZero)
                displayInvName = '#';
            // S-267219 - Hitesh [Dec 07, 2014] - End
                
            if (invoice.ffpsai__BillingEvent__c != null) {   
                /* there is a billing event, so getting related objects to make invoice display lines from */
                for (c2g__codaInvoiceLineItem__c lineRow : invLines) {
                    /* create map of billing event item to invoice line item to be matched up to business objects */
                    if (lineRow.ffpsai__BillingEventItem__c != null) {
                        beiIdToInvLineMap.put(lineRow.ffpsai__BillingEventItem__c, lineRow);
                    }
                }
                //START Added b KRITIKA BHATI for S-546709 on 03/19/2018
               System.debug(invoice.Owner.Name);
                if(invoice.Owner.Name == System.Label.FF_The_Miles_Group_LLC){
                getMilestonesTMG();
               
                }
                else{
                    //END S-546709
                    
                 getMilestones();   
                }// Added b KRITIKA BHATI for S-546709 on 03/19/2018
                getTimecards();                          
                getMiscAdjustments();                                       
                getExpenses();
            } else {
                /* there is no billing event.  just create one display line for the single line invoice from Opportunity */
                if (invLines.size() > 0) {
                    for (c2g__codaInvoiceLineItem__c invLine : invLines) {
                        if (invoice.c2g__Opportunity__c != null) {
                            String grp;
                            SalesInvoiceLineDisplay display = new SalesInvoiceLineDisplay();
                            if (invoice.c2g__Opportunity__r.SubGroup__c != null) {
                                grp = invoice.c2g__Opportunity__r.SubGroup__c;
                            } else {
                                grp = invoice.c2g__Opportunity__r.Group2__c;
                            } 
                            // S-257530 - By Hemlata - Check null condition
                            if (invoice.c2g__Opportunity__r.Membership_Expires__c != null ) {  
                                String dateStr = invoice.c2g__Opportunity__r.Membership_Expires__c.month() + '/' +
                                invoice.c2g__Opportunity__r.Membership_Expires__c.day() + '/' + 
                                invoice.c2g__Opportunity__r.Membership_Expires__c.year();
                            }    
                            // START S-257530 - By Hemlata    
                            // display.description = invoice.c2g__Opportunity__r.Inv_Desc_Prefix__c + ' through ' + dateStr + ' for ' + invoice.c2g__Opportunity__r.Participant_Contact__r.Name;
                            display.description = invoice.c2g__Opportunity__r.Inv_Desc_Prefix__c;
                            // END S-257530 - By Hemlata
                            if (invoice.c2g__Opportunity__r.Discount_Amount__c != null && invoice.c2g__Opportunity__r.Discount_Amount__c > 0) {
                                display.description2 = 'Discount of ' + invoice.c2g__Opportunity__r.Discount_Amount__c  + ' has been applied';
                            }
                            display.quantity = invLine.c2g__Quantity__c;
                            display.unitPrice = invLine.c2g__UnitPrice__c;
                            display.netValue = invLine.c2g__NetValue__c;
                            lines.add(display);  
                        } else {
                            createDisplayFromLine(invLine, null);
                        }
                    }
                }
            }
            // START S-257530 - By Hemlata
            Set<String> taxCode1ValueSets = new Set<String>();
            if (invLines.size() > 0) {
                for (c2g__codaInvoiceLineItem__c invLine : invLines) {
                    if (invLine.c2g__TaxCode1__r.Name != null && invLine.c2g__TaxCode1__r.Name != '') {
                        taxCode1ValueSets.add(invLine.c2g__TaxCode1__r.Name);
                    }    
                }
            }
            system.debug('taxCode1ValueSets***'+taxCode1ValueSets);
            if (taxCode1ValueSets.size() ==0 || taxCode1ValueSets.size() > 1) {
                taxCode1Value = Label.SI_Tax_Total;
            } else if (taxCode1ValueSets.size() == 1) {
                for (String taxValue : taxCode1ValueSets) {
                    taxCode1Value = taxValue;
                }    
            }    
            // END S-257530 - By Hemlata
            detailsLoaded = true;   
        }                                            
        return invoice;         
    }
 private void getMilestones() {
        List<pse__Milestone__c> tempMilestones = [Select Id, Name, pse__Project__r.Name, 
              pse__Billing_Event_Item__c, ffpsai__ServicesProduct__r.Name, pse__Description__c
              From pse__Milestone__c 
              Where pse__Billing_Event_Item__c in :beiIdToInvLineMap.keySet()
              Order by Name];
           
        if (tempMilestones != null && tempMilestones.size() > 0) {
            for (pse__Milestone__c mileRow : tempMilestones) {
                c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(mileRow.pse__Billing_Event_Item__c);
                if (invLine != null) {
                    SalesInvoiceLineDisplay display = createDisplayFromLine(invLine, null);
                    display.description = mileRow.Name; 
                }   
            }   
        }               
    }  
     //START Added b KRITIKA BHATI for S-546709 on 03/19/2018
    private void getMilestonesTMG() {
       
        Map<String, c2g__codaInvoiceLineItem__c> descInvLineMap = new Map<String, c2g__codaInvoiceLineItem__c>();
        Map<String, Decimal> descNetValMap = new Map<String, Decimal>();
        //END S-546709
        List<pse__Milestone__c> tempMilestones = [Select Id, Name, pse__Project__r.Name, 
              pse__Billing_Event_Item__c, ffpsai__ServicesProduct__r.Name, pse__Description__c
              From pse__Milestone__c 
              Where pse__Billing_Event_Item__c in :beiIdToInvLineMap.keySet()
              Order by Name];
           
        if (tempMilestones != null && tempMilestones.size() > 0) {
            for (pse__Milestone__c mileRow : tempMilestones) {
                //START Code modified, commented and added by Kritika BHati for S-546709
                //c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(mileRow.pse__Billing_Event_Item__c);
                c2g__codaInvoiceLineItem__c invLine =  new c2g__codaInvoiceLineItem__c();
                 if(!descInvLineMap.containsKey(mileRow.Name) && !descNetValMap.containsKey(mileRow.Name) ){
                    descInvLineMap.put(mileRow.Name, beiIdToInvLineMap.get(mileRow.pse__Billing_Event_Item__c));
                    descNetValMap.put(mileRow.Name, beiIdToInvLineMap.get(mileRow.pse__Billing_Event_Item__c).c2g__NetValue__c);
                }
                else{
                    invLine = descInvLineMap.get(mileRow.Name);
                    descInvLineMap.put(mileRow.Name, invLine);
                    descNetValMap.put(mileRow.Name, descNetValMap.get(mileRow.Name) + beiIdToInvLineMap.get(mileRow.pse__Billing_Event_Item__c).c2g__NetValue__c);
                }
                /*if (invLine != null) {
                    SalesInvoiceLineDisplay display = createDisplayFromLine(invLine, null);
                    display.description = mileRow.Name; 
                } */  
            }
            for(String str: descInvLineMap.keySet()){
                
              //  c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(str.pse__Billing_Event_Item__c);
                SalesInvoiceLineDisplay display = createDisplayFromLine(descInvLineMap.get(str), null);
                    display.description = str; 
                    display.netValue = descNetValMap.get(str);
            }
          
            
        }               
    }  
      //END S-546709
    
    public void getMiscAdjustments() {
        expenseAdjustments = new List<pse__Miscellaneous_Adjustment__c>();
        List<pse__Miscellaneous_Adjustment__c> tempAdjustments = [Select Id, Name,  pse__Transaction_Category__c,
                                                                Expense_Type__c, pse__Amount__c,
                                                                pse__Description__c, pse__Billing_Event_Item__c
                     From pse__Miscellaneous_Adjustment__c 
                     Where pse__Billing_Event_Item__c in :beiIdToInvLineMap.keySet()
                     Order by Id];
        if (tempAdjustments != null && tempAdjustments.size() > 0) {
            for (pse__Miscellaneous_Adjustment__c miscRow : tempAdjustments) {
                if (miscRow.pse__Transaction_Category__c == 'Pass-Through Ready-to-Bill Revenue' && 
                    miscRow.Expense_Type__c != null) {
                    expenseAdjustments.add(miscRow);
                } else {
                    c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(miscRow.pse__Billing_Event_Item__c);
                    if (invLine != null) {
                        SalesInvoiceLineDisplay disp = createDisplayFromLine(invLine, null);
                        disp.description = miscRow.Name;
                       
                    }   
                }       
            } 
           
        }
    }       
                   
    private void getExpenses() {
        System.debug('beiIdToInvLineMap.keySet()='+beiIdToInvLineMap.keySet());
        List<AggregateResult> tempExpenseResults =  [Select SUM(pse__Billing_Amount__c) amount
                                                     From pse__Expense__c
                                                     Where pse__Billing_Event_Item__c in :beiIdToInvLineMap.keySet()];
        Decimal totAmount = 0;
        SalesInvoiceLineDisplay expLine = new SalesInvoiceLineDisplay();      
        expLine.description = 'Expenses Incurred';
        if (expenseAdjustments.size() > 0) {
            System.debug('expenseAdjustments.size()='+expenseAdjustments.size());
            for (pse__Miscellaneous_Adjustment__c miscRow : expenseAdjustments) {
                System.debug('totAmount='+totAmount);
                c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(miscRow.pse__Billing_Event_Item__c);
                System.debug('invLine='+invLine);
                totAmount += invLine.c2g__NetValue__c;          
            }
            expLine.netValue = totAmount.setScale(2);
        }
        if (tempExpenseResults != null && tempExpenseResults.size() > 0) {  
            System.debug('tempExpenseResults.size()='+tempExpenseResults.size());
            System.debug('tempExpenseResults='+tempExpenseResults);       
            for (AggregateResult tempRow : tempExpenseResults) {
                System.debug('tempRow='+tempRow);
                if (tempRow.get('amount') != null) {
                    totAmount += Double.valueOf(tempRow.get('amount'));        
                    System.debug('final totAmount.='+totAmount);
                   
                    System.debug('expLine');
                }    
            }    
            expLine.netValue = totAmount.setScale(2);
        }     
        if (totAmount > 0) {
            lines.add(expLine);
        }           
    }
    
    private void getTimecards() {
        Set<Id> timecardsToSummAll = new Set<Id>();
        Set<Id> timecardsToSummByDay = new Set<Id>();
        Set<Id> timecardsToSummByResource = new Set<Id>();
    
        List<pse__Timecard__c> tempTimecards = 
                            [SELECT Id, 
                            pse__Milestone__c,  
                            pse__Milestone__r.Name,
                            pse__Timecard_Header__c,
                            pse__Billing_Event_Item__c, 
                            CurrencyIsoCode
                        FROM pse__Timecard__c
                       WHERE pse__Billing_Event_Item__c in :beiIdToInvLineMap.keySet()
                       ORDER BY pse__Milestone__r.Name];
        if (tempTimecards != null && tempTimecards.size() > 0) {
            for (pse__Timecard__c timeRow : tempTimecards) {
                c2g__codaInvoiceLineItem__c invLine = beiIdToInvLineMap.get(timeRow.pse__Billing_Event_Item__c);
                if (invLine != null) {
                    if (invoice.Project__r.Billing_Resource_Rate_Type__c == 'All') {
                        timecardsToSummAll.add(timeRow.Id);                                              
                    } else {
                        timecardsToSummByResource.add(timeRow.Id);                           
                    }
                }       
            } 
            if (timecardsToSummAll.size() > 0) {
                createTimecardDisplaySumAll(timecardsToSummAll);
            }     
              
            if (timecardsToSummByResource.size() > 0) {
                createTimecardDisplaySumResource(timecardsToSummByResource);    
            }              
        }      
    }   
                       
    public void createTimecardDisplaySumAll(Set<Id> timecardList) {
        /* group timecards by Milestone */
        List<AggregateResult> tempResults = [Select 
                                             SUM(Total_Billable_Amount_Number__c) amt,
                                             SUM(pse__Total_Hours__c) hrs,
                                             CurrencyIsoCode curr,
                                             pse__Milestone__r.Name mileName
                                             From pse__Timecard__c
                                             Where id in :timecardList
                                             group by CurrencyIsoCode, pse__Milestone__r.Name
                                             Order by CurrencyIsoCode, pse__Milestone__r.Name];
        for (AggregateResult tempRow : tempResults) {
            SalesInvoiceLineDisplay display = new SalesInvoiceLineDisplay();
            String mileName = String.valueOf(tempRow.get('mileName'));
            Double hrs = Double.valueOf(tempRow.get('hrs'));
            Double amt = Double.valueOf(tempRow.get('amt'));
            String currCode = String.valueOf(tempRow.get('curr'));
            // S-257530 - By Hemlata Changed from Timecards to Fees
            display.description = mileName + ' Fees';
            display.netValue = amt;
            lines.add(display);
        }           
    }       
    
    public void createTimecardDisplaySumResource(Set<Id> timecardList) {
        /* group timecards by Resource */
        List<AggregateResult> tempResults = [
                select 
                SUM(Total_Billable_Amount_Number__c) billAmt,
                SUM(pse__Total_Hours__c) totHrs,
                MAX(Bill_Rate_Number__c) billRt,
                CurrencyIsoCode, 
                pse__Resource__r.Name resource,
                pse__Assignment__c assign,
                pse__Assignment__r.pse__Daily_Bill_Rate__c isDaily
                from pse__Timecard__c
                where ID in :timecardList
                group by CurrencyIsoCode, pse__Resource__r.Name, pse__Assignment__c, pse__Assignment__r.pse__Daily_Bill_Rate__c
                order by CurrencyIsoCode, pse__Resource__r.Name, pse__Assignment__c, pse__Assignment__r.pse__Daily_Bill_Rate__c];
        for (AggregateResult tempRow : tempResults) {
            SalesInvoiceLineDisplay display = new SalesInvoiceLineDisplay();
            String resourceName = String.valueOf(tempRow.get('resource'));
            Decimal amt = Double.valueOf(tempRow.get('billAmt'));
            Decimal hrs = Double.valueOf(tempRow.get('totHrs'));
            Decimal rate = Double.valueOf(tempRow.get('billRt'));
            amt = amt.setScale(2);
            hrs = hrs.setScale(2);
            rate = rate.setScale(2);
            String isDaily = String.valueOf(tempRow.get('isDaily'));
            System.debug('isDaily='+isDaily);
            Decimal days = hrs / 8;
            Decimal dailyRate = 0;
            Decimal hourlyRate = 0;
            if  (isDaily == 'true') {
                /* daily rate, don't need to convert */
                dailyRate = rate;
                hourlyRate = (rate/8).setScale(2);
            } else {
                /* hourly rate, need to get daily */
                dailyRate = (rate * 8).setScale(2);
                hourlyRate = rate;
            }
            System.debug('hourlyRate='+hourlyRate);
            System.debug('dailyRate='+dailyRate);
            if (invoice.Project__r.Billing_Resource_Rate_Type__c == 'Resource By Day') {
                display.description = resourceName + ':  ' + days + ' days at ' + dailyRate + '/day';
            } else if (invoice.Project__r.Billing_Resource_Rate_Type__c == 'Resource By Hour') {
                display.description = resourceName + ':  ' + hrs + ' hours at ' + hourlyRate + '/hour';
            }   
            display.netValue = amt;
            lines.add(display);
        }               
    }
}