/***************************************
Author        : Appirio India [Hitesh Pareek]
Date          : Feb 20, 2017
Purpose       : S-467680
***************************************/
@isTest
private class ClassEnrollmentsInLineControllerTest {

    static testMethod void testEnrollmentInLineList() {
        Account acc = new Account(name='test Acc');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.id, LastName = 'Test Con');
        insert con;
        
        Product2 prod = new Product2();
        prod.Name = 'testProd';
        insert prod;
        
        SFDC_Class__c cls = new SFDC_Class__c();
        cls.Product2__c = prod.id;
        //cls.Staff_Contact__c = con.id;
        cls.Facility__c = 'London';
        cls.Max_Capacity__c = 30;
        insert cls;        
                
        Class_Enrollment__c enroll = new Class_Enrollment__c();
        enroll.Contact__c = con.id;
        enroll.Class__c = cls.id;
        insert enroll;
        
        Test.startTest();
        PageReference p = Page.ClassEnrollmentsInLine;
        Test.setCurrentPage(p);
        ApexPages.StandardController sc = new ApexPages.StandardController(cls);
        ClassEnrollmentsInLineController ext = new ClassEnrollmentsInLineController(sc);
        system.assert(ext.enrollments.size() >0);
        for(Class_Enrollment__c en :ext.enrollments){
            en.Status__c = 'Prospect';
        }
        ext.SaveEnrollments();
        ext.enrollmentToBedeleted = ext.enrollments.get(0).id;
        ext.deleteEnrollmentRecord();        
        Test.stopTest();
    }
}