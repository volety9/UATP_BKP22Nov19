public class QuarterEndForecastingController_PSD2 {
    public List<WrapperClass> wrapper{get; set;}
    public List<WrapperClass> wrapperResult{get; set;}
    public string jsonresult {get; set;}  
    public QuarterEndForecastingController_PSD2()
    {
       wrapperResult = new List<WrapperClass>();  
    }
    
    @ReadOnly
    @RemoteAction
    public Static List<WrapperClass> exec()
    {
        Map<String, Decimal> ytdMap = new Map<String, Decimal>();
        Map<String, Decimal> irrmPipelineMap = new Map<String, Decimal>();
        Map<String, Decimal> commPipelineMap = new Map<String, Decimal>();
        Map<String, Decimal> fxPipelineMap = new Map<String, Decimal>();
        Map<String, Decimal> rollingFXMap = new Map<String, Decimal>();
        Map<String, Decimal> revenueMap = new Map<String, Decimal>();
        Map<String, Decimal> planMap = new Map<String, Decimal>();
        Map<String, Decimal> planPercentMap = new Map<String, Decimal>();
        Map<String, Decimal> quarterEndForecastMap =  new Map<String, Decimal>();
        Map<String, String> divGrpMap = new Map<String, String>();
        Decimal totalYtd = 0.00;
        Decimal totalIRRMPipeline = 0.00;
        Decimal totalCommPipeline = 0.00;
        Decimal totalFxForecast = 0.00;
        Decimal totalRollingFX = 0.00;
        Decimal totalRevenue = 0.00;
        Decimal totalPlan = 0.00;
        Decimal totalPlanPercent = 0.00;
        Decimal totalQuarterEnd = 0.00;
        List<String> divListCB = new List<String>();
        List<String> divListYB = new List<String>();
        List<String> divFinalList = new List<String>();
        Set<String> divSet = new Set<String>();
        Map<String, String> divGroupMap = new Map<String, String>();
         Integer fyStartMonth;
     Date fyStartDate;
     Date fyEndDate; 
        List<WrapperClass> wrapper = new List<WrapperClass>();
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        for(Region__c each : [SELECT Id, Name, Region_Division__r.Name FROM Region__c WHERE Region_Status__c = 'Active'])
        {
            divGroupMap.put(each.Name, each.Region_Division__r.Name);
        }
        id englandBhoursId;
        List<BusinessHours> bhList = [SELECT Id,Name FROM BusinessHours limit 5];
        for(BusinessHours bh : bhList){
            if(bh.Name.equalsIgnoreCase(System.Label.EnglandBusinessHours))
                englandBhoursId = bh.id;
        }        
        
        Period periodListLastQuarter = [Select StartDate, EndDate, Number From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER LIMIT 1];
        Date lastQuarterStartDate = periodListLastQuarter.StartDate;
        Date lastQuarterEndDate = periodListLastQuarter.EndDate;
        Long lastQuarterWorkingDays = (BusinessHours.diff(englandBhoursId , lastQuarterStartDate, lastQuarterEndDate)/(1000*60*60*24))+1;
        
        Period periodListThisQuarter = [Select StartDate, EndDate, Number From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER LIMIT 1];
        Date thisQuarterStartDate = periodListThisQuarter.StartDate;
        Date thisQuarterEndDate = periodListThisQuarter.EndDate;
        Long thisQuarterWorkingDays = (BusinessHours.diff(englandBhoursId , thisQuarterStartDate, thisQuarterEndDate)/(1000*60*60*24))+1;
        Long thisQuarterRemainingWorkingDays = (BusinessHours.diff(englandBhoursId , System.Now(), thisQuarterEndDate)/(1000*60*60*24))+1;
        Integer thisQuarterNumber = periodListThisQuarter.Number;
        
        Period periodListNextQuarter = [Select StartDate, EndDate, Number From Period Where type = 'Quarter' and StartDate = NEXT_FISCAL_QUARTER LIMIT 1];
        Date nextQuarterStartDate = periodListNextQuarter.StartDate;
        Date nextQuarterEndDate = periodListNextQuarter.EndDate;
        Long nextQuarterWorkingDays = (BusinessHours.diff(englandBhoursId , nextQuarterStartDate, nextQuarterEndDate)/(1000*60*60*24))+1;
        
        Decimal planQuarter = thisQuarterNumber * 0.25;
        
        AggregateResult[] ytd = [SELECT SUM(Amount)amt ,Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name div,
                                 Opp_BankName__c bnk FROM Opportunity
                                 WHERE CloseDate = THIS_FISCAL_YEAR AND StageName = 'Closed Won' AND 
                                 RecordType.Name IN ('IRRM', 'Commodity', 'FX Cash') 
                                 GROUP BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, Opp_BankName__c
                                 ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, Opp_BankName__c];
        
        AggregateResult[] pipeLine = [SELECT SUM(Amount)amt, Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name div, RecordType.Name rcd FROM Opportunity 
                                      WHERE CloseDate = THIS_FISCAL_QUARTER AND StageName NOT IN ('Closed Won', 'Closed Lost') AND 
                                      RecordType.Name IN ('IRRM', 'Commodity', 'FX Cash') AND 
                                      Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name != null  
                                      GROUP BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, RecordType.Name
                                      ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, RecordType.Name];
        
        AggregateResult[] rollingFX = [SELECT SUM(Amount)amt, Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name div FROM Opportunity 
                                       WHERE CloseDate = LAST_FISCAL_QUARTER AND StageName = 'Closed Won' AND 
                                       RecordType.Name = 'FX Cash' AND 
                                       Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name != null
                                       GROUP BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name
                                       ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name];
        
        
       
        for(AggregateResult each : ytd)
        {
            /* 
             * @Santhoshan - Changes Done for CB_Retail and YB_Retail Calculation to be pulled directly from Opportunity Object
             * 09/04/2019
             * instead of from Repository Object
             * Starts Here
             * */
            String div = '';
            if(each.get('div') == null && each.get('bnk') == 'CB')
                div = 'CB_Retail';
            else if(each.get('div') == null && each.get('bnk') == 'YB')
                div = 'YB_Retail';
            else
				div = (String)each.get('div');
                
            System.debug('EACH>>>>'+div);
            divSet.add(div);
            if(ytdMap.containsKey(div))
                ytdMap.put(div, ((Decimal)ytdMap.get(div)+((Decimal)each.get('amt'))).setScale(2));
            else
                ytdMap.put(div, ((Decimal)each.get('amt')).setScale(2));
            
            /* 
             * @Santhoshan - Changes Done for CB_Retail and YB_Retail Calculation to be pulled directly from Opportunity Object
             * 09/04/2019
             * instead of from Repository Object
             * Ends Here
             * */
            
            totalYtd = totalYtd + (Decimal)each.get('amt');
            if(quarterEndForecastMap.containsKey(div))
                quarterEndForecastMap.put(div, (((Decimal)each.get('amt')) + quarterEndForecastMap.get(div)));
            else
                quarterEndForecastMap.put(div, ((Decimal)each.get('amt')));
            
            totalQuarterEnd = totalQuarterEnd + (Decimal)each.get('amt');
        }
        System.debug('YTD>>>>'+ytdMap);
        for(AggregateResult each : pipeLine)
        {
            divSet.add((String)each.get('div'));
            if((String)each.get('rcd') == 'FX Cash')
            {
                fxPipelineMap.put((String)each.get('div'), ((Decimal)each.get('amt')).setScale(2));
                totalFxForecast = totalFxForecast + (Decimal)each.get('amt');
            }
            else if((String)each.get('rcd') == 'Commodity')
            {
                commPipelineMap.put((String)each.get('div'), ((Decimal)each.get('amt')).setScale(2));
                totalCommPipeline = totalCommPipeline + (Decimal)each.get('amt');
            }
            else if((String)each.get('rcd') == 'IRRM')
            {
                irrmPipelineMap.put((String)each.get('div'), ((Decimal)each.get('amt')).setScale(2));
                totalIRRMPipeline = totalIRRMPipeline + (Decimal)each.get('amt');
            }
        }
        
        for(AggregateResult each : rollingFX)
        {
            Decimal rollingFXAmount = 0.00;
            if(lastQuarterWorkingDays != 0)
                rollingFXAmount = (((Decimal)each.get('amt') / lastQuarterWorkingDays) * thisQuarterRemainingWorkingDays).setScale(2);
            
            divSet.add((String)each.get('div'));
            rollingFXMap.put((String)each.get('div'), rollingFXAmount);
            totalRollingFX = totalRollingFX + rollingFXAmount;
        }
        
        for(String each : divSet)
        {
            Decimal pipeLineFX = fxPipelineMap.get(each) != null ? fxPipelineMap.get(each) : 0.00;
            Decimal pipeLineComm = commPipelineMap.get(each) != null ? commPipelineMap.get(each) : 0.00;
            Decimal pipeLineIrrm = irrmPipeLineMap.get(each) != null ? irrmPipeLineMap.get(each) : 0.00;
            Decimal rolling = rollingFXMap.get(each) != null ? rollingFXMap.get(each) : 0.00;
            
            revenueMap.put(each, (pipeLineFX + pipeLineComm + pipeLineIrrm + rolling).setScale(2));
            totalRevenue = totalRevenue + (pipeLineFX + pipeLineComm + pipeLineIrrm + rolling);
            
            if(quarterEndForecastMap.containsKey(each))
                quarterEndForecastMap.put(each, ((pipeLineFX + pipeLineComm + pipeLineIrrm + rolling) + quarterEndForecastMap.get(each)));
            else
                quarterEndForecastMap.put(each, (pipeLineFX + pipeLineComm + pipeLineIrrm + rolling));
            
            totalQuarterEnd = totalQuarterEnd + (pipeLineFX + pipeLineComm + pipeLineIrrm + rolling);
        }
        
        List<Region__c> divList = [SELECT Id, Name, Region_FXDirectTarget__c, Region_FXIndirectTarget__c, Region_FXRetail__c, Region_CommTarget__c, Region_IRRMTarget__c FROM
                                   Region__c WHERE Name != null];
        for(Region__c each : divList)
        {
                planMap.put(each.Name, ((each.Region_FXDirectTarget__c + each.Region_FXIndirectTarget__c + each.Region_FXRetail__c + each.Region_CommTarget__c + each.Region_IRRMTarget__c) * planQuarter).setScale(2));
                totalPlan = totalPlan + ((each.Region_FXDirectTarget__c + each.Region_FXIndirectTarget__c + each.Region_FXRetail__c + each.Region_CommTarget__c + each.Region_IRRMTarget__c) * planQuarter);
        }
        
        for(String each : divSet)
        {
            if(planMap.get(each) != 0.00 && planMap.get(each) != null)
            {
                planPercentMap.put(each, ((quarterEndForecastMap.get(each) / planMap.get(each)) * 100).setScale(0));
            }
            else
            {
                planPercentMap.put(each, 0);
            }
        }
        
        if(totalPlan != null && totalPlan != 0.00)
        {
            totalPlanPercent = ((totalQuarterEnd / totalPlan) * 100).setScale(0);
        }
        
        for(String each : divSet)
        {
            if(divGroupMap.get(each) == 'Clydesdale')
                divListCB.add(each);
            else if(divGroupMap.get(each) == 'Yorkshire')
                divListYB.add(each);
        }
        divListCB.sort();
        divListYB.sort();
        
        Integer i=0; 
        Integer j=0;
        while(j < divListCB.size() + divListYB.size())
        {
            divFinalList.add(divListCB[i]);
            divFinalList.add(divListYB[i]);
            i = i+1;
            j = j+2;
        }
        for(String each : divFinalList)
        {
            
            wrapper.add(new WrapperClass(each, ytdMap.get(each), fxPipelineMap.get(each), commPipelineMap.get(each), irrmPipelineMap.get(each),
                                         rollingFXMap.get(each), revenueMap.get(each), quarterEndForecastMap.get(each), planMap.get(each), planPercentMap.get(each)));
            
        }
        
        wrapper.add(new WrapperClass('Total', totalYtd.setScale(2), totalFxForecast.setScale(2), totalCommPipeline.setScale(2), totalIRRMPipeline.setScale(2), totalRollingFX.setScale(2),
                                     totalRevenue.setScale(2), totalQuarterEnd, totalPlan.setScale(2), totalPlanPercent));
        return wrapper;
    }   
    public PageReference downloadReport_FRS() {
        PageReference nextpage = new PageReference('/apex/QuarterEndForecasting_FRS_PSD2_Dld');
        return nextpage;
    }
    public PageReference deserializeWrapperList(){ 
        jsonresult = ApexPages.currentPage().getParameters().get('wrapResult');
        wrapperResult = (List<WrapperClass>)System.JSON.deserialize(jsonresult, List<WrapperClass>.class);        
        return null;
    }
    public Class WrapperClass{
        public String Division{get; set;}
        public Decimal ytd{get; set;}
        public Decimal fxPipeLine{get; set;}
        public Decimal commPipeLine{get; set;}
        public Decimal irrmPipeline{get; set;}
        public Decimal rollingFX{get; set;}
        public Decimal revenue{get; set;}
        public Decimal plan{get; set;}
        public Decimal planPercent{get; set;}
        public Decimal quarterEndForecast{get; set;}
        
        public WrapperClass(String Division, Decimal ytd, Decimal fxPipeLine, Decimal commPipeLine, Decimal irrmPipeline,
                            Decimal rollingFX, Decimal revenue, Decimal quarterEndForecast, Decimal plan, Decimal planPercent)
        {
            this.Division = Division;
            this.ytd = ytd;
            this.fxPipeline = fxPipeline;
            this.commPipeline = commPipeline;
            this.irrmPipeline = irrmPipeline;
            this.rollingFX = rollingFX;
            this.revenue = revenue;
            this.quarterEndForecast = quarterEndForecast;
            this.plan = plan;
            this.planPercent = planPercent;
        }
    }

}