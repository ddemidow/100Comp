/*******************************************************************************
* @Class       : PTOBalanceController
* @author      : Hemlata Mandowara (Appirio JDC)
* @date        : Aug 2014
* @description : Controller for ptoBalance page, used in Home Page Component to display PTO Balances(S-253235)
*******************************************************************************/
public class PTOBalanceController
{ 
    public List<BarWedgeData> getBarData()
    { 
        List<BarWedgeData> data = new List<BarWedgeData>();
        Decimal Vacation_Begin_Bal = 0;
        Decimal Sick_Begin_Bal = 0;
        Decimal Vacation_Used = 0;
        Decimal Sick_Used = 0;
        Decimal Vac_Remaining = 0;
        Decimal Sick_Remaining = 0;
        Date startDate;
        Date endDate;
        
        Id currentUserId = UserInfo.getUserId();
        
         // To get Begin Balance in Hours
        for (contact contobj : [select Id, Name,Vacation_Beg_Bal__c, Sick_Begin_Balance__c, pse__Salesforce_User__c from Contact where pse__Salesforce_User__c = :currentUserId]) {
            if (contobj.Vacation_Beg_Bal__c != null) {
                Vacation_Begin_Bal = contobj.Vacation_Beg_Bal__c;
            }
            if (contobj.Sick_Begin_Balance__c != null) {
                Sick_Begin_Bal = contobj.Sick_Begin_Balance__c;
            }    
        }       
        
        // To get Ids of all Vacation and Sick Projects
        List<Vacation_Sick_Projects__c> projectList = Vacation_Sick_Projects__c.getall().values();
        Map<String, String> projMap = new Map<String,String>();
        for ( Vacation_Sick_Projects__c proj : projectList) {
            if (proj.Project_ID__c != null && proj.Project_ID__c.length() >=15) {
                projMap.put(proj.Project_ID__c.substring(0,15), proj.Project_Type__c);
            }    
        }
        
        // To get Start Date and End Payroll Date 
        List<Payroll_Dates__c> payRollDateList = Payroll_Dates__c.getall().values();
        system.debug('payRollDateList **'+payRollDateList);
        if (payRollDateList != null && payRollDateList.size() > 0) {
            startDate = payRollDateList[0].Start_Date__c;
            endDate = payRollDateList[0].End_Date__c;
        } else {
            startDate  = date.newInstance(System.Today().year(), 01, 01);
            endDate  = System.Today();
        }
        
        // To get Used Hours from Timecard Splits
        for (pse__Timecard__c  timeCardObj : [select Id, pse__Status__c, pse__Total_Hours__c, pse__Project__c, pse__Start_Date__c, pse__End_Date__c,pse__Resource__c, pse__Resource__r.pse__Salesforce_User__c from pse__Timecard__c 
                                                where pse__Resource__r.pse__Salesforce_User__c = :currentUserId 
                                                AND  pse__Status__c in ('Submitted', 'Approved')
                                                AND pse__Start_Date__c >= :startDate AND pse__End_Date__c <= :endDate
                                                AND pse__Project__c in : projMap.keySet()]) {
            System.debug('timeCardObj.pse__Project__c**'+timeCardObj.pse__Project__c);     
            String pse_Project = timeCardObj.pse__Project__c;                   
            if(pse_Project  != null && pse_Project.length() >=15 && projMap.containsKey(pse_Project.substring(0,15))) {
                pse_Project  = pse_Project.substring(0,15); 
                if (projMap.get(pse_Project) != null && projMap.get(pse_Project).toLowerCase() == 'vacation') {
                    Vacation_Used = Vacation_Used + timeCardObj.pse__Total_Hours__c;
                } else if (projMap.get(pse_Project) != null && projMap.get(pse_Project).toLowerCase() == 'sick') {
                    Sick_Used = Sick_Used + timeCardObj.pse__Total_Hours__c;
                }
            }
        }     
        
        // To get Remaining balance
        Vac_Remaining = Vacation_Begin_Bal -  Vacation_Used;
        Sick_Remaining = Sick_Begin_Bal - Sick_Used;
        
        // To put data in wrapper class to create Bar Chart
        data.add(new BarWedgeData('Vacation',Vacation_Begin_Bal,Vacation_Used,Vac_Remaining));
        data.add(new BarWedgeData('Sick',Sick_Begin_Bal,Sick_Used,Sick_Remaining));
        return data; 
    } 
   
    // Wrapper class 
    public class BarWedgeData
    { 
        public String name { get; set; } 
        public Decimal Begin_Balance { get; set; } 
        public Decimal Used { get; set; }
        public Decimal Remaining { get; set; }
       
        public BarWedgeData(String name, Decimal Begin_Bal,Decimal Used, Decimal Remaining)
        { 
            this.name = name; 
            this.Begin_Balance  = Begin_Bal; 
            this.Used= Used; 
            this.Remaining = Remaining;
        } 
    } 
}