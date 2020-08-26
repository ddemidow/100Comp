@isTest

private class Bth_MaintainRptBalanceOnDealSheet_Test{

    static testMethod void Batch_MaintainReportBalanceOnDealSheet(){
    
    Contact c = new Contact();
    c.LastName = 'Test';
    c.pse__Resource_Role__c = 'SSA Associate Consultant';
    insert c;
    
    c2g__codaCompany__c newCompany = new c2g__codaCompany__c(Name='TestCo123');
    insert newCompany;
        
    Deal_Sheet__c deal = new Deal_Sheet__c();   
    pse__Proj__c p = new pse__Proj__c();
    //Account acc = new Account();
    pse__Region__c reg = new pse__Region__c();
    reg.Name ='Region Name SSA Mentore';
    reg.ffpsai__OwnerCompany__c = newCompany.Id;
    insert reg;
    //p.pse__Account__c = acc.Id;
    p.Name = 'Name'; 
    p.pse__Region__c = reg.Id;
    p.pse__Project_Type__c = 'Customer';
    p.pse__Is_Active__c = true;
    p.Sector_Practice__c = 'Financial Services';
    insert p;
     
    deal.Engagement_Manager__c = c.Id;
    deal.Project__c = p.Id;
    deal.Project_Name__c = 'Test Name';
        
    deal.Create_Delete_Reporting_Balance__c = true;
    deal.Prevailing_Version__c = true;
    insert deal; 
    deal.Prevailing_Version__c = false;
    update deal;
        
    List<Deal_Sheet__c> dealList = new List<Deal_Sheet__c>();
    dealList.add(deal);
    
    Deal_Sheet_Line_Item__c dsl = new Deal_Sheet_Line_Item__c();
    dsl.Line_Type__c = 'Resource';
    dsl.Role__c = 'Independent Contractor';
    dsl.Deal_Sheet__c = deal.Id;
    dsl.Suggested_Resource__c = c.Id;
    insert dsl;
    
    Batch_MaintainReportBalanceOnDealSheet cb = new Batch_MaintainReportBalanceOnDealSheet(); 
    Database.QueryLocator ql = cb.start(null);
    Database.executeBatch(cb,200);
    
    //Start
    /*c2g__ReportingBalance__c reportBalance = new c2g__ReportingBalance__c();
    reportBalance.c2g__OwnerCompany__c='a1L2A000004gv2l';
    insert reportBalance;
    *///Stop for case 254740
    //Database.Finish(cb);
        
    /*c2g__codaPeriod__c cg = new c2g__codaPeriod__c();
    c2g__codaYear__c cgYear = new c2g__codaYear__c();
    c2g__codaCompany__c cgCompany = new c2g__codaCompany__c();
    cg.c2g__YearName__c = cgYear.Id;
    cg.c2g__OwnerCompany__c = cgCompany.Id;
    insert cg;
    
    c2g__ReportingBalance__c cgr = new c2g__ReportingBalance__c();
    
    
    delete deal; 
    
    c2g__ReportingBalance__c reportBalance = new c2g__ReportingBalance__c();
    
    insert reportBalance; 
    */  
    
    }
}