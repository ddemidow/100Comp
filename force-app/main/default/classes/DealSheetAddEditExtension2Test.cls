/***************************************************************
Author     : Appirio [Hitesh - Dec 11, 2014]
Purpose    : Test class for the extension class - DealSheetAddEditExtension2.cls
Modifications:
           8.18.15     Nick Sharp     S-334593     Modified
*************************************************************/

@isTest
Public class DealSheetAddEditExtension2Test{
  
    static testmethod void testwithOutId(){
        Test.setCurrentPage(Page.DealSheetAddEditPage2);
            //START NSHARP S-334593 8.18.15
            ResourceParameter__c resourceParameter = new ResourceParameter__c();
            resourceParameter.Name = 'roleList';
            resourceParameter.roles__c = 'SSA Business Analyst,SSA Associate Consultant,SSA Associate Director,SSA Director,SSA Senior Director,SSA Vice President';
            insert resourceParameter;
            //END NSHARP S-334593 8.18.15

            Test.startTest();
               DSLIFieldLengths__c testcs = new DSLIFieldLengths__c();//Added by Nishank for Story S-299054
               testcs.Name='Billable Days';//Added by Nishank for Story S-299054
               testcs.IsFormula__c=true;//Added by Nishank for Story S-299054
               testcs.Length_In_Pixels__c=60;//Added by Nishank for Story S-299054
               Insert testcs;//Added by Nishank for Story S-299054
                Deal_Sheet__c ds = new Deal_Sheet__c();
                ds.Project_Name__c = 'testproj';
                DealSheetAddEditExtension2 extension = new DealSheetAddEditExtension2(new ApexPages.StandardController(ds));
                extension.init();
                //START NSHARP S-334593 8.18.15
                extension.skill_1 = null;
                extension.skill_2 = null;
                extension.skill_3 = null;
                extension.searchResources();
                //END NSHARP S-334593 8.18.15
                extension.createTimeHeaderRecordAction();
                System.assertNotEquals(ds.id,null);
                extension.saveAll();
                extension.saveDealSheet();
                extension.cloneDealSheet();   
                extension.addNewRows(); //Added by Nishank for Story S-299054
                extension.refreshWindow();//Added by Nishank for Story S-299054  
                ApexPages.currentPage().getParameters().put('param1', '0');
                extension.deleteRow();//Added by Nishank for Story S-299054 
                extension.saveAndClose();
            Test.stopTest();
    }

    //START NSHARP S-334593 8.18.15
    static testmethod void searchResourcesTest(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        ResourceParameter__c resourceParameter = new ResourceParameter__c();
        resourceParameter.Name = 'roleList';
        resourceParameter.roles__c = 'SSA Business Analyst,SSA Associate Consultant,SSA Associate Director,SSA Director,SSA Senior Director,SSA Vice President';
        insert resourceParameter;

        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.pse__Is_Resource__c = true;
        con.pse__Resource_Role__c = 'SSA Business Analyst';
        con.pse__Is_Resource_Active__c = true;
        insert con;

        pse__Skill__c skill1 = new pse__Skill__c();
        skill1.Name = 'Test Skill';
        skill1.pse__Type__c = 'Certification';
        insert skill1;

        pse__Skill__c skill2 = new pse__Skill__c();
        skill2.Name = 'Test Skill 2';
        skill2.pse__Type__c = 'Certification';
        insert skill2;

        pse__Skill__c skill3 = new pse__Skill__c();
        skill3.Name = 'Test Skill 3';
        skill3.pse__Type__c = 'Certification';
        insert skill3;

        pse__Skill_Certification_Rating__c rating3 = new pse__Skill_Certification_Rating__c();
        rating3.pse__Rating__c = '2 - Very Inexperienced';
        rating3.pse__Resource__c = con.Id;
        rating3.pse__Skill_Certification__c = skill3.Id;
        insert rating3;
        
        pse__Skill_Certification_Rating__c rating2 = new pse__Skill_Certification_Rating__c();
        rating2.pse__Rating__c = '2 - Very Inexperienced';
        rating2.pse__Resource__c = con.Id;
        rating2.pse__Skill_Certification__c = skill2.Id;
        insert rating2;

        pse__Skill_Certification_Rating__c rating1 = new pse__Skill_Certification_Rating__c();
        rating1.pse__Rating__c = '2 - Very Inexperienced';
        rating1.pse__Resource__c = con.Id;
        rating1.pse__Skill_Certification__c = skill1.Id;
        insert rating1;

        Test.startTest();
           DSLIFieldLengths__c testcs = new DSLIFieldLengths__c();//Added by Nishank for Story S-299054
           testcs.Name='Billable Days';//Added by Nishank for Story S-299054
           testcs.IsFormula__c=true;//Added by Nishank for Story S-299054
           testcs.Length_In_Pixels__c=60;//Added by Nishank for Story S-299054
           Insert testcs;//Added by Nishank for Story S-299054
            Deal_Sheet__c ds = new Deal_Sheet__c();
            ds.Project_Name__c = 'testproj';
            insert ds;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(ds);
            DealSheetAddEditExtension2 extension = new DealSheetAddEditExtension2(sc);
            PageReference pageRef = Page.DealSheetAddEditPage2;
            Test.setCurrentPage(pageRef);
            extension.skill_1 = rating1;
            extension.skill_2 = rating2;
            extension.skill_3 = rating3;
            extension.init();
            extension.createTimeHeaderRecordAction();
            extension.searchResources();
            extension.getDisableEnableFields();
            extension.updateTotals(); // Added for the story #S-349314
            extension.saveAll();
            extension.saveDealSheet();
            extension.selectedRowIndexToDelete = '2';
            extension.cloneDealSheet();   
            extension.addNewRows(); //Added by Nishank for Story S-299054
            extension.updateTotals(); //Added by harendra for S-368446
            Integer hrsDiff = extension.HoursBetweenTwoDates(date.newInstance(2016,1,8),date.newInstance(2016,1,4)); //Added by harendra for S-368446
            System.assertEquals(hrsDiff, 5);
            extension.refreshWindow();//Added by Nishank for Story S-299054  
            extension.deleteRow();//Added by Nishank for Story S-299054 
            extension.goBack();
        Test.stopTest();
    }
    //END NSHARP S-334593 8.18.15
}