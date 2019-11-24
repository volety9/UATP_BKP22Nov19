/*
@Author        : Ramkumar M B
@Name          : LostAccountReportController
@Created Date  : 14th May 2018
@Description   : This is a Controller class for the LostAccountReport VF page 
@version       : 1.0
*/
public class LostAccountReportController {
    
    Public map<Id,Account>customerDetails = new Map<Id,Account>();
    Public map<Id,Decimal>customerWithVACurrentFY = new Map<Id,Decimal>();
    Public map<Id,Decimal>customerbaseEquivalentCurrentFY = new Map<Id,Decimal>();
    Public map<Id,Integer>customerWithDealsCurrentFY = new Map<Id,Integer>();
    Public map<Id,Decimal>customerWithVALastFY = new Map<Id,Decimal>();
    Public map<Id,Decimal>customerbaseEquivalentLastFY = new Map<Id,Decimal>();
    Public map<Id,Integer>customerWithDealsLastFY = new Map<Id,Integer>();
    Public List<WrapperClass>wrappedDataList {get; set;}
    Public map<Id,Decimal>customerNameWithTOCurrentFY = new Map<Id,Decimal>();
    Public map<Id,Decimal>customerNameWithDealsCurrentFY = new Map<Id,Decimal>();
    Public map<id,List<Opportunity>>customerWithOpportunitiesCurrentFY = new map<id,List<Opportunity>>();
    Public map<id,List<Opportunity>>customerWithOpportunitiesLastFY = new map<id,List<Opportunity>>();
    Date createdDateFrom;
    Date createdDateTo;
    
    Public LostAccountReportController(){
        
        wrappedDataList = new List<WrapperClass>();
        Integer currentMonth =  Date.Today().Month();
        Integer yearvalue    =  Date.Today().Year();
        Integer dayValue     =  Date.Today().Day();
        createdDateFrom = Date.newInstance(yearvalue-2, 10, 1);
        If(currentMonth==2){
            createdDateTo   = Date.newInstance(yearvalue-1, 3, 1);
        }else 
        {
            createdDateTo   = Date.newInstance(yearvalue-1, currentMonth, dayValue);
        }
        
        
        fetchReportData();
        
    }
    
    /**
* @description       Method to process the fetch data for the report
* @name              fetchReportData
* @param             void 
* @return            void
* @throws            NA
*/     
    
