global class TMGPProjectWizardCoachingAdvisoryCont {
    global string milestoneId{get; set;}
    global Milestone1_Project__c milestone{
        get{
            Milestone1_Project__c milestone = new Milestone1_Project__c();
            if(milestoneId != null){
                List<Milestone1_Project__c> milestones = new List<Milestone1_Project__c>([Select Id, Name, RecordType.Name, Project_Wizard__r.Name, Status__c, Account__r.Name, Kickoff__c, Client__r.Name, Deadline__c, Opportunity__r.Name,  Description__c,  Board_Dates__c, X360__c, Team_Offsite__c from Milestone1_Project__c where Id=:milestoneId AND (RecordType.Name = 'Executive Coaching' OR RecordType.Name = 'Advisory') Limit 1]);
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
                List<TMG_Category__c> categories = new List<TMG_Category__c>([Select id, Frequency__c, Type__c, Number_of_in_person_meetings__c, Description__c from TMG_Category__c where TMG_Project__c =: milestoneId and recordType.Name = 'Coaching' and Due_Date__c != null order by Due_Date__c asc limit 1]);
                if(categories.size() > 0){
                    category.Frequency__c = categories.get(0).Frequency__c;
                    category.Type__c = categories.get(0).Type__c;
                    category.Number_of_in_person_meetings__c = categories.get(0).Number_of_in_person_meetings__c;
                    category.Description__c = categories.get(0).Description__c;
                }
            }
            return category;
        }
        set;
    }
    global Milestone1_Milestone__c[] deliverables{
        get{
            List<Milestone1_Milestone__c> deliverables;
            Milestone1_Milestone__c deliverable = new Milestone1_Milestone__c();
            if(milestoneId != null){
                deliverables = new List<Milestone1_Milestone__c>([Select Id, Assessed_Executive__r.Name, First_Chair__c from Milestone1_Milestone__c where Project__c = :milestoneId AND RecordType.Name = 'Executive Coaching' order by Assessed_Executive__r.Name asc]);
            }
            return deliverables;
        }
        set;
    }
}