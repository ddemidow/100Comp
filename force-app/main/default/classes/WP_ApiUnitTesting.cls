@isTest
private class WP_ApiUnitTesting{
   static testMethod void WPUnit_updateEvent(){     
        WP_updateEvent updateEvent  = new WP_updateEvent();
        Event__c Event = new Event__c(name = 'test');
        insert event;
        
        Account acc = new Account( name = 'test');
        insert acc;
          Contact mp = new Contact(lastname = 'test' ,firstname = 'test',Accountid = acc.id , email = 'test@apexunit.com');
        insert mp;
        Event_Members__c reg= new  Event_Members__c(Event__c = Event.id,Contact__c = mp.id );
        insert reg;
        
        
       WP_DataWrapper dData   = new   WP_DataWrapper();
       dData.teamMemberFirst = 'Tmfirst2';
       dData.teamMemberLast= 'Tmlast2';
       dData.teamMemberEmail= 'tmfirst2.tmlast2@apexunit.com';
       dData.teamMemberTitle = 'COO';
       
       dData.teamMemberBadgeFirst = 'Tmfirst2';
       dData.teamMemberBadgeLast = 'Tmfirst2 Tmlast2';
       
       dData.teamMemberAssistantFirst = 'Assistantfirst';
       dData.teamMemberAssistantLast = 'aasisstantfirst.assistantlast@apexunit.com';
       dData.teamMemberAssistantPhone = '(555) 555-5555';
       dData.teamMemberAssistantEmail= 'aasisstantfirst.assistantlast@apexunit.com';
       
       
       String Data  =  JSON.serialize(dData); 
        
       WP_updateEvent.doGet(  reg.Id,  event.Id, mp.Id, acc.Id ,
                              'test@apexunit.com', 'test', 'Member',
                              'badgeName',  'Dietary', 'dayOne', 'dayTwo',
                              'dinner', 'preDinner', 'morningSession' ,
                              'comments', 'dayOnePlus', 'dayTwoPlus',
                              'dinnerPlus', 'preDinnerPlus', 'morningSessionPlus',
                              true, //assistant
                              Data ,  true,
                              false,
                              'test@apexunit.com' , //previousNotAttending@test.com 
                              true,
                               'test@apexunit.com'); 
   

    }
    //Start--- Code Added By Parag Bhatt To fix Case #00253117
    static testMethod void WPUnit_updateEvent1(){     
        WP_updateEvent updateEvent  = new WP_updateEvent();
        Event__c Event = new Event__c(name = 'test');
        insert event;
        
        Account acc = new Account( name = 'test');
        insert acc;
          Contact mp = new Contact(lastname = 'test' ,firstname = 'test',Accountid = acc.id , email = 'test@apexunit.com');
        insert mp;
        Event_Members__c reg= new  Event_Members__c(Event__c = Event.id,Contact__c = mp.id );
        insert reg;
        
        
       WP_DataWrapper dData   = new   WP_DataWrapper();
       dData.teamMemberFirst = 'Tmfirst2';
       dData.teamMemberLast= 'Tmlast2';
       dData.teamMemberEmail= 'tmfirst2.tmlast2@apexunit.com';
       dData.teamMemberTitle = 'COO';
       
       dData.teamMemberBadgeFirst = 'Tmfirst2';
       dData.teamMemberBadgeLast = 'Tmfirst2 Tmlast2';
       
       dData.teamMemberAssistantFirst = 'Assistantfirst';
       dData.teamMemberAssistantLast = 'aasisstantfirst.assistantlast@apexunit.com';
       dData.teamMemberAssistantPhone = '(555) 555-5555';
       dData.teamMemberAssistantEmail= 'aasisstantfirst.assistantlast@apexunit.com';
       
       
       String Data  =  JSON.serialize(dData); 
   
   
   WP_updateEvent.doGet(  reg.Id,  event.Id, mp.Id, acc.Id ,
                              'test@apexunit.com', 'test', 'Member',
                              'badgeName',  'Dietary', 'dayOne', 'dayTwo',
                              'dinner', 'preDinner', 'morningSession' ,
                              'comments', 'dayOnePlus', 'dayTwoPlus',
                              'dinnerPlus', 'preDinnerPlus', 'morningSessionPlus',
                              true, //assistant
                              Data ,  true,
                              false,
                              'test@apexunit.com' , //previousNotAttending@test.com 
                              true, 'test@apexunit.com'); 
   

    }
    
    //END--- Code Added By Parag Bhatt To fix Case #00253117
    
    
  static testMethod void WPUnit_attendEvent(){     
        WP_updateEvent updateEvent  = new WP_updateEvent();
        Event__c Event = new Event__c(name = 'test');
        insert event;
        
        Account acc = new Account( name = 'test');
        insert acc;
        
        //Event_Members__c reg= new  Event_Members__c(Event__c = Event.id);
        //insert reg;
        Contact mp = new Contact(lastname = 'test' ,firstname = 'test',Accountid = acc.id , email = 'test@apexunit.com');
        insert mp;
        
        
        
        
        
       WP_DataWrapper dData   = new   WP_DataWrapper();
       dData.teamMemberFirst = 'Tmfirst2';
       dData.teamMemberLast= 'Tmlast2';
       dData.teamMemberEmail= 'tmfirst2.tmlast2@apexunit.com';
       dData.teamMemberTitle = 'COO';
       
       dData.teamMemberBadgeFirst = 'Tmfirst2';
       dData.teamMemberBadgeLast = 'Tmfirst2 Tmlast2';
       
       dData.teamMemberAssistantFirst = 'Assistantfirst';
       dData.teamMemberAssistantLast = 'aasisstantfirst.assistantlast@apexunit.com';
       dData.teamMemberAssistantPhone = '(555) 555-5555';
       dData.teamMemberAssistantEmail= 'aasisstantfirst.assistantlast@apexunit.com';
       
       
       String Data  =  JSON.serialize(dData); 
        
       WP_attendEvent.doGet(     event.Id, mp.Id, acc.Id ,
                              'test@apexunit.com', 'test', 'Member',
                              'badgeName',  'Dietary', 'dayOne', 'dayTwo',
                              'dinner', 'preDinner', 'morningSession' ,
                              'comments', 'dayOnePlus', 'dayTwoPlus',
                              'dinnerPlus', 'preDinnerPlus', 'morningSessionPlus',
                              true, //assistant
                              Data ,  true,
                              false, 'test@apexunit.com' ); 
   
   
    WP_attendEvent.doGet( event.Id, mp.Id, acc.Id ,
                              'test@apexunit.com', 'test', 'Member',
                              'badgeName',  'Dietary', 'dayOne', 'dayTwo',
                              'dinner', 'preDinner', 'morningSession' ,
                              'comments', 'dayOnePlus', 'dayTwoPlus',
                              'dinnerPlus', 'preDinnerPlus', 'morningSessionPlus',
                              true, //assistant
                              Data ,  true,
                              false, 'test@apexunit.com' ); 
   

    }    
}