public class ytdPerformanceControllerGroup_FRS {
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    Public List<Repository__c> wrapDataList = new List<Repository__c>();
    
    Public Decimal totalYtd = 0.00;
    Public Map<String, Decimal> ytdMap = new Map<String, Decimal>();
    Public Map<String, String> divGroupMap = new Map<String, String>();
    Public Set<String> divSet = new Set<String>();
    
    Integer fyStartMonth;
    Public Date fyStartDate;
    Public Date fyEndDate; 
    
    public ytdPerformanceControllerGroup_FRS()
    {
        wrappedDataList = new List<WrapperClass>();
        Map<String, Decimal> ytdMap = new Map<String, Decimal>();
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        fetchData();
    }
    
    
    Public void fetchData(){
        Decimal tarTot = 0.00;
        Decimal ytdTot = 0.00;
        Decimal varTot = 0.00;
        Map<String, Decimal> targetMap = new Map<String, Decimal>();
        List<String> CBDivList = new List<String>();
        List<String> YBDivList = new List<String>();
        List<String> divFinalList = new List<String>();
        id scotlandBHoursId;
        id englandBhoursId;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.today(), fyStartMonth);
        Datetime endDate;            
        Date fyEndDate = CYBGUtilClass.findEndDateOfFY(System.today(), fyStartMonth);
        Long scotDays;
        Long engDays;
        Long scotTotDays;
        Long engTotDays;
        
        endDate = System.Now();
        List<BusinessHours> bhList = [SELECT Id,Name FROM BusinessHours limit 5];
        for(BusinessHours bh : bhList){
            if(bh.Name.equalsIgnoreCase(System.Label.ScotlandBusinessHours))
                scotlandBHoursId = bh.id;
            if(bh.Name.equalsIgnoreCase(System.Label.EnglandBusinessHours))
                englandBhoursId = bh.id;
        }        
        
        
        engDays = (BusinessHours.diff(englandBhoursId , startDate, endDate)/(1000*60*60*24))+1;
        engTotDays = (BusinessHours.diff(englandBhoursId , startDate, fyEndDate)/(1000*60*60*24))+1;               
        
        scotDays = (BusinessHours.diff(scotlandBHoursId , startDate, endDate)/(1000*60*60*24))+1;
        scotTotDays = (BusinessHours.diff(scotlandBHoursId , startDate, fyEndDate)/(1000*60*60*24))+1;               
        
        for(Region__c each : [SELECT Id, Name, Region_Division__r.Name, Region_FXDirectTarget__c, 
                              Region_FXIndirectTarget__c, Region_FXRetail__c, Region_IRRMTarget__c, Region_CommTarget__c  
                              FROM Region__c WHERE Region_Status__c = 'Active'])
        {
            Decimal target = 0.00;
            target = each.Region_FXDirectTarget__c + each.Region_FXIndirectTarget__c + each.Region_FXRetail__c + each.Region_IRRMTarget__c + each.Region_CommTarget__c;
            target = ((target / engTotDays) * engDays).setScale(2);
            if(targetMap.containsKey(each.Name))
                targetMap.put(each.Name, (Decimal)targetMap.get(each.Name) + target);
            else
                targetMap.put(each.Name, target);
            
            divGroupMap.put(each.Name, each.Name);
            
            if(each.Region_Division__r.Name == 'Clydesdale')
                CBDivList.add(each.Name);
            else if(each.Region_Division__r.Name == 'Yorkshire')
                YBDivList.add(each.Name);
        }
        
        CBDivList.sort();
        YBDivList.sort();
        Integer i=0; 
        Integer j=0;
        while(j < CBDivList.size() + YBDivList.size())
        {
            divFinalList.add(CBDivList[i]);
            divFinalList.add(YBDivList[i]);
            i = i+1;
            j = j+2;
        }
        
        AggregateResult[] ytdAgr = [SELECT SUM(Amount) amt, Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name div,
                                     Opp_BankName__c bnk
                                    FROM Opportunity WHERE CloseDate = THIS_FISCAL_YEAR AND StageName = 'Closed Won' AND
                                    RecordType.Name IN ('FX Cash', 'Commodity', 'IRRM')
                                    Group By Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name,Opp_BankName__c
                                    ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name,Opp_BankName__c];
        
        for(AggregateResult each : ytdAgr)
        {
            Decimal ytd = 0.00;
            String div = '';
            
            System.debug('');
            if((String)each.get('div') == null && each.get('bnk') == 'CB')
                div = 'CB_Retail';
            else if((String)each.get('div') == null && each.get('bnk') == 'YB')
                div = 'YB_Retail';
            else
                div = (String)each.get('div');
            
                System.debug((Decimal)each.get('amt'));
            divSet.add(div);
            if(ytdMap.containsKey(div))
                ytdMap.put(div, ((Decimal)ytdMap.get(div)+((Decimal)each.get('amt'))).setScale(2));
            else
                ytdMap.put(div, ((Decimal)each.get('amt')).setScale(2));
            
        }
        
        for(String each : divFinalList)
        {
            Decimal variance = 0.00;
            Decimal ytd = 0.00;
            Decimal target = 0.00;
            
            if(ytdMap.get(each) != null)
                ytd = ytdMap.get(each);
            if(targetMap.get(each) != null)
                target = targetMap.get(each);
            if(target !=  0.00)
                variance = ((ytd / target) * 100).setScale(2);
            
            ytdTot = ytdTot + ytd;
            tarTot = tarTot + target;
            wrappedDataList.add(new WrapperClass(each, ytd, variance));
        }
        if(tarTot != 0.00)
            varTot = ((ytdTot / tarTot) * 100).setScale(2);
        wrappedDataList.add(new WrapperClass('Total', ytdTot, varTot, true));
        
    }    
    public PageReference downloadReport_FRS() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceGroup_FRS_Dld');
        return nextpage;
    }
    Public class WrapperClass{

        Public String frsm {get; set;}
        Public Decimal actYtdTot {get; set;}
        Public Decimal varPer {get; set;}
        Public Boolean grouper {get; set;}
        
        /* Public Boolean groupIt {get; set;}*/
        Public WrapperClass(String frsm,  Decimal actYtdTot,  Decimal varPer)
        {
            this.frsm =  frsm;
            this.actYtdTot = actYtdTot;
            this.varPer = varPer;
        }
        Public WrapperClass(String frsm,  Decimal actYtdTot,  Decimal varPer, Boolean grouper)
        {
            this.frsm =  frsm;
            this.actYtdTot = actYtdTot;
            this.varPer = varPer;
            this.grouper = grouper;
        }
    }
}