public class RMPerformanceYTDReportController {
    
    Public List<WrapperClass> wrappedDataList{get; set;}

    Public List<Repository__c> wrapDataList = new List<Repository__c>();

    Public Boolean batchRunning {get; set;}
    
    Public Decimal amount=0.00;
    Public List<String> descriptionList = new List<String>{'FX Direct', 'FX Indirect', 'Commodities', 'IRRM'};
        Integer fyStartMonth;
    Public Date fyStartDate;
    Public Date fyEndDate; 

    
    public RMPerformanceYTDReportController()
    {
        wrappedDataList = new List<WrapperClass>();
        amount = 0.00;
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        AsyncApexJob[] aaj = [SELECT Id, Status FROM AsyncApexJob WHERE Status IN ('Processing', 'Preparing') AND ApexClass.Name = 'RepositoryDataBatch'];
        
        if(aaj.size() > 0 )
            batchRunning = false;
        else
            batchRunning = true;

        if(batchRunning == true)
        fetchData();
    }
    
    
    Public void fetchData(){
        Decimal fxDirectActual = 0.00;
        Decimal fxIndirectActual = 0.00;
        Decimal commActual = 0.00;
        Decimal irrmActual = 0.00;
        String outerKey = '';
        String innerKey = '';
        String keys = '';
        Map<String, List<String>> fxDirectMap = new Map<String, List<String>>();
        Map<String, List<String>> fxIndirectMap = new Map<String, List<String>>();
        Map<String, List<String>> commMap = new Map<String, List<String>>();
        Map<String, List<String>> irrmMap = new Map<String, List<String>>();
        Map<String, Decimal> fxDirectSum = new Map<String, Decimal>();
        Map<String, Decimal> fxIndirectSum = new Map<String, Decimal>();
        Map<String, Decimal> commSum = new Map<String, Decimal>();
        Map<String, Decimal> irrmSum = new Map<String, Decimal>();
        Map<String, String> bcMap = new Map<String, String>();
        Map<String, String> bcMapOut = new Map<String, String>();
        Map<String, String> rmMap = new Map<String, String>();

        
        Map<String, List<String>> groupMapfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapinfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapcomm = new Map<String, List<String>>();
        Map<String, List<String>> groupMapirrm = new Map<String, List<String>>();
        
        Map<String, String> q6Map = new Map<String, String>();
        
        Set<String> outerKeySet = new Set<String>();
        Set<String> innerKeySet = new Set<String>();
        
        Set<String> groupSet = new Set<String>();
        
        Set<String> combineIdSet = new Set<String>();
        List<String> fxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
            List<String> fxindirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> commActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> irrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        Map<String, Decimal> pipeLine = new Map<String, Decimal>();
        
        Map<String, Decimal> pipeLineTot = new Map<String, Decimal>();
        
        //RepositoryBatch obj = new RepositoryBatch();
        //  Database.executeBatch(obj);
        //List<Repository__c> resList = [SELECT Rep_Month__c FROM Repository__c];
        
        //Changed for Pipeline Logic from Created Date to CloseDate -- Santhoshan -- 01/11/2018
        AggregateResult[] orr = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                 Account.RM_Name__r.Con_Team__c bus, Account.RM_Name__c rm
                                 FROM Opportunity
                                 WHERE StageName NOT IN ('Closed Lost','Closed Won') AND
                                 CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate
                                 AND RecordType.Name NOT IN ('Vanilla FX', 'Business Loan', 'FX Cash')
                                 GROUP BY Account.RM_Name__r.Con_Team__c, Account.RM_Name__c
                                 ORDER BY Account.RM_Name__r.Con_Team__c, Account.RM_Name__c];
        AggregateResult[] orrtot = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                    Account.RM_Name__r.Con_Team__c bus
                                    FROM Opportunity
                                    WHERE StageName NOT IN ('Closed Lost','Closed Won') AND 
                                    CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate
                                    AND RecordType.Name NOT IN ('Vanilla FX', 'Business Loan', 'FX Cash')
                                    GROUP BY Account.RM_Name__r.Con_Team__c
                                    ORDER BY Account.RM_Name__r.Con_Team__c];
        
        for(AggregateResult each : orr)
        {
            
            if(each != null)
                pipeLine.put((String)each.get('bus') + (String)each.get('rm'), (Decimal)each.get('ammo'));
            
            // pipeLine.put((String)each.get('bus'), Decimal.valueOf(each..get('ammo')));
        }
        for(AggregateResult each : orrtot)
        {
            
            if(each != null)
                pipeLineTot.put((String)each.get('bus'), (Decimal)each.get('ammo'));
            
            // pipeLine.put((String)each.get('bus'), Decimal.valueOf(each..get('ammo')));
        }
        AggregateResult[] arr = [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, 
                                 Rep_BusinessCentreId__c combine, Rep_MonthText__c mon
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 AND RecordType.Name = 'BusinessAndRM'
                                 GROUP BY Rep_BusinessCentreId__c, Rep_MonthText__c
                                ORDER BY Rep_BusinessCentreId__c, Rep_MonthText__c];
        List<String> ofxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
            List<String> ofxindirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> ocommActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> oirrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        
                        String older = '';
        
        for(AggregateResult each : arr)
        {

            keys = ((String)each.get('combine'));

            if(older != keys)
            {
                ofxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    ofxindirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        ocommActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            oirrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                
                                if(each.get('fxDirect') != null)
                ofxDirectActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxDirect'));
                                   if(each.get('fxIndirect') != null)
                ofxindirectActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxIndirect'));
                                      if(each.get('comm') != null)
                ocommActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('comm'));
                                         if(each.get('irrm') != null)
                oirrmActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('irrm'));

                groupMapfx.put(keys, ofxDirectActualList);
                groupMapinfx.put(keys, ofxindirectActualList);
                groupMapcomm.put(keys, ocommActualList);
                groupMapirrm.put(keys, oirrmActualList);
                       
                older = keys;
            }
            else
            {
                if(each.get('fxDirect') != null)
                groupMapfx.get(keys)[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxDirect'));
                   if(each.get('fxIndirect') != null)
                groupMapinfx.get(keys)[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxIndirect'));
                      if(each.get('comm') != null)
                groupMapcomm.get(keys)[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('comm'));
                         if(each.get('irrm') != null)
                groupMapirrm.get(keys)[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('irrm'));
                
                groupMapfx.put(keys, ofxDirectActualList);
                groupMapinfx.put(keys, ofxindirectActualList);
                groupMapcomm.put(keys, ocommActualList);
                groupMapirrm.put(keys, oirrmActualList);
                
            }
            
       
            if((Integer)each.get('co') >= 1 && each.get('combine') != null)
            {
                groupSet.add(((String)each.get('combine')).split(',')[0]);
         
            }
        }
        String bc = '';
        String rm = '';
        String businessName = '';
        Decimal directSumm = 0.00;
        Decimal indirectSumm = 0.00;
        Decimal commSumm = 0.00;
        Decimal irrmSumm = 0.00;
        Map<String, Decimal> indirectSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> directSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> commSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> irrmSumMMap = new Map<String, Decimal>();
        AggregateResult[] insideSum= [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, 
                                 Rep_CombineId__c combine, Rep_MonthText__c mon
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 AND RecordType.Name = 'BusinessAndRM'
                                 GROUP BY Rep_CombineId__c, Rep_MonthText__c
                                ORDER BY Rep_CombineId__c, Rep_MonthText__c];
        
        for(AggregateResult eachRec : insideSum)
        {

            keys = ((String)eachRec.get('combine')).split(',')[0] + ((String)eachRec.get('combine')).split(',')[1];
            if(fxDirectMap.containsKey(keys) && eachRec.get('fxDirect') != null)
            {
               
                fxDirectMap.get(keys)[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('fxDirect'));
                fxDirectMap.put(keys, fxDirectActualList);

            }
            else if(eachRec.get('fxDirect') != null)
            {
                fxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                fxDirectActualList[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('fxDirect'));
                fxDirectMap.put(keys, fxDirectActualList);

            }
            
            
            if(fxIndirectMap.containsKey(keys) && eachRec.get('fxIndirect') != null)
            {
               
                fxIndirectMap.get(keys)[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('fxIndirect'));
                fxIndirectMap.put(keys, fxIndirectActualList);

            }
            else if(eachRec.get('fxIndirect') != null)
            {
                fxIndirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                fxIndirectActualList[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('fxIndirect'));
                fxIndirectMap.put(keys, fxIndirectActualList);

            }
            
            
            if(commMap.containsKey(keys) && eachRec.get('comm') != null)
            {
               
                commMap.get(keys)[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('comm'));
                commMap.put(keys, commActualList);

            }
            else if(eachRec.get('comm') != null)
            {
                commActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                commActualList[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('comm'));
                commMap.put(keys, commActualList);

            }
            
            
            if(irrmMap.containsKey(keys) && eachRec.get('irrm') != null)
            {
               
                irrmMap.get(keys)[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('irrm'));
                irrmMap.put(keys, irrmActualList);

            }
            else if(eachRec.get('irrm') != null)
            {
                irrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                irrmActualList[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('irrm'));
                irrmMap.put(keys, irrmActualList);

            }
        }
        Opportunity[] mapQuery = [SELECT 
                                 Account.RM_Name__r.Con_Team__c, Account.RM_Name__c,
                                      Account.RM_Name__r.Con_Team__r.Name, Account.RM_Name__r.Name
                                 FROM Opportunity
                                 WHERE Account.RM_Name__c != null AND Account.RM_Name__r.Con_Team__c != null AND
                                 CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate
                                 ORDER BY Account.RM_Name__r.Con_Team__c, Account.RM_Name__c];
        for(Opportunity eachId : mapQuery)
        {
            outerKey = (String)eachId.Account.RM_Name__r.Con_Team__c;
            innerKey = (String)eachId.Account.RM_Name__c;
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            
            bcMap.put(keys, (String)eachId.Account.RM_Name__r.Con_Team__r.Name);
            rmMap.put(keys, (String)eachId.Account.RM_Name__r.Name);
            bcMapOut.put(outerKey, (String)eachId.Account.RM_Name__r.Con_Team__r.Name);
        }
        
        AggregateResult[] insideSumtot= [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, 
                                 Rep_BusinessCentreId__c combine, Rep_RMId__c tsm, Rep_BusinessCentre__c com,
                                         Rep_RMName__c rm
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 AND RecordType.Name = 'BusinessAndRM'
                                 GROUP BY Rep_BusinessCentreId__c, Rep_BusinessCentre__c, Rep_RMId__c, Rep_RMName__c
                                ORDER BY Rep_BusinessCentreId__c,Rep_BusinessCentre__c, Rep_RMId__c, Rep_RMName__c];
        for(AggregateResult eachRec : insideSumtot)
        {
            outerKey = (String)eachRec.get('combine');
            innerKey = (String)eachRec.get('tsm');
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            
            bcMap.put(keys, (String)eachRec.get('com'));
            rmMap.put(keys, (String)eachRec.get('rm'));
            bcMapOut.put(outerKey, (String)eachRec.get('com'));

            
            //keys = ((String)eachRec.get('combine')) + ((String)eachRec.get('tsm'));
            if(fxDirectSum.containsKey(keys) && eachRec.get('fxDirect') != null)
            {
                fxDirectSum.put(keys, (Decimal)eachRec.get('fxDirect') + fxDirectSum.get(keys));
            }
            else if(eachRec.get('fxDirect') != null)
            {
                fxDirectSum.put(keys, (Decimal)eachRec.get('fxDirect'));
            }
            
            
            if(fxIndirectSum.containsKey(keys) && eachRec.get('fxIndirect') != null)
            {
               
                fxIndirectSum.put(keys, (Decimal)eachRec.get('fxIndirect') + fxDirectSum.get(keys));
            }
            else if(eachRec.get('fxIndirect') != null)
            {
                fxIndirectSum.put(keys, (Decimal)eachRec.get('fxIndirect'));
            }
            
            
            if(commSum.containsKey(keys) && eachRec.get('comm') != null)
            {

                commSum.put(keys, (Decimal)eachRec.get('comm') + fxDirectSum.get(keys));
            }
            else if(eachRec.get('comm') != null)
            {
                commSum.put(keys, (Decimal)eachRec.get('comm'));
            }
            
            
            if(irrmSum.containsKey(keys) && eachRec.get('irrm') != null)
            {
                irrmSum.put(keys, (Decimal)eachRec.get('irrm') + irrmSum.get(keys));
            }
            else if(eachRec.get('irrm') != null)
            {
                irrmSum.put(keys, (Decimal)eachRec.get('irrm'));
            }
        }
  
        wrapDataList = [SELECT Rep_RMId__c, Rep_Q6Code__c, 
                        Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c
                        WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 AND RecordType.Name = 'BusinessAndRM'
                                ORDER BY Rep_BusinessCentreId__c,Rep_BusinessCentre__c, Rep_RMId__c, Rep_RMName__c];
        
        for(Repository__c rep : wrapDataList)
        {
            q6Map.put(rep.Rep_RMId__c, rep.Rep_Q6Code__c);
        }
        
        for(String out : outerKeySet)
        {
            String keysin = '';
            Integer grouper = 0;
            Decimal pipeTt = 0.00;
            Decimal fxtot = 0.00;
            Decimal infxtot = 0.00;
            Decimal commtot = 0.00;
            Decimal irrmtot = 0.00;
               List<String> ifxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> iinfxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> icommact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> iirrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
      
            if((Decimal)pipeLineTot.get(out) != null)
                pipeTt = (Decimal)pipeLineTot.get(out);
            for(String inn : innerKeySet)
            {
                keysin = out + inn;
                List<String> fxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> infxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> commact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> irrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                     
                if(combineIdSet.contains(keysin))
                {
                    grouper = grouper + 1;
                    Decimal pipe = 0.00;
                    if(pipeLine.get(keysin) != null)
                    {
                        pipe = pipeLine.get(keysin);
                    }
                    
                    if(fxDirectSum.get(keysin) != null)
                    {
                        fxtot = fxtot + fxDirectSum.get(keysin);
                    }
                    if(fxIndirectSum.get(keysin) != null)
                        infxtot = infxtot + fxIndirectSum.get(keysin);
                    if(commSum.get(keysin) != null)
                        commtot = commtot + commSum.get(keysin);
                    if(irrmSum.get(keysin) != null)
                        irrmtot = irrmtot + irrmSum.get(keysin);
                    
                    if(fxDirectMap.get(keysin) != null)
                    {
                        fxact = fxDirectMap.get(keysin);
                    }
                    if(fxIndirectMap.get(keysin) != null)
                    {
                        infxact = fxIndirectMap.get(keysin);
                    }
                    if(commMap.get(keysin) != null)
                    {
                        commact = commMap.get(keysin);
                    }
                    if(irrmMap.get(keysin) != null)
                    {
                        irrmact = irrmMap.get(keysin);
                    }
                    
                    
                    wrappedDataList.add(new WrapperClass(bcMap.get(keysin), rmMap.get(keysin), q6Map.get(inn), (String[])descriptionList, fxact, infxact,
                                                         commact, irrmact, fxDirectSum.get(keysin), fxIndirectSum.get(keysin),
                                                         commSum.get(keysin), irrmSum.get(keysin), (Decimal)pipe));
                }
            }   
            
            if(grouper > 1)
            {
                
                    if(groupMapfx.get(out) != null)
                    {
                        ifxact = groupMapfx.get(out);
                    }
                    if(groupMapinfx.get(out) != null)
                    {
                        iinfxact = groupMapinfx.get(out);
                    }
                    if(groupMapcomm.get(out) != null)
                    {
                        icommact = groupMapcomm.get(out);
                    }
                    if(groupMapirrm.get(out) != null)
                    {
                        iirrmact = groupMapirrm.get(out);
                    }
                    if(bcMapOut.get(out) != null)
                        businessName = bcMapOut.get(out);
                    else
                        businessName = '';
                wrappedDataList.add(new WrapperClass('Subtotal '+bcMapOut.get(out), '', '', (String[])descriptionList, ifxact, iinfxact,
                                                     icommact, iirrmact, fxtot, infxtot,
                                                     commtot, irrmtot, (Decimal)pipeTt));
            }
        }
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/RMPerformanceYTDReportDld');
        return nextpage;
    }
    
    Public class WrapperClass{
        Public String bc {get; set;}
        Public String rm {get; set;}
        Public String[] descriptionList {get; set;}
        Public String[] FXDirectActual {get; set;}
        Public String[] CommActual {get; set;}
        
        Public String[] FXIndirectActual {get; set;}
        
        Public String[] IRRMActual {get; set;}
        Public Decimal fxDirectActualsTillDate {get; set;}
        Public Decimal fxInDirectActualsTillDate {get; set;}
        Public Decimal commActualsTillDate {get; set;}
        Public Decimal irrmActualsTillDate {get; set;}
        Public Decimal ytdPipeLine {get; set;}
        Public String q6Code {get; set;}

        /* Public Boolean groupIt {get; set;}*/
        Public WrapperClass(String bc, String rm, String q6Code, List<String>descriptionList, List<String> FXDirectActual, List<String> FXIndirectActual,
                            List<String> CommActual, List<String> IRRMActual, Decimal fxDirectActualsTillDate,
                            Decimal fxInDirectActualsTillDate, Decimal commActualsTillDate, Decimal irrmActualsTillDate, 
                            Decimal ytdPipeLine)
        {
            
            
            this.bc = bc; 
            this.rm =  rm;
            this.q6Code = q6Code;

            this.descriptionList = descriptionList;
            this.FXDirectActual = FXDirectActual;
            
            this.FXIndirectActual = FXIndirectActual;
            
            this.CommActual = CommActual;
            
            this.IRRMActual = IRRMActual;
            this.fxDirectActualsTillDate = fxDirectActualsTillDate;
            this.fxInDirectActualsTillDate = fxInDirectActualsTillDate;
            this.commActualsTillDate = commActualsTillDate;
            this.irrmActualsTillDate = irrmActualsTillDate;
            this.ytdPipeLine = ytdPipeLine;
        }
    }
}