public class DirectFXYOYPerformanceController {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Date pfyStartDate;
    Date pfyEndDate;
    
    Decimal marginPercent = 0.00;
    Decimal amount = 0.0;
    Decimal TO = 0.0;
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    Id FXCashRecId;
    
    Map<Id, String> CusNameMap = new Map<Id, String>();
    Map<Id, String> OwnerNameMap= new Map<Id, String>();
    
    Map<String, Decimal> currCustomerOwnerVAMap= new Map<String, Decimal>();
    Map<String, Decimal> lastCustomerOwnerVAMap= new Map<String, Decimal>();
    Map<String, Decimal> currCustomerOwnerTOMap= new Map<String, Decimal>();
    Map<String, Decimal> lastCustomerOwnerTOMap= new Map<String, Decimal>();
    Map<String, Decimal> currCustomerOwnerMarginPercentMap= new Map<String, Decimal>();
    Map<String, Decimal> lastCustomerOwnerMarginPercentMap= new Map<String, Decimal>();
    Map<String, Integer> currCustomerOwnerDealsMap= new Map<String, Integer>();
    Map<String, Integer> lastCustomerOwnerDealsMap= new Map<String, Integer>();
    
    Set<Id> CustNameSet = new Set<Id>();
    Set<Id> OwnerSet = new Set<Id>();
    
    public DirectFXYOYPerformanceController(){
        wrappedDataList = new List<WrapperClass>();
        FXCashRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        pfyStartDate = Date.newInstance(fyStartDate.year()-1, fyStartMonth, 1);
        pfyEndDate = Date.newInstance(fyEndDate.year()-1, fyEndDate.month(), Date.daysInMonth(fyEndDate.year()-1 , fyEndDate.month()));
        fetchData();
    }
    
