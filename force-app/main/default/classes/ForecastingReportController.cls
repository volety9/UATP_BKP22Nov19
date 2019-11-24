/*
@Author        : Ramkumar M B
@Name          : ForecastingReportController
@Created Date  : 16th May 2018
@Description   : This is a Controller class for the QuarterlyForecastingReport VF page 
@version       : 1.0
*/
public class ForecastingReportController {
    public List<Account> accountList {get; set;}
    Public map<String,Division__c>divisionDetails = new Map<String,Division__c>();
    Public map<String,Decimal>divisionWithClosedWonOpportunity = new Map<String,Decimal>();
    Public map<String,Decimal>divisionWithOpenOpportunity = new Map<String,Decimal>();
    Public map<String,Decimal>divisionWithFXTargetAmount = new Map<String,Decimal>();
    Public map<String,Decimal>divisionWithNonFXTargetAmount = new Map<String,Decimal>();
    Public map<String,Decimal>divisionWithJournals = new Map<String,Decimal>();
    Public List<WrapperClass>wrappedDataList {get; set;}
    Public Decimal grandTotalClosed ;
    Public Decimal grandTotalOpen ;
    Public Decimal grandTotalFX ;
    Public Decimal grandTotalRevenue ;
    Public Decimal grandTotalPlan;
    Public Decimal grandTotalPercentage;
    Public Decimal grandTotalLYEndIncome;
    Decimal percantage;
    
    public ForecastingReportController()
    {
        grandTotalClosed = 0.00;
        grandTotalOpen   = 0.00;
        grandTotalFX     = 0.00;
        grandTotalRevenue = 0.00;
        grandTotalPlan   = 0.00;
        grandTotalPercentage = 0.00;
        grandTotalLYEndIncome = 0.00;
        wrappedDataList = new List<WrapperClass>();
        Integer currentMonthVal = Date.Today().Month();
        Integer yearvalueVal   =  Date.Today().Year();
        
        fetchReportData(currentMonthVal,yearvalueVal);
    }
    /**
* @description       Method to process the fetch data for the report
* @name              fetchReportData
* @param             void 
* @return            void
* @throws            NA
*/     
    
