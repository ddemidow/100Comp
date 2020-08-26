/****************************************
Author          : Appirio India - [Hitesh Pareek]
Date Original   : Dec 30, 2016
Purpose         : S-449232
****************************************/

public class UploadProjectCloseoutExt {
    
    public String Project_Benefits {get;set;}
    private pse__Proj__c Project {get;set;} 
    public String fileName {get;set;}
    public Blob fileBody {get;set;}
    //public string projbenifit_pick {get;set;}
    //public decimal benefit_amount {get;set;}
    public Project_Closeout__c obj {get;set;}
    
    public UploadProjectCloseoutExt(ApexPages.StandardController controller) { 
        this.Project = (pse__Proj__c)controller.getRecord();
        obj = new Project_Closeout__c();
    }   
    
    // creates a new Project_Closeout__c record
    private Database.SaveResult saveCustomAttachment() {                  
        //Project_Closeout__c obj = new Project_Closeout__c();
        obj.Project__c = Project.Id; 
        obj.Project_Benefits__c = Project_Benefits;
        //obj.Project_Benefit_multiselect__c = projbenifit_pick;
        //obj.Benefit_Amount__c = benefit_amount;
        // fill out cust obj fields
        return Database.insert(obj);
    }
    
    // create an actual Attachment record with the Project_Closeout__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        
        Attachment attachment = new Attachment();
        attachment.body = this.fileBody;
        attachment.name = this.fileName;
        attachment.parentId = parentId;
        // inser the attahcment
        result = Database.insert(attachment);
        // reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }
     
    /**
    * Upload process is:
    *  1. Insert new Project_Closeout__c record
    *  2. Insert new Attachment with the new Project_Closeout__c record as parent
    *  3. Update the Project_Closeout__c record with the ID of the new Attachment
    **/
    public PageReference processUpload() {
        try {            
            
            if(fileBody == null && fileName == null){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Please select a file to upload.'));
                return null;
            }
            
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
            
            if (customAttachmentResult == null || !customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));
                return null;
            }
        
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
        
            if (attachmentResult == null || !attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                  'Could not save attachment.'));            
                return null;
            } else {
                // update the custom attachment record with some attachment info
                Project_Closeout__c customAttachment = [select id from Project_Closeout__c where id = :customAttachmentResult.getId()];
                customAttachment.name = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        
        } catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        
        return new PageReference('/'+Project.Id);
    }
    
    public PageReference back() {
        return new PageReference('/'+Project.Id);
    }     

}