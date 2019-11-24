public class PerformanceTrackerProductManagers {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Decimal fxDirectPercentage;
    Decimal fxInDirectPercentage;
    Decimal crmPercentage;
    Decimal commPercentage;
    Decimal irrmPercentage;
    Decimal retailPercentage;
    Decimal ytdRevenue;
    Decimal ytdPlan;
    Decimal variance;
    Decimal planPercentage;
    Decimal ytdPipeLine;
    Boolean Grouper;

    Public Set<Id> pmSet = new Set<Id>();
    
    //Public Set<Id> bcSet = new Set<Id>();
    //Public Map<String, String> combineId = new Map<String, String>();
    
    Public Map<Id, Decimal> oppMap= new Map<Id, Decimal>();
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    public PerformanceTrackerProductManagers(){
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        //fyStartDate = date.newInstance(2018, 10, 01);
        //fyEndDate = date.newInstance(2019, 09, 30);
        wrappedDataList = new List<WrapperClass>();
        
        fetchData();
    }
    
    Public void fetchData(){
       /* 
        Map<String, String> locationMap = new Map<String, String>();
        Long calDays;
        Long calTotDays;
        
        
        
               
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
        
        endDate = System.Now()-2;
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
        */

        for(PMTarget__c eachPMRec : [SELECT Name,PMTar_PMUser__c FROM PMTarget__c WHERE PMTar_Status__c = 'Active'
                                     AND PMTar_FYStartDate__c >= :fyStartDate AND PMTar_FYEndDate__c <= :fyEndDate])
        {
            pmSet.add(eachPMRec.PMTar_PMUser__c);
            
            // bcSet.add(eachPMRec.TSMTar_Team__c);
        }
        
         AggregateResult[] opptyAR = [SELECT SUM(PMTar_FXDirectTarget__c) fxDirectTarget, SUM(PMTar_FXDirectActual__c) fxDirectActual,
                                     SUM(PMTar_FXIndirectTarget__c) fxInDirectTarget, SUM(PMTar_FXIndirectActual__c) fxInDirectActual,
                                     SUM(PMTar_CRMTarget__c)crmTarget, SUM(PMTar_CRMActual__c)crmActual,
                                     SUM(PMTar_CommTarget__c)commTarget, SUM(PMTar_CommActual__c)commActual,
                                     SUM(PMTar_IRRMTarget__c)irrmTarget, SUM(PMTar_IRRMActual__c)irrmActual,
                                     SUM(PMTar_FXRetail__c)retailTarget, SUM(PMTar_FXRetailActual__c)retailActual,
                                     SUM(PMTar_FXDirectTargetTillDate__c)fxDirectTargetTillDate, SUM(PMTar_FXIndirerctTargetTillDate__c)fxInDirectTargetTillDate,
                                     SUM(PMTar_CRMTargetTillDate__c)crmTargetTillDate, SUM(PMTar_CommTargetTillDate__c)commTargetTillDate,
                                     SUM(PMTar_IRRMTargetTillDate__c)irrmTargetTillDate, SUM(PMTar_FXRetailTillDate__c)retailTargetTillDate,
                                     PMTar_PMUser__r.Name pm, PMTar_PMUser__c pmId
                                     FROM PMTarget__c
                                     WHERE PMTar_PMUser__c IN :pmSet AND CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                     GROUP BY PMTar_PMUser__r.Name, PMTar_PMUser__c];
        
        /*
        List<PMTarget__c> pmList = [SELECT PMTar_FXDirectTarget__c, PMTar_FXDirectActual__c,
                                     PMTar_FXIndirectTarget__c, PMTar_FXIndirectActual__c,
                                     PMTar_CRMTarget__c, PMTar_CRMActual__c,
                                     PMTar_CommTarget__c, PMTar_CommActual__c,
                                     PMTar_IRRMTarget__c, PMTar_IRRMActual__c,
                                     PMTar_FXRetail__c, PMTar_FXRetailActual__c,
                                     PMTar_FXDirectTargetTillDate__c, PMTar_FXIndirerctTargetTillDate__c,
                                     PMTar_CRMTargetTillDate__c, PMTar_CommTargetTillDate__c,
                                     PMTar_IRRMTargetTillDate__c, PMTar_FXRetailTillDate__c,
                                     PMTar_PMUser__r.Name, PMTar_PMUser__c
                                     FROM PMTarget__c
                                     WHERE PMTar_PMUser__c IN :pmSet AND CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                     ORDER BY PMTar_PMUser__r.Name, PMTar_PMUser__c];
        for(PMTarget__c eachPM : pmList)
        {
            
        }*/
        PMTarget__c[] eachPM = [SELECT PMTar_FXDirectTarget__c, PMTar_FXDirectActual__c, PMTar_FXIndirectTarget__c, 
                                PMTar_FXIndirectActual__c, PMTar_CRMTarget__c, PMTar_CRMActual__c,
                                PMTar_CommTarget__c, PMTar_CommActual__c, PMTar_IRRMTarget__c, PMTar_IRRMActual__c,
                                PMTar_FXRetail__c, PMTar_FXRetailActual__c,
                                PMTar_FXDirectTargetTillDate__c, PMTar_FXIndirerctTargetTillDate__c, 
                                PMTar_CRMTargetTillDate__c, PMTar_CommTargetTillDate__c,
                                PMTar_IRRMTargetTillDate__c, PMTar_FXRetailTillDate__c, PMTar_PMUser__r.Name,
                                Name, PMTar_PMUser__c, PMTar_PMUser__r.Location__c
                                FROM PMTarget__c WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND PMTar_PMUser__c In :pmSet
                                ORDER BY Name, PMTar_PMUser__c, CreatedDate];   
        
        for(AggregateResult oppList : [SELECT Sum(Amount) amount, OwnerId owner From Opportunity WHERE 
                                       CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName != 'Closed Won' AND StageName != 'Closed Lost'
                                       GROUP BY OwnerId])
        {
            oppMap.put((Id)oppList.get('owner'), (Decimal)oppList.get('amount'));
        }
        
       
        
        for(AggregateResult opptyArr : opptyAR)
        {
            
            
            if((Decimal)opptyArr.get('fxDirectTargetTillDate') != 0 && (Decimal)opptyArr.get('fxDirectTargetTillDate')!=null && (Decimal)opptyArr.get('fxDirectActual') != null)
                fxDirectPercentage = (((Decimal)opptyArr.get('fxDirectActual') * 100) / (Decimal)opptyArr.get('fxDirectTargetTillDate')).setScale(2);
            else
                fxDirectPercentage = 0;
            if((Decimal)opptyArr.get('fxInDirectTargetTillDate') != 0 && (Decimal)opptyArr.get('fxInDirectTargetTillDate')!=null && (Decimal)opptyArr.get('fxInDirectActual') != null)
                fxInDirectPercentage = (((Decimal)opptyArr.get('fxInDirectActual') * 100) / (Decimal)opptyArr.get('fxInDirectTargetTillDate')).setScale(2);
            else
                fxInDirectPercentage = 0;
            if((Decimal)opptyArr.get('crmTargetTillDate') != 0 && (Decimal)opptyArr.get('crmTargetTillDate')!=null && (Decimal)opptyArr.get('crmActual') != null)
                crmPercentage = (((Decimal)opptyArr.get('crmActual') * 100) / (Decimal)opptyArr.get('crmTargetTillDate')).setScale(2);
            else
                crmPercentage=0;
            
            if((Decimal)opptyArr.get('commTargetTillDate') != 0 && (Decimal)opptyArr.get('commTargetTillDate')!=null && (Decimal)opptyArr.get('commActual') != null)
                commPercentage = (((Decimal)opptyArr.get('commActual') * 100) / (Decimal)opptyArr.get('commTargetTillDate')).setScale(2);
            else
                commPercentage=0;
            if((Decimal)opptyArr.get('irrmTargetTillDate') != 0 && (Decimal)opptyArr.get('irrmTargetTillDate')!=null && (Decimal)opptyArr.get('irrmActual') != null)
                irrmPercentage = (((Decimal)opptyArr.get('irrmActual') * 100) / (Decimal)opptyArr.get('irrmTargetTillDate')).setScale(2);
            else
                irrmPercentage=0;
            if((Decimal)opptyArr.get('retailTargetTillDate') != 0 && (Decimal)opptyArr.get('retailTargetTillDate')!=null && (Decimal)opptyArr.get('retailActual') != null)
                retailPercentage = (((Decimal)opptyArr.get('retailActual') * 100) / (Decimal)opptyArr.get('retailTargetTillDate')).setScale(2);
            else
                retailPercentage=0;
            Decimal opptyfxda = 0.00;
            Decimal opptyfxida = 0.00;
            Decimal opptycrma = 0.00;
            Decimal opptycomma = 0.00;
            Decimal opptyirrma = 0.00;
            Decimal opptyreta = 0.00;
            if((Decimal)opptyArr.get('fxDirectActual') != null)
            {
                opptyfxda = (Decimal)opptyArr.get('fxDirectActual');
            }
            if((Decimal)opptyArr.get('fxInDirectActual') != null)
            {
                opptyfxida = (Decimal)opptyArr.get('fxInDirectActual');
            }
            if((Decimal)opptyArr.get('crmActual') != null)
            {
                opptycrma = (Decimal)opptyArr.get('crmActual');
            }
            if((Decimal)opptyArr.get('commActual') != null)
            {
                opptycomma = (Decimal)opptyArr.get('commActual');
            }
            if((Decimal)opptyArr.get('irrmActual') != null)
            {
                opptyirrma = (Decimal)opptyArr.get('irrmActual');
            }
            if((Decimal)opptyArr.get('retailActual') != null)
            {
                opptyreta = (Decimal)opptyArr.get('retailActual');
            }
            
            ytdRevenue = (opptyfxda + opptyfxida +
                          opptycomma + 
                          opptyirrma + opptyreta).setScale(2);
            
            Decimal opptyfxdt = 0.00;
            Decimal opptyfxidt = 0.00;
            Decimal opptycrmt = 0.00;
            Decimal opptycommt = 0.00;
            Decimal opptyirrmt = 0.00;
            Decimal opptyrett = 0.00;
            if((Decimal)opptyArr.get('fxDirectTargetTillDate') != null)
            {
                opptyfxdt = ((Decimal)opptyArr.get('fxDirectTargetTillDate')).setScale(2);
            }
            if((Decimal)opptyArr.get('fxInDirectTargetTillDate') != null)
            {
                opptyfxidt = ((Decimal)opptyArr.get('fxInDirectTargetTillDate')).setScale(2);
            }
            if((Decimal)opptyArr.get('crmTargetTillDate') != null)
            {
                opptycrmt = ((Decimal)opptyArr.get('crmTargetTillDate')).setScale(2);
            }
            if((Decimal)opptyArr.get('commTargetTillDate') != null)
            {
                opptycommt = ((Decimal)opptyArr.get('commTargetTillDate')).setScale(2);
            }
            if((Decimal)opptyArr.get('irrmTargetTillDate') != null)
            {
                opptyirrmt = ((Decimal)opptyArr.get('irrmTargetTillDate')).setScale(2);
            }
            if((Decimal)opptyArr.get('retailTargetTillDate') != null)
            {
                opptyrett = ((Decimal)opptyArr.get('retailTargetTillDate')).setScale(2);
            }
            ytdPlan = (opptyfxdt + opptyfxidt + opptycommt + opptyirrmt + opptyrett).setScale(2);
            
            variance =((Decimal)ytdRevenue- (Decimal)ytdPlan ).setScale(2);
            if((Decimal)ytdPlan != 0)
                planPercentage =((((Decimal)ytdRevenue) * 100) / (Decimal)ytdPlan).setScale(2);
            else
                planPercentage =0;
            
            if((Decimal)oppMap.get((Id)opptyArr.get('pmId')) != null)
                ytdPipeLine = (Decimal)oppMap.get((Id)opptyArr.get('pmId'));
            else
                ytdPipeLine = 0;
            
            
            wrappedDataList.add(new WrapperClass((String)opptyArr.get('pm'), ((Decimal)opptyArr.get('fxDirectActual')).setScale(2), opptyfxdt, 
                                                 ((Decimal)fxDirectPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('fxInDirectActual')).setScale(2), opptyfxidt, 
                                                 ((Decimal)fxInDirectPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('crmActual')).setScale(2), opptycrmt, 
                                                 ((Decimal)crmPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('commActual')).setScale(2), opptycommt, 
                                                 ((Decimal)commPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('irrmActual')).setScale(2), opptyirrmt, 
                                                 ((Decimal)irrmPercentage).setScale(2),
                                                 ((Decimal)opptyArr.get('retailActual')).setScale(2), opptyrett, 
                                                 ((Decimal)retailPercentage).setScale(2),
                                                 ((Decimal)ytdRevenue).setScale(2), ((Decimal)ytdPlan).setScale(2), ((Decimal)variance).setScale(2), ((Decimal)planPercentage).setScale(2), ((Decimal)ytdPipeLine).setScale(2), true));
            
            for(PMTarget__c pmArr : eachPM)
            {
                
                if((String)opptyArr.get('pmId') != null && (String)opptyArr.get('pmId') == (String)pmArr.PMTar_PMUser__c)
                {
                    
                    if((Decimal)pmArr.PMTar_FXDirectTargetTillDate__c != 0)
                        fxDirectPercentage = (((Decimal)pmArr.PMTar_FXDirectActual__c * 100) / (Decimal)pmArr.PMTar_FXDirectTargetTillDate__c).setScale(2);
                    else
                        fxDirectPercentage = 0;
                    if((Decimal)pmArr.PMTar_FXIndirerctTargetTillDate__c != 0)
                        fxInDirectPercentage = (((Decimal)pmArr.PMTar_FXIndirectActual__c * 100) / (Decimal)pmArr.PMTar_FXIndirerctTargetTillDate__c).setScale(2);
                    else
                        fxInDirectPercentage = 0;
                    if((Decimal)pmArr.PMTar_CRMTargetTillDate__c != 0)
                        crmPercentage = (((Decimal)pmArr.PMTar_CRMActual__c * 100) / (Decimal)pmArr.PMTar_CRMTargetTillDate__c).setScale(2);
                    else
                        crmPercentage=0;
                    
                    if((Decimal)pmArr.PMTar_CommTargetTillDate__c != 0)
                        commPercentage = (((Decimal)pmArr.PMTar_CommActual__c * 100) / (Decimal)pmArr.PMTar_CommTargetTillDate__c).setScale(2);
                    else
                        commPercentage=0;
                    if((Decimal)pmArr.PMTar_IRRMTargetTillDate__c != 0)
                        irrmPercentage = (((Decimal)pmArr.PMTar_IRRMActual__c * 100) / (Decimal)pmArr.PMTar_IRRMTargetTillDate__c).setScale(2);
                    else
                        irrmPercentage=0;
                    if((Decimal)pmArr.PMTar_FXRetailTillDate__c != 0)
                        retailPercentage = (((Decimal)pmArr.PMTar_FXRetailActual__c * 100) / (Decimal)pmArr.PMTar_FXRetailTillDate__c).setScale(2);
                    else
                        retailPercentage=0;
                    Decimal iopptyfxda = 0.00;
                    Decimal iopptyfxida = 0.00;
                    Decimal iopptycrma = 0.00;
                    Decimal iopptycomma = 0.00;
                    Decimal iopptyirrma = 0.00;
                    Decimal iopptyreta = 0.00;
                    
                    if((Decimal)pmArr.PMTar_FXDirectActual__c != null)
                    {
                        iopptyfxda = (Decimal)pmArr.PMTar_FXDirectActual__c;
                    }
                    if((Decimal)pmArr.PMTar_FXIndirectActual__c != null)
                    {
                        iopptyfxida = (Decimal)pmArr.PMTar_FXIndirectActual__c;
                    }
                    if((Decimal)pmArr.PMTar_CRMActual__c != null)
                    {
                        iopptycrma = (Decimal)pmArr.PMTar_CRMActual__c;
                    }
                    if((Decimal)pmArr.PMTar_CommActual__c != null)
                    {
                        iopptycomma = (Decimal)pmArr.PMTar_CommActual__c;
                    }
                    if((Decimal)pmArr.PMTar_IRRMActual__c != null)
                    {
                        iopptyirrma = (Decimal)pmArr.PMTar_IRRMActual__c;
                    }
                    if((Decimal)pmArr.PMTar_FXRetailActual__c != null)
                    {
                        iopptyreta = (Decimal)pmArr.PMTar_FXRetailActual__c;
                    }

                    ytdRevenue = (iopptyfxda + iopptyfxida +
                                   iopptycomma + 
                                  iopptyirrma + iopptyreta).setScale(2);
                    
                    Decimal iopptyfxdt = 0.00;
                    Decimal iopptyfxidt = 0.00;
                    Decimal iopptycrmt = 0.00;
                    Decimal iopptycommt = 0.00;
                    Decimal iopptyirrmt = 0.00;
                    Decimal iopptyrett = 0.00;
                    
                    if((Decimal)pmArr.PMTar_FXDirectTargetTillDate__c != null)
                    {
                        iopptyfxdt = ((Decimal)pmArr.PMTar_FXDirectTargetTillDate__c).setScale(2);
                    }
                    if((Decimal)pmArr.PMTar_FXIndirerctTargetTillDate__c != null)
                    {
                        iopptyfxidt = ((Decimal)pmArr.PMTar_FXIndirerctTargetTillDate__c).setScale(2);
                    }
                    if((Decimal)pmArr.PMTar_CRMTargetTillDate__c != null)
                    {
                        opptycrmt = ((Decimal)pmArr.PMTar_CRMTargetTillDate__c).setScale(2);
                    }
                    if((Decimal)pmArr.PMTar_CommTargetTillDate__c != null)
                    {
                        iopptycommt = ((Decimal)pmArr.PMTar_CommTargetTillDate__c).setScale(2);
                    }
                    if((Decimal)pmArr.PMTar_IRRMTargetTillDate__c != null)
                    {
                        iopptyirrmt = ((Decimal)pmArr.PMTar_IRRMTargetTillDate__c).setScale(2);
                    }
                    if((Decimal)pmArr.PMTar_FXRetailTillDate__c != null)
                    {
                        iopptyrett = ((Decimal)pmArr.PMTar_FXRetailTillDate__c).setScale(2);
                    }
                    
                    ytdPlan = (iopptyfxdt + iopptyfxidt + iopptycommt + iopptyirrmt + iopptyrett).setScale(2);
                    
                    variance =((Decimal)ytdRevenue- (Decimal)ytdPlan ).setScale(2);
                    
                    if((Decimal)ytdPlan != 0)
                        planPercentage =((((Decimal)ytdRevenue) * 100) / (Decimal)ytdPlan).setScale(2);
                    else
                        planPercentage =0;
                    
                    wrappedDataList.add(new WrapperClass((String)pmArr.PMTar_PMUser__r.Name+': \n'+pmArr.Name+'\n' ,
                                                         ((Decimal)pmArr.PMTar_FXDirectActual__c).setScale(2), iopptyfxdt, 
                                                         ((Decimal)fxDirectPercentage).setScale(2), 
                                                         ((Decimal)pmArr.PMTar_FXIndirectActual__c).setScale(2), iopptyfxidt, 
                                                         ((Decimal)fxInDirectPercentage).setScale(2), 
                                                         ((Decimal)pmArr.PMTar_CRMActual__c).setScale(2), iopptycrmt, 
                                                         ((Decimal)crmPercentage).setScale(2), 
                                                         ((Decimal)pmArr.PMTar_CommActual__c).setScale(2), iopptycommt, 
                                                         ((Decimal)commPercentage).setScale(2), 
                                                         ((Decimal)pmArr.PMTar_IRRMActual__c).setScale(2), iopptyirrmt, 
                                                         ((Decimal)irrmPercentage).setScale(2),
                                                         ((Decimal)pmArr.PMTar_FXRetailActual__c).setScale(2), iopptyrett, 
                                                         ((Decimal)retailPercentage).setScale(2),
                                                         ((Decimal)ytdRevenue).setScale(2), ((Decimal)ytdPlan).setScale(2), ((Decimal)variance).setScale(2), ((Decimal)planPercentage).setScale(2),((Decimal)0).setScale(2), false));
                }
            }
        }
        
    }
    
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/PerformanceTrackerForProductManagerDld');
        return nextpage;
    }
    
    Public class WrapperClass{
        Public String PM{get; set;}
        Public Decimal fxDirectActual{get; set;}
        Public Decimal fxDirectTarget{get; set;}
        Public Decimal fxDirectPercentage{get; set;}
        Public Decimal fxInDirectActual{get; set;}
        Public Decimal fxInDirectTarget{get; set;}
        Public Decimal fxInDirectPercentage{get; set;}
        Public Decimal crmActual{get; set;}
        Public Decimal crmTarget{get; set;}
        Public Decimal crmPercentage{get; set;}
        Public Decimal commActual{get; set;}
        Public Decimal commTarget{get; set;}
        Public Decimal commPercentage{get; set;}
        Public Decimal irrmActual{get; set;}
        Public Decimal irrmTarget{get; set;}
        Public Decimal irrmPercentage{get; set;}
        Public Decimal retailActual{get; set;}
        Public Decimal retailTarget{get; set;}
        Public Decimal retailPercentage{get; set;}
        Public Decimal ytdRevenue {get; set;}
        Public Decimal ytdPlan {get; set;}
        Public Decimal variance {get; set;}
        Public Decimal planPercentage {get; set;}
        Public Boolean Grouper {get; set;}
        Public Decimal pipeLine {get; set;}
        
        Public WrapperClass(String PM, Decimal fxDirectActual, Decimal fxDirectTarget, Decimal fxDirectPercentage, 
                            Decimal fxInDirectActual, Decimal fxInDirectTarget, Decimal fxInDirectPercentage, 
                            Decimal crmActual, Decimal crmTarget, Decimal crmPercentage, 
                            Decimal commActual, Decimal commTarget, Decimal commPercentage, 
                            Decimal irrmActual, Decimal irrmTarget, Decimal irrmPercentage,
                            Decimal retailActual, Decimal retailTarget, Decimal retailPercentage,
                            Decimal ytdRevenue, Decimal ytdPlan, Decimal variance, Decimal planPercentage, Decimal pipeLine, Boolean Grouper)
        {
            this.PM =PM;
            this.fxDirectActual=fxDirectActual;
            this.fxDirectTarget=fxDirectTarget;
            this.fxDirectPercentage=fxDirectPercentage;
            this.fxInDirectActual=fxInDirectActual;
            this.fxInDirectTarget=fxInDirectTarget;
            this.fxInDirectPercentage=fxInDirectPercentage;
            this.crmActual=crmActual;
            this.crmTarget=crmTarget;
            this.crmPercentage=crmPercentage;
            this.commActual=commActual;
            this.commTarget=commTarget;
            this.commPercentage=commPercentage;
            this.irrmActual=irrmActual;
            this.irrmTarget=irrmTarget;
            this.irrmPercentage=irrmPercentage;
            this.retailActual=retailActual;
            this.retailTarget=retailTarget;
            this.retailPercentage=retailPercentage;
            this.ytdRevenue = ytdRevenue;
            this.ytdPlan = ytdPlan;
            this.variance = variance;
            this.planPercentage = planPercentage;
            this.pipeLine = pipeLine;
            this.Grouper = Grouper;
        }
    }
}