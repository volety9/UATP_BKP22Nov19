public class PerformanceTrackersFRSM {
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
    Decimal ytdPipeLine;
    Decimal variance;
    Decimal planPercentage;
    Boolean Grouper;
    
    Public Set<String> tsmSet = new Set<String>();
    
    Public Set<String> bcSet = new Set<String>();
    Public Map<String, String> combineId = new Map<String, String>();
    
    Public Map<String, Decimal> oppMap= new Map<String, Decimal>();
    Public Map<String, Decimal> totalPipeLineMap= new Map<String, Decimal>();
    Public Set<String> jliListSet = new Set<String>();
    String oldValue = '';
    String oldValue2 = '';
    Decimal totalPipeLine = 0.00;
    Decimal amountIn = 0.00;
    //Decimal variance = 0.00;
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    public PerformanceTrackersFRSM(){
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today()-2, fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today()-2, fyStartMonth);
        //fyStartDate = date.newInstance(2018,10,01);
        //fyEndDate = date.newInstance(2019,09,30);
        wrappedDataList = new List<WrapperClass>();
        
        fetchData();
    }
    
    Public void fetchData(){
        
        
        for(TSMTarget__c eachTSMRec : [SELECT TSMTar_TSM__c, TSMTar_Team__c FROM TSMTarget__c WHERE TSMTar_Status__c = 'Active'
                                        AND TSMTar_FYStartDate__c >= :fyStartDate AND TSMTar_FYEndDate__c <= :fyEndDate])
        {
            tsmSet.add(eachTSMRec.TSMTar_TSM__c);
            
            bcSet.add(eachTSMRec.TSMTar_Team__c);
        }
        System.debug('tsmSet =====>'+tsmSet.size());
        System.debug('bcSet =====>'+bcSet.size());
        AggregateResult[] opptyAR = [SELECT SUM(TSMTar_FXDirectTarget__c) fxDirectTarget, SUM(TSMTar_FXDirectActual__c) fxDirectActual,
                                     SUM(TSMTar_FXIndirectTarget__c) fxInDirectTarget, SUM(TSMTar_FXIndirectActual__c) fxInDirectActual,
                                     SUM(TSMTar_CRMTarget__c)crmTarget, SUM(TSMTar_CRMActual__c)crmActual,
                                     SUM(TSMTar_CommTarget__c)commTarget, SUM(TSMTar_CommActual__c)commActual,
                                     SUM(TSMTar_IRRMTarget__c)irrmTarget, SUM(TSMTar_IRRMActual__c)irrmActual,
                                     SUM(TSMTar_FXRetail__c)retailTarget, SUM(TSMTar_FXRetailActual__c)retailActual,
                                     SUM(TSMTar_FXDirectTargetTillDate__c)fxDirectTargetTillDate, SUM(TSMTar_FXIndirectTargetTillDate__c)fxInDirectTargetTillDate,
                                     SUM(TSMTar_CRMTargetTillDate__c)crmTargetTillDate, SUM(TSMTar_CommTargetTillDate__c)commTargetTillDate,
                                     SUM(TSMTar_IRRMTargetTillDate__c)irrmTargetTillDate, SUM(TSMTar_FXRetailTillDate__c)retailTargetTillDate,
                                     TSMTar_TSM__r.Name tsm, TSMTar_TSM__c tsmId
                                     FROM TSMTarget__c
                                     WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND TSMTar_TSM__c  IN :tsmSet AND  TSMTar_Team__c IN :bcSet
                                     GROUP BY TSMTar_TSM__c, TSMTar_TSM__r.name];
        System.debug('opptyAR =====>'+opptyAR.size());   
        
        TSMTarget__c[] eachTSM = [SELECT TSMTar_FXDirectTarget__c, TSMTar_FXDirectActual__c, TSMTar_FXIndirectTarget__c, 
                                  TSMTar_FXIndirectActual__c, TSMTar_CRMTarget__c, TSMTar_CRMActual__c,
                                  TSMTar_CommTarget__c, TSMTar_CommActual__c, TSMTar_IRRMTarget__c, TSMTar_IRRMActual__c,
                                  TSMTar_FXRetail__c, TSMTar_FXRetailActual__c, 
                                  TSMTar_FXDirectTargetTillDate__c, TSMTar_FXIndirectTargetTillDate__c, 
                                  TSMTar_CRMTargetTillDate__c, TSMTar_CommTargetTillDate__c,
                                  TSMTar_IRRMTargetTillDate__c, TSMTar_FXRetailTillDate__c,
                                  TSMTar_TSM__r.Name, TSMTar_Team__c, TSMTar_Team__r.Name, Name, TSMTar_TSM__c, TSMTar_TSM__r.Location__c
                                  FROM TSMTarget__c WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND TSMTar_TSM__c  IN :tsmSet AND  TSMTar_Team__c IN :bcSet
                                  ORDER BY TSMTar_TSM__r.Name, TSMTar_Team__c, CreatedDate];
        
        System.debug('eachTSM =====>'+eachTSM.size());
        System.debug('fxDirectTarget =====>'+eachTSM[0].TSMTar_FXDirectTarget__c);
        
        
        for(AggregateResult jliList : [SELECT Journal_Team__c teamId, Journal_TeamName__c teamName, Journal_TSM__c tsm 
                                       FROM JournalLineItem__c
                                      WHERE Journal_Team__c IN :bcSet AND Journal_TSM__c IN :tsmSet
                                       AND Journal_TSMTarget__c != null
                                      GROUP BY Journal_Team__c, Journal_TeamName__c, Journal_TSM__c])
        {
            jliListSet.add((String)jliList.get('tsm'));
            
        }
        
        for(Opportunity oppList : [SELECT amount, OwnerId, Account.RM_Name__r.Con_Team__c From Opportunity WHERE 
                                CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName NOT IN ('Closed Lost','Closed Won') AND
                                   OwnerId IN :tsmSet AND Account.RM_Name__r.Con_Team__c IN :bcSet AND
                                       OwnerId IN :jliListSet AND RecordType.Name NOT IN ('Vanilla FX', 'Business Loan', 'FX Cash')
                                  ORDER BY OwnerId, Account.RM_Name__r.Con_Team__c ])
        {
            if(oldValue != (String)oppList.Account.RM_Name__r.Con_Team__c)
            {
               oldValue = (String)oppList.Account.RM_Name__r.Con_Team__c;
                amountIn = 0.00;
            }
            if(oldValue2 != (String)oppList.OwnerId)
            {
                oldValue2 = (String)oppList.OwnerId;
                totalPipeLine = 0.00;
            }
               
            //if(totalPipeLineMap.containsKey(key))
            if(oppList.amount!=null)
            amountIn = amountIn + oppList.amount;
            
                oppMap.put((String)oppList.Account.RM_Name__r.Con_Team__c + (String)oppList.OwnerId , amountIn);
            if(oppList.amount!=null)
            totalPipeLine = totalPipeLine + (Decimal)oppList.amount;
            totalPipeLineMap.put((String)oppList.OwnerId, totalPipeLine);
        }
        /*for(AggregateResult oppList : [SELECT Sum(Amount) amount, OwnerId owner From Opportunity WHERE 
                                       CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName != 'Closed Won' AND StageName != 'Closed Lost'
                                       GROUP BY OwnerId])
        {
            oppMap.put((Id)oppList.get('owner'), (Decimal)oppList.get('amount'));
        }*/
        
        for(AggregateResult opptyArr : opptyAR)
        {
            
            if((Decimal)opptyArr.get('fxDirectTargetTillDate') != 0)
                fxDirectPercentage = (((Decimal)opptyArr.get('fxDirectActual') * 100) / (Decimal)opptyArr.get('fxDirectTargetTillDate')).setScale(2);
            else
                fxDirectPercentage = 0;
            if((Decimal)opptyArr.get('fxInDirectTargetTillDate') != 0)
                fxInDirectPercentage = (((Decimal)opptyArr.get('fxInDirectActual') * 100) / (Decimal)opptyArr.get('fxInDirectTargetTillDate')).setScale(2);
            else
                fxInDirectPercentage = 0;
            if((Decimal)opptyArr.get('crmTargetTillDate') != 0)
                crmPercentage = (((Decimal)opptyArr.get('crmActual') * 100) / (Decimal)opptyArr.get('crmTargetTillDate')).setScale(2);
            else
                crmPercentage=0;
            
            if((Decimal)opptyArr.get('commTargetTillDate') != 0)
                commPercentage = (((Decimal)opptyArr.get('commActual') * 100) / (Decimal)opptyArr.get('commTargetTillDate')).setScale(2);
            else
                commPercentage=0;
            if((Decimal)opptyArr.get('irrmTargetTillDate') != 0)
                irrmPercentage = (((Decimal)opptyArr.get('irrmActual') * 100) / (Decimal)opptyArr.get('irrmTargetTillDate')).setScale(2);
            else
                irrmPercentage=0;
            if((Decimal)opptyArr.get('retailTargetTillDate') != 0)
                retailPercentage = (((Decimal)opptyArr.get('retailActual') * 100) / (Decimal)opptyArr.get('retailTargetTillDate')).setScale(2);
            else
                retailPercentage=0;
            
            ytdRevenue = ((Decimal)opptyArr.get('fxDirectActual') + (Decimal)opptyArr.get('fxInDirectActual') +
                          /* (Decimal)opptyArr.get('crmActual') + */ (Decimal)opptyArr.get('commActual') + 
                          (Decimal)opptyArr.get('irrmActual') /* + (Decimal)opptyArr.get('retailActual')*/).setScale(2);
            ytdPlan = ((Decimal)opptyArr.get('fxDirectTargetTillDate') + (Decimal)opptyArr.get('fxInDirectTargetTillDate') +
                      /* (Decimal)opptyArr.get('crmTargetTillDate')  + */ (Decimal)opptyArr.get('commTargetTillDate') + 
                       (Decimal)opptyArr.get('irrmTargetTillDate') /* + (Decimal)opptyArr.get('retailTargetTillDate') */ ).setScale(2);
            System.debug('ytdPlan ======>'+ytdPlan);
            variance =((Decimal)ytdRevenue- (Decimal)ytdPlan).setScale(2);
            if((Decimal)ytdPlan != 0)
                planPercentage =((((Decimal)ytdRevenue) * 100) / (Decimal)ytdPlan).setScale(2);
            else
                planPercentage =0;
            
            if((Decimal)totalPipeLineMap.get((String)opptyArr.get('tsmId')) != null)
                ytdPipeLine = (Decimal)totalPipeLineMap.get((String)opptyArr.get('tsmId'));
            else
                ytdPipeLine = 0.00;
            
            //Changes made to make all the Targets to YTD - Santhoshan
            wrappedDataList.add(new WrapperClass((String)opptyArr.get('tsm'), ((Decimal)opptyArr.get('fxDirectActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('fxDirectTargetTillDate')).setScale(2), 
                                                 ((Decimal)fxDirectPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('fxInDirectActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('fxInDirectTargetTillDate')).setScale(2), 
                                                 ((Decimal)fxInDirectPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('crmActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('crmTargetTillDate')).setScale(2), 
                                                 ((Decimal)crmPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('commActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('commTargetTillDate')).setScale(2), 
                                                 ((Decimal)commPercentage).setScale(2), 
                                                 ((Decimal)opptyArr.get('irrmActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('irrmTargetTillDate')).setScale(2), 
                                                 ((Decimal)irrmPercentage).setScale(2),
                                                 ((Decimal)opptyArr.get('retailActual')).setScale(2), 
                                                 ((Decimal)opptyArr.get('retailTargetTillDate')).setScale(2), 
                                                 ((Decimal)irrmPercentage).setScale(2),
                                                 ((Decimal)ytdRevenue).setScale(2), ((Decimal)ytdPlan).setScale(2), ((Decimal)variance).setScale(2), ((Decimal)planPercentage).setScale(2), ((Decimal)ytdPipeLine).setScale(2), true));
            for(TSMTarget__c tsmArr : eachTSM)
            {
                if((String)opptyArr.get('tsm') == tsmArr.TSMTar_TSM__r.Name)
                {
                    
                    if((Decimal)tsmArr.TSMTar_FXDirectTargetTillDate__c != 0)
                        fxDirectPercentage = (((Decimal)tsmArr.TSMTar_FXDirectActual__c * 100) / (Decimal)tsmArr.TSMTar_FXDirectTargetTillDate__c).setScale(2);
                    else
                        fxDirectPercentage = 0;
                    if((Decimal)tsmArr.TSMTar_FXIndirectTargetTillDate__c != 0)
                        fxInDirectPercentage = (((Decimal)tsmArr.TSMTar_FXIndirectActual__c * 100) / (Decimal)tsmArr.TSMTar_FXIndirectTargetTillDate__c).setScale(2);
                    else
                        fxInDirectPercentage = 0;
                    if((Decimal)tsmArr.TSMTar_CRMTargetTillDate__c != 0)
                        crmPercentage = (((Decimal)tsmArr.TSMTar_CRMActual__c * 100) / (Decimal)tsmArr.TSMTar_CRMTargetTillDate__c).setScale(2);
                    else
                        crmPercentage=0;
                    
                    if((Decimal)tsmArr.TSMTar_CommTargetTillDate__c != 0)
                        commPercentage = (((Decimal)tsmArr.TSMTar_CommActual__c * 100) / (Decimal)tsmArr.TSMTar_CommTargetTillDate__c).setScale(2);
                    else
                        commPercentage=0;
                    if((Decimal)tsmArr.TSMTar_IRRMTargetTillDate__c != 0)
                        irrmPercentage = (((Decimal)tsmArr.TSMTar_IRRMActual__c * 100) / (Decimal)tsmArr.TSMTar_IRRMTargetTillDate__c).setScale(2);
                    else
                        irrmPercentage=0;
                    if((Decimal)tsmArr.TSMTar_FXRetailTillDate__c != 0)
                        retailPercentage = (((Decimal)tsmArr.TSMTar_FXRetailActual__c * 100) / (Decimal)tsmArr.TSMTar_FXRetailTillDate__c).setScale(2);
                    else
                        retailPercentage=0;
                    
                    ytdRevenue = ((Decimal)tsmArr.TSMTar_FXDirectActual__c + (Decimal)tsmArr.TSMTar_FXIndirectActual__c +
                                  /* (Decimal)tsmArr.TSMTar_CRMActual__c  + */ (Decimal)tsmArr.TSMTar_CommActual__c + 
                                  (Decimal)tsmArr.TSMTar_IRRMActual__c /* +  (Decimal)tsmArr.TSMTar_FXRetailActual__c */ ).setScale(2);
                    ytdPlan =((Decimal)tsmArr.TSMTar_FXDirectTargetTillDate__c + (Decimal)tsmArr.TSMTar_FXInDirectTargetTillDate__c +
                              /* (Decimal)tsmArr.TSMTar_crmTargetTillDate__c  + */ (Decimal)tsmArr.TSMTar_commTargetTillDate__c + 
                              (Decimal)tsmArr.TSMTar_irrmTargetTillDate__c /* +  (Decimal)tsmArr.TSMTar_FXRetailTillDate__c */ ).setScale(2);
                    variance =((Decimal)ytdRevenue - (Decimal)ytdPlan).setScale(2);
                    
                    if((Decimal)ytdPlan != 0)
                        planPercentage =((((Decimal)ytdRevenue) * 100) / (Decimal)ytdPlan).setScale(2);
                    else
                        planPercentage =0;
                              
  
                    
                    if((Decimal) oppMap.get((String)tsmArr.get('TSMTar_Team__c') + (String)tsmArr.get('TSMTar_TSM__c')) != null)
                        ytdPipeLine = (Decimal)oppMap.get((String)tsmArr.get('TSMTar_Team__c') + (String)tsmArr.get('TSMTar_TSM__c'));
                    else
                        ytdPipeLine = 0.00;
                    wrappedDataList.add(new WrapperClass((String)tsmArr.TSMTar_TSM__r.Name+': \n'+tsmArr.Name+': \n'+tsmArr.TSMTar_Team__r.Name, 
                                                         ((Decimal)tsmArr.TSMTar_FXDirectActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_FXDirectTargetTillDate__c).setScale(2), 
                                                         ((Decimal)fxDirectPercentage).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_FXIndirectActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_FXIndirectTargetTillDate__c).setScale(2), 
                                                         ((Decimal)fxInDirectPercentage).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_CRMActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_CRMTargetTillDate__c).setScale(2), 
                                                         ((Decimal)crmPercentage).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_CommActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_CommTargetTillDate__c).setScale(2), 
                                                         ((Decimal)commPercentage).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_IRRMActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_IRRMTargetTillDate__c).setScale(2), 
                                                         ((Decimal)irrmPercentage).setScale(2),
                                                         ((Decimal)tsmArr.TSMTar_FXRetailActual__c).setScale(2), 
                                                         ((Decimal)tsmArr.TSMTar_FXRetailTillDate__c).setScale(2), 
                                                         ((Decimal)retailPercentage).setScale(2),
                                                         ((Decimal)ytdRevenue).setScale(2), ((Decimal)ytdPlan).setScale(2), ((Decimal)variance).setScale(2), ((Decimal)planPercentage).setScale(2), ((Decimal)ytdPipeLine).setScale(2), false));
                }
            }
        }
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/PerformanceTrackerForFRSMDownload');
        return nextpage;
    }
    Public class WrapperClass{
        Public String TSM {get; set;}
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
        
        Public WrapperClass(String TSM, Decimal fxDirectActual, Decimal fxDirectTarget, Decimal fxDirectPercentage, 
                            Decimal fxInDirectActual, Decimal fxInDirectTarget, Decimal fxInDirectPercentage, 
                            Decimal crmActual, Decimal crmTarget, Decimal crmPercentage, 
                            Decimal commActual, Decimal commTarget, Decimal commPercentage, 
                            Decimal irrmActual, Decimal irrmTarget, Decimal irrmPercentage,
                            Decimal retailActual, Decimal retailTarget, Decimal retailPercentage,
                            Decimal ytdRevenue, Decimal ytdPlan, Decimal variance, Decimal planPercentage, Decimal pipeLine, Boolean Grouper)
        {
            this.TSM =TSM;
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