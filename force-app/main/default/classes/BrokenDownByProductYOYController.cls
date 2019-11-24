public class BrokenDownByProductYOYController {
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
    
    Map<String, Decimal> currCustomerProductVAMap = new Map<String, Decimal>();
    Map<String, Decimal> currCustomerProductTOMap = new Map<String, Decimal>();
    Map<String, Decimal> currCustomerProductMarginPercentMap = new Map<String, Decimal>();
    Map<String, Integer> currCustomerProductDealsMap = new Map<String, Integer>();
    Map<String, Decimal> lastCustomerProductVAMap = new Map<String, Decimal>();
    Map<String, Decimal> lastCustomerProductTOMap = new Map<String, Decimal>();
    Map<String, Decimal> lastCustomerProductMarginPercentMap = new Map<String, Decimal>();
    Map<String, Integer> lastCustomerProductDealsMap = new Map<String, Integer>();
    
    Set<Id> CustNameSet = new Set<Id>();
    Set<String> ProductSet = new Set<String>();
    
    public BrokenDownByProductYOYController(){
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
                                       Product__c product
                                       FROM Opportunity
                                       WHERE CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND StageName = 'Closed Won' 
                                       GROUP BY  Account.Id, Account.Name, Product__c])
        {
            amount = (Decimal)opptyAR.get('amount');
            TO = (Decimal)opptyAR.get('TO');
            
            if(amount != null && TO != null)
                marginPercent = amount / TO;
            else
                marginPercent = 0.00;
            marginPercent = marginPercent.setScale(2);
            if(TO == null)
            {
                TO = 0.0;
            }
            
            CusNameMap.put((ID)opptyAR.get('accId'), (String)opptyAR.get('accName'));

            currCustomerProductVAMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), (Decimal)opptyAR.get('amount'));
            currCustomerProductTOMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), TO);
            currCustomerProductMarginPercentMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), marginPercent);
            currCustomerProductDealsMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), (Integer)opptyAR.get('deals'));
            
            CustNameSet.add((ID)opptyAR.get('accId'));
            ProductSet.add((String)opptyAR.get('product'));
        }
        
        For(AggregateResult opptyAR : [SELECT SUM(Amount)amount, SUM(Opp_BaseEquivalent__c)TO, COUNT(ID)deals, 
                                       Account.Id accId, Account.Name accName, 
                                       Product__c product
                                       FROM Opportunity
                                       WHERE CloseDate >= :pfyStartDate AND CloseDate <= :pfyEndDate AND StageName = 'Closed Won' 
                                       GROUP BY  Account.Id, Account.Name, Product__c])
        {
            amount = (Decimal)opptyAR.get('amount');
            TO = (Decimal)opptyAR.get('TO');
            
            if(amount != null && TO != null)
                marginPercent = amount/TO;
            else
                marginPercent = 0.00;
            marginPercent = marginPercent.setScale(2);
            if(TO == null)
            {
                TO = 0.0;
            }
            
            CusNameMap.put((ID)opptyAR.get('accId'), (String)opptyAR.get('accName'));

            lastCustomerProductVAMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), (Decimal)opptyAR.get('amount'));
            lastCustomerProductTOMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), TO);
            lastCustomerProductMarginPercentMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), marginPercent);
            lastCustomerProductDealsMap.put((String)opptyAR.get('accId')+(String)opptyAR.get('product'), (Integer)opptyAR.get('deals'));
            
            CustNameSet.add((ID)opptyAR.get('accId'));
        }
        
        For(Id eId : CustNameSet)
        {
            for(String eachId : ProductSet)
            {
                String combineId = (String)eId+(String)eachId;
                if(currCustomerProductVAMap.get(combineId) != null && lastCustomerProductVAMap.get(combineId) != null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         (String)eachId,
                                                         currCustomerProductVAMap.get(combineId), currCustomerProductTOMap.get(combineId),
                                                         currCustomerProductMarginPercentMap.get(combineId), currCustomerProductDealsMap.get(combineId),
                                                         lastCustomerProductVAMap.get(combineId), lastCustomerProductTOMap.get(combineId),
                                                         lastCustomerProductMarginPercentMap.get(combineId), lastCustomerProductDealsMap.get(combineId),
                                                         currCustomerProductVAMap.get(combineId) - lastCustomerProductVAMap.get(combineId),
                                                         currCustomerProductTOMap.get(combineId) - lastCustomerProductTOMap.get(combineId),
                                                         currCustomerProductMarginPercentMap.get(combineId) - lastCustomerProductMarginPercentMap.get(combineId),
                                                         currCustomerProductDealsMap.get(combineId) - lastCustomerProductDealsMap.get(combineId)));
                }
                else if(currCustomerProductVAMap.get(combineId) != null && lastCustomerProductVAMap.get(combineId) == null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         (String)eachId,
                                                         currCustomerProductVAMap.get(combineId), currCustomerProductTOMap.get(combineId),
                                                         currCustomerProductMarginPercentMap.get(combineId), currCustomerProductDealsMap.get(combineId),
                                                         0.0, 0.0,
                                                         0.00, 0,
                                                         currCustomerProductVAMap.get(combineId), currCustomerProductTOMap.get(combineId),
                                                         currCustomerProductMarginPercentMap.get(combineId), currCustomerProductDealsMap.get(combineId)));
                }
                else if(lastCustomerProductVAMap.get(combineId) != null && currCustomerProductVAMap.get(combineId) == null)
                {
                    wrappedDataList.add(new WrapperClass(CusNameMap.get(eId),
                                                         (String)eachId,
                                                         0.0, 0.0,
                                                         0.00, 0,
                                                         lastCustomerProductVAMap.get(combineId), lastCustomerProductTOMap.get(combineId),
                                                         lastCustomerProductMarginPercentMap.get(combineId), lastCustomerProductDealsMap.get(combineId),
                                                         lastCustomerProductVAMap.get(combineId) * -1, lastCustomerProductTOMap.get(combineId) * -1,
                                                         lastCustomerProductMarginPercentMap.get(combineId) * -1, lastCustomerProductDealsMap.get(combineId) * -1));
                }
            }
        }
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/BrokenDownByProductYOYDownload');
        return nextpage;
    }
    Public class WrapperClass{
        Public String customerName {get; set;}
        Public String Product {get; set;}
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
        
        Public WrapperClass(String customerName, String Product, Decimal currYearVA, Decimal currYearTO, 
                            Decimal currYearMarginPercent, Integer currYearDeals,
                            Decimal lastYearVA,Decimal lastYearTO, 
                            Decimal lastYearMarginPercent, Integer lastYearDeals,
                            Decimal diffYearVA,Decimal diffYearTO, 
                            Decimal diffYearMarginPercent, Integer diffYearDeals)
        {
            this.customerName = customerName; 
            this.Product =  Product ;
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