global class TMGPProjectWizardCEOSuccessController {
	global string milestoneId{get; set;}
	global Milestone1_Project__c milestone{
		get{
			Milestone1_Project__c milestone = new Milestone1_Project__c();
			if(milestoneId != null){
				List<Milestone1_Project__c> milestones = new List<Milestone1_Project__c>([Select Id, Name, RecordType.Name, Project_Wizard__r.Name, Status__c, Account__r.Name, Kickoff__c, Client__r.Name, Deadline__c, Description__c, Board_Dates__c from Milestone1_Project__c where Id=:milestoneId AND RecordType.Name = 'CEO Succession' Limit 1]);
				if(milestones.size()>0){
					milestone = milestones.get(0);
				}
			}
			return milestone;
		}
		set;
	}
	global TMG_Category__c category{
		get{
			TMG_Category__c category = new TMG_Category__c();
			if(milestoneId != null){
			   List<TMG_Category__c> categories = new List<TMG_Category__c>([Select id,Due_Date__c from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name = 'Data Collection' and Due_Date__c != null order by Due_Date__c asc limit 1]);                 
		       if(categories.size() > 0)
		           category.Due_Date__c = categories.get(0).Due_Date__c;
		       categories = new List<TMG_Category__c>([Select id ,Draft_Assessment__c ,Final_Assessment__c ,Draft_Coaching_Plan__c from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name = 'Written Deliverables' and Draft_Assessment__c  != null order by Draft_Assessment__c asc limit 1]);                 
		       if(categories.size() > 0){
		           category.Draft_Assessment__c = categories.get(0).Draft_Assessment__c;
		           category.Final_Assessment__c = categories.get(0).Final_Assessment__c;
		           category.Draft_Coaching_Plan__c= categories.get(0).Draft_Coaching_Plan__c ;
		       }
		       categories = new List<TMG_Category__c>([Select id,Due_Date__c from TMG_Category__c where TMG_Project__c =: milestoneId and (recordType.Name ='Feedback' or recordType.Name = 'Manager Debriefs') order by Due_Date__c asc limit 1]);                 
		       if(categories.size() > 0)
		           category.Kick_Off__c = categories.get(0).Due_Date__c ;
	           categories = new List<TMG_Category__c>([Select Draft_Process_Document__c, Draft_Questionnaire_Strawman__c, Draft_Key_Selection_Criteria_Revise_St__c, Final_Key_Selection_Criteria__c from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name ='S&E Profile' order by Due_Date__c asc limit 1]);
			   if(categories.size() > 0){
			   		category.Draft_Process_Document__c = categories.get(0).Draft_Process_Document__c;
			   		category.Draft_Questionnaire_Strawman__c = categories.get(0).Draft_Questionnaire_Strawman__c;
			   		category.Draft_Key_Selection_Criteria_Revise_St__c = categories.get(0).Draft_Key_Selection_Criteria_Revise_St__c;
			   		category.Final_Key_Selection_Criteria__c = categories.get(0).Final_Key_Selection_Criteria__c;
			   }
			}
			return category;
		}
		set;
	}
	global List<Milestone1_Milestone__c> participants{
		get{
			List<Milestone1_Milestone__c> participants = new List<Milestone1_Milestone__c>();
			if(milestoneId != null){
				participants = new List<Milestone1_Milestone__c>([Select id , Interview_Date__c ,Assessed_Executive__c,Assessed_Executive__r.Name from Milestone1_Milestone__c where Assessed_Executive__c != null and Project__c =: milestoneId and RecordType.Name = 'Data Collection']);
			}
			return participants;
		}
		set;
	}
	global string projectLink{
		get{
			string projectLink = '';
			if(milestoneId != null){
				projectLink = URL.getSalesforceBaseUrl().toExternalForm() + '/'+ milestoneId ;
			}
			return projectLink;
		}
	}
	global Milestone1_Milestone__c inteviewDeliverable{
		get{
			Milestone1_Milestone__c inteviewDeliverable = new Milestone1_Milestone__c();
			if(milestoneId != null){
				List<Milestone1_Milestone__c> deliverables = new List<Milestone1_Milestone__c>([Select Id, Deadline__c from Milestone1_Milestone__c where Project__c = :milestoneId AND RecordType.Name = 'Interview' order by Deadline__c asc limit 1 ]);
				if(deliverables.size()>0){
					inteviewDeliverable = deliverables.get(0);
				}
			}
			return inteviewDeliverable;
		}
		set;
	}
	global Milestone1_Milestone__c debriefDeliverable{
		get{
			Milestone1_Milestone__c debriefDeliverable = new Milestone1_Milestone__c();
			if(milestoneId != null){
				List<Milestone1_Milestone__c> deliverables = new List<Milestone1_Milestone__c>([Select Id, Deadline__c from Milestone1_Milestone__c where Project__c = :milestoneId AND RecordType.Name = 'Stakeholder Debrief' order by Deadline__c asc limit 1 ]);
				if(deliverables.size()>0){
					debriefDeliverable = deliverables.get(0);
				}
			}
			return debriefDeliverable;
		}
		set;
	}
}