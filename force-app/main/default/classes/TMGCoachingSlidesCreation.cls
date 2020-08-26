/***********************************************************************************************************
* Appirio, Inc
* Name          : TMGCoachingSlidesCreation
* Created By    : Shivani Jain(Appirio)
* Purpose       : Create TMG Coaching Slides for Email Attachments received on coachingplans@miles-group.com
* Created Date  : 17/02/2019
*
* Date Modified                Modified By             Description of the update
* Updated By    : Lokesh Korani(Appirio)
* Purpose       : Create TMG Content View records for Email  received on coachingplans@miles-group.com
* Updated Date  : 12/07/2020
*
* Date Modified                Modified By             Description of the update

----------------------------------------------------------------------------------------------------------
* [Date]                       [Person Name]           [Short Description]
**********************************************************************************************************/
global class TMGCoachingSlidesCreation implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //START, Changes updated by Lokesh Korani on 12/07/2020 for Story :S-665486 (Create TMG Content View records for Email)
        Set<String> emails = new Set<String>();
        Map<String,Id> emailToConMap = new Map<String, Id>();
        Map<String, String> IdToURLMap = new Map<String, String>();
        string cavanEmail = '';
        user fromUser;
         if(email != NULL) {
        for(Contact con : [SELECT id,Email,Name from Contact where Email IN: email.toAddresses   ]) {
            emailToConMap.put(con.Email, con.id);
        }
        for(user U : [Select id,email from user where Email =: email.fromAddress or id=: Label.Cavan_Email]){
            if(string.valueof(U.id).substring(0,15)== Label.Cavan_Email){
               cavanEmail = u.email; 
                 if(email.fromAddress == u.email){
                    fromUser = u;
                }
            }
            else{
            fromUser = u;
            }
        }
            Set<String> NewList =New Set<String>();
            if (email.plainTextBody != null) { 
                for (String line : email.plainTextBody.split('\n')) { 
                    for (String row : line.split(' ')) {
                    TMG_Content_Viewed__c tCoachSlide = new TMG_Content_Viewed__c();
                    row = row.trim();
                    if(row.contains(System.Label.URLTmgContentView)) {
                        String Ab = row.replaceAll(' ', '');
                        Integer A= Ab.lastIndexOf('/');
                        NewList.add(Ab.right(Ab.length()-A-1));
                    }
                }
                }
            }
            set<string> contactnotExist = new set<string>();
            List<TMG_Content_Viewed__c	> contentViewToBeInserted = new list<TMG_Content_Viewed__c	>();
            If(NewList.size()>0){
            for(TMG_Coaching_Guide__c	 cg : [Select id,name from TMG_Coaching_Guide__c	 where name in :NewList ]){
                Newlist.remove(cg.name);
                for(String emailAddress: Email.toAddresses){
                    if(!emailToConMap.ContainsKey(emailAddress)){
                        contactnotExist.add(emailAddress);
                    }
                    else{
                    contentViewToBeInserted.add(new TMG_Content_Viewed__c(TMG_Coaching_Guides__c=cg.id,Contact__c = emailToConMap.get(emailAddress), From_lu__c = fromUser!= null?fromUser.id:null,Date_Sent__c=System.today(),Sent__c=TRUE,To__c = emailAddress));
                }
                }
                
            }
            }
            if(!contentViewToBeInserted.isEmpty()){
                try{
                    Database.insert(contentViewToBeInserted,false);
                }catch(exception e){
                    
                }
            }
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
            if(!Newlist.isEmpty() ){
                for(string s: Newlist){
                    messages.add(createEmail(email.toAddresses,email.fromAddress,s,cavanEmail));
                }
            }    
            if(!contactnotExist.isEmpty() ){
                for(string s: contactnotExist){
                   
                    messages.add(createEmail(email.toAddresses,email.fromAddress,s,cavanEmail));
                }   
            }
            if(!messages.isEmpty()){ 
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
         }
        return result;
    }
    

Public static Messaging.SingleEmailMessage CreateEmail(list<string> toAddress, string fromAddress, string ID ,string cavanEmail){
     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();    
                    message.toAddresses = new String[] { System.Label.TmgContentViewRecords,CavanEmail };
                        message.subject = System.Label.TmgContentViewSubject;
                    message.plainTextBody = Label.TmgContentViewBody +'\n'+
                        '\n TO: '+string.join(new list<string>(toAddress),';')+'\n'+
                        '\n FROM: '+fromAddress+'\n'+
                        '\n ID: '+id+'\n'+
                        '\n Date: '+date.today();
    return message;
    
}
     //END, Changes updated by Lokesh Korani on 12/07/2020 for Story :S-665486 (Create TMG Content View records for Email)
}