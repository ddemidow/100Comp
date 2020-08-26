/**
 *  Purpose         :   This class is used to generate email body for Notification through Batch_OpportunityAgeAlerts.
 *
 *  Created By      :   Padmesh Soni (Appirio Offshore)
 *
 *  Created Date    :   02/23/2016
 *
 *  Current Version :   V_1.0
 *
 *  Revision Log    :   V_1.0 - Created - S-374199
 **/
global class OpportunityAgeAlertsEmailGenerator {
    
	/**
	 * 	@description	:	This method is used to send Opps Approaching Median Age email template type message.
	 *
	 * 	@param			:	Messaging.SingleEmailMessage mail, Milestone1_Task__c task
	 *
	 * 	@return			:	void
	 **/
	global static List<Messaging.SingleEmailMessage> getOppsMedianAgeEmailBody(Map<String, List<Opportunity>> mapOppsWithRecipient) {
		
		//Initialize list of emailMessages
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		
		//Loop through key set of map
		for(String uniqueKey : mapOppsWithRecipient.keySet()) {
			
			//Initialize a list of string
			List<String> splittedUniqueKey = new List<String>();
			
			//populate list by splitting with comma
			splittedUniqueKey = uniqueKey.split(',');
			
			//Check for size of list
			if(splittedUniqueKey.size() == 4) {
				
				//Populate subject
				String subject = splittedUniqueKey[1] != 'Default' ? splittedUniqueKey[1] +' Opp Approaching Median Age': 'Opp Approaching Median Age';
				
				//Loop through all Opportunities got from map
				for(Opportunity opportunity : mapOppsWithRecipient.get(uniqueKey)) {
					
					//Initialize Email Message
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setToAddresses(New String[]{splittedUniqueKey[2]});
					mail.setSubject(subject);
					
					//Populate body of Email Message
					String body = 'Dear '+ splittedUniqueKey[0]+',<BR/><BR/>'
									+ '<p>We have found that after about '+ splittedUniqueKey[3] +' months the win rate for'+ (splittedUniqueKey[1] != 'Default' ? ' ' + splittedUniqueKey[1] : '') 
									+' opportunities reduces significantly.</p>'
									+ '<p>This opportunity is approaching that age: </p>'  
									+ 'Opportunity: '+ opportunity.Name +'<BR/>'
									+ 'Owner: '+ opportunity.Owner.Name +'<BR/>'
									+ 'Stage: '+ opportunity.StageName +'<BR/>'
									+ 'Close Date: '+ (opportunity.CloseDate != null ? opportunity.CloseDate.year() +'/'+ opportunity.CloseDate.month() + '/' + opportunity.CloseDate.day() : '') 
									+'<BR/>'
									+ 'URL: '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id + '<BR/><BR/>'
									+ '<p>Please take a look at this opportunity and see if there is anything that can be done now to push this forward or if it should '
									+'be closed at this time.</p>'
									+ 'Thank you!';
					
					mail.setHtmlBody(body);
					emailMessages.add(mail);
				}
			}
		}
		
		//return to list of email Messages
		return emailMessages;
	}
}