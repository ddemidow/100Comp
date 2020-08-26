// 
// (c) 2014 Appirio, Inc.
//
// This class serves as a controller for Story S-217432 and custom VF page [PotentialSpeakerTopics]
//
// 7/11/2014   Jyoti Singh      
//
public class PotentialSpeakerTopicsController{
    public Set<String> speakerTopic {get;set;}   
    public String selectedTopics {get;set;} 
    public Contact contact{ get; set;}  
    public String reportID {get; set;}
    public Integer countOfTags;
    
    public PotentialSpeakerTopicsController(ApexPages.StandardController stdController){
        contact = (Contact)stdController.getRecord();
        speakerTopic = new Set<String>();
        for(Potential_Speaker_Topic__c topic:[Select Id, Name from Potential_Speaker_Topic__c ORDER BY Name limit 1000]){
            this.speakerTopic.add(topic.Name);
            // Limit the apex:repeat collection size to 1000
            if(this.speakerTopic.size() ==1000){
                break;
            }
        } // for
        // START S-261774 - By Hemlata 
        List<PotentialSpeaker_Report_Setting__c> speakerSetting = PotentialSpeaker_Report_Setting__c.getall().values();
        if (speakerSetting != null && speakerSetting.size() > 0 ) {
          reportID = speakerSetting[0].name;
        }
        // END S-261774
    }
     // save story record
    public PageReference doSave() { 
        if(upsertRecord()){
            
           return null;
        } else{
            return null;
        }
    }
    
    public Integer getCountOfTags() {
    Integer count = 0;
        if ( contact.Potential_Speaker_Topics__c != null &&  contact.Potential_Speaker_Topics__c != '') {
             List<String> topics = contact.Potential_Speaker_Topics__c.split(', ');
             if (topics != null && topics.size() > 0) {
              count = topics.size();
             } 
        } 
        return count;
    }
    
    // This upsert operation handles "Save"/"Save & New"
    private Boolean upsertRecord(){
        Boolean status = false;
        try {                  
                contact.Potential_Speaker_Topics__c = selectedTopics;  
                if (selectedTopics != null && selectedTopics != '') {      
                    List<String> topics = selectedTopics.split(', ');
                    List<Potential_Speaker_Topic__c> pstopics = new List<Potential_Speaker_Topic__c>();
                   // START S-261774 - By Hemlata 
                   Set<String> existingTopicNames = new Set<String>();
                   for (Potential_Speaker_Topic__c speacerRec : [Select Id, Name from Potential_Speaker_Topic__c where Name in :topics]) {
                       existingTopicNames.add(speacerRec.Name);
                   }
                    system.debug('existingTopicNames***'+existingTopicNames);
                   for(String str:topics) {
                        if(!existingTopicNames.contains(str)){
                            Potential_Speaker_Topic__c pst = new Potential_Speaker_Topic__c(Name = str);
                            pstopics.add(pst);
                            if(this.SpeakerTopic.size() < 1000)
                                this.SpeakerTopic.add(str);
                        }
                   }
                   // END S-261774 - By Hemlata   
            if(pstopics.size()>0){
               system.debug('pstopics***'+pstopics);
                insert pstopics;
            }

           } // if 
            upsert(contact);
            status = true;
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
        }
        return status;
    }
    
}