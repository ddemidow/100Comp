/*********************************************************************************
Name : Harendra Sain
Created By : Appirio  
Created Date : 17 Dec. 2015
Purpose : Batch class to send an email of due date Tasks 
*********************************************************************************/
global class DueDateTaskUpdatedBatch implements Database.Batchable<sObject>{
    
    global String Query;
    global List<String> notifyingInactiveUsertoCJ; //S-441787 Praful Gupta

    
    // Constructor
    global DueDateTaskUpdatedBatch(){        
        notifyingInactiveUsertoCJ = new List<String>{Label.USERNAME_Email_Cavan_Jones};     //S-441787 Praful Gupta  
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        set<Id> recTypes = new set<Id>();
        Map<string, Schema.RecordTypeInfo> recTypesMap = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName();
        for(string recTypeName :recTypesMap.keySet()){
            if(recTypeName.equalsIgnoreCase('Deliver Report') || recTypeName.equalsIgnoreCase('Highlight & Summarize') || recTypeName.equalsIgnoreCase('Materials to be received') || recTypeName.equalsIgnoreCase('Report - 1st Draft')){
              recTypes.add(recTypesMap.get(recTypeName).getRecordTypeId());
            }                        
        }
        
Query = 'SELECT id,Name,Assigned_To__c,Assigned_To__r.name,Project_Name__c,Scheduled_Date__c, Due_Date__c, Task_Stage__c,Description__c FROM Milestone1_Task__c WHERE Due_Date__c < today AND Task_Stage__c != \'Complete\'  AND recordTypeId in :recTypes';
        //Query = Query + ' LIMIT 1 ' ;
        system.debug('Query -> ' + query );
        return Database.getQueryLocator(query);
        
    }
    //Execute Method
    global void execute(Database.BatchableContext BC,List<Milestone1_Task__c> dueTaskList){ 
        system.debug('+++dueTaskList++'+dueTaskList);
        //S-441787 Praful Gupta - Code update starts
          //  List<string> cj = new List<string>();
          // String CJemailAddress = [Select id,Email,name from User Where Name in :notifyingInactiveUsertoCJ].Email;
          // cj.add(CJemailAddress);
          //S-441787 Praful Gupta - Code update ENDS
          //  Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<String> ccTo = new List<String>(); 
        Messaging.SingleEmailMessage singlEmail;
        String body ;
        Set<Id> userIdSet = new Set<Id>();
        map<id,User> userMap = new Map<Id,User>();
        if(!dueTaskList.isEmpty()){
            for(Milestone1_Task__c t : dueTaskList){
                userIdSet.add(t.Assigned_To__c);
            }
            if(!userIdSet.isEmpty()){
                        //S-441787 -  Praful Gupta - query update
                for(User u: [Select id,Email,name, IsActive from User Where Id in :userIdSet AND email != null]){
                    userMap.put(u.id,u);
                }
            } 
            String  DueDatestr  ;
            for(Milestone1_Task__c t : dueTaskList){
                // Create a new Email
                singlEmail = new Messaging.SingleEmailMessage();
                body = '' ;
                singlEmail.setSubject('Please Update The  Task Detail');
                //Set list of people who should get the email 
                if(userMap.containsKey(t.Assigned_To__c)){ 
                          //S-441787 - Praful Gupta - Code update starts 
                   //if active user , send to t.Assigned_To__c
                    if(userMap.get(t.Assigned_To__c).IsActive)
                    { 
                        singlEmail.setToAddresses(new List<String>{userMap.get(t.Assigned_To__c).email });
                        //Set email contents 
                        string yy = string.valueof(t.Due_Date__c.year());
                        string mm = string.valueof(t.Due_Date__c.month());
                        string dd = string.valueof(t.Due_Date__c.day());
                        DueDatestr = mm+'/'+dd+'/'+yy;
                        //DueDate = String.valueOf(t.Due_Date__c).substring(0,10).replace('-','/') ;
                        //DueDate = DueDate.subString(5,7) + '/' + DueDate.subString(8,10) + '/' + DueDate.subString(0,4) ; 
                        body = '<span style="font-size:11.0pt;font-family:&quot;Calibri&quot;,sans-serif;color:#0070c0"> '
                                + body + userMap.get(t.Assigned_To__c).name + ' ,' + '<br/>' 
                                + ' <br/> Has the following task been completed ? ' + '<br/><br/>'
                                +  t.Project_Name__c + ' , ' +  t.name   + ' due ' + DueDatestr +   ' <br/> <br/>'
                                +   '<a href="' + label.DuedateTaskSendSiteUrl +'/?id=' + t.id +'&ans=yes">     Yes </a>  '
                                +   '&nbsp;&nbsp;&nbsp;&nbsp;  <a href="'+label.DuedateTaskSendSiteUrl + '/?id=' + t.id +'&ans=no"> No </a> <br/>'                  
                                + '<br/> Thank you, <br/> Salesforce Admin  </span>' ;
                     } 
                     else 
                       //if Inactive user , send to Label.USERNAME_Email_Cavan_Jones
                     {                   
                        singlEmail.setToAddresses(notifyingInactiveUsertoCJ);
                        //Set email contents 
                        string yy = string.valueof(t.Due_Date__c.year());
                        string mm = string.valueof(t.Due_Date__c.month());
                        string dd = string.valueof(t.Due_Date__c.day());
                        DueDatestr = mm+'/'+dd+'/'+yy;
                        //DueDate = String.valueOf(t.Due_Date__c).substring(0,10).replace('-','/') ;
                        //DueDate = DueDate.subString(5,7) + '/' + DueDate.subString(8,10) + '/' + DueDate.subString(0,4) ; 
                        body = '<span style="font-size:11.0pt;font-family:&quot;Calibri&quot;,sans-serif;color:#0070c0"> '
                                + body + userMap.get(t.Assigned_To__c).name + ' ,' + '<br/>' 
                                + ' <br/> Has the following task been completed ? ' + '<br/><br/>'
                                +  t.Project_Name__c + ' , ' +  t.name   + ' due ' + DueDatestr +   ' <br/> <br/>'
                                +   '<a href="' + label.DuedateTaskSendSiteUrl +'/?id=' + t.id +'&ans=yes">     Yes </a>  '
                                +   '&nbsp;&nbsp;&nbsp;&nbsp;  <a href="'+label.DuedateTaskSendSiteUrl + '/?id=' + t.id +'&ans=no"> No </a> <br/>'                  
                                + '<br/> Thank you, <br/> Salesforce Admin  </span>' ;
                               
                     } 
                   // moving code 'mails.add' inside if condition for 'UserMap.containsKey(t.Assigned_To__c))' because if there will be no value in Assigned_To__c will cause error as its used in body of emaila and to address
                    //singlEmail.setToAddresses(new List<String>{'hsain@appirio.com'});
                    singlEmail.setHtmlBody(body);             
                   // Add your email to the master list
                    mails.add(singlEmail);
               }  

        }

            //  Send all emails in the master list 
            if(!mails.isempty())
            {
                Messaging.sendEmail(mails);  
            }    
        }
      } 
     //S-441787 - Praful Gupta - Code update ENDS 

    // Finish Method
    global void finish(Database.BatchableContext BC){
        
    }
}