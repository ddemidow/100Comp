/**
 *  Purpose         :   This class is used to notify different user on Coaching Task dues as per below:
 *                          (1) If a task falls more than 3 weeks behind, the 'first chair' and 'assigned to'  to should receive an email alert that the task is past due.
 *                          (2) Cavan Jones and Jan Stoe  should receive an alert when a tasks' due date goes beyond the deliverable due date.
 *                          (3) The task assigned to user should get an email if  a coaching task has a scheduled date and it’s due date changes.
 *                              If the user has more than 1 tasks that meets this criteria, they should get 1 email.
 *                      Additional request via email:
 *                          No emails should be sent if the following criteria are met
 *                          Object: Project
 *                          Status: Completed or On Hold
 *                              Or
 *                          Object: Task
 *                          Record Type: Billing or Deliver Report or Highlight & Summarize or Report – 1st draft or Report – Final Review
 *                          The email alerts for past due tasks should only occur if the task ‘stage’ is ‘To Be Scheduled’ or ‘TBR (to be rescheduled)’ or ‘Client Contacted’
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   11/10/2015
 *
 *  Current Version :   V_1.3
 *
 *  Revision Log    :   V_1.0 - Created - S-358685
 *                      V_1.1 - Modified - Alka Taneja (Appirio Offshore - 12/16/2015) - Case #00144076
 *                              Changes:
 *                                  1. Receiving past due alerts for billing tasks, excluded this record type from query.
 *                      V_1.2 - Modified - Padmesh Soni (Appirio Offshore - 12/18/2015) - S-371205
 *                              Changes:    
 *                                  Please update the TMG Deadline extended alert from story S-358685  to include the following criteria:
 *                                  1. Please exclude deliverables that are complete. There is a ‘complete’ checkbox field. If true, then no alert.
 *                                  2. Also the stage on the task whose due date extends past the deliverable deadline should only be one of the following:
 *                                      1. Stage = To Be Scheduled, Client Contacted, Scheduled, TBR (To Be Rescheduled)
 *                                  3. Taks with any other stage should be excluded.
 *                      V_1.3 - Modified - Padmesh Soni (01/07/2016 - Appirio Offshore) - Case #- 00144734
 *                              Changes:    
 *                                  1. Assigned_To__r.FirstName field added in query
 **/
