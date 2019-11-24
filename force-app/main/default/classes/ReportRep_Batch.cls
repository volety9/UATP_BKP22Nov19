global class ReportRep_Batch implements Database.Batchable<sObject>{ 
    global List<AggregateResult> agrLast ; 
    global List<AggregateResult> agrCurr ;
    global List<Opportunity> oppList;
     //global List<AggregateResult> queryLast; 
    //global List<AggregateResult> queryCurr;
    
    public List<Repository__c> repList = new List<Repository__c>();
    Public Map<String, Repository__c> repMap = new Map<String, Repository__c>();
    
  /*  global ReportRep_Batch(List<AggregateResult> agrLast, List<AggregateResult> agrCurr){ 
        
        this.agrLast = agrLast; 
        this.agrCurr = agrCurr; 
        
    } */
    
    public ReportRep_Batch(List<Opportunity> opptyList)
    {
        oppList = new List<Opportunity>();
        oppList.addAll(opptyList);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
    
   /*List<Repository__c> repList = [SELECT Id FROM Repository__c WHERE RecordType.Name = 'CustomerAndPM'];
        if(repList.size() > 0)
            delete repList;*/
    
   
        /*oppList = [SELECT Id, account.id, account.name, account.owner.name, account.Commodity_Manager__c, account.FX_Manager__c, account.IRRM_Manager__c, 
                                     RecordType.Name, Opp_ETBranchNumber__c, Account.RM_Name__r.Name, Account.RM_Name__r.Con_Team__r.Name, Account.WID__c,
                                     Opp_PrimaryCurrency__c, Opp_PrimaryAmount__c, Opp_SecondaryCurrency__c, Opp_SecondaryAmount__c,
                                     account.Commodity_Manager__r.Name, account.FX_Manager__r.Name, account.IRRM_Manager__r.Name FROM Opportunity];
        
    */
           
    
        System.debug('const' + agrLast); 
        System.debug('const' + agrCurr); 
        String query = 'SELECT Id FROM Opportunity LIMIT 100';
                            
        return Database.getQueryLocator(query);
        
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        System.debug('Size>>>>>>>>>'+oppList.size());
         Date endLastYear = System.today().Addyears(-1);
        Date endThisYear = System.today();
        
        Integer startMonth =  CYBGUtilClass.fiscalYearStartMonth();
        
        Date startLastYear = CYBGUtilClass.findStartDateOfFY(endLastYear, startMonth ) ;
        Date startThisYear = CYBGUtilClass.findStartDateOfFY(endThisYear, startMonth ) ;
        
        agrLast = [SELECT Count(ID) cnt,SUM(Amount) amt, SUM(Opp_PrimaryAmount__c)prmAmount, SUM(Opp_SecondaryAmount__c) scndAmount,
                                           Opp_PrimaryCurrency__c prmCurr, Opp_SecondaryCurrency__c scndCurr, Account.Name accName, Account.Id accId, 
                                           Account.FX_Manager__c fxm, Account.Commodity_Manager__c commm, Account.IRRM_Manager__c irrmm, RecordType.Name rcd,
                                           MAX(CloseDate) csd
                                           FROM Opportunity WHERE CloseDate >= :startLastYear AND CloseDate <= :endLastYear
                                           AND StageName = 'Closed Won' 
                                           GROUP BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c
                                           ORDER BY Account.Id,Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c]; 
        
         agrCurr = [SELECT Count(ID) cnt, SUM(Amount) amt, SUM(Opp_PrimaryAmount__c)prmAmount, SUM(Opp_SecondaryAmount__c) scndAmount,
                                           Opp_PrimaryCurrency__c prmCurr, Opp_SecondaryCurrency__c scndCurr, Account.Name accName, Account.Id accId, 
                                           Account.FX_Manager__c fxm, Account.Commodity_Manager__c commm, Account.IRRM_Manager__c irrmm, RecordType.Name rcd,
                                           MAX(CloseDate) csd
                                           FROM Opportunity WHERE CloseDate >= :startThisYear AND CloseDate <= :endThisYear
                                           AND StageName = 'Closed Won'
                                           GROUP BY Account.Id,Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c
                                           ORDER BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c]; 
    
        Id CustomerPMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('CustomerAndPM').getRecordTypeId();
        Set<String> accIdSet = new Set<String>();
        List<Repository__c> repList = new List<Repository__c>();
        
        Repository__c repObj;
        Map<String, Decimal> amtMapOld = new Map<String, Decimal>();
        Map<String, Decimal> toMapOld = new Map<String, Decimal>();
        Map<String, Integer> dealsMapOld = new Map<String, Integer>();
        Map<String, Date> maxDate = new Map<String, Date>();
        Set<String> YOYSet = new Set<String>();      
        
        for(AggregateResult ar : agrLast)
        {
            
            String currSuff = '';
            String pmSuff = '';
            String pmId = '';
            String accId='';  
            //String oppname='';
            Decimal to = 0.00;
            Decimal margin = 0.00;
            String prmCurr = '';
            String scndCurr = '';
            Decimal prmAmount = 0.00;
            Decimal scndAmount = 0.00;
            

            if((String)ar.get('prmCurr') != null)
                prmCurr = (String)ar.get('prmCurr');
            if((String)ar.get('scndCurr') != null)
                scndCurr = (String)ar.get('scndCurr');
            if((Decimal)ar.get('prmAmount') != null)
                prmAmount = (Decimal)ar.get('prmAmount');
            if((Decimal)ar.get('scndAmount') != null)
                scndAmount = (Decimal)ar.get('scndAmount');
            
            accId=(String)ar.get('accId');     
            //oppname=(String)ar.get('oppname');  
            accIdSet.add((String)ar.get('accId'));
            
            if((String)ar.get('accName') == 'LOGANAIR LTD')
            {
                System.debug('MAX Date '+maxDate.get((String)ar.get('accId') + (String)ar.get('rcd')));
            }
            
            if(prmCurr == 'GBP' && prmAmount != null)
            {
                to = (prmAmount > 0 ? prmAmount : -1 * prmAmount);
                
            }
            else if(scndCurr == 'GBP' && scndAmount != null)
            {
                to = (scndAmount > 0 ? scndAmount : -1 * scndAmount);
                
            }
            else if(prmAmount != null)
            {
                to = (prmAmount > 0 ? prmAmount : -1 * prmAmount);
            }
            
            
            
            if((String)ar.get('rcd') == 'FX Cash' && (String)ar.get('fxm') != null)
            {
                pmId = (String)ar.get('fxm');
                pmSuff = 'FX';
            }
            else if((String)ar.get('rcd') == 'Commodity' && (String)ar.get('commm') != null)
            {
                pmId = (String)ar.get('commm');
                pmSuff = 'COMM';
            }
            else if((String)ar.get('rcd') == 'IRRM' && (String)ar.get('irrmm') != null)
            {
                pmId = (String)ar.get('irrmm');
                pmSuff = 'IRRM';
            }
            
            if(maxDate.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && maxDate.get((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr) > (Date)ar.get('csd'))
                maxDate.put((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr, maxDate.get((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr));
            else
                maxDate.put((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Date)ar.get('csd'));
            
            if(toMapOld.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                toMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, toMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + to);
            }
            else
            {
                toMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, to);
            }
            
            if(amtMapOld.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                amtMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, amtMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + (Decimal)ar.get('amt'));
            }
            else
            {
                amtMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Decimal)ar.get('amt'));
            }
            
            if(toMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) != 0.00 && toMapOld.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && amtMapOld.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && amtMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) != null)
                margin = (amtMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) / toMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr)) * 100;
            
            if(dealsMapOld.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                dealsMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, dealsMapOld.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + (Integer)ar.get('cnt'));
            }
            else
            {
                dealsMapOld.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Integer)ar.get('cnt'));
            }
            
            System.debug('To >>>>>>>'+to);
            System.debug('Margin >>>>>>>'+margin);
            if(repMap.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            	repObj = repMap.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr);    
            else
            	repObj = new Repository__c();
            
            repObj.RecordTypeId = CustomerPMRecordType;
            repObj.Rep_CustomerName__c = (String)ar.get('accName');
            //repObj.Rep_PMName__c = pmId;
            repObj.Rep_CombineId__c = (String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr;
            repObj.Rep_AmountLast__c = amtMapOld.get(repObj.Rep_CombineId__c);
            repObj.Rep_TOLast__c = toMapOld.get(repObj.Rep_CombineId__c);
            repObj.Rep_MarginLast__c = margin;            
            repObj.Rep_DealsLast__c = dealsMapOld.get(repObj.Rep_CombineId__c);
            repObj.Rep_PrimaryCurrency__c = prmCurr;
            repObj.Rep_SecondaryCurrency__c = scndCurr;
            //repObj.Rep_PrimaryAmount__c = prmAmount;
            //repObj.Rep_SecondaryAmount__c = scndAmount;
            //Sandeep
            if(prmAmount < 0){
                repObj.Rep_PrimaryAmount__c = prmAmount*-1; 
            }else{
                repObj.Rep_PrimaryAmount__c = prmAmount;   
            }
            if(scndAmount < 0){
                repObj.Rep_SecondaryAmount__c = scndAmount*-1; 
            }else{
                repObj.Rep_SecondaryAmount__c = scndAmount;
            }            
            repObj.Opportunity_RecordType__c = (String)ar.get('rcd');
            repobj.Rep_AccountId__c=accId;
            //repobj.Rep_OppName__c=oppname;  
            
            if(maxDate.containsKey(repObj.Rep_CombineId__c))
                repObj.Rep_DealLastDate__c = maxDate.get(repObj.Rep_CombineId__c);
            
            YOYSet.add(repObj.Rep_CombineId__c);
            //repList.add(repObj);
            // accIdSet.put((Id)ar.get('accId'));
            if((String)ar.get('accId') != null && pmId != null && pmSuff != '')
            repMap.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, repObj);
        }
        
        Map<String, Decimal> amtMapCurr = new Map<String, Decimal>();
        Map<String, Decimal> toMapCurr = new Map<String, Decimal>();
        Map<String, Integer> dealsMapCurr = new Map<String, Integer>();
        for(AggregateResult ar : agrCurr)
        {
            accIdSet.add((String)ar.get('accId'));
            //repObj = new Repository__c();            
            String pmId = '';
            String accId1= '';
            //String oppname1='';
            String currSuff = '';
            String pmSuff = '';
            Decimal to = 0.00;
            Decimal margin = 0.00;
            String prmCurr = '';
            String scndCurr = '';
            Decimal prmAmount = 0.00;
            Decimal scndAmount = 0.00; 
            
            

            if((String)ar.get('prmCurr') != null)
                prmCurr = (String)ar.get('prmCurr');
            if((String)ar.get('scndCurr') != null)
                scndCurr = (String)ar.get('scndCurr');
            if((Decimal)ar.get('prmAmount') != null)
                prmAmount = (Decimal)ar.get('prmAmount');
            if((Decimal)ar.get('scndAmount') != null)
                scndAmount = (Decimal)ar.get('scndAmount');
            
            accId1=(String)ar.get('accId');
          //  oppname1=(String)ar.get('oppname');
             
            
            if((String)ar.get('accName') == 'LOGANAIR LTD')
            {
                System.debug('MAX Date '+maxDate.get((String)ar.get('accId') + (String)ar.get('rcd')));
            }
            
            if(prmCurr == 'GBP' && prmAmount != null)
            {
                to = (prmAmount > 0 ? prmAmount : -1 * prmAmount);
                
            }
            else if(scndCurr == 'GBP' && scndAmount != null)
            {
                to = (scndAmount > 0 ? scndAmount : -1 * scndAmount);
                
            }
            else if(prmAmount != null)
            {
                to = (prmAmount > 0 ? prmAmount : -1 * prmAmount);
            }
            
            
            if((String)ar.get('rcd') == 'FX Cash' && (String)ar.get('fxm') != null)
            {
                pmId = (String)ar.get('fxm');
                pmSuff = 'FX';
            }
            else if((String)ar.get('rcd') == 'Commodity' && (String)ar.get('commm') != null)
            {
                pmId = (String)ar.get('commm');
                pmSuff = 'COMM';
            }
            else if((String)ar.get('rcd') == 'IRRM' && (String)ar.get('irrmm') != null)
            {
                pmId = (String)ar.get('irrmm');
                pmSuff = 'IRRM';
            }
            
            
             if(maxDate.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && maxDate.get((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr) > (Date)ar.get('csd'))
                maxDate.put((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr, maxDate.get((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr));
            else
                maxDate.put((String)ar.get('accId')  + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Date)ar.get('csd'));
            
            
            
            if(toMapCurr.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                toMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, toMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + to);
            }
            else
            {
                toMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, to);
            }
            
            if(amtMapCurr.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                amtMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, amtMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + (Decimal)ar.get('amt'));
            }
            else
            {
                amtMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Decimal)ar.get('amt'));
            }
            
            if(toMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) != 0.00 && toMapCurr.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && amtMapCurr.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) && amtMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) != null)
                margin = (amtMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) / toMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr)) * 100;
            
            if(dealsMapCurr.containsKey((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr))
            {
                dealsMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, dealsMapCurr.get((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr) + (Integer)ar.get('cnt'));
            }
            else
            {
                dealsMapCurr.put((String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr, (Integer)ar.get('cnt'));
            }
            
            if(repMap.containsKey((String)ar.get('accId') + pmId + 'CP' + pmSuff+prmCurr+scndCurr))
            {
                repObj = repMap.get((String)ar.get('accId') + pmId + 'CP' + pmSuff+prmCurr+scndCurr);
            }
            else
            {
                repObj = new Repository__c();
            }
            repObj.RecordTypeId = CustomerPMRecordType;
            repObj.Rep_CustomerName__c = (String)ar.get('accName');
            //repObj.Rep_PMName__c = pmId;
            repObj.Rep_CombineId__c = (String)ar.get('accId') + pmId +'CP'+pmSuff+prmCurr+scndCurr;
            repObj.Rep_AmountCurr__c = amtMapCurr.get(repObj.Rep_CombineId__c);
            repObj.Rep_TOCurr__c = toMapCurr.get(repObj.Rep_CombineId__c);
            repObj.Rep_MarginCurr__c = margin;            
            repObj.Rep_DealsCurr__c = dealsMapCurr.get(repObj.Rep_CombineId__c);
            repObj.Rep_PrimaryCurrency__c = prmCurr;
            repObj.Rep_SecondaryCurrency__c = scndCurr;
            //repObj.Rep_PrimaryAmount__c = prmAmount;
            //repObj.Rep_SecondaryAmount__c = scndAmount;
            //Sandeep
            if(prmAmount < 0){
                repObj.Rep_PrimaryAmount__c = prmAmount*-1;
            }else{
                repObj.Rep_PrimaryAmount__c = prmAmount;
            }
            if(scndAmount < 0){
                repObj.Rep_SecondaryAmount__c = scndAmount*-1;
            }else{
               repObj.Rep_SecondaryAmount__c = scndAmount; 
            }
            repObj.Opportunity_RecordType__c = (String)ar.get('rcd');
            repobj.Rep_AccountId__c=accId1;
            //repobj.Rep_oppName__c=oppname1;
            
            if(maxDate.containsKey(repObj.Rep_CombineId__c))
                repObj.Rep_DealLastDate__c = maxDate.get(repObj.Rep_CombineId__c);
            
            YOYSet.add(repObj.Rep_CombineId__c);
            //repList.add(repObj);
            
            
            //accIdSet.put((String)ar.get('accId'));
            if((String)ar.get('accId') != null && pmId != null && pmSuff != '')
                repMap.put((String)ar.get('accId') + pmId + 'CP' + pmSUff+prmCurr+scndCurr, repObj);
            
            
        }
        for(String each : YOYSet)
        {
            if(repMap.containsKey(each))
            {
                repObj = repMap.get(each);
            }
            else
            {
                repObj = new Repository__c();
            }
            repObj.Rep_CombineId__c = each;
            Decimal amountLast = ((Decimal)repObj.Rep_AmountLast__c == null ? 0.00 : (Decimal)repObj.Rep_AmountLast__c);
            Decimal toLast = ((Decimal)repObj.Rep_TOLast__c == null ? 0.00 : (Decimal)repObj.Rep_TOLast__c);
            Decimal dealsLast = ((Decimal)repObj.Rep_DealsLast__c == null ? 0.00 : (Decimal)repObj.Rep_DealsLast__c);
            Decimal amountCurr = ((Decimal)repObj.Rep_AmountCurr__c == null ? 0.00 : (Decimal)repObj.Rep_AmountCurr__c);
            Decimal toCurr = ((Decimal)repObj.Rep_TOCurr__c == null ? 0.00 : (Decimal)repObj.Rep_TOCurr__c);
            Decimal dealsCurr = ((Decimal)repObj.Rep_DealsCurr__c == null ? 0.00 : (Decimal)repObj.Rep_DealsCurr__c);
            
            repObj.Rep_AmountYOY__c = amountCurr - amountLast;
            repObj.Rep_TOYOY__c = toCurr - toLast;
            repObj.Rep_DealsYOY__c = dealsCurr - dealsLast;
            
            Decimal amountYOY = ((Decimal)repObj.Rep_AmountYOY__c == null ? 0.00 : (Decimal)repObj.Rep_AmountYOY__c);
            Decimal toYOY = ((Decimal)repObj.Rep_TOYOY__c == null ? 0.00 : (Decimal)repObj.Rep_TOYOY__c);
            
            if(toYOY != 0.00)
                //repObj.Rep_MarginYOY__c = (amountYOY / toYOY) * 100;
            //repObj.Rep_MarginYOY__c = amountYOY - toYOY;
            //repObj.Rep_MarginYOY__c = margin_Curr - margin_Last;
            if(each != '')
                repMap.put(each, repObj);
            
        }
        
       /* List<Opportunity> oppList1 = [SELECT Id, account.id, account.name, account.owner.name, 

account.Commodity_Manager__c, account.FX_Manager__c, account.IRRM_Manager__c, 
                                     RecordType.Name, Opp_ETBranchNumber__c, Account.RM_Name__r.Name, 

Account.RM_Name__r.Con_Team__r.Name, Account.WID__c,
                                     Opp_PrimaryCurrency__c, Opp_PrimaryAmount__c, Opp_SecondaryCurrency__c, 

Opp_SecondaryAmount__c,
                                     account.Commodity_Manager__r.Name, account.FX_Manager__r.Name, 

account.IRRM_Manager__r.Name FROM Opportunity WHERE Account.id IN :accIdSet];*/
        
        
        for(Opportunity each : oppList)
        {
            //Repository__c repObj = new Repository__c();
            String pmSuff = '';
            String pmId = '';
            String pmName = '';
            if(each.RecordType.Name == 'FX Cash')
            {
                pmId = each.account.FX_Manager__c;
                pmName = each.account.FX_Manager__r.Name;
                pmSuff = 'FX';
            }
            else if(each.RecordType.Name == 'Commodity')
            {
                pmId = each.account.Commodity_Manager__c;
                pmName = each.account.Commodity_Manager__r.Name;
                pmSuff = 'COMM';
            }
            else if(each.RecordType.Name == 'IRRM')
            {
                pmId = each.account.IRRM_Manager__c;
                pmName = each.account.IRRM_Manager__r.Name;
                pmSuff = 'IRRM';
            }
            
            if(repMap.containsKey(each.account.Id + pmId + 'CP' + pmSuff + each.Opp_PrimaryCurrency__c + each.Opp_SecondaryCurrency__c))
            {
                repObj = repMap.get(each.account.Id + pmId + 'CP' + pmSuff + each.Opp_PrimaryCurrency__c + each.Opp_SecondaryCurrency__c);
                repObj.Rep_TSMName__c = each.Account.Owner.Name;
                repObj.Rep_PMName__c = pmName;
                repObj.Rep_ETBranchNumber__c = each.Opp_ETBranchNumber__c;
                repObj.Rep_RMName__c = each.Account.RM_Name__r.Name;
                repObj.Rep_BusinessCentre__c = each.Account.RM_Name__r.Con_Team__r.Name;
                if(each.Account.WID__c != null)
                    repObj.Rep_WID__c = each.Account.WID__c;
                else
                    repObj.Rep_WID__c = each.AccountId;
                
                repMap.put(each.account.Id + pmId + 'CP' + pmSuff + each.Opp_PrimaryCurrency__c + each.Opp_SecondaryCurrency__c, repObj);
            }
        }
        
        
        insert repMap.values();
    } 
    global void finish(Database.BatchableContext BC){ 
        
    } 
}