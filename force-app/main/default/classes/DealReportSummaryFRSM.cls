public class DealReportSummaryFRSM {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Date pfyStartDate;
    Date pfyEndDate;
    //String fyStartDateString;
    //String fyEndDateString;
    
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    
    public Map<String, String> branchNumwithQ6Map = new Map<String, String>();
    public List<Q6Values__mdt> Q6ValueList = new List<Q6Values__mdt>();
    
    
    Public Map<String, String> oppMap= new Map<String, String>();
    Public Map<String, String> accMap= new Map<String, String>();
    Public Map<String, String> recMap= new Map<String, String>();
    Public Map<String, String> ownMap= new Map<String, String>();
    Public Map<String, String> etbMap= new Map<String, String>();
    Public Map<String, String> baseMap= new Map<String, String>();
    Public Map<String, String> bankerMap= new Map<String, String>();
    Public Map<String, String> teamMap= new Map<String, String>();
    Public Map<String, String> q6Map= new Map<String, String>();
    Public Map<String, String> brnoMap= new Map<String, String>();
    Public Map<String, String> etrMap= new Map<String, String>();
    Public Map<String, String> datMap= new Map<String, String>();
    Public Map<String, String> cidMap= new Map<String, String>();
    Public Map<String, String> tidMap= new Map<String, String>();
    
    Public Set<String> tradeSet= new Set<String>();
    
    //List<T> fullList = new List<T>();
    
    public DealReportSummaryFRSM(){
        
        wrappedDataList = new List<WrapperClass>();
        
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        fetchData();
    }
    
    Public void fetchData(){
        for(Q6Values__mdt q6 : [SELECT Q6Value__c, TradeKeyword__c FROM Q6Values__mdt]){
            branchNumwithQ6Map.put(q6.TradeKeyword__c, q6.Q6Value__c);        
        }

        for(Opportunity opptyList : [SELECT Account.Name,Amount,CloseDate, RecordType.Name, OwnerId, Owner.Name, Opp_ETBranchNumber__c, Opp_BaseEquivalent__c,
                                     Account.RM_Name__r.Officer_Code__c,
                                     Opp_BranchNumber__c, LastModifiedDate,Opp_ETRef__c, Opp_TradeID__c, Account.RM_Name__r.Name,
                                     Account.RM_Name__r.Con_Team__r.Name FROM Opportunity
                                     WHERE CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate 
                                     ORDER BY CloseDate ASC])
        {
            system.debug('rm name-->'+ opptyList.Account.RM_Name__r.Name);
            accMap.put(opptyList.OwnerId, opptyList.Account.Name);
            recMap.put(opptyList.OwnerId, opptyList.RecordType.Name);
            ownMap.put(opptyList.OwnerId, opptyList.Owner.Name);
            baseMap.put(opptyList.OwnerId, String.valueOf(opptyList.Amount));
            bankerMap.put(opptyList.OwnerId, opptyList.Account.RM_Name__r.Name);
            teamMap.put(opptyList.OwnerId, opptyList.Account.RM_Name__r.Con_Team__r.Name);
            brnoMap.put(opptyList.OwnerId, opptyList.Opp_BranchNumber__c);
            etrMap.put(opptyList.OwnerId, opptyList.Opp_ETRef__c);
            datMap.put(opptyList.OwnerId, String.valueOf(opptyList.CloseDate));
            tidMap.put(opptyList.OwnerId, opptyList.Opp_TradeID__c);
            System.debug('Trade'+(opptyList.Opp_TradeID__c));
            if(opptyList.Opp_TradeID__c != null)
            {
                tradeSet.add(opptyList.Opp_TradeID__c);
            }
            if(opptyList.Account.RM_Name__r.Officer_Code__c != null)
            {
                q6Map.put(opptyList.OwnerId, opptyList.Account.RM_Name__r.Officer_Code__c);
            }
            
            
            
        }
        System.debug('Trade'+tradeSet);
       
        for(CalypsoData__c keys: [SELECT Name, CD_Customer__r.OwnerId, CD_TradeID__c, 
                                  CD_ETBranchNumber__c, CD_BranchNumber__c, CD_Customer__r.Officer_Code__c FROM CalypsoData__c WHERE CD_TradeID__c IN :tradeSet])
        {
            System.debug('Name'+keys.Name);
            if(recMap.get(keys.CD_Customer__r.OwnerId) == 'FX Cash' && keys.CD_TradeID__c == tidMap.get(keys.CD_Customer__r.OwnerId))
            {
            cidMap.put(keys.CD_Customer__r.OwnerId, keys.Name);
                etbMap.put(keys.CD_Customer__r.OwnerId, keys.CD_ETBranchNumber__c);
                
                if(keys.CD_Customer__r.Officer_Code__c != null)
                {
                    q6Map.put(keys.CD_Customer__r.OwnerId, keys.CD_Customer__r.Officer_Code__c);
                }
                else if(keys.CD_BranchNumber__c != null && branchNumwithQ6Map.get(keys.CD_BranchNumber__c) != null)
                {
                    
                    q6Map.put(keys.CD_Customer__r.OwnerId, branchNumwithQ6Map.get(keys.CD_BranchNumber__c));
                }
                else
                {
                    q6Map.put(keys.CD_Customer__r.OwnerId, null);
                }
            }
            /*
            */
        }
        
        for(String keys: ownMap.keySet())
        {
            System.debug('CID'+cidMap.get(keys));
            wrappedDataList.add(new WrapperClass(datMap.get(keys), ownMap.get(keys), accMap.get(keys), recMap.get(keys), etbMap.get(keys),
                                                cidMap.get(keys), baseMap.get(keys), bankerMap.get(keys), q6Map.get(keys), teamMap.get(keys)));
        }
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/DealReportSummaryFRSMDld');
        return nextpage;
    }
    
    
    Public class WrapperClass{
        Public String tradeDate {get; set;}
        Public String customerName {get; set;}
        Public String product {get; set;}
        Public String etbranchNumber {get; set;}
        Public String cid {get; set;}
        Public String revenue {get; set;}
        Public String rm {get; set;}
        Public String q6 {get; set;}
        Public String team {get; set;}
        Public String OwnerNames {get; set;}
                
        Public WrapperClass(String tradeDate, String OwnerNames, String customerName, String product,String etbranchNumber, String cid,
                            String revenue,String rm,String q6,String team)
        {
            
            
            this.tradeDate = tradeDate; 
            this.customerName =  customerName;
            this.product =  product;
            this.etbranchNumber =  etbranchNumber;
            this.cid = cid;
            this.revenue =  revenue;
            this.rm =  rm;
            this.q6 =  q6;
            this.team = team;
            this.OwnerNames = OwnerNames;
        }
    }
}