global class Batch_NotifyForCoachingTaskDues implements Database.Batchable<sObject> {

    //Class Properties
    //String to hold Notification Type
    global Integer notificationType;
    //S-441780 - Praful Gupta- code update starts
    List<string> cj = new List<string> {Label.USERNAME_Email_Cavan_Jones};
    // List<string> cj = new List<string> {'cjones@miles-group.com', 'jnorman@appirio.com'};
   //S-441780 - Praful Gupta- code update Ends
    global Set<String> notifyingUsers;

    //Constructor defintion
    global Batch_NotifyForCoachingTaskDues(Integer notificationType) {

        //assign from local variable to global varialbe
        this.notificationType = notificationType;

        //populate set of string of user's name
        notifyingUsers = new Set<String>{Label.USERNAME_JAN_STOE};
    }

    //Start method definition of Batchable interface abstract method
    global Database.QueryLocator start(Database.BatchableContext BC) {

        //Exclude the Project Status from query hold those values in Set
        Set<String> excludeProjectStatus = new Set<String>{Label.TASK_PROJECT_STATUS_ON_HOLD,
                                                            Label.TASK_PROJECT_STATUS_COMPLETED};

        //Exclude the Task Record Type from query hold those values in Set
        Set<String> excludeTaskRecordTypes = new Set<String>{Label.TASK_RECORDTYPE_DEVELOPERNAME_DELIVER_REPORT,
                                                                Label.TASK_RECORDTYPE_DEVELOPERNAME_HIGHLIGHT_NOTES_SUMMARIES,
                                                                Label.TASK_RECORDTYPE_DEVELOPERNAME_REPORT_1ST_DRAFT_NEW,
                                                                Label.TASK_RECORDTYPE_DEVELOPERNAME_BILLING, //added for the case #00144076
                                                                Label.TASK_RECORDTYPE_DEVELOPERNAME_REPORT_FINAL_REVIEW_NEW};

        Set<String> extendIncludeRecordTypes = new Set<String>{Label.TASK_RECORDTYPE_DEVELOPERNAME_COACHING_SESSION,
                                                                                            Label.DELIVERABLE_RECORDTYPE_DEVELOPERNAME_EXECUTIVE_COACHING};



        //Check for notification counter
        if(notificationType == 1) {

            //Getting query result from Milestone1_Task__c sobject
            return Database.getQueryLocator([SELECT Id, First_Chair_User__c, Assigned_To__c, Scheduled_Date__c, Due_Date__c, Project_Milestone__r.Assessed_Executive__r.Name,
                                                Project_Milestone__c,Assigned_To__r.Contact.FirstName, Project_Name__c, Name, Project_Milestone__r.Name,
                                                //Code added - Padmesh Soni (01/07/2016 - Appirio Offshore) - Case #- 00144734
                                                //Assigned_To__r.FirstName field added in query
                                                Assigned_To__r.FirstName
                                                FROM Milestone1_Task__c WHERE Project_Milestone__c != null
                                                //AND Project_Milestone__r.TMG_Category__c != null
                                                //AND Project_Milestone__r.TMG_Category__r.RecordType.DeveloperName =: Label.TMG_CATEGORY_RECORDTYPE_DEVELOPER_NAME_COACHING
                                                //JN Changed line 65 from or to AND
                                                AND (ProjectStatus__c NOT IN: excludeProjectStatus AND RecordType.DeveloperName NOT IN: excludeTaskRecordTypes)
                                                AND (Task_Stage__c =: Label.TASK_STAGE_TO_BE_SCHEDULED OR Task_Stage__c =: Label.TASK_STAGE_CLIENT_CONTACTED
                                                OR Task_Stage__c =: Label.TASK_STAGE_TBR_TO_BE_RESCHEDULED)
                                                AND Due_Date__c != null AND Due_Date__c <=: Date.today().addDays(-21)]);
        } else if(notificationType == 2) {

            //Getting query result from Milestone1_Task__c sobject
            return Database.getQueryLocator([SELECT Id, First_Chair_User__c, Assigned_To__c, Scheduled_Date__c, Due_Date__c, Project_Milestone__r.Assessed_Executive__r.Name,
                                                Project_Milestone__c,Assigned_To__r.Contact.FirstName, Project_Milestone__r.deadline__c, Project_Name__c, Name, Project_Milestone__r.Name
                                                FROM Milestone1_Task__c WHERE Project_Milestone__c != null
                                                //AND Project_Milestone__r.TMG_Category__c != null
                                                //AND Project_Milestone__r.TMG_Category__r.RecordType.DeveloperName =: Label.TMG_CATEGORY_RECORDTYPE_DEVELOPER_NAME_COACHING
                                                AND (ProjectStatus__c NOT IN: excludeProjectStatus AND RecordType.DeveloperName IN: extendIncludeRecordTypes AND Project_Milestone__r.RecordType.DeveloperName IN: extendIncludeRecordTypes)
                                                //JN Update to include select record types and removed the scheudled date check
                                                //Code modified - Padmesh Soni (Appirio Offshore - 12/18/2015) - S-371205
                                                //Changes start here
                                                //AND Task_Stage__c !=: Label.TASK_STAGE_COMPLETE 
                                                AND Project_Milestone__r.Complete__c = false AND Task_Stage__c != null 
                                                AND (Task_Stage__c =: Label.TASK_STAGE_TO_BE_SCHEDULED  OR Task_Stage__c =: Label.TASK_STAGE_CLIENT_CONTACTED 
                                                OR Task_Stage__c =: Label.TASK_STAGE_TBR_TO_BE_RESCHEDULED)
                                                //Changes stop here
                                                //Code modified - Padmesh Soni (Appirio Offshore - 12/18/2015) - S-371205
                                                AND Due_Date__c != null]);
                                                //AND Task_Stage__c !=: Label.TASK_STAGE_COMPLETE AND Due_Date__c != null AND Scheduled_Date__c =: Date.today().addDays(-1)]);
        } else if(notificationType == 3) {

            //Getting query result from Milestone1_Task__c sobject
            return Database.getQueryLocator([SELECT Id, First_Chair_User__c, Assigned_To__c, Scheduled_Date__c, Due_Date__c, Project_Milestone__r.Assessed_Executive__r.Name,
                                                Project_Milestone__c,Assigned_To__r.Contact.FirstName, Project_Name__c, Name, Project_Milestone__r.Name,
                                                //Code added - Padmesh Soni (01/07/2016 - Appirio Offshore) - Case #- 00144734
                                                //Assigned_To__r.FirstName field added in query
                                                Assigned_To__r.FirstName
                                                FROM Milestone1_Task__c WHERE Project_Milestone__c != null
                                                //AND Project_Milestone__r.TMG_Category__c != null
                                                //AND Project_Milestone__r.TMG_Category__r.RecordType.DeveloperName =: Label.TMG_CATEGORY_RECORDTYPE_DEVELOPER_NAME_COACHING
                                                AND (ProjectStatus__c NOT IN: excludeProjectStatus OR RecordType.DeveloperName NOT IN: excludeTaskRecordTypes)
                                                AND Due_Date_Changed__c = true AND Task_Stage__c =: Label.TASK_STAGE_SCHEDULED]);
        }

        return null;
    }

    //Execute method definition of Batchable interface abstract method
    global void execute(Database.BatchableContext BC, List<Milestone1_Task__c> scope) {

        //List to hold SingleEmailMessage
        List<Messaging.SingleEmailMessage> singleEmails = new List<Messaging.SingleEmailMessage>();

        //List to hold EmailTemplate Developer's Name
        List<String> emailTemplateDeveloperNames = new List<String>{Label.EMAIL_TEMPLATE_DEV_NAME_TMG_TASK_PAST_DELIVERABLE_DEADLINE,
                                                            Label.EMAIL_TEMPLATE_DEV_NAME_TMG_DUE_DATE_CHANGED,
                                                            Label.EMAIL_TEMPLATE_DEV_NAME_TMG_TASK_PAST_DUE};
        //Query results of Email Templates
        List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN: emailTemplateDeveloperNames AND IsActive = true
                                                ORDER BY DeveloperName];

        //Verify the EmailTemplate size
        //System.assertEquals(3, emailTemplates.size());

        //Check for notification counter
        if(notificationType == 1) {

            //Map to hold All Milestone Tasks with respect to their "First Chair" and "Assigned To" user
            Map<Id, List<Milestone1_Task__c>> mapUserWith3WeekBehindTasks = new Map<Id, List<Milestone1_Task__c>>();

            //Loop through Task
            for(Milestone1_Task__c task : scope) {

                //Check for not null
                if(task.First_Chair_User__c != null && task.First_Chair_User__c != Label.CEO_STEPHEN_MILES) {

                    //Check for already contained key of First Chair User on Task
                    if(mapUserWith3WeekBehindTasks.containsKey(task.First_Chair_User__c)) {

                        //add on already contained key as value
                        mapUserWith3WeekBehindTasks.get(task.First_Chair_User__c).add(task);
                    } else {

                        //populate map
                        mapUserWith3WeekBehindTasks.put(task.First_Chair_User__c, new List<Milestone1_Task__c>{task});
                    }
                }

                if(task.Assigned_To__c != null) {

                    //Check for already contained key of First Chair User on Task
                    if(mapUserWith3WeekBehindTasks.containsKey(task.Assigned_To__c)) {

                        //add on already contained key as value
                        mapUserWith3WeekBehindTasks.get(task.Assigned_To__c).add(task);
                    } else {

                        //populate map
                        mapUserWith3WeekBehindTasks.put(task.Assigned_To__c, new List<Milestone1_Task__c>{task});
                    }
                }
            }

            //Check for size of map
            if(mapUserWith3WeekBehindTasks.size() > 0) {

                //Loop through Map's keyset
                for(Id userId : mapUserWith3WeekBehindTasks.keyset()) {

                    //Getting Task associated to User
                    for(Milestone1_Task__c task : mapUserWith3WeekBehindTasks.get(userId)) {

                        //Instantiates SingleEmailMessage
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        //set Target Object Ids
                        mail.setTargetObjectId(userId);
                        mail.setCCAddresses(cj);
                        CoachingTaskNoticeEmailGenerator.getTMGTaskPastDueEmailBody(mail, task);
                        //mail.setWhatId(mapUserWith3WeekBehindTasks.get(userId)[0].Id);

                        mail.setSaveAsActivity(false);

                        //Set EmailTemplate
                        /**if(Test.isRunningTest())
                            mail.setHtmlBody('Test');
                        else
                            mail.setTemplateId(emailTemplates[2].Id);**/

                        //Add mail in list
                        singleEmails.add(mail);
                    }
                }
            }
        } else if(notificationType == 2) {

            //Query result of users to be notified
            Map<Id, User> mapUsersToBeNotified = new Map<Id, User>([SELECT Id, Email, FirstName FROM User WHERE Name IN: notifyingUsers
                                                                        AND Profile.Name =: Label.PROFILE_NAME_MILES_GROUP_USER AND IsActive = true]);

            //Map to hold All Milestone Tasks with respect to mapUsersToBeNotified Users
            Map<Id, List<Milestone1_Task__c>> mapUserWithTaskBeyondDeliverable = new Map<Id, List<Milestone1_Task__c>>();

            //Check for size
            if(mapUsersToBeNotified.size() > 0) {

                //Loop through Task
                for(Milestone1_Task__c task : scope) {
                  //JN Added to only send emails fro tasks where due date > deadline
                  if (task.Due_Date__c > task.Project_Milestone__r.deadline__c) {

                    //Integer currentDiffFromDue = task.Due_Date__c.daysBetween(Date.today());
                    //Integer passDueFromSchedule = task.Due_Date__c.daysBetween(task.Scheduled_Date__c) + 1;

                    //Check for due date goes beyond the deliverable due date or not
                    //if(currentDiffFromDue == passDueFromSchedule) {

                        //Check for not null
                        for(Id notifyUserId : mapUsersToBeNotified.keyset()) {

                            //Check for already contained key of First Chair User on Task
                            if(mapUserWithTaskBeyondDeliverable.containsKey(notifyUserId)) {

                                //add on already contained key as value
                                mapUserWithTaskBeyondDeliverable.get(notifyUserId).add(task);
                            } else {

                                //populate map
                                mapUserWithTaskBeyondDeliverable.put(notifyUserId, new List<Milestone1_Task__c>{task});
                            }
                        }
                    //}
                }
              }
            }

            //Check for size of map
            if(mapUserWithTaskBeyondDeliverable.size() > 0) {

                //Loop through  map's keyset
                for(Id userId : mapUserWithTaskBeyondDeliverable.keyset()) {

                    //Getting Task associated to User
                    for(Milestone1_Task__c task : mapUserWithTaskBeyondDeliverable.get(userId)) {

                        //Instantiates SingleEmailMessage
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        //set Target Object Ids
                        mail.setTargetObjectId(userId);
                        mail.setCcAddresses(cj);
                        //set What Id
                        //mail.setWhatId(mapUserWithTaskBeyondDeliverable.get(userId)[0].Id);

                        CoachingTaskNoticeEmailGenerator.getTMGTaskPastDeliverableDeadlineEmailBody(mail, task, mapUsersToBeNotified.get(userId));

                        mail.setSaveAsActivity(false);

                        //Set EmailTemplate
                        /**if(Test.isRunningTest())
                            mail.setHtmlBody('Test');
                        else
                            mail.setTemplateId(emailTemplates[0].Id);**/

                        //Add mail in list
                        singleEmails.add(mail);
                    }
                }
            }
        } else if(notificationType == 3) {


            //Map to hold All Milestone Tasks with respect to their "Assigned To" user
            Map<Id, List<Milestone1_Task__c>> mapUserWithScheduledTaskDueChanged = new Map<Id, List<Milestone1_Task__c>>();

            //List to hold all tasks which need to be updated
            List<Milestone1_Task__c> tasksToBeUpdated = new List<Milestone1_Task__c>();

            //Loop through Task
            for(Milestone1_Task__c task : scope) {

                //Check for not null
                if(task.Assigned_To__c != null) {

                    //Check for already contained key of First Chair User on Task
                    if(mapUserWithScheduledTaskDueChanged.containsKey(task.Assigned_To__c)) {

                        //add on already contained key as value
                        mapUserWithScheduledTaskDueChanged.get(task.Assigned_To__c).add(task);
                    } else {

                        //populate map
                        mapUserWithScheduledTaskDueChanged.put(task.Assigned_To__c, new List<Milestone1_Task__c>{task});
                    }

                    //populate list of Tasks
                    tasksToBeUpdated.add(new Milestone1_Task__c(Id = task.Id, Due_Date_Changed__c = false));
                }
            }

            //Check for size of list
            if(tasksToBeUpdated.size() > 0) {

                //Perform DML Operation on tasks which need to be updated
                update tasksToBeUpdated;
            }

            //Check for size of map
            if(mapUserWithScheduledTaskDueChanged.size() > 0) {

                //Loop through map's keyset
                for(Id userId : mapUserWithScheduledTaskDueChanged.keyset()) {

                    //Getting Task associated to User
                    for(Milestone1_Task__c task : mapUserWithScheduledTaskDueChanged.get(userId)) {

                        //Instantiates SingleEmailMessage
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                        //set Target Object Ids
                        mail.setTargetObjectId(userId);
                        mail.setCcAddresses(cj);
                        CoachingTaskNoticeEmailGenerator.getTMGDueDateChangedEmailBody(mail, task);

                        //set what Id
                        //mail.setWhatId(mapUserWithScheduledTaskDueChanged.get(userId)[0].Id);

                        mail.setSaveAsActivity(false);

                        //Set EmailTemplate
                        /**if(Test.isRunningTest())
                            mail.setHtmlBody('Test');
                        else
                            mail.setTemplateId(emailTemplates[1].Id);**/

                        //Add mail in list
                        singleEmails.add(mail);
                    }
                }
            }
        }

        System.debug('singleEmails ::::'+ singleEmails);

        //Check for size
        if(singleEmails.size() > 0) {

            //Send emails here
            Messaging.sendEmail(singleEmails);
        }
    }

    //Finish method definition of Batchable interface abstract method
    global void finish(Database.BatchableContext BC) {

        System.debug('notificationType :::'+ notificationType);

        //Initialize Batch process again for next tasks
        Batch_NotifyForCoachingTaskDues batchProcess = notificationType == 1 ? new Batch_NotifyForCoachingTaskDues(3) : null;

        if(batchProcess != null)
            //Execute the batch to delete the orphan Report Balances
            Database.executeBatch(batchProcess, 200);
    }
}