    Public void fetchReportData(Integer monthval,Integer yearVal)
    {
        Integer currentMonth = monthval;
        Integer yearvalue   =  yearVal;
        Date createdDateFrom;
        Date createdDateTo;
        If(currentMonth>=1 && currentMonth <=3)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 1, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 3, 31);
        }else If(currentMonth>=4 && currentMonth <=6)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 4, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 6, 30);
        }else If(currentMonth>=7 && currentMonth <=9)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 7, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 9, 30);
        }else 
        {
            createdDateFrom = date.newInstance(yearvalue-1, 10, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 12, 31);
        }
                
        
        
        For(JournalLineItem__c eachJournal :[Select Id,Journal_Amount__c,Journal_Division__c from JournalLineItem__c
                                             where Journal_Trade_date__c >=:createdDateFrom and Journal_Trade_date__c <=:createdDateTo
                                             And Journal_Division__c!=Null])
        {
            if(!divisionWithJournals.containsKey(eachJournal.Journal_Division__c))
            {
                divisionWithJournals.put(eachJournal.Journal_Division__c, eachJournal.Journal_Amount__c);
            }else
            {
                Decimal journalAmount = divisionWithJournals.get(eachJournal.Journal_Division__c);
                journalAmount = journalAmount + eachJournal.Journal_Amount__c;
                divisionWithJournals.put(eachJournal.Journal_Division__c,journalAmount);
            }
            
        }
        

        
        For(Opportunity eachOpportunity :[Select Id,Name,Division__c,Amount from Opportunity 
                                          where createdDate =THIS_FISCAL_QUARTER And Stagename =:Label.Opp_Stage_Closed_Won and Division__c!=Null]){
                                              
                                              
                                              if(!divisionWithClosedWonOpportunity.containsKey(eachOpportunity.Division__c)){
                                                  
                                                  divisionWithClosedWonOpportunity.put(eachOpportunity.Division__c, eachOpportunity.Amount);
                                              }else
                                              {
                                                  Decimal opportunityAmount = divisionWithClosedWonOpportunity.get(eachOpportunity.Division__c);
                                                  
                                                  if(opportunityAmount!=null && eachOpportunity.Amount!=null){
                                                      opportunityAmount = opportunityAmount+eachOpportunity.Amount;
                                                  }else{
                                                      opportunityAmount =0;
                                                  }
                                                  divisionWithClosedWonOpportunity.put(eachOpportunity.Division__c, opportunityAmount);
                                              }
                                              
                                          }
        
        For(Opportunity eachOpportunity :[Select Id,Name,Division__c,Amount from Opportunity 
                                          where createdDate =THIS_FISCAL_QUARTER And Stagename NOT IN ('Closed Won','Closed Lost') and Division__c!=Null]){
                                              
                                              if(!divisionWithOpenOpportunity.containsKey(eachOpportunity.Division__c)){
                                                  
                                                  divisionWithOpenOpportunity.put(eachOpportunity.Division__c, eachOpportunity.Amount);
                                              }else
                                              {
                                                  Decimal opportunityAmount = divisionWithOpenOpportunity.get(eachOpportunity.Division__c);
                                                  if(opportunityAmount!=null){
                                                      opportunityAmount = opportunityAmount+eachOpportunity.Amount;
                                                  }else{
                                                      opportunityAmount =0;
                                                  }
                                                  
                                                  divisionWithOpenOpportunity.put(eachOpportunity.Division__c, opportunityAmount);
                                              }
                                              
                                          }
        
        For(Division__c eachDivision :[Select Id,Name,Div_FXDirectTarget__c,Div_FXIndirectTarget__c,Div_CommTarget__c,
                                       Div_CRMTarget__c,Div_IRRMTarget__c from Division__c where Div_Status__c ='Active'])
        {
            if(!divisionWithFXTargetAmount.containsKey(eachDivision.Name)){
                
                Decimal fxTargetAmount = eachDivision.Div_FXDirectTarget__c + eachDivision.Div_FXIndirectTarget__c;
                Decimal nonFxTargetAmount = eachDivision.Div_CRMTarget__c + eachDivision.Div_CommTarget__c + 
                    eachDivision.Div_IRRMTarget__c;
                divisionDetails.put(eachDivision.Name, eachDivision);   
                divisionWithFXTargetAmount.put(eachDivision.Name, fxTargetAmount);
                divisionWithNonFXTargetAmount.put(eachDivision.Name, nonFxTargetAmount);   
                
            }
            
        }
        
        For(String eachDivision : divisionDetails.keySet())
        {
            if(eachDivision !=null )
            {
                
                Decimal revenueAmount = ((divisionWithClosedWonOpportunity.containsKey(eachDivision) && 
                                          divisionWithClosedWonOpportunity.get(eachDivision)!=Null)?
                                         divisionWithClosedWonOpportunity.get(eachDivision):0)
                    +((divisionWithOpenOpportunity.containsKey(eachDivision) && 
                       divisionWithOpenOpportunity.get(eachDivision)!=Null)?
                      divisionWithOpenOpportunity.get(eachDivision):0) 
                    + ((divisionWithFXTargetAmount.containsKey(eachDivision) && 
                        divisionWithFXTargetAmount.get(eachDivision)!=Null)?
                       divisionWithFXTargetAmount.get(eachDivision):0);
                
                if(divisionWithNonFXTargetAmount.get(eachDivision)==0)
                {
                    percantage = ((revenueAmount/1)*100).setScale(2);
                }else 
                {
                    percantage = ((revenueAmount/divisionWithNonFXTargetAmount.get(eachDivision))*100).setScale(2);
                }
                grandTotalClosed = grandTotalClosed + ((divisionWithClosedWonOpportunity.containsKey(eachDivision) && divisionWithClosedWonOpportunity.get(eachDivision)!=Null)?divisionWithClosedWonOpportunity.get(eachDivision):0);
                grandTotalOpen   = grandTotalOpen   + ((divisionWithOpenOpportunity.containsKey(eachDivision) && divisionWithOpenOpportunity.get(eachDivision)!=Null)?divisionWithOpenOpportunity.get(eachDivision):0);
                grandTotalFX     = grandTotalFX + ((divisionWithFXTargetAmount.containsKey(eachDivision) && divisionWithFXTargetAmount.get(eachDivision)!=Null)?divisionWithFXTargetAmount.get(eachDivision):0);
                grandTotalRevenue = grandTotalRevenue + revenueAmount;
                grandTotalPlan  =  grandTotalPlan + ((divisionWithNonFXTargetAmount.containsKey(eachDivision) && divisionWithNonFXTargetAmount.get(eachDivision)!=Null)?divisionWithNonFXTargetAmount.get(eachDivision):0);
                grandTotalLYEndIncome = grandTotalLYEndIncome + ((divisionWithJournals.containsKey(eachDivision) && divisionWithJournals.get(eachDivision)!=Null)?divisionWithJournals.get(eachDivision):0);
                
                wrappedDataList.add(new WrapperClass(eachDivision,((divisionWithClosedWonOpportunity.containsKey(eachDivision) && divisionWithClosedWonOpportunity.get(eachDivision)!=Null)?divisionWithClosedWonOpportunity.get(eachDivision):0),
                                                     ((divisionWithOpenOpportunity.containsKey(eachDivision) && divisionWithOpenOpportunity.get(eachDivision)!=Null)?divisionWithOpenOpportunity.get(eachDivision):0),
                                                     ((divisionWithFXTargetAmount.containsKey(eachDivision) && divisionWithFXTargetAmount.get(eachDivision)!=Null)?divisionWithFXTargetAmount.get(eachDivision):0),
                                                     (divisionWithNonFXTargetAmount.containsKey(eachDivision)?divisionWithNonFXTargetAmount.get(eachDivision):0),
                                                     revenueAmount,((divisionWithNonFXTargetAmount.containsKey(eachDivision) && divisionWithNonFXTargetAmount.get(eachDivision)!=Null)?divisionWithNonFXTargetAmount.get(eachDivision):0),
                                                     percantage,((divisionWithJournals.containsKey(eachDivision) && divisionWithJournals.get(eachDivision)!=Null)?divisionWithJournals.get(eachDivision):0)));
                
                
            }
        }
        
        grandTotalPercentage = (grandTotalRevenue/((grandTotalPlan==0)?1:grandTotalPlan)*100).setScale(2);
        wrappedDataList.add(new WrapperClass(Null,Null,
                                             Null,
                                             Null,
                                             Null,
                                             Null,Null,
                                             Null,Null));
        wrappedDataList.add(new WrapperClass('Grand Total',grandTotalClosed,
                                             grandTotalOpen,
                                             grandTotalFX,
                                             grandTotalPlan,
                                             grandTotalRevenue,grandTotalPlan,
                                             grandTotalPercentage,grandTotalLYEndIncome));
        
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/QuarterlyForecastingReportDownload');
        return nextpage;
        
    }
    Public class WrapperClass{
        
        Public String divisionName {get; set;}
        Public Decimal closedWonOpportunityAmount {get; set;}
        Public Decimal openOpportunityAmount {get; set;}
        Public Decimal fxTargetAmount {get; set;}
        Public Decimal nonFxTargetAmount {get; set;}
        Public Decimal revenueForcast {get; set;}
        Public Decimal plan {get; set;}
        Public Decimal percentage {get; set;}
        Public Decimal lastYearIncome {get; set;}
        
        Public WrapperClass(String name,Decimal wonAmount,Decimal openAmount,Decimal fxAmount,Decimal nonFxAmount,
                            Decimal revenueAmount,Decimal planAmount,Decimal percentageAmount,Decimal lyIncome)
        {
            divisionName = name;
            closedWonOpportunityAmount = (wonAmount!=Null)?wonAmount.setScale(2, RoundingMode.HALF_UP):wonAmount;
            openOpportunityAmount =(openAmount!=Null)?openAmount.setScale(2, RoundingMode.HALF_UP):openAmount;
            fxTargetAmount = (fxAmount!=Null)?fxAmount.setScale(2, RoundingMode.HALF_UP):fxAmount;
            nonFxTargetAmount = (nonFxAmount!=Null)?nonFxAmount.setScale(2, RoundingMode.HALF_UP):nonFxAmount;
            revenueForcast     = (revenueAmount!=Null)?revenueAmount.setScale(2, RoundingMode.HALF_UP):revenueAmount;
            plan        = (planAmount!=Null)?planAmount.setScale(2, RoundingMode.HALF_UP):planAmount;
            percentage =(percentageAmount!=Null)?percentageAmount.setScale(2, RoundingMode.HALF_UP):percentageAmount;
            lastYearIncome = (lyIncome!=Null)?lyIncome.setScale(2, RoundingMode.HALF_UP):lyIncome;
        }
    }
}