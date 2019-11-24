public class ytdPerformanceControllerGroup {
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    //Public List<String> wList{get; set;}
    Public List<Repository__c> wrapDataList = new List<Repository__c>();
    //Public List<Repository__c> allDataList{get; set;}
    Public Decimal amount=0.00;
    Public List<String> descriptionList = new List<String>{'FX Direct', 'FX Indirect', 'Commodities', 'IRRM', 'FX Retail'};
        Integer fyStartMonth;
    Public Date fyStartDate;
    Public Date fyEndDate; 
    
    Public Boolean batchRunning {get; set;}
    
    Public Map<String, Decimal> fxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> retailTargetMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> retailTargetTillDateMap= new Map<String, Decimal>();
    //public Integer mon{get; set;}
    
    public ytdPerformanceControllerGroup()
    {
        wrappedDataList = new List<WrapperClass>();
        amount = 0.00;
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
          //fyStartDate = date.newInstance(2018, 10, 01) ;
		//fyEndDate = date.newInstance(2019, 09, 30) ;
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
        Decimal retailActual = 0.00;
        String outerKey = '';
        String innerKey = '';
        String keys = '';
        Map<String, List<String>> fxDirectMap = new Map<String, List<String>>();
        Map<String, List<String>> fxIndirectMap = new Map<String, List<String>>();
        Map<String, List<String>> commMap = new Map<String, List<String>>();
        Map<String, List<String>> irrmMap = new Map<String, List<String>>();
        Map<String, List<String>> retailMap = new Map<String, List<String>>();
        Map<String, Decimal> fxDirectSum = new Map<String, Decimal>();
        Map<String, Decimal> fxIndirectSum = new Map<String, Decimal>();
        Map<String, Decimal> commSum = new Map<String, Decimal>();
        Map<String, Decimal> irrmSum = new Map<String, Decimal>();
        Map<String, Decimal> retailSum = new Map<String, Decimal>();
        Map<String, String> bcMap = new Map<String, String>();
        Map<String, String> rmMap = new Map<String, String>();
        
        Map<String, List<String>> groupMapfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapinfx = new Map<String, List<String>>();
        Map<String, List<String>> groupMapcomm = new Map<String, List<String>>();
        Map<String, List<String>> groupMapirrm = new Map<String, List<String>>();
        Map<String, List<String>> groupMapretail = new Map<String, List<String>>();
        
        
        Set<String> outerKeySet = new Set<String>();
        Set<String> innerKeySet = new Set<String>();
        
        Set<String> groupSet = new Set<String>();
        
        Set<String> combineIdSet = new Set<String>();
        List<String> fxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
            List<String> fxindirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> commActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> irrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> retailActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            
                        Map<String, Decimal> pipeLine = new Map<String, Decimal>();
        
        Map<String, Decimal> pipeLineTot = new Map<String, Decimal>();
        
        //RepositoryBatch obj = new RepositoryBatch();
        //  Database.executeBatch(obj);
        //List<Repository__c> resList = [SELECT Rep_Month__c FROM Repository__c];
        
        
        /*
        AggregateResult[] orr = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                 Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name bus, Account.RM_Name__r.Con_Team__r.Name rm
                                 FROM Opportunity
                                 WHERE (StageName != 'Closed Lost' OR StageName != 'Closed Won') AND
                                 CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                 GROUP BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, Account.RM_Name__r.Con_Team__r.Name
                                 ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name, Account.RM_Name__r.Con_Team__r.Name];
        AggregateResult[] orrtot = [SELECT COUNT(Id) co, SUM(Amount)ammo, 
                                    Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name bus
                                    FROM Opportunity
                                    WHERE (StageName != 'Closed Lost' OR StageName != 'Closed Won') AND 
                                    CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                    GROUP BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name
                                    ORDER BY Account.RM_Name__r.Con_Team__r.Team_Centre__r.Centre_Region__r.Name];
        
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
*/
               
        id scotlandBHoursId;
        id englandBhoursId;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.today(), fyStartMonth);
        //Date startDate = date.newInstance(2018, 10, 01) ;
        Datetime endDate;            
        Date fyEndDate = CYBGUtilClass.findEndDateOfFY(System.today(), fyStartMonth);
        Long scotDays;
        Long engDays;
        Long scotTotDays;
        Long engTotDays;
        
       endDate = System.Now();
       // endDate=date.newInstance(2019, 09, 30);
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
        
        
        /*AggregateResult[] arrRetail = [SELECT Count(Id) co, SUM(Amount) amt, Calendar_Month(CloseDate) cd, Account.Branch__c br FROM Opportunity 
                         WHERE Amount != 0 AND CloseDate > 2018-09-30 AND CloseDate <= 2019-09-30 AND Owner.Name = 'Retail FRSM'
                        GROUP BY Account.Branch__c, Calendar_Month(CloseDate)
                        ORDER BY Account.Branch__c, Calendar_Month(CloseDate)];
          */  
        for(Opportunity each : [SELECT Id, Amount, 
                                Account.RM_Name__r.Con_Region__c, Account.RM_Name__r.Con_Division__c, Opp_CorpCode__c
                                FROM Opportunity
                                WHERE StageName NOT IN (:System.Label.ClosedLost,:System.Label.ClosedWon) AND 
                                CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND
                                RecordType.Name NOT IN (:System.Label.RecordTypeVanilaFX, :System.Label.RecordTypeCRMBusinessLoan, :System.Label.RecordTypeFXCash)
                                ORDER BY Account.RM_Name__r.Con_Division__c, Account.RM_Name__r.Con_Region__c])
        {
            System.debug('MM Oppty PIPE'+each.Account.RM_Name__r.Con_Region__c);
            System.debug('MM Oppty PIPE'+each.Amount);
            String outerGrp;
            String innerGrp;
            
            if(each.Account.RM_Name__r.Con_Division__c != null && each.Account.RM_Name__r.Con_Region__c != null)
            {
                outerGrp = each.Account.RM_Name__r.Con_Division__c;
                innerGrp = each.Account.RM_Name__r.Con_Region__c;
            }
            else
            {
                if(each.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                {
                    outerGrp = System.Label.Retail_Group;
                    innerGrp = System.Label.Retail_Division;
                }
                else if(each.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                {
                    outerGrp = System.Label.YB_Retail_Group;
                    innerGrp = System.Label.YB_Retail_Division;
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
        AggregateResult[] arr = [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, SUM(Rep_RetailActual__c)retail,
                                 Rep_GroupName__c combine, Rep_MonthText__c mon
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 //WHERE CreatedDate=today
                                 AND RecordType.Name = 'GroupAndDivision'
                                 GROUP BY Rep_GroupName__c, Rep_MonthText__c
                                ORDER BY Rep_GroupName__c, Rep_MonthText__c];
        List<String> ofxDirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
            List<String> ofxindirectActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> ocommActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> oirrmActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> oretailActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        
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
                                oretailActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                    
                                    if(each.get('fxDirect') != null)
                                    ofxDirectActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxDirect'));
                if(each.get('fxIndirect') != null)
                    ofxindirectActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('fxIndirect'));
                if(each.get('comm') != null)
                    ocommActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('comm'));
                if(each.get('irrm') != null)
                    oirrmActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('irrm'));
                if(each.get('retail') != null)
                    oretailActualList[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('retail'));

                groupMapfx.put(keys, ofxDirectActualList);
                groupMapinfx.put(keys, ofxindirectActualList);
                groupMapcomm.put(keys, ocommActualList);
                groupMapirrm.put(keys, oirrmActualList);
                groupMapretail.put(keys, oretailActualList);
                       
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
                if(each.get('retail') != null)
                    groupMapretail.get(keys)[Integer.valueOf(((String)each.get('mon')))] = String.valueOf(each.get('retail'));
                
                groupMapfx.put(keys, ofxDirectActualList);
                groupMapinfx.put(keys, ofxindirectActualList);
                groupMapcomm.put(keys, ocommActualList);
                groupMapirrm.put(keys, oirrmActualList);
                groupMapretail.put(keys, oretailActualList);
                
            }
            
            /*if(each.get('fxIndirect') != null)
ofxindirectActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('fxIndirect'));
if(each.get('comm') != null)
ocommActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('comm'));
if(each.get('irrm') != null)
oirrmActualList[Integer.valueOf(((String)each.get('combine')).split(',')[2])] = String.valueOf(each.get('irrm'));
*/
            if((Integer)each.get('co') >= 1)
            {
                if((String)each.get('combine') != null)
                    groupSet.add(((String)each.get('combine')).split(',')[0]);
                else
                {
                    groupSet.add(System.Label.Retail_Group);
                    groupSet.add(System.Label.YB_Retail_Group);
                }
                
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
        Decimal retailSumm = 0.00;
        Map<String, Decimal> indirectSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> directSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> commSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> irrmSumMMap = new Map<String, Decimal>();
        Map<String, Decimal> retailSumMMap = new Map<String, Decimal>();
        AggregateResult[] insideSum= [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, SUM(Rep_RetailActual__c)retail,
                                 Rep_CombineId__c combine, Rep_MonthText__c mon
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 //WHERE CreatedDate=today
                                 AND RecordType.Name = 'GroupAndDivision'
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
            System.debug('JJ each Rec retail'+eachRec.get('retail'));
            System.debug('JJ retailMap.containsKey(keys)'+retailMap.containsKey(keys));
             if(retailMap.containsKey(keys) && eachRec.get('retail') != null)
            {
               
                retailMap.get(keys)[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('retail'));
                retailMap.put(keys, retailActualList);

            }
            else if(eachRec.get('retail') != null)
            {
                retailActualList = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                retailActualList[Integer.valueOf((String)eachRec.get('mon'))] = String.valueOf((Decimal)eachRec.get('retail'));
                retailMap.put(keys, retailActualList);

            }
            System.debug('JJ Retail Map After'+retailMap.get(keys));
        }
        String mapQuery = 'SELECT '+
            'Region_Division__r.Name, Name '+
            'FROM Region__c '+
            'ORDER BY Region_Division__r.Name, Name, CreatedDate';
        for(Region__c eachID :  Database.query(mapQuery))
        {
            outerKey = (String)eachID.Region_Division__r.Name ;
            innerKey = (String)eachID.Name;
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            
            
            bcMap.put(keys, (String)eachID.Region_Division__r.Name);
            rmMap.put(keys, (String)eachID.Name);
            
        }
        
        AggregateResult[] insideSumtot= [SELECT COUNT(Id) co, SUM(Rep_FXDirectActual__c)fxDirect, SUM(Rep_FXIndirectActual__c)fxIndirect,
                                 SUM(Rep_CommodityActual__c)comm, SUM(Rep_IRRMActual__c)irrm, SUM(Rep_RetailActual__c)retail,
                                    Rep_GroupName__c combine, Rep_DivisionName__c tsm
                                 FROM Repository__c
                                 WHERE CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                                 //WHERE CreatedDate=today
                                 AND RecordType.Name = 'GroupAndDivision'
                                 GROUP BY Rep_GroupName__c, Rep_DivisionName__c
                                ORDER BY Rep_GroupName__c, Rep_DivisionName__c];
        for(AggregateResult eachRec : insideSumtot)
        {
            outerKey = (String)eachRec.get('combine');
            innerKey = (String)eachRec.get('tsm');
            keys = outerKey+innerKey;
            combineIdSet.add(keys);
            outerKeySet.add(outerKey);
            innerKeySet.add(innerKey);
            System.debug('JJ'+keys);
            bcMap.put(keys, (String)eachRec.get('combine'));
            rmMap.put(keys, (String)eachRec.get('tsm'));
            
            keys = ((String)eachRec.get('combine')) + ((String)eachRec.get('tsm'));
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
            
            
            if(retailSum.containsKey(keys) && eachRec.get('retail') != null)
            {
                retailSum.put(keys, (Decimal)eachRec.get('retail') + retailSum.get(keys));
            }
            else if(eachRec.get('retail') != null)
            {
                retailSum.put(keys, (Decimal)eachRec.get('retail'));
            }
        }
        wrapDataList = [SELECT Rep_CombineId__c, Rep_Month__c, 
                        Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_DivisionName__c,
                        Rep_GroupName__c, Rep_RetailActual__c,
                        Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c
                        WHERE (Rep_FXDirectActual__c != null oR Rep_FXIndirectActual__c != null OR 
                        Rep_CommodityActual__c != null OR Rep_IRRMActual__c != null OR Rep_RetailActual__c != null) AND 
                       CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate
                       //CreatedDate=today
                        AND RecordType.Name = 'GroupAndDivision'
                        ORDER BY Rep_CombineId__c];
        
        
        
            //copy 
            
        String TSMQuery1 = 'SELECT Region_FXDirectTarget__c, Region_FXIndirectTarget__c, '+
            'Region_CommTarget__c, Region_IRRMTarget__c, Region_FXRetail__c, '+
            'Region_Division__r.Name, Name '+
            'FROM Region__c '+
            'ORDER BY Region_Division__r.Name, Name, CreatedDate';
        
        for(Region__c eachID :  Database.query(TSMQuery1))
        {
            String combineID = (String)eachID.Region_Division__r.Name + (String)eachID.Name;

            combineIdSet.add(combineID);
            
            fxDirectTargetTillDateMap.put(combineID, eachID.Region_FXDirectTarget__c.setScale(2));
            fxInDirectTargetTillDateMap.put(combineID, eachID.Region_FXIndirectTarget__c.setScale(2));

            commTargetTillDateMap.put(combineID, eachID.Region_CommTarget__c.setScale(2));
            irrmTargetTillDateMap.put(combineID, eachID.Region_IRRMTarget__c.setScale(2));
            retailTargetTillDateMap.put(combineID, eachID.Region_FXRetail__c.setScale(2));
            
            fxDirectTargetMap.put(combineID, eachID.Region_FXDirectTarget__c);
            fxInDirectTargetMap.put(combineID, eachID.Region_FXIndirectTarget__c);

            commTargetMap.put(combineID, eachID.Region_CommTarget__c);
            irrmTargetMap.put(combineID, eachID.Region_IRRMTarget__c);
            retailTargetMap.put(combineID, eachID.Region_FXRetail__c);
        }
        System.debug('fxDirectTargetTillDateMap'+fxDirectTargetTillDateMap);
        
        /*copy*/
        String oldValue = '';
        Decimal sumifxDirectTargetTD = 0.00;
           Decimal sumifxInDirectTargetTD = 0.00;
           Decimal sumiirrmTargetTD = 0.00;
           Decimal sumicommTargetTD = 0.00;
        Decimal sumiretailTargetTD = 0.00;
        
        Map<String, Decimal> ifxDirectTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> ifxInDirectTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> iirrmTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> icommTargetTDMap = new Map<String, Decimal>();
        Map<String, Decimal> iretailTargetTDMap = new Map<String, Decimal>();
        
        for(AggregateResult agr : [SELECT SUM(Div_FXDirectTarget__c) fxDirectTar, SUM(Div_FXIndirectTarget__c)fxIndirectTar, 
                                   SUM(Div_CommTarget__c)commTar, SUM(Div_IRRMTarget__c)irrmTar, SUM(Div_FXRetail__c)retailTar, 
                                   Name team
                                   FROM Division__c 
                                   GROUP BY Name
                                   ORDER BY Name])
        {
            if(oldValue != (String)agr.get('team'))
            {
                oldValue = (String)agr.get('team');
                
                sumifxDirectTargetTD = 0.00;
                sumifxInDirectTargetTD = 0.00;
                sumiirrmTargetTD = 0.00;
                sumicommTargetTD = 0.00;
                sumiretailTargetTD = 0.00;
                
            }
            System.debug('TEAM>>>>>>>>>>>>>>'+agr.get('team'));
            System.debug('TEAM>>>>>>>>>>>>>>'+agr);
            sumifxDirectTargetTD = sumifxDirectTargetTD + (Decimal)agr.get('fxDirectTar');
            sumifxInDirectTargetTD = sumifxInDirectTargetTD + (Decimal)agr.get('fxIndirectTar');
            sumiirrmTargetTD = sumiirrmTargetTD + (Decimal)agr.get('irrmTar');
            sumicommTargetTD = sumicommTargetTD + (Decimal)agr.get('commTar');
            sumiretailTargetTD = sumiretailTargetTD + (Decimal)agr.get('retailTar');
            
            ifxDirectTargetTDMap.put((String)agr.get('team'), sumifxDirectTargetTD);
            ifxInDirectTargetTDMap.put((String)agr.get('team'), sumifxInDirectTargetTD);
            iirrmTargetTDMap.put((String)agr.get('team'), sumiirrmTargetTD);
            icommTargetTDMap.put((String)agr.get('team'), sumicommTargetTD);
            iretailTargetTDMap.put((String)agr.get('team'), sumiretailTargetTD);
            
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
             Decimal retailtot = 0.00;
            Decimal actYtdTot = 0.00;
             Decimal ifxDirectVariance = 0.00;
                Decimal ifxInDirectVariance = 0.00;
                Decimal icommVariance = 0.00;
                Decimal iirrmVariance = 0.00;
                Decimal iretailVariance = 0.00;
            List<Decimal> itargetsTillDate = new List<Decimal>{0.00,0.00,0.00,0.00,0.00};
               List<String> ifxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> iinfxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> icommact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> iirrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                List<String> iretailact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
      
            List<String> iactTot = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
      
            if((Decimal)pipeLineTot.get(out) != null)
                pipeTt = (Decimal)pipeLineTot.get(out);
            for(String inn : innerKeySet)
            {
                Decimal fxDirectVariance = 0.00;
                Decimal fxInDirectVariance = 0.00;
                Decimal commVariance = 0.00;
                Decimal irrmVariance = 0.00;
                Decimal retailVariance = 0.00;
                
                targetsTillDate = new List<Decimal>{0.00,0.00,0.00,0.00,0.00};

                keysin = out + inn;

                List<String> fxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    List<String> infxact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> commact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> irrmact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                List<String> retailact = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                     
                List<String> actTot = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                 
                if(combineIdSet.contains(keysin))
                {
                    System.debug('keysin JJ'+keysin);
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
                    if(retailSum.get(keysin) != null)
                        retailtot = retailtot + retailSum.get(keysin);
                    
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
                    if(retailMap.get(keysin) != null)
                    {
                        retailact = retailMap.get(keysin);
                    }
                    System.debug('Retail Act JJ'+retailMap.get(keysin));
                    if((Decimal)fxDirectTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[0] = (((Decimal)fxDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays).setScale(2);
                    if((Decimal)fxInDirectTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[1] = (((Decimal)fxInDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays).setScale(2);
                    if((Decimal)commTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[2] = (((Decimal)commTargetTillDateMap.get(keysin)/engTotDays)*engDays).setScale(2);
                    if((Decimal)irrmTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[3] = (((Decimal)irrmTargetTillDateMap.get(keysin)/engTotDays)*engDays).setScale(2);
                    if((Decimal)retailTargetTillDateMap.get(keysin) != null)
                    targetsTillDate[4] = (((Decimal)retailTargetTillDateMap.get(keysin)/engTotDays)*engDays).setScale(2);
                    System.debug('Targets Till Date JJ'+targetsTillDate[4]);
                    
                                    
                                        fxDirectVariance = ((((Decimal)fxDirectSum.get(keysin) == null ? 0.00 : (Decimal)fxDirectSum.get(keysin))
                                                             - ((Decimal)fxDirectTargetTillDateMap.get(keysin) == null ? 0.00 : ((Decimal)fxDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays))).setScale(2);
                                    
                                        fxInDirectVariance = ((((Decimal)fxIndirectSum.get(keysin) == null ? 0.00 : (Decimal)fxIndirectSum.get(keysin))
                                                               - ((Decimal)fxInDirectTargetTillDateMap.get(keysin) == null ? 0.00 : ((Decimal)fxInDirectTargetTillDateMap.get(keysin)/engTotDays)*engDays))).setScale(2);
                                    
                                        commVariance = ((((Decimal)commSum.get(keysin) == null ? 0.00 : (Decimal)commSum.get(keysin))
                                                         - ((Decimal)commTargetTillDateMap.get(keysin) == null ? 0.00 : ((Decimal)commTargetTillDateMap.get(keysin)/engTotDays)*engDays))).setScale(2);
                                   
                                        irrmVariance = ((((Decimal)irrmSum.get(keysin) == null ? 0.00 : (Decimal)irrmSum.get(keysin))
                                                         - ((Decimal)irrmTargetTillDateMap.get(keysin) == null ? 0.00 : ((Decimal)irrmTargetTillDateMap.get(keysin)/engTotDays)*engDays))).setScale(2);
                                        
                                        retailVariance = ((((Decimal)retailSum.get(keysin) == null ? 0.00 : (Decimal)retailSum.get(keysin))
                                                         - ((Decimal)retailTargetTillDateMap.get(keysin) == null ? 0.00 : ((Decimal)retailTargetTillDateMap.get(keysin)/engTotDays)*engDays))).setScale(2);
                                   
                    
                    System.debug(' IN fxDirectTargetTillDateMap'+fxDirectTargetTillDateMap);
                    System.debug(' IN targetsTillDate'+targetsTillDate);
                    
                    Decimal fxdVariancePercent = 0;
                    Decimal fxindVariancePercent = 0;
                    Decimal commVariancePercent = 0;
                    Decimal irrmVariancePercent = 0;
                    Decimal retailVariancePercent = 0;
                    
                    if((Decimal)targetsTillDate[0] != 0 && (Decimal)fxDirectSum.get(keysin) != null)
                    fxdVariancePercent = (((Decimal)fxDirectSum.get(keysin)/(Decimal)targetsTillDate[0])*100).setScale(0);
                    if((Decimal)targetsTillDate[1] != 0 && (Decimal)fxIndirectSum.get(keysin) != null)
                    fxindVariancePercent = (((Decimal)fxIndirectSum.get(keysin)/(Decimal)targetsTillDate[1])*100).setScale(0);
                    if((Decimal)targetsTillDate[2] != 0 && (Decimal)commSum.get(keysin) != null)
                    commVariancePercent = (((Decimal)commSum.get(keysin)/(Decimal)targetsTillDate[2])*100).setScale(0);
                    if((Decimal)targetsTillDate[3] != 0 && (Decimal)irrmSum.get(keysin) != null)
                    irrmVariancePercent = (((Decimal)irrmSum.get(keysin)/(Decimal)targetsTillDate[3])*100).setScale(0);
                    if((Decimal)targetsTillDate[4] != 0 && (Decimal)retailSum.get(keysin) != null)
                    retailVariancePercent = (((Decimal)retailSum.get(keysin)/(Decimal)targetsTillDate[4])*100).setScale(0);
                        
                    
                    for(Integer i=0; i < 13; i++)
                    {
                        actTot[i] = String.valueOf(Decimal.valueOf(fxact[i]) + Decimal.valueOf(infxact[i]) + Decimal.valueOf(commact[i]) + Decimal.valueOf(irrmact[i]) + Decimal.valueOf(retailact[i]));
                        System.debug('JJ Retail After'+Decimal.valueOf(actTot[i]));
                    }
                    
                    Decimal fxSumTot = 0.00;
                    Decimal infxSumTot = 0.00;
                    Decimal commSumTot = 0.00;
                    Decimal irrmSumTot = 0.00;
                    Decimal retailSumTot = 0.00;
                    
                    if(fxDirectSum.get(keysin) != null)
                        fxSumTot = fxDirectSum.get(keysin);
                    if(fxIndirectSum.get(keysin) != null)
                        infxSumTot = fxIndirectSum.get(keysin);
                    if(commSum.get(keysin) != null)
                        commSumTot = commSum.get(keysin);
                    if(irrmSum.get(keysin) != null)
                        irrmSumTot = irrmSum.get(keysin);
                    if(retailSum.get(keysin) != null)
                        retailSumTot = retailSum.get(keysin);
                    
                    
                    actYtdTot = fxSumTot + infxSumTot + commSumTot + irrmSumTot + retailSumTot;
                    
                    Decimal ytdTarTot = targetsTillDate[0] + targetsTillDate[1] + targetsTillDate[2] + targetsTillDate[3] + targetsTillDate[4];
                    Decimal var = actYtdTot - ytdTarTot;
                     Decimal varPer = 0;
                    if(ytdTarTot != 0)
                    varPer = ((actYtdTot / ytdTarTot) * 100).setScale(0);
                    
                    if(out != null && inn != null)
                    {
                    wrappedDataList.add(new WrapperClass(bcMap.get(keysin), rmMap.get(keysin), (String[])descriptionList, fxact, infxact,
                                                         commact, irrmact, retailact, fxDirectSum.get(keysin), fxIndirectSum.get(keysin),
                                                         commSum.get(keysin), irrmSum.get(keysin), retailSum.get(keysin), (Decimal[])targetsTillDate, 
                                                         (Decimal)fxDirectVariance,(Decimal)fxInDirectVariance,
                                                         (Decimal)commVariance,(Decimal)irrmVariance,(Decimal)retailVariance,
                                                         fxdVariancePercent,fxindVariancePercent,
                                                         commVariancePercent,irrmVariancePercent,retailVariancePercent,
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
                    if(groupMapretail.get(out) != null)
                    {
                        iretailact = groupMapretail.get(out);
                    }
                
                if((Decimal)ifxDirectTargetTDMap.get(out) != null)
                itargetsTillDate[0] = (((Decimal)(ifxDirectTargetTDMap.get(out)/engTotDays)*engDays).setScale(2));
                if((Decimal)ifxInDirectTargetTDMap.get(out) != null)
                itargetsTillDate[1] = (((Decimal)(ifxInDirectTargetTDMap.get(out)/engTotDays)*engDays).setScale(2));
                if((Decimal)icommTargetTDMap.get(out) != null)
                itargetsTillDate[2] = (((Decimal)(icommTargetTDMap.get(out)/engTotDays)*engDays).setScale(2));
                if((Decimal)iirrmTargetTDMap.get(out) != null)
                itargetsTillDate[3] = (((Decimal)(iirrmTargetTDMap.get(out)/engTotDays)*engDays).setScale(2));
                if((Decimal)iretailTargetTDMap.get(out) != null)
                itargetsTillDate[4] = (((Decimal)(iretailTargetTDMap.get(out)/engTotDays)*engDays).setScale(2));
                   System.debug('Targets Till Date JJ'+itargetsTillDate[4]);
                
               
                                        ifxDirectVariance = (((Decimal)fxtot
                                                             - (Decimal)itargetsTillDate[0])).setScale(2);
                                   
                                        ifxInDirectVariance = (((Decimal)infxtot
                                                               - (Decimal)itargetsTillDate[1])).setScale(2);
                                    
                                        icommVariance = (((Decimal)commtot
                                                         - (Decimal)itargetsTillDate[2])).setScale(2);
                                   
                                        iirrmVariance = (((Decimal)irrmtot
                                                         - (Decimal)itargetsTillDate[3])).setScale(2);
                
                                        iretailVariance = (((Decimal)retailtot
                                                         - (Decimal)itargetsTillDate[4])).setScale(2);
                                   
                Decimal ifxdVariancePercent = 0;
                    Decimal ifxindVariancePercent = 0;
                    Decimal icommVariancePercent = 0;
                    Decimal iirrmVariancePercent = 0;
                Decimal iretailVariancePercent = 0;
                    
                if((Decimal)itargetsTillDate[0] != 0)
                    ifxdVariancePercent = (((Decimal)fxtot/(Decimal)itargetsTillDate[0])*100).setScale(0);
                if((Decimal)itargetsTillDate[1] != 0)
                    ifxindVariancePercent = (((Decimal)infxtot/(Decimal)itargetsTillDate[1])*100).setScale(0);
                if((Decimal)itargetsTillDate[2] != 0)
                    icommVariancePercent = (((Decimal)commtot/(Decimal)itargetsTillDate[2])*100).setScale(0);
                if((Decimal)itargetsTillDate[3] != 0)
                    iirrmVariancePercent = (((Decimal)irrmtot/(Decimal)itargetsTillDate[3])*100).setScale(0);
                if((Decimal)itargetsTillDate[4] != 0)
                    iretailVariancePercent = (((Decimal)retailtot/(Decimal)itargetsTillDate[4])*100).setScale(0);
                
                for(Integer i=0; i < 13; i++)
                {
                    iactTot[i] = String.valueOf(Decimal.valueOf(ifxact[i]) + Decimal.valueOf(iinfxact[i]) + Decimal.valueOf(icommact[i]) + Decimal.valueOf(iirrmact[i]) + Decimal.valueOf(iretailact[i]));
                }
                System.debug('YY'+itargetsTillDate[4]);
                iactYtdTot = fxtot + infxtot + commtot + irrmtot + retailtot; 
                Decimal iytdTarTot = itargetsTillDate[0] + itargetsTillDate[1] + itargetsTillDate[2] + itargetsTillDate[3] + itargetsTillDate[4];
                Decimal ivar = iactYtdTot - iytdTarTot;
                Decimal ivarPer = 0;
                if(iytdTarTot != 0)
                    ivarPer = ((iactYtdTot / iytdTarTot) * 100).setScale(0);
                
                if(out != null)
                    {
                wrappedDataList.add(new WrapperClass('Subtotal '+out, '', (String[])descriptionList, ifxact, iinfxact,
                                                     icommact, iirrmact,iretailact, fxtot, infxtot,
                                                     commtot, irrmtot,  retailtot, (Decimal[])itargetsTillDate, 
                                                     ifxDirectVariance, ifxInDirectVariance, 
                                                     icommVariance, iirrmVariance, iretailVariance, 
                                                     ifxdVariancePercent, ifxindVariancePercent, 
                                                     icommVariancePercent, iirrmVariancePercent, iretailVariancePercent, (Decimal)pipeTt, (String[])iactTot, (Decimal)iactYtdTot,
                                                    (Decimal)iytdTarTot, (Decimal)ivar, (Decimal)ivarPer));
                    }
            }
        }
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceGroupDld');
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
    public PageReference downloadReport_FRS() {
        PageReference nextpage = new PageReference('/apex/ytdPerformanceGroup_FRS_Dld');
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
        Public String[] retailActual {get; set;}
        Public Decimal fxDirectActualsTillDate {get; set;}
        Public Decimal fxInDirectActualsTillDate {get; set;}
        Public Decimal commActualsTillDate {get; set;}
        Public Decimal irrmActualsTillDate {get; set;}
        Public Decimal retailActualsTillDate {get; set;}
        Public Decimal ytdPipeLine {get; set;}
        Public Decimal[] targetsTillDate {get; set;}
        Public Decimal fxvariance {get; set;}
        Public Decimal infxvariance {get; set;}
        Public Decimal commvariance {get; set;}
        Public Decimal irrmvariance {get; set;}
        Public Decimal retailvariance {get; set;}
        Public Decimal fxvariancePercent {get; set;}
        Public Decimal infxvariancePercent {get; set;}
        Public Decimal commvariancePercent {get; set;}
        Public Decimal irrmvariancePercent {get; set;}
        Public Decimal retailvariancePercent {get; set;}
        Public String[] actTot {get; set;}
        Public Decimal actYtdTot {get; set;}
        Public Decimal ytdTarTot {get; set;}
        Public Decimal var {get; set;}
        Public Decimal varPer {get; set;}
        
        /* Public Boolean groupIt {get; set;}*/
        Public WrapperClass(String bc, String frsm, List<String>descriptionList, List<String> FXDirectActual, List<String> FXIndirectActual,
                            List<String> CommActual, List<String> IRRMActual, List<String> retailActual, Decimal fxDirectActualsTillDate,
                            Decimal fxInDirectActualsTillDate, Decimal commActualsTillDate, Decimal irrmActualsTillDate, Decimal retailActualsTillDate,
                            List<Decimal> targetsTillDate, Decimal fxvariance, Decimal infxvariance,
                            Decimal commvariance, Decimal irrmvariance, Decimal retailVariance,
                             Decimal fxvariancePercent, Decimal infxvariancePercent,
                            Decimal commvariancePercent, Decimal irrmvariancePercent, Decimal retailvariancePercent,
                            Decimal ytdPipeLine, List<String> actTot, Decimal actYtdTot, Decimal ytdTarTot, Decimal var, Decimal varPer)
        {
            
            
            this.bc = bc; 
            this.frsm =  frsm;
            this.descriptionList = descriptionList;
            this.FXDirectActual = FXDirectActual;
            
            this.FXIndirectActual = FXIndirectActual;
            
            this.CommActual = CommActual;
            
            this.IRRMActual = IRRMActual;
            this.retailActual = retailActual;
            this.fxDirectActualsTillDate = fxDirectActualsTillDate;
            this.fxInDirectActualsTillDate = fxInDirectActualsTillDate;
            this.commActualsTillDate = commActualsTillDate;
            this.irrmActualsTillDate = irrmActualsTillDate;
            this.retailActualsTillDate = retailActualsTillDate;
            this.ytdPipeLine = ytdPipeLine;
            this.targetsTillDate = targetsTillDate;
            this.fxvariance = fxvariance;
            this.infxvariance = infxvariance;
            this.commvariance = commvariance;
            this.irrmvariance = irrmvariance;
            this.retailvariance = retailvariance;
            this.fxvariancePercent = fxvariancePercent;
            this.infxvariancePercent = infxvariancePercent;
            this.commvariancePercent = commvariancePercent;
            this.irrmvariancePercent = irrmvariancePercent;
            this.retailvariancePercent = retailvariancePercent;
            this.actTot = actTot;
            this.actYtdTot = actYtdTot;
            this.ytdTarTot = ytdTarTot;
            this.var = var;
            this.varPer = varPer;
        }
    }
}