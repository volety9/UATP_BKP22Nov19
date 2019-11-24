public class ytdPerformanceController {
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    //Public List<String> wList{get; set;}
    Public List<Repository__c> wrapDataList = new List<Repository__c>();
    //Public List<Repository__c> allDataList{get; set;}
    Public Decimal amount = 0.00;
    Public List<String> descriptionList = new List<String>{'FX Direct', 'FX Indirect', 'Commodities', 'IRRM'};
        Integer fyStartMonth;
    Public Date fyStartDate;
    Public Date fyEndDate; 
    
    Public Boolean batchRunning {get; set;}
    
    Public Map<String, Decimal> fxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetTillDateMap= new Map<String, Decimal>();
    //public Integer mon{get; set;}
    
    public ytdPerformanceController()
    {
        
        wrappedDataList = new List<WrapperClass>();
        amount = 0.00;
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        //fyStartDate = date.newInstance(2018, 10, 01);
        //fyEndDate = date.newInstance(2019, 09, 30);
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
        Map<String, String> rmMap = new Map<String, String>();
        
        Map<String, List<String>> groupMapfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapinfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapcomm = new Map<String, List<String>>();
        Map<String, List<String>> groupMapirrm = new Map<String, List<String>>();
        
        
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
        
        
        
       /*AggregateResult[] orr = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                 Account.RM_Name__r.Con_Team__r.Name bus, Owner.Name rm
                                 FROM Opportunity
                                 WHERE StageName NOT IN ('Closed Lost','Closed Won') AND 
                                    CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND
                                RecordType.Name != 'Vanilla FX'
                                 GROUP BY Account.RM_Name__r.Con_Team__r.Name, Owner.Name
                                 ORDER BY Account.RM_Name__r.Con_Team__r.Name, Owner.Name];
      
        System.debug('AGGRE>>>>'+orr);  */
        //String oldoutValue = '';
        //String oldinValue = '';
        //Decimal outPipeline = 0.00;
        //Map<String, Decimal> pipeOutMap = Map<String, Decimal>();
        //Map<String, Decimal> pipeInMap = Map<String, Decimal>();
        
        
        
id scotlandBHoursId;
        id englandBhoursId;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.today(), fyStartMonth);
        //Date startDate =date.newInstance(2018, 10, 01);
        Datetime endDate;            
        Date fyEndDate = CYBGUtilClass.findEndDateOfFY(System.today(), fyStartMonth);
        Long scotDays;
        Long engDays;
        Long scotTotDays;
        Long engTotDays;
        
        endDate = System.Now();
        //endDate=date.newInstance(2019, 09, 30);
        
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
        
        
        for(Opportunity each : [SELECT Id, Amount, 
                                Account.RM_Name__r.Con_Team__r.Name, Owner.Name, Opp_CorpCode__c
                                FROM Opportunity
                                WHERE StageName NOT IN (:System.Label.ClosedLost,:System.Label.ClosedWon) AND 
                                CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND
                                RecordType.Name NOT IN (:System.Label.RecordTypeVanilaFX, :System.Label.RecordTypeCRMBusinessLoan, :System.Label.RecordTypeFXCash)
                                ORDER BY Account.RM_Name__r.Con_Team__r.Name, Owner.Name])
        {
            String outerGrp;
            String innerGrp;
            
            if(each.Account.RM_Name__r.Con_Team__r.Name != null && each.Owner.Name != null)
            {
                outerGrp = each.Account.RM_Name__r.Con_Team__r.Name;
                innerGrp = each.Owner.Name;
            }
            else
            {
                if(each.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                {
                    outerGrp = System.Label.Retail_Team;
                    innerGrp = System.Label.Retail_FRSM;
                }
                else if(each.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                {
                    outerGrp = System.Label.YB_Retail_Team;
                    innerGrp = System.Label.Retail_FRSM;
                }
            }
            
            if(each.Amount != null)
            {
                if(pipeLineTot.containsKey(outerGrp))
                {
                    pipeLineTot.put(outerGrp, each.Amount + pipeLineTot.get(outerGrp));
                }
                else
                {
                    pipeLineTot.put(outerGrp, each.Amount);
                }
                
                if(pipeLine.containsKey(outerGrp + innerGrp) && each.Amount != null)
                {
                    pipeLine.put(outerGrp + innerGrp, each.Amount + pipeLine.get(outerGrp + innerGrp));
                }
                else
                {
                    pipeLine.put(outerGrp + innerGrp, each.Amount);
                }
            }
        }
      /* AggregateResult[] orrtot = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                    Account.RM_Name__r.Con_Team__r.Name bus
                                    FROM Opportunity
                                    WHERE StageName NOT IN ('Closed Lost','Closed Won') AND 
                                    CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND
                                RecordType.Name != 'Vanilla FX'
                                    GROUP BY Account.RM_Name__r.Con_Team__r.Name
                                    ORDER BY Account.RM_Name__r.Con_Team__r.Name];
        
        for(AggregateResult each : orr)
        {
            System.debug('HELLO AGGREGATE>>>'+each);
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
*/
        AggregateResult[] arr = [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, 
                                 Rep_BusinessCentre__c combine, Rep_MonthText__c mon
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 //WHERE CreatedDate =today
                                 AND RecordType.Name = 'BusinessAndTSM'
                                 GROUP BY Rep_BusinessCentre__c, Rep_MonthText__c
                                ORDER BY Rep_BusinessCentre__c, Rep_MonthText__c];
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
            
            /*if(each.get('fxIndirect') != null)
ofxindirectActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('fxIndirect'));
if(each.get('comm') != null)
ocommActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('comm'));
if(each.get('irrm') != null)
oirrmActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('irrm'));
*/
            if((Integer)each.get('co') >= 1 && each.get('combine') != null)
            {
                groupSet.add(((String)each.get('combine')).split(',')[0]);
                
                /* groupMapinfx.put(keys, ofxindirectActualList);
groupMapcomm.put(keys, ocommActualList);
groupMapirrm.put(keys, oirrmActualList);*/
            }
        }
        String bc = '';
        String rm = '';
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
                                 //WHERE CreatedDate =today
                                 AND RecordType.Name = 'BusinessAndTSM'
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
        String mapQuery = 'SELECT  TSMTar_TSM__c, TSMTar_Team__c, '+
            'TSMTar_TSM__r.Name, TSMTar_Team__r.Name '+
            'FROM TSMTarget__c WHERE '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate ORDER BY TSMTar_Team__r.Name, TSMTar_TSM__r.Name, CreatedDate';
        for(TSMTarget__c eachID :  Database.query(mapQuery))
        {
            outerKey = (String)eachID.TSMTar_Team__r.Name ;
            innerKey = (String)eachID.TSMTar_TSM__r.Name;
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            
            bcMap.put(keys, (String)eachID.TSMTar_Team__r.Name);
            rmMap.put(keys, (String)eachID.TSMTar_TSM__r.Name);
            
        }
        
        AggregateResult[] insideSumtot= [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, 
                                 Rep_BusinessCentre__c combine, Rep_TSMName__c tsm
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 //WHERE CreatedDate =today
                                 AND RecordType.Name = 'BusinessAndTSM'
                                 GROUP BY Rep_BusinessCentre__c, Rep_TSMName__c
                                ORDER BY Rep_BusinessCentre__c, Rep_TSMName__c];
        for(AggregateResult eachRec : insideSumtot)
        {
            outerKey = (String)eachRec.get('combine');
            innerKey = (String)eachRec.get('tsm');
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            
            bcMap.put(keys, (String)eachRec.get('combine'));
            rmMap.put(keys, (String)eachRec.get('tsm'));
           // keys = ((String)eachRec.get('combine')) + ((String)eachRec.get('tsm'));
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
        wrapDataList = [SELECT Rep_CombineId__c, Rep_Month__c, Rep_BusinessCentreId__c, Rep_TSMId__c,
                        Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_BusinessCentre__c,
                        Rep_TSMName__c, 
                        Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c
                        WHERE (Rep_FXDirectActual__c != null OR Rep_FXIndirectActual__c != null OR 
                        Rep_CommodityActual__c != null OR Rep_IRRMActual__c != null) AND 
                        CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                        //CreatedDate=today
                        AND RecordType.Name = 'BusinessAndTSM'
                        ORDER BY Rep_CombineId__c];
        
        
        
            //copy 
        //List<Team__c> locationList = [SELECT Id, Name, Team_Division__c FROM Team__c];
        Map<String, String> locationOutMap = new Map<String, String>();
        Map<String, String> locationInMap = new Map<String, String>();
       
        
        String TSMQuery1 = 'SELECT TSMTar_FXDirectTargetTillDate__c, TSMTar_FXIndirectTargetTillDate__c, '+
            'TSMTar_CommTargetTillDate__c, TSMTar_IRRMTargetTillDate__c, '+
            'TSMTar_FXDirectTarget__c, TSMTar_FXIndirectTarget__c, '+
            'TSMTar_CommTarget__c, TSMTar_IRRMTarget__c, '+
            'TSMTar_TSM__r.Name, TSMTar_Team__r.Name '+
            'FROM TSMTarget__c WHERE '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate ORDER BY TSMTar_Team__r.Name, TSMTar_TSM__r.Name, CreatedDate';
        
        for(TSMTarget__c eachID :  Database.query(TSMQuery1))
        {
            
            String combineID = (String)eachID.TSMTar_Team__r.Name + (String)eachID.TSMTar_TSM__r.Name;

            combineIdSet.add(combineID);
            
            //locationOutMap.put(eachRec.Name, eachRec.Team_Division__c);
            //locationInMap.put(eachRec.Name, eachRec.Team_Division__c);
            
            fxDirectTargetTillDateMap.put(combineID, eachID.TSMTar_FXDirectTarget__c.setScale(2));
            fxInDirectTargetTillDateMap.put(combineID, eachID.TSMTar_FXIndirectTarget__c.setScale(2));

            commTargetTillDateMap.put(combineID, eachID.TSMTar_CommTarget__c.setScale(2));
            irrmTargetTillDateMap.put(combineID, eachID.TSMTar_IRRMTarget__c.setScale(2));
            
           /* fxDirectTargetMap.put(combineID, eachID.TSMTar_FXDirectTarget__c);
            fxInDirectTargetMap.put(combineID, eachID.TSMTar_FXIndirectTarget__c);

            commTargetMap.put(combineID, eachID.TSMTar_CommTarget__c);
            irrmTargetMap.put(combineID, eachID.TSMTar_IRRMTarget__c);*/
        }
        System.debug('fxDirectTargetTillDateMap'+fxDirectTargetTillDateMap);
        
        /*copy*/
        String oldValue = '';
        Decimal sumifxDirectTargetTD = 0.00;
           Decimal sumifxInDirectTargetTD = 0.00;
           Decimal sumiirrmTargetTD = 0.00;
           Decimal sumicommTargetTD = 0.00;
        
        Map<String, Decimal> ifxDirectTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> ifxInDirectTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> iirrmTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> icommTargetTDMap = new Map<String, Decimal>();
        
        for(AggregateResult agr : [SELECT SUM(TSMTar_FXDirectTarget__c) fxDirectTar, SUM(TSMTar_FXIndirectTarget__c)fxIndirectTar, 
                                   SUM(TSMTar_CommTarget__c)commTar, SUM(TSMTar_IRRMTarget__c)irrmTar, 
                                   SUM(TSMTar_FXDirectTargetTillDate__c)fxDirectTarTD, SUM(TSMTar_FXIndirectTargetTillDate__c)fxInDirectTarTD,
                                   SUM(TSMTar_CommTargetTillDate__c)commTarTD, SUM(TSMTar_IRRMTargetTillDate__c)irrmTarTD,
                                   SUM(TSMTar_FXDirectActual__c) fxDirectActTD, SUM(TSMTar_FXIndirectActual__c) fxInDirectActTD,
                                   SUM(TSMTar_CommActual__c)commActTD, SUM(TSMTar_IRRMActual__c)irrmActTD,
                                   TSMTar_Team__r.Name team, calendar_month(CreatedDate) credMonth
                                   FROM TSMTarget__c 
                                   WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                   GROUP BY TSMTar_Team__r.Name, calendar_month(CreatedDate) 
                                   ORDER BY TSMTar_Team__r.Name, calendar_month(CreatedDate)])
        {
            if(oldValue != (String)agr.get('team'))
            {
                oldValue = (String)agr.get('team');
                
                sumifxDirectTargetTD = 0.00;
                sumifxInDirectTargetTD = 0.00;
                sumiirrmTargetTD = 0.00;
                sumicommTargetTD = 0.00;
                
            }
            
            sumifxDirectTargetTD = sumifxDirectTargetTD + (Decimal)agr.get('fxDirectTar');
            sumifxInDirectTargetTD = sumifxInDirectTargetTD + (Decimal)agr.get('fxIndirectTar');
            sumiirrmTargetTD = sumiirrmTargetTD + (Decimal)agr.get('irrmTar');
            sumicommTargetTD = sumicommTargetTD + (Decimal)agr.get('commTar');
            
            ifxDirectTargetTDMap.put((String)agr.get('team'), sumifxDirectTargetTD);
            ifxInDirectTargetTDMap.put((String)agr.get('team'), sumifxInDirectTargetTD);
            iirrmTargetTDMap.put((String)agr.get('team'), sumiirrmTargetTD);
            icommTargetTDMap.put((String)agr.get('team'), sumicommTargetTD);
            
        }
        
        for(String out : outerKeySet)
        {
            String keysin = '';
            Integer grouper = 0;
             List<Decimal> targetsTillDate;
            Decimal pipeTt = 0.00;
            Decimal fxtot = 0.00;
            Decimal infxtot = 0.00;
            Decimal commtot = 0.00;
            Decimal irrmtot = 0.00;
            Decimal actYtdTot = 0.00;
            
             Decimal ifxDirectVariance = 0.00;
                Decimal ifxInDirectVariance = 0.00;
                Decimal icommVariance = 0.00;
                Decimal iirrmVariance = 0.00;
            List<Decimal> itargetsTillDate = new List<Decimal>{0.00,0.00,0.00,0.00};
               List<String> ifxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> iinfxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> icommact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> iirrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
      
                                
                  List<String> iactTot = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
      
            if((Decimal)pipeLineTot.get(out) != null)
                pipeTt = (Decimal)pipeLineTot.get(out);
            for(String inn : innerKeySet)
            {
                Decimal fxDirectVariance = 0.00;
                Decimal fxInDirectVariance = 0.00;
                Decimal commVariance = 0.00;
                Decimal irrmVariance = 0.00;
                
                targetsTillDate = new List<Decimal>{0.00,0.00,0.00,0.00};
                keysin = out + inn;
                
                List<String> fxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> infxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> commact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> irrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                     
                                
                 
                List<String> actTot = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                     
                if(combineIdSet.contains(keysin))
                {
                    System.debug('keysin'+keysin);
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
                    
                    if((Decimal)fxDirectTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[0] = ((((Decimal)fxDirectTargetTillDateMap.get(keysin)) / engTotDays) * engDays).setScale(2);
                    if((Decimal)fxInDirectTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[1] = ((((Decimal)fxInDirectTargetTillDateMap.get(keysin))/engTotDays)* engDays).setScale(2);
                    if((Decimal)commTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[2] = ((((Decimal)commTargetTillDateMap.get(keysin))/engTotDays)* engDays).setScale(2);
                    if((Decimal)irrmTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[3] = ((((Decimal)irrmTargetTillDateMap.get(keysin))/engTotDays)* engDays).setScale(2);
                    
                    
                                    
                                        
                                        fxDirectVariance = ((((Decimal)fxDirectSum.get(keysin) == null ? 0.00 : (Decimal)fxDirectSum.get(keysin))
                                                             - ((Decimal)fxDirectTargetTillDateMap.get(keysin) == null ? 0.00 : (((Decimal)fxDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays)))).setScale(2);
                                    
                                    
                                        fxInDirectVariance = ((((Decimal)fxIndirectSum.get(keysin) == null ? 0.00 : (Decimal)fxIndirectSum.get(keysin))
                                                               - ((Decimal)fxInDirectTargetTillDateMap.get(keysin) == null ? 0.00 : (((Decimal)fxInDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays)))).setScale(2);
                                    
                                        commVariance = ((((Decimal)commSum.get(keysin) == null ? 0.00 : (Decimal)commSum.get(keysin))
                                                         - ((Decimal)commTargetTillDateMap.get(keysin) == null ? 0.00 : (((Decimal)commTargetTillDateMap.get(keysin)/engTotDays)*engDays)))).setScale(2);
                                    
                                        irrmVariance = ((((Decimal)irrmSum.get(keysin) == null ? 0.00 : (Decimal)irrmSum.get(keysin))
                                                         - ((Decimal)irrmTargetTillDateMap.get(keysin) == null ? 0.00 : (((Decimal)irrmTargetTillDateMap.get(keysin)/engTotDays)*engDays)))).setScale(2);
                                    
                    
                    Decimal fxdVariancePercent = 0;
                    Decimal fxindVariancePercent = 0;
                    Decimal commVariancePercent = 0;
                    Decimal irrmVariancePercent = 0;
                    
                    if((Decimal)targetsTillDate[0] != 0 && (Decimal)fxDirectSum.get(keysin) != null)
                    fxdVariancePercent = (((Decimal)fxDirectSum.get(keysin)/(Decimal)targetsTillDate[0])*100).setScale(0);
                    if((Decimal)targetsTillDate[1] != 0 && (Decimal)fxIndirectSum.get(keysin) != null)
                    fxindVariancePercent = (((Decimal)fxIndirectSum.get(keysin)/(Decimal)targetsTillDate[1])*100).setScale(0);
                    if((Decimal)targetsTillDate[2] != 0 && (Decimal)commSum.get(keysin) != null)
                    commVariancePercent = (((Decimal)commSum.get(keysin)/(Decimal)targetsTillDate[2])*100).setScale(0);
                    if((Decimal)targetsTillDate[3] != 0 && (Decimal)irrmSum.get(keysin) != null)
                    irrmVariancePercent = (((Decimal)irrmSum.get(keysin)/(Decimal)targetsTillDate[3])*100).setScale(0);
                        
                    
                    
                    for(Integer i=0; i < 13; i++)
                    {	
                        actTot[i] = String.valueOf(Decimal.valueOf(fxact[i]) + Decimal.valueOf(infxact[i]) + Decimal.valueOf(commact[i]) + Decimal.valueOf(irrmact[i]));
                    }
                    
                    Decimal fxSumTot = 0.00;
                    Decimal infxSumTot = 0.00;
                    Decimal commSumTot = 0.00;
                    Decimal irrmSumTot = 0.00;
                    
                    if(fxDirectSum.get(keysin) != null)
                        fxSumTot = fxDirectSum.get(keysin);
                    if(fxIndirectSum.get(keysin) != null)
                        infxSumTot = fxIndirectSum.get(keysin);
                    if(commSum.get(keysin) != null)
                        commSumTot = commSum.get(keysin);
                    if(irrmSum.get(keysin) != null)
                        irrmSumTot = irrmSum.get(keysin);
                    
                    
                    actYtdTot = fxSumTot + infxSumTot + commSumTot + irrmSumTot;
                    Decimal ytdTarTot = targetsTillDate[0] + targetsTillDate[1] + targetsTillDate[2] + targetsTillDate[3];
                    Decimal var = actYtdTot - ytdTarTot;
                     Decimal varPer = 0;
                    if(ytdTarTot != 0)
                    varPer = ((actYtdTot / ytdTarTot) * 100).setScale(0);
                    if(out != null && inn != null)
                    {
                    wrappedDataList.add(new WrapperClass(bcMap.get(keysin), rmMap.get(keysin), (String[])descriptionList, fxact, infxact,
                                                         commact, irrmact, fxDirectSum.get(keysin), fxIndirectSum.get(keysin),
                                                         commSum.get(keysin), irrmSum.get(keysin), (Decimal[])targetsTillDate, 
                                                         (Decimal)fxDirectVariance,(Decimal)fxInDirectVariance,
                                                         (Decimal)commVariance,(Decimal)irrmVariance,
                                                         fxdVariancePercent,
                                                         fxindVariancePercent,
                                                         commVariancePercent,
                                                         irrmVariancePercent,
                                                         (Decimal)pipe, (String[])actTot, (Decimal)actYtdTot, (Decimal)ytdTarTot, (Decimal)var, 
                                                         (Decimal)varPer));
                    }
                }
            }   
            
            if(grouper > 1)
            {
                Decimal iactYtdTot = 0.00;
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
                
                if((Decimal)ifxDirectTargetTDMap.get(out) != null)
                itargetsTillDate[0] = ((((Decimal)(ifxDirectTargetTDMap.get(out)).setScale(2))/engTotDays)*engDays).setScale(2);
                if((Decimal)ifxInDirectTargetTDMap.get(out) != null)
                itargetsTillDate[1] = ((((Decimal)(ifxInDirectTargetTDMap.get(out)).setScale(2))/engTotDays)*engDays).setScale(2);
                if((Decimal)icommTargetTDMap.get(out) != null)
                itargetsTillDate[2] = ((((Decimal)(icommTargetTDMap.get(out)).setScale(2))/engTotDays)*engDays).setScale(2);
                if((Decimal)iirrmTargetTDMap.get(out) != null)
                itargetsTillDate[3] = ((((Decimal)(iirrmTargetTDMap.get(out)).setScale(2))/engTotDays)*engDays).setScale(2);
                   
                
                
                                        ifxDirectVariance = (((Decimal)fxtot
                                                             - (Decimal)itargetsTillDate[0])).setScale(2);
                                   
                                        ifxInDirectVariance = (((Decimal)infxtot
                                                               - (Decimal)itargetsTillDate[1])).setScale(2);
                                    
                                        icommVariance = (((Decimal)commtot
                                                         - (Decimal)itargetsTillDate[2])).setScale(2);
                                    
                                        iirrmVariance = (((Decimal)irrmtot
                                                         - (Decimal)itargetsTillDate[3])).setScale(2);
                
                    Decimal ifxdVariancePercent = 0;
                    Decimal ifxindVariancePercent = 0;
                    Decimal icommVariancePercent = 0;
                    Decimal iirrmVariancePercent = 0;
                    
                    if((Decimal)itargetsTillDate[0] != 0)
                    ifxdVariancePercent = (((Decimal)fxtot/(Decimal)itargetsTillDate[0])*100).setScale(0);
                    if((Decimal)itargetsTillDate[1] != 0)
                    ifxindVariancePercent = (((Decimal)infxtot/(Decimal)itargetsTillDate[1])*100).setScale(0);
                    if((Decimal)itargetsTillDate[2] != 0)
                    icommVariancePercent = (((Decimal)commtot/(Decimal)itargetsTillDate[2])*100).setScale(0);
                    if((Decimal)itargetsTillDate[3] != 0)
                    iirrmVariancePercent = (((Decimal)irrmtot/(Decimal)itargetsTillDate[3])*100).setScale(0);
                
                for(Integer i=0; i < 13; i++)
                {
                    iactTot[i] = String.valueOf(Decimal.valueOf(ifxact[i]) + Decimal.valueOf(iinfxact[i]) + Decimal.valueOf(icommact[i]) + Decimal.valueOf(iirrmact[i]));
                }
                
                iactYtdTot = fxtot + infxtot + commtot + irrmtot; 
                Decimal iytdTarTot = itargetsTillDate[0] + itargetsTillDate[1] + itargetsTillDate[2] + itargetsTillDate[3];
                Decimal ivar = iactYtdTot - iytdTarTot;
                Decimal ivarPer = 0;
                if(iytdTarTot != 0)
                	ivarPer = ((iactYtdTot / iytdTarTot) * 100).setScale(0);
                if(out != null)
                    {
                wrappedDataList.add(new WrapperClass('Subtotal '+out, '', (String[])descriptionList, ifxact, iinfxact,
                                                     icommact, iirrmact, fxtot, infxtot,
                                                     commtot, irrmtot, (Decimal[])itargetsTillDate, 
                                                     ifxDirectVariance, ifxInDirectVariance, 
                                                     icommVariance, iirrmVariance, 
                                                     ifxdVariancePercent, ifxindVariancePercent, 
                                                     icommVariancePercent, iirrmVariancePercent, (Decimal)pipeTt, (String[])iactTot, (Decimal)iactYtdTot,
                                                    (Decimal)iytdTarTot, (Decimal)ivar, (Decimal)ivarPer));
                    }
            }
        }
        
    }
    
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceDld');
        return nextpage;
    }
    public PageReference submitBusCen() {
        PageReference nextpage = new PageReference('/apex/ytdPerformance');
        return nextpage;
    }
    public PageReference submitRegions() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceRegion');
        return nextpage;
    }
    public PageReference submitDivisions() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceDivision');
        return nextpage;
    }
    public PageReference submitGroups() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceGroup');
        return nextpage;
    }
    public PageReference submitBanks() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceBank');
        return nextpage;
    }
    
    Public class WrapperClass{
        Public String bc {get; set;}
        Public String frsm {get; set;}
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
        Public Decimal[] targetsTillDate {get; set;}
        Public Decimal fxvariance {get; set;}
        Public Decimal infxvariance {get; set;}
        Public Decimal commvariance {get; set;}
        Public Decimal irrmvariance {get; set;}
        Public Decimal fxvariancePercent {get; set;}
        Public Decimal infxvariancePercent {get; set;}
        Public Decimal commvariancePercent {get; set;}
        Public Decimal irrmvariancePercent {get; set;}
        Public String[] actTot {get; set;}
        Public Decimal actYtdTot {get; set;}
        Public Decimal ytdTarTot {get; set;}
        Public Decimal var {get; set;}
        Public Decimal varPer {get; set;}
        
        /* Public Boolean groupIt {get; set;}*/
        Public WrapperClass(String bc, String frsm, List<String>descriptionList, List<String> FXDirectActual, List<String> FXIndirectActual,
                            List<String> CommActual, List<String> IRRMActual, Decimal fxDirectActualsTillDate,
                            Decimal fxInDirectActualsTillDate, Decimal commActualsTillDate, Decimal irrmActualsTillDate, 
                            List<Decimal> targetsTillDate, Decimal fxvariance, Decimal infxvariance,
                            Decimal commvariance, Decimal irrmvariance,
                             Decimal fxvariancePercent, Decimal infxvariancePercent,
                            Decimal commvariancePercent, Decimal irrmvariancePercent,
                            Decimal ytdPipeLine, List<String> actTot, Decimal actYtdTot, Decimal ytdTarTot, Decimal var, Decimal varPer)
        {
            
            
            this.bc = bc; 
            this.frsm =  frsm;
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
            this.targetsTillDate = targetsTillDate;
            this.fxvariance = fxvariance;
            this.infxvariance = infxvariance;
            this.commvariance = commvariance;
            this.irrmvariance = irrmvariance;
            this.fxvariancePercent = fxvariancePercent;
            this.infxvariancePercent = infxvariancePercent;
            this.commvariancePercent = commvariancePercent;
            this.irrmvariancePercent = irrmvariancePercent;
            this.actTot = actTot;
            this.actYtdTot = actYtdTot;
            this.ytdTarTot = ytdTarTot;
            this.var = var;
            this.varPer = varPer;
        }
    }
}