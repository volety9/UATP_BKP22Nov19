/*
@Author        : Suhas
@Name          : MonthlyPostingSummaryCls 
@Created Date  : 26th March 2018
@Description   : This is a Controller class for Monthly Postal Summary 
@version       : 1.0
*/

global class MonthlyPostingSummaryCls implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',
            6 => 'June',7 => 'July',8 => 'August',9 => 'Sept',10 => 'October',11 => 'November',12 => 'December'};
                integer startMonth = CYBGUtilClass.fiscalYearStartMonth();
        List<MonthlyPostingSummary__c> mpsList = new List<MonthlyPostingSummary__c>();
        String firstName = String.valueOf(System.today());
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        for(integer i=0;i<12;i++){
            MonthlyPostingSummary__c mps = new MonthlyPostingSummary__c();
            if(startMonth<fyStartMonth){
                Integer year = Integer.valueOf(System.Today().Year())+1; 
                mps.Name= monthMap.get(startMonth)+' '+String.valueOf(year);  
            }else{
                mps.Name= monthMap.get(startMonth)+' '+System.Today().Year();
            }
            mps.MPS_Month__c=startMonth;
            if(startMonth==12){
                startMonth=1;    
            }else{
                startMonth++;
            }            
            mps.MPS_Current_Posting_Month__c=false;
            mps.MPS_Fiscal_Year__c= CYBGUtilClass.findCurrentFY(System.Today(), 1);
            mps.MPS_Status__c='Not Published';            
            mpsList.add(mps);

        }

        
       Database.SaveResult[] resultEOMJournalRecordList = Database.Insert(mpsList, False); 
    }

}