/**************************************************************************************
Name        : ResourcePlannerReminderBatch
Created By  : Appirio India(Nimisha Prashant)
Date        : 11th May,2016
Purpose     : S-408902
****************************************************************************************/

global class ResourcePlannerReminderBatch implements Database.Batchable<sObject>, Schedulable {
    
    global final String query;
    
    global ResourcePlannerReminderBatch() {
        String q = '';
        q += 'SELECT Id, pse__Start_Date__c, pse__End_Date__c, pse__Estimated_Hours__c, ';
        q += 'pse__Resource__c, pse__Resource__r.Name, pse__Resource__r.pse__Exclude_from_Resource_Planner__c, pse__Resource__r.pse__Salesforce_User__c, ';
        q += 'pse__Assignment__c, pse__Assignment__r.pse__Exclude_from_Planners__c ';
        q += 'FROM pse__Est_Vs_Actuals__c ';
        q += 'WHERE pse__Start_Date__c = THIS_WEEK ';
        if(!Test.isRunningTest()) {
            q += 'AND pse__End_Date__c = THIS_WEEK ';
        }
        q += 'AND pse__Resource__r.pse__Exclude_from_Resource_Planner__c = false AND pse__Assignment__r.pse__Exclude_from_Planners__c = false';
        if(Test.isRunningTest()) {
            q += ' limit 10';
        }
        //q += ' AND pse__Resource__c = \'003F0000024MOLNIA4\''; //Added for testing
        query = q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<pse__Est_Vs_Actuals__c> scope) {
        Map<String, List<pse__Est_Vs_Actuals__c>> mapResourceAssignmentToEstActuals = new Map<String, List<pse__Est_Vs_Actuals__c>>();
        for(pse__Est_Vs_Actuals__c estActuals : scope) {
            if(estActuals.pse__Resource__c != null && estActuals.pse__Assignment__c != null) {
                //Start I-218441 
                /*String resourceAssignmentKey = estActuals.pse__Resource__c + '~' + estActuals.pse__Assignment__c;
                if(!mapResourceAssignmentToEstActuals.containsKey(resourceAssignmentKey)) {
                    mapResourceAssignmentToEstActuals.put(resourceAssignmentKey, new List<pse__Est_Vs_Actuals__c>());
                }
                mapResourceAssignmentToEstActuals.get(resourceAssignmentKey).add(estActuals);*/
                if(!mapResourceAssignmentToEstActuals.containsKey(estActuals.pse__Resource__c)) {
                    mapResourceAssignmentToEstActuals.put(estActuals.pse__Resource__c, new List<pse__Est_Vs_Actuals__c>());
                }
                mapResourceAssignmentToEstActuals.get(estActuals.pse__Resource__c).add(estActuals);
                //End I-218441 
            }
        }
        
        List<EmailTemplate> template = new List<EmailTemplate>([SELECT Id, DeveloperName, Subject, HtmlValue, Body 
                                                                FROM EmailTemplate 
                                                                WHERE DeveloperName = :Constants.REMINDER_TEMPLATE_NAME]);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(String resourceAssignmentKey : mapResourceAssignmentToEstActuals.keySet()) {
            Decimal estimatedHoursSum = 0.0;
            for(pse__Est_Vs_Actuals__c estActuals : mapResourceAssignmentToEstActuals.get(resourceAssignmentKey)) {
                estimatedHoursSum += estActuals.pse__Estimated_Hours__c;
            }
            if(estimatedHoursSum > 0) {
                continue;
            }
            if(!mapResourceAssignmentToEstActuals.get(resourceAssignmentKey).isEmpty()) {
                pse__Est_Vs_Actuals__c estVsActuals = mapResourceAssignmentToEstActuals.get(resourceAssignmentKey)[0];
                if(template.size() >0 ){
                    
                    String email_Body = template.get(0).HtmlValue;
                    String Subject = template.get(0).Subject;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(estVsActuals.pse__Resource__r.pse__Salesforce_User__c != null)
                        mail.setTargetObjectId(estVsActuals.pse__Resource__r.pse__Salesforce_User__c);
                    else
                        mail.setTargetObjectId(estVsActuals.pse__Resource__c);  
                        
                    email_Body = email_Body.replaceAll('<!\\[CDATA\\[', '');
                    email_Body = email_Body.replaceAll('\\]\\]>', '');
                    email_Body = email_Body.replace('{!pse__Est_Vs_Actuals__c.pse__Resource__r.Name}', estVsActuals.pse__Resource__r.Name);
                    email_Body = email_Body.replace('{!pse__Est_Vs_Actuals__c.pse__Start_Date__c}', estVsActuals.pse__Start_Date__c.format());
                    email_Body = email_Body.replace('{!pse__Est_Vs_Actuals__c.pse__End_Date__c}', estVsActuals.pse__End_Date__c.format());
                    email_Body = email_Body.replace('{!pse__Est_Vs_Actuals__c.Link}', URL.getSalesforceBaseUrl().toExternalForm() + Page.pse__ResourcePlanner.getUrl() + '?Id=' + estVsActuals.pse__Resource__r.pse__Salesforce_User__c);
                    
                    mail.setSubject(Subject);
                    mail.SetHTMLBody(email_Body);
                    mail.setSaveAsActivity(false);
                    
                    emails.add(mail);
                }
            }
        }
        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    global void execute(SchedulableContext sc){
       ResourcePlannerReminderBatch planReminder = new ResourcePlannerReminderBatch();
       Database.executeBatch(planReminder, 200);
    }
}