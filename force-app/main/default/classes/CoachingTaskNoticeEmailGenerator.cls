/**
 *  Purpose         :   This class is used to generate email body for Notification through Batch_NotifyForCoachingTaskDues.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   11/10/2015
 *
 *  Current Version :   V_1.1
 *
 *  Revision Log    :   V_1.0 - Created - S-358685
 *						V_1.1 - Modified - Padmesh Soni (01/08/2016 - Appirio Offshore) - Case #- 00144734
 *								Changes: 	
 *									1. Assigned_To__r.FirstName field added email body
 **/
global class CoachingTaskNoticeEmailGenerator {

	global static List<Document> tMGLogo = [SELECT ID FROM Document WHERE DeveloperName = 'TMG_Logo' AND IsPublic = true];

	/**
	 * 	@description	:	This method is used to send TMG Task Past Due email template type message.
	 *
	 * 	@param			:	Messaging.SingleEmailMessage mail, Milestone1_Task__c task
	 *
	 * 	@return			:	void
	 **/
	global static String addSignature() {

		String baseUrl = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
		integer startSub = baseUrl.indexOf('://') + 3;
		integer endSub = baseUrl.indexOf('.salesforce');
		String domain = baseUrl.substring(startSub, endSub);

		string strDocUrl = tMGLogo.isEmpty() ? '' : URL.getSalesforceBaseUrl().getProtocol() + '://c.'+ domain
							+ '.content.force.com/servlet/servlet.ImageServer?id=' + tMGLogo[0].Id + '&oid=' + UserInfo.getOrganizationId();

		String signature = '<p class="MsoNormal">'
								+ '<span style="font-size:11.0pt;font-family:Calibri,sans-serif;color:#1f497d">'
								+'<img width="180" height="73" src="'+strDocUrl+'" alt="Description: TMGLogo_small" class="CToWUd"><u></u><u></u></span><BR/>'
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

		return signature;
	}

	/**
	 * 	@description	:	This method is used to send TMG Task Past Due email template type message.
	 *
	 * 	@param			:	Messaging.SingleEmailMessage mail, Milestone1_Task__c task
	 *
	 * 	@return			:	void
	 **/
	global static void getTMGTaskPastDueEmailBody(Messaging.SingleEmailMessage mail, Milestone1_Task__c task) {

		String subject = '<PAST DUE> '+ task.Project_Name__c +', '+ task.Name;
		mail.setSubject(subject);
		
		//Code added - Padmesh Soni (01/08/2016 - Appirio Offshore) - Case #- 00144734
        String TO_NAME = '';
        TO_NAME += task.Assigned_To__c != null && task.Assigned_To__r.FirstName != null ? task.Assigned_To__r.FirstName : TO_NAME;
        
		//Code updated - Padmesh Soni (01/08/2016 - Appirio Offshore) - Case #- 00144734
		//TO_NAME used instead of task.Assigned_To__r.FirstName
        //Updated for case 00144734 - JN
		String body = TO_NAME +',<BR/><BR/>'
						+ '<p>This is a reminder that the following task is 2 or more weeks past due. Please click the below link for further information, or to make any necessary edits.</p><BR/><BR/>'
						+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '<BR/><BR/>'
						+ 'Best,<BR/>'
						+ addSignature();

		mail.setHtmlBody(body);
	}

	/**
	 * 	@description	:	This method is used to send TMG Task Past Deliverable Deadline email template type message.
	 *
	 * 	@param			:	Messaging.SingleEmailMessage mail, Milestone1_Task__c task, User user
	 *
	 * 	@return			:	void
	 **/
	global static void getTMGTaskPastDeliverableDeadlineEmailBody(Messaging.SingleEmailMessage mail, Milestone1_Task__c task, User user) {

		String subject = '<DEADLINE EXTENDED> '+ task.Project_Name__c + ', ' + task.Project_Milestone__r.Name;
		mail.setSubject(subject);

		String body = user.FirstName  +',<BR/><BR/>'
						+ '<p>The following deliverable has tasks outside the contract range. Please click the below link to determine what action is necessary.</p><BR/><BR/>'
						+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Project_Milestone__c + '<BR/><BR/>'
						+ 'Best,<BR/>'
						+ addSignature();

		mail.setHtmlBody(body);
	}

	/**
	 * 	@description	:	This method is used to send TMG Due Date Changed email template type message.
	 *
	 * 	@param			:	Messaging.SingleEmailMessage mail, Milestone1_Task__c task
	 *
	 * 	@return			:	void
	 **/
	global static void getTMGDueDateChangedEmailBody(Messaging.SingleEmailMessage mail, Milestone1_Task__c task) {

		String subject = '<CHANGE IN DUE DATE> '+ task.Name +', '+ task.Project_Name__c;
		mail.setSubject(subject);
		
		//Code added - Padmesh Soni (01/08/2016 - Appirio Offshore) - Case #- 00144734
        String TO_NAME = '';
        TO_NAME += task.Assigned_To__c != null && task.Assigned_To__r.FirstName != null ? task.Assigned_To__r.FirstName : TO_NAME;
        
		//Code updated - Padmesh Soni (01/08/2016 - Appirio Offshore) - Case #- 00144734
		//TO_NAME used instead of task.Assigned_To__r.FirstName
        //Updated for case 00144734 - JN
		String body = TO_NAME  +',<BR/><BR/>'
					+ '<p>The due date for the following scheduled task has been updated. Please click the below link and make sure no changes are necessary. </p><BR/><BR/>'
					+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id + '<BR/><BR/>'
					+ 'Best,<BR/>'
					+ addSignature();

		mail.setHtmlBody(body);
	}
}