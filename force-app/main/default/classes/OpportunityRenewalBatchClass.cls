/*********************************************************************************
Name : Harendra Sain
Created By : Appirio
Created Date : 21 Dec. 2015
Purpose : Trigger Handler for send the mail on basis of below criteria
*********************************************************************************/
global class OpportunityRenewalBatchClass implements Database.Batchable<SObject> {
    
    global Database.queryLocator start(Database.BatchableContext ctx) {
        Date today = System.today();
        //Start- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        //Date month4 = today.addMonths(-4);
        //Date month9 = today.addMonths(-9);
        Date month3 = today.addMonths(-3);
        string qry = 'select Participant_Contact__r.lastname,';
        //End- Updated | Mohit | 5/22/2020 | 00278378 | Updating stage name value
        Map<String,Schema.SObjectField> Oppfields = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        for(string fApi :Oppfields.keySet()){
            qry += fApi + ', ';
        }
        qry = qry.removeEnd(', ');
        //from clause
        qry += ' From Opportunity ';
        // Where clause
        // qry += ' Where Group2__c = \'The Miles Group\' AND Engagement_Type__c = \'Coaching\' AND StageName = \'100 - Signed Contract\' AND (Project_Start_Date__c = :month4 or Project_Start_Date__c = :month9) ';//Commented by Kritika Bhati fro S-545118
        //Start- Updated | Mohit | 5/22/2020 | 00278378 |  00278629 |Updating stage name value
        qry += ' Where Group2__c = \'The Miles Group\' AND (Engagement_Type__c = \'Coaching\' OR Engagement_Type__c = \'Executive Assessment with Coaching\' OR Engagement_Type__c=\'Advisory\')  AND StageName = \'100 - Closed/Won\' AND (Project_Start_Date__c = :month3) ';//Added by Kritika Bhati for S-545118
        //End- Updated | Mohit | 5/22/2020 | 00278378 |  00278629 |Updating stage name value
        return Database.getQueryLocator(qry);
        
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        list<Opportunity> RenewalOppToInsert =  new list <Opportunity>();
        //Start- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        Id ASRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advisory Services - TMG').getRecordTypeId();
        //End- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        for(opportunity opp : (List<Opportunity>)scope){
            RenewalOppToInsert.add(CreatedRenewalRecord(opp, ASRecTypeId));
        }
        if(RenewalOppToInsert.size() > 0){
            database.insert(RenewalOppToInsert,false);
        }
    }
    
    global Opportunity CreatedRenewalRecord (Opportunity opp, Id recTypeId){
        // Only create renewal opps for closed won deals
        Opportunity renewal = new Opportunity();
        //start - Updated | Cavan | 06/18/2020 | Change in Mapping
        renewal = (Opportunity)opp.clone(false,true,false,true);
        //start - Updated | Cavan | 06/18/2020 | Change in Mapping
        renewal.IsRenewalOpportunity__c = true;
        renewal.Probability = 5;
        //renewal.AccountId   = opp.AccountId;
        //renewal.amount = opp.amount;
        //renewal.Lead_Contact__c = opp.Lead_Contact__c;
        //renewal.LeadSource = opp.LeadSource;
        //Start- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        renewal.Participant_Contact__c = opp.Participant_Contact__c;
        //renewal.Participant_Contact__c = null ; //Added by - Jai Gupta - S-559561 - Aug 30,2018
        if('Executive Assessment with Coaching'.equalsIgnoreCase(opp.Engagement_Type__c))
        renewal.Engagement_Type__c = 'Coaching';
        else renewal.Engagement_Type__c = opp.Engagement_Type__c;
        //End- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        if(opp.Project_Start_Date__c != null  && opp.Project_End_Date__c != null ){
            // if(Math.abs(opp.Project_End_Date__c.monthsBetween(opp.Project_Start_Date__c)) == 12){//Commented  if and else condition by Kriitka for S-545118
            //Start- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
            renewal.Project_Start_Date__c = opp.Project_End_Date__c.adddays(1);
            renewal.Project_End_Date__c = renewal.Project_Start_Date__c.addMonths(Math.abs(opp.Project_End_Date__c.monthsBetween(opp.Project_Start_Date__c)));
            //Commented below Name Update | Cavan | 06/18/2020 | Change in Mapping
            //renewal.Project_Name__c = opp.Project_Name__c+' '+renewal.Project_Start_Date__c.year()+'-'+renewal.Project_End_Date__c.year();
            renewal.Project_Name__c = opp.Engagement_Type__c+' - '+opp.Participant_Contact__r.lastname+' '+renewal.Project_Start_Date__c.year()+'-'+renewal.Project_End_Date__c.year();
            //End- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
            renewal.CloseDate   = opp.Project_End_Date__c;
            //Commented below if and else condition by Kriitka for S-545118
            /*     }else{ 
                            renewal.Project_Start_Date__c = opp.Project_End_Date__c;
                            renewal.Project_End_Date__c = renewal.Project_Start_Date__c.addMonths(6);
                            renewal.CloseDate   = opp.Project_End_Date__c;
                            }
            */
        }
        //Start- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        //else renewal.Project_Name__c = opp.Project_Name__c;
        //Updated | Cavan | 06/18/2020 | Change in Mapping
        else renewal.Project_Name__c = opp.Engagement_Type__c+' - '+opp.Participant_Contact__r.lastName;
        //End- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        //renewal.Name        = opp.Name + 'Renewal';
        //renewal.CloseDate   = opp.CloseDate + 365; // Add a year
        //Start- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        renewal.StageName   = '10 - Renewal Pending';
        //End- Updated | Mohit | 6/03/2020 | 00278629 | Change in Mapping
        renewal.RecordTypeId  =  recTypeId;
        renewal.IsRenewableFromBatch__c = true;//Added by Kritika Bhati for S-S-545118
        //Updated| Cavan | 06/18/2020 | Change in Mapping
        //renewal.TMG_Project__c = opp.TMG_Project__c;
        //renewal.OwnerId     = opp.OwnerId;

        //new code to make Description__c & Issues_Speedbumps__c blank in new Opportunity
        renewal.Description__c = null;
        renewal.Issues_Speedbumps__c = null;

        return renewal;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}