    Public void fetchReportData(){
        
        For(Account eachAccount : [Select Id,Name,(Select Id,Name,Amount,Opp_BaseEquivalent__c from Opportunities where 
                                                   CloseDate = THIS_FISCAL_YEAR) from Account where Customer_Status__c = 'Lost'])            
        {
            Integer dealNumber = 0;
            Decimal vaAmount = 0.0;
            Decimal baseEquivalentAmount = 0.0;
            For(Opportunity eachOpportunity :eachAccount.opportunities){
                dealNumber = dealNumber + 1;
                vaAmount = vaAmount + (eachOpportunity.Amount!=Null?eachOpportunity.Amount:0.0);
                baseEquivalentAmount = baseEquivalentAmount+(eachOpportunity.Opp_BaseEquivalent__c!=Null?eachOpportunity.Opp_BaseEquivalent__c:0.0);
                
                
            }
            customerWithVACurrentFY.put(eachAccount.Id, vaAmount);
            customerbaseEquivalentCurrentFY.put(eachAccount.Id, baseEquivalentAmount);
            customerWithDealsCurrentFY.put(eachAccount.Id, dealNumber);
            customerDetails.put(eachAccount.Id, eachAccount); 
        }
        
        For(Account eachAccount : [Select Id,Name,(Select Id,Name,Amount,Opp_BaseEquivalent__c from Opportunities where 
                                                   CloseDate >= :createdDateFrom and CloseDate <=:createdDateTo) 
                                   from Account where Customer_Status__c = 'Lost'])
        {
            Decimal vaAmount = 0.0;
            Decimal baseEquivalentAmount = 0.0;
            Integer dealNumber = 0;
            For(Opportunity eachOpportunity :eachAccount.opportunities){
                dealNumber = dealNumber + 1;
                vaAmount = vaAmount + (eachOpportunity.Amount!=Null?eachOpportunity.Amount:0.0);
                baseEquivalentAmount = baseEquivalentAmount+(eachOpportunity.Opp_BaseEquivalent__c!=Null?eachOpportunity.Opp_BaseEquivalent__c:0.0);
                
            }
            customerWithVALastFY.put(eachAccount.Id, vaAmount);
            customerbaseEquivalentLastFY.put(eachAccount.Id, baseEquivalentAmount);
            customerWithDealsLastFY.put(eachAccount.Id, dealNumber); 
        }
        For(Id eachId :customerWithVACurrentFY.keySet())
        {
            Decimal lastFypercentageValue = 0.0;
            if(customerWithVALastFY.containsKey(eachId))
            {
                
                Decimal currentFypercentageValue;
                if((customerWithVALastFY.get(eachId)==0.0) || (customerbaseEquivalentLastFY.get(eachId) ==0.0))
                {
                    currentFypercentageValue = 0.0;
                }else{
                    
                    currentFypercentageValue = ((customerWithVACurrentFY.get(eachId))/(customerbaseEquivalentCurrentFY.get(eachId)))*100;
                    
                }
                
                if((customerWithVALastFY.get(eachId)==0.0) || (customerbaseEquivalentLastFY.get(eachId) ==0.0))
                {
                    lastFypercentageValue = 0.0;
                }else{
                    
                    lastFypercentageValue = ((customerWithVALastFY.get(eachId))/(customerbaseEquivalentLastFY.get(eachId)))*100;
                    
                }
                wrappedDataList.add(new WrapperClass((String)customerDetails.get(eachId).Name,
                                                     customerWithVACurrentFY.get(eachId),customerbaseEquivalentCurrentFY.get(eachId),
                                                     customerWithDealsCurrentFY.get(eachId),customerWithVALastFY.get(eachId),
                                                     customerbaseEquivalentLastFY.get(eachId),customerWithDealsLastFY.get(eachId),
                                                     currentFypercentageValue,lastFypercentageValue));
            }else {
                
                Decimal currentFypercentageValue = ((customerWithVACurrentFY.get(eachId))/(customerbaseEquivalentCurrentFY.get(eachId)))*100;
                wrappedDataList.add(new WrapperClass((String)customerDetails.get(eachId).Name, customerWithVACurrentFY.get(eachId),customerbaseEquivalentCurrentFY.get(eachId), customerWithDealsCurrentFY.get(eachId),0.0, 0.0,0, currentFypercentageValue,0.0));
            }
        }
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/ForecastReportForLostAccountsDownload');
        return nextpage;
        
    }
    Public class WrapperClass{
        
        Public String customerName {get; set;}
        Public Decimal currentFYVA {get; set;}
        Public Decimal currentFYBaseequivalent {get; set;}
        Public Decimal LastFYVA {get; set;}
        Public Decimal LastFYBaseequivalent {get; set;}
        Public Integer currentFYDeals {get; set;}
        Public Integer lastFYDeals {get; set;}
        Public Decimal currentFYpercentage {get; set;}
        Public Decimal lastFYpercentage {get; set;}
        
        Public WrapperClass(String name,Decimal cVA,Decimal cBaseAmount,Integer cDeals,Decimal lVA,Decimal lBaseAmount,
                            Integer lDeals,Decimal cPercentage,Decimal lPercentage){
                                customerName = name; 
                                currentFYVA =  cVA ;
                                currentFYBaseequivalent =  cBaseAmount;
                                lastFYVA = lVA;
                                LastFYBaseequivalent = lBaseAmount;
                                currentFYDeals = cDeals;
                                lastFYDeals    = lDeals;
                                currentFYpercentage = cPercentage;
                                lastFYpercentage = lPercentage;   
                            }
        
    }
    
}