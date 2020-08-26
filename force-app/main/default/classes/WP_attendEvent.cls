@RestResource(urlMapping='/WP_attendEvent/*')
global without sharing class WP_attendEvent{


    @HttpPost
    global static Resp doGet(  String eventId,String mpId,String accountId ,
                             String email,String badgeNameFirst,String badgeNameLast ,
                             String badgeName, String Dietary,String dayOne,String dayTwo,
                             String dinner,String preDinner,String morningSession ,
                             String comments,String dayOnePlus,String dayTwoPlus,
                             String dinnerPlus,String preDinnerPlus,String morningSessionPlus,
                             Boolean assistant,
                             String Data , Boolean  teamMember ,
                             Boolean   Debug,
                             String siteSelection  )
    {
        Resp Res = new Resp();
        
        WP_DataWrapper dData   = (WP_DataWrapper)JSON.deserialize( Data , WP_DataWrapper.class);
        
        // -1- 
        Contact Con = New Contact(id = mpId);
        Con.Dietary__c = Dietary;
        Con.website_user__c = true;
        update Con;
        
        //EOC -1-
        
        
        // -2- 
        Event_Members__c eventMsg = New Event_Members__c(Event__c=  eventId,Contact__c = mpId);
        eventMsg.Badge_Name__c =  badgeName ;
        if(preDinner != null && preDinner.trim() != '')
            eventMsg.Pre_Dinner_Role__c =  preDinner ;
        eventMsg.Day_1_Role__c =  dayOne ;
        eventMsg.Day_2_Role__c =  dayTwo ;
        eventMsg.Dinner_Role__c =  dinner ;
        if(morningSession   != null && morningSession.trim()    != '')
               eventMsg.Optional_Morning_Session_TC__c =  morningSession   ;
        eventMsg.RSVP_Comments__c =  comments   ;
        eventMsg.RSVP_Submitted_Email__c = email ;
        insert eventMsg;
        res.resid =eventMsg.id;
        //EOC -2-
        
        // -3- 
        Res.plus1Contact = null;
        if(teamMember   == true)
        {
             List<Contact> cons = [ SELECT  Id  FROM Contact WHERE  Email = : dData.teamMemberEmail ]   ; // -3.1- 
             if(cons.size() ==  0 )    // -3.2- 
             {
                 Contact ConTeamMem = new Contact();
                 ConTeamMem.Email     = dData.teamMemberEmail ;
                 ConTeamMem.FirstName = dData.teamMemberFirst ;
                 ConTeamMem.LastName  = dData.teamMemberLast ;
                 ConTeamMem.Title     = dData.teamMemberTitle ;
                 ConTeamMem.Accountid = accountId  ;
                 insert  ConTeamMem;
                 Res.plus1Contact =ConTeamMem.id ;

             }else
             {    
                 Res.plus1Contact =cons[0].id ;
             }
             
            //  -3.3- 
             
                 
                 List<Event_Members__c> events = [select id from Event_Members__c where   Contact__c = :  Res.plus1Contact AND Event__c = : eventId limit 1];
                 if(events.size()  > 0 )  // -3.3.1-
                 {
                     events[0].Badge_Name__c = dData.teamMemberBadgeName ;
                     events[0].RSVP_Submitted_Email__c = dData.teamMemberEmail;
                     if(preDinnerPlus  != null && preDinnerPlus.trim()  != '')
                     {
                         events[0].Pre_Dinner_Role__c  =preDinnerPlus ;
                     }
                     events[0].Day_1_Role__c =dayOnePlus  ;
                     events[0].Day_2_Role__c =dayTwoPlus ;
                     events[0].Dinner_Role__c = dinnerPlus;
                     if(morningSessionPlus != null && morningSessionPlus.trim()  != '')
                     {
                         events[0].Optional_Morning_Session_TC__c  =morningSessionPlus ;
                     }
                     update events;
                     res.registrationId  =  events[0].id;
                 }else
                 {
                     Event_Members__c event = new Event_Members__c();
                     event.event__c = eventId;
                     event.Contact__c  =  Res.plus1Contact ;
                     event.Badge_Name__c = dData.teamMemberBadgeName ;
                     event.RSVP_Submitted_Email__c = dData.teamMemberEmail ;
                     
                     if(preDinnerPlus != null && preDinnerPlus.trim()  != '')
                     {
                         event.Pre_Dinner_Role__c =   preDinnerPlus ;
                     }
                     event.Day_1_Role__c =dayOnePlus  ;
                     event.Day_2_Role__c =dayTwoPlus ;
                     event.Dinner_Role__c = dinnerPlus ;
                     
                     
                     
                     if(morningSessionPlus != null && morningSessionPlus.trim()  != '')
                     {
                         event.Optional_Morning_Session_TC__c  = morningSessionPlus ;
                     }
                     insert event;
                     res.registrationId  = event.id;
                 
                 }
             
               
        }
       //EOC -3-  
        
        
        // -4- 
        if(assistant == true)
        {
              // -4.1- 
             List<Contact> cons = [ SELECT   Assistant_1__c, Assistant_2__c , Assistant_3__c, Id  FROM Contact WHERE  Email = : dData.teamMemberAssistantEmail ]   ;
             if(cons.size() ==  0 )    // -4.2- 
             {
                  Contact ConAssistant  = new Contact();
                  ConAssistant.Email = dData.teamMemberAssistantEmail ;
                  ConAssistant.FirstName = dData.teamMemberAssistantFirst ;
                  ConAssistant.LastName = dData.teamMemberAssistantLast ;
                  ConAssistant.Phone  = dData.teamMemberAssistantPhone;
                  ConAssistant.Accountid = Accountid;
                  if(Res.plus1Contact != null )
                  {
                      ConAssistant.ReportsToId = Res.plus1Contact ;
                  }
                  insert ConAssistant;
                  res.ConAssistantId  = ConAssistant.id;
             }else
             {
                 res.ConAssistantId  = cons[0].id;
                 /* we assume older contact alreaedy have reporttoid .
                 if(Res.plus1Contact != null )
                  {
                      cons[0].ReportsToId = Res.plus1Contact ;
                      update cons[0];
                  }
                 */
                 
             }
             
             
             if(Res.plus1Contact  != null )
             {
                 cons = [ SELECT   Assistant_1__c, Assistant_2__c , Assistant_3__c, Id  FROM Contact WHERE  id = : Res.plus1Contact limit 1 ]   ;
               
                 if(cons[0].Assistant_1__c  != res.ConAssistantId && cons[0].Assistant_2__c != res.ConAssistantId && cons[0].Assistant_3__c != res.ConAssistantId) {
                     if(cons[0].Assistant_1__c  == null  )
                     {
                             cons[0].Assistant_1__c =res.ConAssistantId;update cons;
                     }else if(cons[0].Assistant_2__c  == null )
                     {
                             cons[0].Assistant_2__c =Res.ConAssistantId;update cons;
                     }else if(cons[0].Assistant_3__c  == null )
                     {
                             cons[0].Assistant_3__c =Res.ConAssistantId;update cons;
                     }
                 }
             
             }
             
             
        }
        //EOC -4-  
        return res;
    
    
    }
    
    
    
    global class Resp 
    {
        Public boolean Succses {get ; set ;}
        Public String  ErrorMsg {get ; set ;}
        public Id plus1Contact = null;
        public Id  ConAssistantId = null;
        public Id  registrationId = null;
        public Id  resId = null;
        public Resp()
        {
            Succses   = true;
        }
         
    }
    
}