    Public void fetchData(){
        
        For(AggregateResult opptyAR : [SELECT SUM(Amount)amount, SUM(Opp_BaseEquivalent__c)TO, COUNT(ID)deals, 
                                       Account.Name accName, Account.Id accId, 
                                       Owner.Name owner, Owner.Id oId FROM Opportunity
                                       WHERE StageName = 'Closed Won' AND CloseDate >= :fyStartDate AND 
                                       CloseDate <= :fyEndDate AND Recordtypeid = :FXCashRecId
                                       GROUP BY  Account.Id, Account.Name, Owner.Name, Owner.Id])
        {
            amount = (Decimal)opptyAR.get('amount');
            TO = (Decimal)opptyAR.get('TO');
            
            if(amount != null && TO != null){
                if(TO == 0){
                    TO = 1;
                    marginPercent = amount / TO;
                }
              
            }
                
            else{
                marginPercent = 0.00;
            }
            if(TO == null)
            {
                TO = 0.0;
            }
            marginPercent = marginPercent.setScale(2);
            
            CusNameMap.put((ID)opptyAR.get('accId'), (String)opptyAR.get('accName'));
            OwnerNameMap.put((ID)opptyAR.get('oId'), (String)opptyAR.get('owner'));
            currCustomerOwnerVAMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), (Decimal)opptyAR.get('amount'));
            currCustomerOwnerTOMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), TO);
            currCustomerOwnerMarginPercentMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), marginPercent);
            currCustomerOwnerDealsMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), (Integer)opptyAR.get('deals'));
            
            CustNameSet.add((ID)opptyAR.get('accId'));
            OwnerSet.add((ID)opptyAR.get('oId'));
        }
        
        For(AggregateResult opptyAR : [SELECT SUM(Amount)amount, SUM(Opp_BaseEquivalent__c)TO, COUNT(ID)deals, 
                                       Account.Id accId, Account.Name accName, Owner.Name owner, Owner.Id oId FROM Opportunity
                                       WHERE  StageName = 'Closed Won' AND CloseDate >= :pfyStartDate AND
                                       CloseDate <= :pfyEndDate AND Recordtypeid = :FXCashRecId
                                       GROUP BY  Account.Id, Account.Name, Owner.Name, Owner.Id])
        {
            amount = (Decimal)opptyAR.get('amount');
            TO = (Decimal)opptyAR.get('TO');
            
            if(amount != null && TO != null)
                marginPercent = amount/TO;
            else
                marginPercent = 0.00;
            
            if(TO == null)
            {
                TO = 0.0;
            }
            marginPercent = marginPercent.setScale(2);
            
            CusNameMap.put((ID)opptyAR.get('accId'), (String)opptyAR.get('accName'));
            OwnerNameMap.put((ID)opptyAR.get('oId'), (String)opptyAR.get('owner'));
            lastCustomerOwnerVAMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), (Decimal)opptyAR.get('amount'));
            lastCustomerOwnerTOMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), TO);
            lastCustomerOwnerMarginPercentMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), marginPercent);
            lastCustomerOwnerDealsMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('oId'), (Integer)opptyAR.get('deals'));
            
            CustNameSet.add((ID)opptyAR.get('accId'));
            OwnerSet.add((ID)opptyAR.get('oId'));
        }
        
        For(Id eId : CustNameSet)
        {
            for(Id eachId : OwnerSet)
            {
                String combineId = (String)eId+(String)eachId;
                if(currCustomerOwnerVAMap.get(combineId) != null && lastCustomerOwnerVAMap.get(combineId) != null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         OwnerNameMap.get(eachId),
                                                         currCustomerOwnerVAMap.get(combineId), currCustomerOwnerTOMap.get(combineId),
                                                         currCustomerOwnerMarginPercentMap.get(combineId), currCustomerOwnerDealsMap.get(combineId),
                                                         lastCustomerOwnerVAMap.get(combineId), lastCustomerOwnerTOMap.get(combineId),
                                                         lastCustomerOwnerMarginPercentMap.get(combineId), lastCustomerOwnerDealsMap.get(combineId),
                                                         currCustomerOwnerVAMap.get(combineId) - lastCustomerOwnerVAMap.get(combineId),
                                                         currCustomerOwnerTOMap.get(combineId) - lastCustomerOwnerTOMap.get(combineId),
                                                         currCustomerOwnerMarginPercentMap.get(combineId) - lastCustomerOwnerMarginPercentMap.get(combineId),
                                                         currCustomerOwnerDealsMap.get(combineId) - lastCustomerOwnerDealsMap.get(combineId)));
                }
                else if(currCustomerOwnerVAMap.get(combineId) != null && lastCustomerOwnerVAMap.get(combineId) == null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         OwnerNameMap.get(eachId),
                                                         currCustomerOwnerVAMap.get(combineId), currCustomerOwnerTOMap.get(combineId),
                                                         currCustomerOwnerMarginPercentMap.get(combineId), currCustomerOwnerDealsMap.get(combineId),
                                                         0.0, 0.0,
                                                         0.00, 0,
                                                         currCustomerOwnerVAMap.get(combineId), currCustomerOwnerTOMap.get(combineId),
                                                         currCustomerOwnerMarginPercentMap.get(combineId), currCustomerOwnerDealsMap.get(combineId)));
                }
                else if(lastCustomerOwnerVAMap.get(combineId) != null && currCustomerOwnerVAMap.get(combineId) == null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         OwnerNameMap.get(eachId),
                                                         0.0, 0.0,
                                                         0.00, 0,
                                                         lastCustomerOwnerVAMap.get(combineId), lastCustomerOwnerTOMap.get(combineId),
                                                         lastCustomerOwnerMarginPercentMap.get(combineId), lastCustomerOwnerDealsMap.get(combineId),
                                                         lastCustomerOwnerVAMap.get(combineId) * -1, lastCustomerOwnerTOMap.get(combineId) * -1,
                                                         lastCustomerOwnerMarginPercentMap.get(combineId) * -1, lastCustomerOwnerDealsMap.get(combineId) * -1));
                }
            }
        }
        
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/DirectFXYOYPerformanceDownload');
        return nextpage;
        
    }
    Public class WrapperClass{
        Public String customerName {get; set;}
        Public String TSM {get; set;}
        Public Decimal currYearVA {get; set;}
        Public Decimal currYearTO {get; set;}
        Public Integer currYearDeals {get; set;}
        Public Decimal currYearMarginPercent {get; set;}
        Public Decimal lastYearVA {get; set;}
        Public Decimal lastYearTO {get; set;}
        Public Integer lastYearDeals {get; set;}
        Public Decimal lastYearMarginPercent {get; set;}
        Public Decimal diffYearVA {get; set;}
        Public Decimal diffYearTO {get; set;}
        Public Integer diffYearDeals {get; set;}
        Public Decimal diffYearMarginPercent {get; set;}
        
        Public WrapperClass(String customerName, String TSM, Decimal currYearVA,Decimal currYearTO, 
                            Decimal currYearMarginPercent, Integer currYearDeals,
                            Decimal lastYearVA,Decimal lastYearTO, 
                            Decimal lastYearMarginPercent, Integer lastYearDeals,
                            Decimal diffYearVA,Decimal diffYearTO, 
                            Decimal diffYearMarginPercent, Integer diffYearDeals)
        {
            this.customerName = customerName; 
            this.TSM =  TSM ;
            this.currYearVA =  currYearVA;
            this.currYearTO = currYearTO;
            this.currYearMarginPercent = currYearMarginPercent;
            this.currYearDeals = currYearDeals;
            this.lastYearVA =  lastYearVA;
            this.lastYearTO = lastYearTO;
            this.lastYearMarginPercent = lastYearMarginPercent;
            this.lastYearDeals = lastYearDeals;
            this.diffYearVA = diffYearVA;
            this.diffYearTO = diffYearTO;
            this.diffYearMarginPercent = diffYearMarginPercent;
            this.diffYearDeals = diffYearDeals;
        }
    }
}