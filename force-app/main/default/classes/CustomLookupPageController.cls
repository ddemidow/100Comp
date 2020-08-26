/*
 * Appirio, Inc
 * Name: CustomLookupPageController
 * Description: [S-551675]
 * Created Date: 16 April 2018
 * Created By: Kumari Purnima (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 */

public with sharing class CustomLookupPageController {
 
    public Boolean render1 { get; set; }
    List<Account> records=new List<Account>();
    public String searchvalue { get; set; }
 
    public CustomLookupPageController()
    {
        try
        {    
            searchvalue=ApexPages.currentPage().getParameters().get('parentname');
            String id=ApexPages.currentPage().getParameters().get('parentid');
 
            if(String.IsNotBlank(searchvalue)){
                render1=true;
                records=[Select Id, Name, BillingCountry, Industry, AnnualRevenue, TickerSymbol, sic, Fortune__c from Account where Name like :+searchvalue+'%' order by Name asc Limit 50];
            }
            else
            {
                render1=true;
                records=[Select Id, Name, BillingCountry, Industry, AnnualRevenue, TickerSymbol, sic, Fortune__c from Account order by Name asc limit 50];
 
            }
        }
        catch(Exception e)
        {
        }
    }
 
    public List<Account> getRecords() {
        if(records.size()!=0)
        {
            return records;
        }else
        {
            return null;
        }
    }
 
    public PageReference onkeyupAction() {
        searchAction();
        return null;
    }
 
    public PageReference searchAction() {
        render1=true;
        records=[Select Id, Name, BillingCountry, Industry, AnnualRevenue, TickerSymbol, sic, Fortune__c from Account where Name like :+searchvalue+'%' order by Name asc limit 50];
        if(records.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,'No Records Found'));
        }
        return null;
    }
}