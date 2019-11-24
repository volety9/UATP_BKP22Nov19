public class CommodityReportYOY {
    public Decimal yoyVa = 0.00;
    public Decimal margin = 0.00;
    Public Decimal YoyFa = 0.00;
    
   public date endLastYear = System.today().Addyears(-1);
   public date endThisYear = System.today();
   
   public integer startMonth =  CYBGUtilClass.fiscalYearStartMonth();
    
   public date startLastYear = CYBGUtilClass.findStartDateOfFY(endLastYear, startMonth ) ;
   public date startThisYear = CYBGUtilClass.findStartDateOfFY(endThisYear, startMonth ) ;
    
    public Set<String> accSet = new Set<String>();
    public Set<String> accIDSet = new Set<String>();
    
    public Map<String, Decimal> vaMapOld = new Map<String, Decimal>();
    public Map<String, Decimal> vaMapNew = new Map<String, Decimal>();
    public Map<String, Decimal> vaMapDiff = new Map<String, Decimal>();
    
    /*public Map<String, Decimal> FaceValueMapOld = new Map<String, Decimal>();
      public Map<String, Decimal> FaceValueMapNew = new Map<String, Decimal>();
      public Map<String, Decimal> FaceValueMapDiff = new Map<String, Decimal>();*/
    
    public Map<String, Decimal> TurnOverOld = new Map<String, Decimal>();
    public Map<String, Decimal> TurnOverNew = new Map<String, Decimal>();
    public Map<String, Decimal> TurnOverDiff = new Map<String, Decimal>();
    
    public Map<String, Decimal> CountOld = new Map<String, Decimal>();
    public Map<String, Decimal> CountNew = new Map<String, Decimal>();
    public Map<String, Decimal> CountDiff = new Map<String, Decimal>();
    
    public Map<String, Decimal> MarginOld = new Map<String, Decimal>();
    public Map<String, Decimal> MarginNew = new Map<String, Decimal>();
    public Map<String, Decimal> MarginDiff = new Map<String, Decimal>();
    
    public Map<String, Decimal> CloseDateOld = new Map<String, Decimal>();
    public Map<String, Decimal> CloseDateNew = new Map<String, Decimal>();
    public Map<String, Decimal> CloseDateDiff = new Map<String, Decimal>();
    
    public Map<String, String> CustomerName = new Map<String, String>();
    public Map<String, String> lastDealDate = new Map<String, String>();
    public Map<String, String> RelationshipManger = new Map<String, String>();
    public Map<String, String> FRSM = new Map<String, String>();
    public Map<String, String> WID = new Map<String, String>();
    public Map<String, String> BusinessCentre = new Map<String, String>();
    
    public String keyOld = '';
    public String keyNew = '';
    
    Public List<WrapperClass> Wrapper{get; set;}
    
    public CommodityReportYOY(){
        Wrapper = new List<WrapperClass>();
        AggregateResult[] agrlast = [SELECT Count(ID) cnt, SUM(Amount) amt, SUM(Face_Value_Amount__c) faAmt, Account.Name accName, Account.Id accID, Owner.Name frsm, MAX(CloseDate) closedate
                                     FROM Opportunity WHERE CloseDate >= :startLastYear AND CloseDate <= :endLastYear
                                     AND StageName = 'Closed Won' AND RecordType.Name = 'Commodity'
                                     GROUP BY Account.Name, Owner.Name, Account.Id
                                    ];
        for(AggregateResult each : agrlast)
        { 
            Decimal TurnOver = 0.00;
            keyOld = (String)each.get('accName') + (String)each.get('frsm');
            CustomerName.put(keyOld,(String)each.get('accName'));
            FRSM.put(keyOld,(String)each.get('frsm'));
            accIDSet.add((String)each.get('accID'));
            vaMapOld.put(keyOld, (Decimal)each.get('amt'));
            String ldt; 
            ldt = ((Date)each.get('closedate')).format();
            lastDealDate.put(keyOld, ldt);
            
            TurnOver = (Decimal)each.get('faAmt');
            TurnOverOld.put(keyOld, TurnOver);
            
            /*if(each.get('primaryCurr') == 'GBP' && (Decimal)each.get('pamt') != null)
                TurnOver = (Decimal)each.get('pamt');    
            else if(each.get('secondaryCurr') == 'GBP' && (Decimal)each.get('samt') != null)
                TurnOver = (Decimal)each.get('samt');    
            else if((Decimal)each.get('pamt') != null)
                TurnOver = (Decimal)each.get('pamt');
            
            if(TurnOverOld.containsKey(keyOld))
                TurnOverOld.put(keyOld, TurnOver + TurnOverOld.get(keyOld));
            else
                TurnOverOld.put(keyOld, TurnOver);*/
            CountOld.put(keyOld, (Decimal)each.get('cnt'));
            accSet.add(keyOld);
            System.debug('HERE TO>>>>>>>'+TurnOver);
            System.debug('HERE AMT>>>>>>>'+(Decimal)each.get('amt'));
            if((Decimal)each.get('amt') != null && TurnOver != 0)
                MarginOld.put(keyOld,(((Decimal)each.get('amt')/TurnOver)*100).setScale(2));
            else
                MarginOld.put(keyOld,0);
            
            

            System.debug('Count '+each.get('cnt'));
        }
        
        
        AggregateResult[] agr = [SELECT Count(ID) cnt, SUM(Amount) amt, SUM(Face_Value_Amount__c) faAmt, Account.Name accName, Account.Id accID, Owner.Name frsm, MAX(CloseDate) closedate
                                 FROM Opportunity WHERE CloseDate >= :startThisYear AND CloseDate <= :endThisYear
                                 AND StageName = 'Closed Won' AND RecordType.Name = 'Commodity'
                                 GROUP BY Account.Name, Owner.Name, Account.Id
                                ];
        for(AggregateResult each : agr)
        {
            Decimal TurnOver = 0.00;
            keyNew = (String)each.get('accName') + (String)each.get('frsm') ;
            CustomerName.put(keyNew,(String)each.get('accName'));
            FRSM.put(keyNew,(String)each.get('frsm'));
            accIDSet.add((String)each.get('accID'));
            
            vaMapNew.put(keyNew, (Decimal)each.get('amt'));
            String ldt; 
            ldt = ((Date)each.get('closedate')).format();
            lastDealDate.put(keyNew, ldt);
            
            TurnOver = (Decimal)each.get('faAmt');
            TurnOverNew.put(keyNew, TurnOver);
            
            /*if(each.get('primaryCurr') == 'GBP' && (Decimal)each.get('pamt') != null)
                TurnOver = (Decimal)each.get('pamt');    
            else if(each.get('secondaryCurr') == 'GBP' && (Decimal)each.get('samt') != null)
                TurnOver = (Decimal)each.get('samt');    
            else if((Decimal)each.get('pamt') != null)
                TurnOver = (Decimal)each.get('pamt'); 
            if(TurnOverNew.containsKey(keyNew))
                TurnOverNew.put(keyNew, TurnOver + TurnOverNew.get(keyNew));
            else
                TurnOverNew.put(keyNew, TurnOver) ;  */
            CountNew.put(keyNew, (Decimal)each.get('cnt'));
            accSet.add(keyNew);
            if((Decimal)each.get('amt') != null && TurnOver != 0)
                
                MarginNew.put(keyNew,(((Decimal)each.get('amt')/TurnOver)*100).setScale(2));
            else
                MarginNew.put(keyNew,0);
        }
        
        for(String ech : accSet)
        {
            Decimal oldVa = 0.00;
            Decimal newVa = 0.00;
            Decimal diffVa = 0.00;
            
            
            if(vaMapNew.get(ech) != null)
                newVa = vaMapNew.get(ech);
            if(vaMapOld.get(ech) != null)
                oldVa = vaMapOld.get(ech);
            
            diffVa = newVa - oldVa;
            vaMapDiff.put(ech, diffVa);
            
            Decimal oldTurnOver = 0.00;
            Decimal newTurnOver = 0.00;
            Decimal diffTurnover = 0.00;
            
            if( TurnOverNew.get(ech) != null)
                newTurnOver = TurnOverNew.get(ech);
            if( TurnOverOld.get(ech) != null)
                oldTurnOver = TurnOverOld.get(ech);
            
            
            diffTurnover = newTurnOver - oldTurnOver;
            TurnOverDiff.put(ech, diffTurnover);
            
            
            Decimal oldCount = 0;
            Decimal newCount = 0;
            Decimal diffCount = 0;
            
            if( CountNew.get(ech) != null)
                newCount = CountNew.get(ech);
            if( CountOld.get(ech) != null)
                oldCount = CountOld.get(ech);
            
            diffCount = newCount - oldCount;
            CountDiff.put(ech, diffCount);
            
            Decimal oldMargin = 0;
            Decimal newMargin = 0;
            Decimal diffMargin = 0;
            
            if( MarginNew.get(ech) != null)
                newMargin = MarginNew.get(ech);
            if( MarginOld.get(ech) != null)
                oldMargin = MarginOld.get(ech);
            
            diffMargin = newMargin - oldMargin;
            MarginDiff.put(ech, diffMargin);
            
            
            System.debug('Count Old '+oldCount);
            System.debug('Count New '+newCount);
            System.debug('Count Diff '+diffCount);
            
        }
        
        For(Account accountmap :[Select Id,Name,Owner.Name,RM_Name__c, RM_Name__r.Name, RM_Name__r.con_team__c , RM_Name__r.con_team__r.Name,WID__c From Account 
                                 where Id In :accIDSet])
        { String key = accountmap.Name + accountmap.Owner.Name;
         RelationshipManger.put(key, accountmap.RM_Name__r.Name);
         BusinessCentre.put(key, accountmap.RM_Name__r.con_team__r.Name);
         WID.put(key,accountmap.WID__c );
         
        }
        for(String ech : accSet)
        {
            Wrapper.add(new WrapperClass((String)CustomerName.get(ech), (String)FRSM.get(ech), (Decimal)vaMapOld.get(ech),
                                         (Decimal)vaMapNew.get(ech), (Decimal)vaMapDiff.get(ech), 
                                         (Decimal)TurnOverOld.get(ech),(Decimal)TurnOverNew.get(ech),
                                         (Decimal)TurnOverDiff.get(ech),(Decimal)CountOld.get(ech),
                                         (Decimal)CountNew.get(ech),(Decimal)CountDiff.get(ech),
                                         (Decimal)MarginOld.get(ech),(Decimal)MarginNew.get(ech),
                                         (Decimal)MarginDiff.get(ech),(String)lastDealDate.get(ech), 
                                         (String)RelationshipManger.get(ech),(String)BusinessCentre.get(ech),
                                         (String)WID.get(ech) ));
        }
        
    }  
      public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/CommodityReportYOY_Dld');
        return nextpage;
    }
    
    public class WrapperClass
    {
        public String customerName{get; set;}
        public String frsm{get; set;}
        public Decimal vaLastYear{get; set;}
        public Decimal vaThisYear{get; set;}
        public Decimal vaYOY{get; set;}
        public Decimal toLastYear{get; set;}
        public Decimal toThisYear{get; set;}
        public Decimal toYOY{get; set;}
        public Decimal dealsLastYear{get; set;}
        public Decimal dealsThisYear{get; set;}
        public Decimal dealsYOY{get; set;}
        public Decimal marginLastYear{get; set;}
        public Decimal marginThisYear{get; set;}
        public Decimal marginYOY{get; set;}
        public String dateLastDealt{get; set;}
        public String relationshipManager{get; set;}
        public String centre{get; set;}
        public String wid{get; set;}
        
        public WrapperClass(String customerName,String frsm,Decimal vaLastYear,Decimal vaThisYear,Decimal vaYOY,Decimal toLastYear,Decimal toThisYear,Decimal toYOY, Decimal dealsLastYear,
                            Decimal dealsThisYear,Decimal dealsYOY, Decimal marginLastYear,Decimal marginThisYear,Decimal marginYOY,String dateLastDealt,string relationshipManager,String centre,String wid)
            
        {
            
            this.customerName = customerName; 
            this.frsm =  frsm ;
            this.vaLastYear =  vaLastYear;
            this.vaThisYear = vaThisYear;
            this.vaYOY = vaYOY;
            this.toLastYear = toLastYear;
            this.toThisYear =  toThisYear;
            this.toYOY = toYOY;
            this.dealsLastYear = dealsLastYear;
            this.dealsThisYear = dealsThisYear;
            this.dealsYOY = dealsYOY;
            this.marginLastYear = marginLastYear;
            this.marginThisYear = marginThisYear;
            this.marginYOY = marginYOY;
            this.dateLastDealt = dateLastDealt;
            this.relationshipManager = relationshipManager;
            this.centre = centre;
            this.wid = wid;
            
        }                       
        
    }
}