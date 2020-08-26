// 
// (c) 2017 Appirio (A Wipro company), Inc.
//
// Overriding clone button on Milestone object and also used in Clear & Clone
//
// 26 Dec 2017     Jai Gupta       Original (S-534162) Clone and Clear & Clone functionality implementation on Milestone object.
//
//

public class CustomClone {
    
    public Id objID ;
    @testVisible boolean clearClone = false ;
    
    public CustomClone(ApexPages.standardController sc) {
    		try {
            objID = Apexpages.currentPage().getParameters().get('id');
            
            if(Apexpages.currentPage().getParameters().get('clearclone') != null) {
                clearClone = true ;
            } else {
                clearClone = false ;
            }
        } catch(Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+e.getMessage());
            ApexPages.addMessage(myMsg);
        }
    	
    }
    
    public pageReference redirect() {
    
        if(objID != null) {
            String sObjectName = String.valueOf(objID.getSObjectType());
            List<Custom_Clone_Fields__mdt> cFields = fetchCloneFields(sObjectName);
            return genereateCloneURL(cFields);
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Id in the url.');
            ApexPages.addMessage(myMsg);
            return null ;
        }
    }
    
    public List<Custom_Clone_Fields__mdt> fetchCloneFields(string objectName) {
        
        String query = 'Select Clear_Clone__c, Clone__c, Field_value__c, html_id__c, Object_API_Name__c from Custom_Clone_Fields__mdt where Object_API_Name__c = :objectName' ;
        
        if(clearClone) {
            query += ' and Clear_Clone__c = true ' ;
        } else {
        		query += ' and Clone__c = true ' ;
        }
        
        List<Custom_Clone_Fields__mdt> cloneFields = (List<Custom_Clone_Fields__mdt>)Database.query(query);
        
        return cloneFields ;
    }
    
    public pageReference genereateCloneURL(List<Custom_Clone_Fields__mdt> cloneFields) {
        
        string cloneURL = '' ;
        string baseURL = '' ;
        string cloneBaseURL = baseURL + '/'+objID+'/e?clone=1&nooverride=1&retURL=/'+objID ;
        
        cloneURL += cloneBaseURL ;
        
        string tempURL = '' ;
        for(Custom_Clone_Fields__mdt c : cloneFields) {
            tempURL += '&' ;
            string fieldVal = '' ;
            if(String.isNotBlank(c.Field_value__c)) {
                fieldVal = c.Field_value__c ;
            }
            tempURL += c.html_id__c+'='+fieldVal ;
        }
        
        PageReference pg = new PageReference(cloneURL + tempURL);
        pg.setRedirect(true);
        return pg ;

    }
}