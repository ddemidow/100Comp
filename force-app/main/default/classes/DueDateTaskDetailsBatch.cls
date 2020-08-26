/*********************************************************************************
Name : Jyotirmaya Rath
Created By : Appirio  
Created Date : 03 Nov 2015
Update: 15 January 2018 - Jesse B Case 00215311
Purpose : Batch class to send an email of due Tasks 
*********************************************************************************/



global class DueDateTaskDetailsBatch implements Database.Batchable<sObject>{
    
    Global String Query;
    Set<String> stagesToExclude = new Set<String> {'Complete', 'To Be Assigned', 'To Be Scheduled', 'Client Contacted', 'Incomplete (Calendar Conflicts)', 'Cancelled by TMG', 'Cancelled by Client', 'Cancelled by Client(Forfeit)', 'TBR (To Be Rescheduled)', 'Incomplete', 'Pending Approval', 'Pending Renewal', 'On Hold', 'Received', 'Not Attending', 'Client Contacted'};
    String baseUrl;
    integer startSub;
    integer endSub;
    String domain;
    List<Document> tmgLogo;
    string strDocUrl;
    // Constructor
    global DueDateTaskDetailsBatch(){        
    	baseUrl = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
		startSub = baseUrl.indexOf('://') + 3;
		endSub = baseUrl.indexOf('.salesforce');
		domain = baseUrl.substring(startSub, endSub);
    	tMGLogo = new List<Document> ([SELECT ID FROM Document WHERE DeveloperName = 'TMG_Logo' AND IsPublic = true]);
		strDocUrl = tMGLogo.isEmpty() ? '' : URL.getSalesforceBaseUrl().getProtocol() + '://c.'+ domain + '.content.force.com/servlet/servlet.ImageServer?id=' + tMGLogo[0].Id + '&oid=' + UserInfo.getOrganizationId();        
    }
    
    // Start Method - JesseB updating below block of code to look for record types Case 00215311
    global Database.QueryLocator start(Database.BatchableContext BC){
        set<Id> recTypesToExclude = new set<Id>();
        Map<string, Schema.RecordTypeInfo> recTypesMap = Schema.SObjectType.Milestone1_Task__c.getRecordTypeInfosByName();
        for(string recTypeName :recTypesMap.keySet()){
            if(recTypeName.equalsIgnoreCase('Deliver Report') || recTypeName.equalsIgnoreCase('Highlight & Summarize') || recTypeName.equalsIgnoreCase('Materials to be received') || recTypeName.equalsIgnoreCase('Report - 1st Draft') || recTypeName.equalsIgnoreCase('BD - Materials Sent') || recTypeName.equalsIgnoreCase('Materials Sent') || recTypeName.equalsIgnoreCase('Report Draft')){ //JesseB Case 00215311 added new record types to filter out per Cavan 
              recTypesToExclude.add(recTypesMap.get(recTypeName).getRecordTypeId());
            }
        
        }   

        Query = 'SELECT id,Name,Assigned_To__c,Assigned_To__r.name,Project_Name__c,Scheduled_Date__c,Task_Stage__c,Description__c FROM Milestone1_Task__c WHERE Scheduled_Date__c < TODAY AND Task_Stage__c NOT IN :stagesToExclude AND recordTypeId NOT IN :recTypesToExclude'; //Jesse B Case 00215311 excluding many stages from query
       // Start Lokesh Korani Case 00248710
        if(Test.isRunningTest()){
            Query = 'SELECT id,Name,Assigned_To__c,Assigned_To__r.name,Project_Name__c,Scheduled_Date__c,Task_Stage__c,Description__c FROM Milestone1_Task__c WHERE Scheduled_Date__c < TODAY AND Task_Stage__c NOT IN :stagesToExclude AND recordTypeId NOT IN :recTypesToExclude LIMIT 100';
        }
        // End Lokesh Korani Case 00248710
        return Database.getQueryLocator(query);
        
    }
    //Execute Method
    global void execute(Database.BatchableContext BC,List<Milestone1_Task__c> dueTaskList){ 
        
        //  Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<String> ccTo = new List<String>(); 
        Messaging.SingleEmailMessage singlEmail;
        String body ;
        Set<Id> userIdSet = new Set<Id>();
        OrgWideEmailAddress owa = [SELECT id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Cavan Jones' LIMIT 1];
        map<id,User> userMap = new Map<Id,User>();
        if(!dueTaskList.isEmpty()){
            for(Milestone1_Task__c t : dueTaskList){
                if (t.Assigned_to__c != null){ //JesseB adding null check
                    userIdSet.add(t.Assigned_To__c);
                }
            }
            if(!userIdSet.isEmpty()){
                for(User u: [Select id,Email,name from User Where Id in :userIdSet AND email != null]){
                    userMap.put(u.id,u);
                }
            } 
            String  SchDate  ;
            
            for(Milestone1_Task__c t : dueTaskList){
                // Create a new Email
                singlEmail = new Messaging.SingleEmailMessage();
                body = '' ;
                singlEmail.setOrgWideEmailAddressId(owa.Id); //JesseB Case 00215311 Updating to send from Cavan Jones' email.
                singlEmail.setSubject('Please Update The Task Detail');
                //Set list of people who should get the email 
                if(userMap.containsKey(t.Assigned_To__c)){ 
                    singlEmail.setToAddresses(new List<String>{userMap.get(t.Assigned_To__c).email });
                    //Set email contents 
                    SchDate = String.valueOf(t.Scheduled_Date__c).substring(0,10).replace('-','/') ;
                    SchDate = schDate.subString(5,7) + '/' + schDate.subString(8,10) + '/' + schDate.subString(0,4) ; 
                    body = '<span style="font-size:11.0pt;font-family:&quot;Calibri&quot;,sans-serif;color:#000000"> '
                            + body + userMap.get(t.Assigned_To__c).name + ' ,' + '<br/>' 
                            + ' <br/> Has the following task been completed ? ' + '<br/><br/>'
                            +  t.Project_Name__c + ' , ' +  t.name   + ' scheduled for ' + SchDate +   ' <br/> <br/>'
                            +   '<a href="' + label.DuedateTaskSendSiteUrl +'/?id=' + t.id +'&ans=yes">     Yes </a>  '
                            +   '&nbsp;&nbsp;&nbsp;&nbsp;  <a href="'+label.DuedateTaskSendSiteUrl + '/?id=' + t.id +'&ans=no"> No </a> <br/>'                  
                            + '<br/>Thank you, <br/>Cavan <br/> <br/>'
                            + '<span style="font-size:11.0pt;font-family:Calibri,sans-serif;color:#1f497d">'
								+'<img width="180" height="73" src="'+strDocUrl+'" alt="Description: TMGLogo_small" class="CToWUd"><u></u><u></u></span> <BR/> <BR/>'
								+'<b><span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">Cavan Jones<u></u><u></u></span></b><BR/>'
								+'<b><span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">THE MILES GROUP<u></u><u></u></span></b><BR/>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">630 Fifth Avenue, Suite 3210<u></u><u></u></span><BR/>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">New York, NY 10111<u></u><u></u></span><BR/></p>'
								+'</span>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">direct: +1 212 899 6929<u></u><u></u></span><BR/>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">cell: +1 917 566 3203'
								+'<u></u><u></u></span><BR/>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959">fax: +1 212 332 3791<u></u><u></u></span><BR/>'+
								'<b><u><span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:blue">'
								+'<a href="mailto:cjones@miles-group.com" target="_blank">cjones@miles-group.com</a></span></u></b><b>'
								+'<span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959"><u></u><u></u></span></b>'
								+'<BR/><b><span style="font-size:10.0pt;font-family:Verdana,sans-serif;color:#595959"><a href="http://www.miles-group.com/" target="_blank">www.miles-group.com</a>'
								+'<u></u><u></u></span></b><BR/>'
								+'<span style="font-size:8.0pt;font-family:Cambria,serif;color:#404040">This email message (together with any attachments) is confidential and/or privileged. It is to be used by the intended recipient only. Use of the information contained'
                                +'in this email by anyone other than the intended recipient is strictly prohibited.<u></u><u></u></span></p>';
 
                    singlEmail.setHtmlBody(body);
                    // Add your email to the master list
                    mails.add(singlEmail);
                }  
            
               
            }
            
            //  Send all emails in the master list 
            if(!mails.isempty()){
                Messaging.sendEmail(mails);
            }    
        }
        
    }    
    // Finish Method
    global void finish(Database.BatchableContext BC){
        
    }
    
}