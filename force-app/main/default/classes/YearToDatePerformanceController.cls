public class YearToDatePerformanceController {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Date pfyStartDate;
    Date pfyEndDate;
    
    Boolean grouper = false;
    Integer counter = 0;

    String oldValue = '';
    String SetQuery = '';
    String JournalQuery = '';
    String TSMQuery = '';
    Public List<WrapperClass> wrappedDataList{get; set;}
    
    Public Set<ID> innerSet = new Set<ID>();
    Public Set<ID> outerSet = new Set<ID>();
    Public Set<String> combineIdSet = new Set<String>();
    Public Set<String> combineIdMonthSet = new Set<String>();
    
    Public Map<String, Decimal> totalPipeLineMap= new Map<String, Decimal>();
    
    Public Map<String, String> outerMap= new Map<String, String>();
    Public Map<String, String> innerMap= new Map<String, String>();
    
    Public Map<String, Decimal> fxDirectTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetTillDateMap= new Map<String, Decimal>();

    Public Map<String, Decimal> commTargetTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetTillDateMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectActualTillDateMap= new Map<String, Decimal>();

    Public Map<String, Decimal> commActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmActualTillDateMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectActualMap= new Map<String, Decimal>();

    Public Map<String, Decimal> commActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmActualMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetMap= new Map<String, Decimal>();

    Public Map<String, Decimal> commTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetMap= new Map<String, Decimal>();
    
    
    Public Map<String, Decimal> ifxDirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualMap= new Map<String, Decimal>();

    Public Map<String, Decimal> icommActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> ifxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectTargetMap= new Map<String, Decimal>();

    Public Map<String, Decimal> icommTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmTargetMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> ifxDirectTargetTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectTargetTDMap= new Map<String, Decimal>();

    Public Map<String, Decimal> icommTargetTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmTargetTDMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> ifxDirectActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualTDMap= new Map<String, Decimal>();

    Public Map<String, Decimal> icommActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualTDMap= new Map<String, Decimal>();
   
    Public Map<String, String> TeamNameMap= new Map<String, String>();
    Public Set<String> jliListSet = new Set<String>();
    Public Map<String, Decimal> oppMap= new Map<String, Decimal>();
    
    
    Public List<String> descriptionList = new List<String>{'Sum of FX Direct Target', 'Sum of FX Direct Actual', 'Sum of FX Indirect Target', 'Sum of FX Indirect Actual',
        'Sum of Commodity Target', 'Sum of Commodity Actual',
        'Sum of IRRM Target', 'Sum of IRRM Actual'};
            
            //List<T> fullList = new List<T>();
            
            public YearToDatePerformanceController(){
                wrappedDataList = new List<WrapperClass>();
                
                fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
                fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
                fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
                pfyStartDate = Date.newInstance(fyStartDate.year()-1, fyStartMonth, 1);
                pfyEndDate = Date.newInstance(fyEndDate.year()-1, fyEndDate.month(), Date.daysInMonth(fyEndDate.year()-1 , fyEndDate.month()));
                fetchData();
            }
    
    Public void fetchData(){
        Decimal sumfxDirectActuals = 0;
        Decimal sumfxIndirectActuals = 0;
        Decimal sumretailActuals = 0;

        Decimal sumcommActuals = 0;
        Decimal sumirrmActuals = 0;
        Decimal sumfxDirectTargets = 0;
        Decimal sumfxIndirectTargets = 0;
        Decimal sumretailTargets = 0;
        Decimal sumcommTargets = 0;
        Decimal sumirrmTargets = 0;
        
        Decimal indirectSum = 0.00;
        Decimal directSum = 0.00;
        Decimal commSum = 0.00;
        Decimal irrmSum = 0.00;
        
        Decimal sumifxDirectTargets = 0.00;
        Decimal sumifxIndirectTargets = 0.00;
        Decimal sumicommTargets = 0.00;
        Decimal sumiirrmTargets = 0.00;
        Decimal sumifxDirectTargetTD = 0.00;
        Decimal sumifxInDirectTargetTD = 0.00;
        Decimal sumiirrmTargetTD = 0.00;
        Decimal sumicommTargetTD = 0.00;
        
        Decimal sumifxDirectActualTD = 0.00;
        Decimal sumifxInDirectActualTD = 0.00;
        Decimal sumiirrmActualTD = 0.00;
        Decimal sumicommActualTD = 0.00;
        Decimal totalPipeLine = 0.00;
        String OldValue2 = '';
        Decimal amountIn = 0.00;
        
        SetQuery = 'SELECT TSMTar_TSM__c, TSMTar_Team__c FROM TSMTarget__c ORDER BY TSMTar_Team__c, TSMTar_TSM__c';
        
        
        for(TSMTarget__c eachID : Database.query(SetQuery))
        {
            innerSet.add(eachID.TSMTar_TSM__c);
            outerSet.add(eachID.TSMTar_Team__c);
        }
        for(AggregateResult jliList : [SELECT Journal_Team__c teamId, Journal_TeamName__c teamName, Journal_TSM__c tsm 
                                       FROM JournalLineItem__c
                                      WHERE Journal_Team__c IN :outerSet AND Journal_TSM__c IN :innerSet
                                       AND Journal_TSMTarget__c != null
                                      GROUP BY Journal_Team__c, Journal_TeamName__c, Journal_TSM__c])
        {
            jliListSet.add((String)jliList.get('tsm'));
            TeamNameMap.put((String)jliList.get('teamId'), (String)jliList.get('teamName'));
        }
        
        for(Opportunity oppList : [SELECT amount, OwnerId, Deal_Executed_By__r.Con_Team__c From Opportunity WHERE 
                                       CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName != 'Closed Won' AND StageName != 'Closed Lost' AND
                                   OwnerId IN :innerSet AND Deal_Executed_By__r.Con_Team__c IN :outerSet AND
                                       OwnerId IN :jliListSet
                                   
                                  ORDER BY Deal_Executed_By__r.Con_Team__c, OwnerId])
        {
            if(oldValue != (String)oppList.Deal_Executed_By__r.Con_Team__c)
            {
               oldValue = (String)oppList.Deal_Executed_By__r.Con_Team__c;
                totalPipeLine = 0.00;
            }
            if(oldValue2 != (String)oppList.OwnerId)
            {
                oldValue2 = (String)oppList.OwnerId;
                amountIn = 0.00;
            }
                
            amountIn = amountIn + oppList.amount;
            
            System.debug('amoutn'+amountIn);
                oppMap.put((String)oppList.OwnerId + (String)oppList.Deal_Executed_By__r.Con_Team__c, amountIn);
            System.debug('totalP'+oppMap);
            totalPipeLine = totalPipeLine + (Decimal)oppList.amount;
            totalPipeLineMap.put((String)oppList.Deal_Executed_By__r.Con_Team__c, totalPipeLine);
            System.debug('total'+totalPipeLine);
        }
        /*
        for(AggregateResult oppList : [SELECT Sum(Amount) amount, OwnerId owner, Deal_Executed_By__r.Con_Team__c team From Opportunity WHERE 
                                       CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName != 'Closed Won' AND StageName != 'Closed Lost' AND
                                       OwnerId IN :innerSet AND Deal_Executed_By__r.Con_Team__c IN :outerSet AND
                                       OwnerId IN :jliListSet 
                                       GROUP BY Deal_Executed_By__r.Con_Team__c, OwnerId
                                       ORDER BY Deal_Executed_By__r.Con_Team__c, OwnerId])
        {
            oppMap.put((String)oppList.get('owner')+(String)oppList.get('team'), (Decimal)oppList.get('amount'));
            if(oldValue != (String)oppList.get('team'))
            {
                oldValue = (String)oppList.get('team');
                totalPipeLine = 0.00;
            }
            
            totalPipeLine = totalPipeLine + (Decimal)oppList.get('amount');
            totalPipeLineMap.put((String)oppList.get('team'), totalPipeLine);
        }
        */
        System.debug('PipeLine'+oppMap);

        JournalQuery = 'SELECT ID, Journal_ProductFamily__c, Journal_Amount__c, Journal_IsQ6Available__c, '+
            'Journal_BranchNumber__c, Journal_CorpCode__c, Journal_TransactionType__c, '+
            'Journal_TSMName__c, Journal_TSMTarget__c, Journal_BankerName__c, '+
            'Journal_Team__c, Journal_TeamName__c, Journal_Centre__c, Journal_Region__c, '+ 
            'Journal_Division__c, Journal_Group__c, Journal_TSM__c, CreatedDate  '+
            'FROM JournalLineItem__c '+
            'WHERE Journal_TSM__c IN :innerSet AND Journal_TSMTarget__c != Null AND '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate '+
            'ORDER BY Journal_Team__c, Journal_TSM__c, CreatedDate';
        
        TSMQuery = 'SELECT TSMTar_FXDirectTargetTillDate__c, TSMTar_FXIndirectTargetTillDate__c, '+
            'TSMTar_CommTargetTillDate__c, TSMTar_IRRMTargetTillDate__c, '+
            'TSMTar_FXDirectTarget__c, TSMTar_FXIndirectTarget__c, '+
            'TSMTar_CommTarget__c, TSMTar_IRRMTarget__c, '+
            'TSMTar_TSM__c, TSMTar_Team__c '+
            'FROM TSMTarget__c WHERE TSMTar_TSM__c IN :innerSet AND TSMTar_Team__c IN :outerSet AND '+
			'TSMTar_TSM__c IN :jliListSet AND '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate ORDER BY TSMTar_Team__c, TSMTar_TSM__c, CreatedDate';
        
        oldValue = '';
        for(AggregateResult ags : [SELECT SUM(Journal_Amount__c) amount, Journal_Team__c teamId,
                                   Journal_TSMName__c tsm, Journal_IsQ6Available__c q6,
                                   Journal_TeamName__c teamName,  Journal_ProductFamily__c product, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c  brNum,
                                   calendar_month(CreatedDate) credMonth
                                   FROM JournalLineItem__c
                                   WHERE  Journal_Team__c IN :outerSet AND 
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                   GROUP BY Journal_Team__c, Journal_TeamName__c, Journal_TSMName__c, Journal_ProductFamily__c, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c, Journal_IsQ6Available__c, calendar_month(CreatedDate) 
                                   ORDER BY Journal_Team__c, calendar_month(CreatedDate)])
        {
           

          if(oldValue != (String)ags.get('teamId'))
            {
                oldValue = (String)ags.get('teamId');
                indirectSum = 0.00;
                directSum = 0.00;
                commSum = 0.00;
                irrmSum = 0.00;
            }
                if(ags.get('product') == 'FX Cash')	
                {
                    if(ags.get('brNum') == System.Label.CBDirectDealingClient || 
                       ags.get('brNum') == System.Label.YBDirectDealingClient)
                    {
                        if(ags.get('q6') == true)
                        {
                            //fxDirectActuals = fxDirectActuals + ags.get('amount');
                            directSum = directSum + (Decimal)ags.get('amount');
                            ifxDirectActualMap.put((String)ags.get('teamId') + ',' + String.valueOf(ags.get('credMonth')), directSum);
                        }
                    }
                    else if(ags.get('brNum') == System.Label.CBCardedRateSheet || ags.get('brNum') == System.Label.YBCardedRateSheet ||
                            ags.get('brNum') == System.Label.CBIndirect || ags.get('brNum') == System.Label.YBIndirect ||
                            ags.get('brNum') == System.Label.CBSortingCode || ags.get('brNum') == System.Label.YBSortingCode ||
                            ags.get('brNum') == System.Label.CBGeneric || ags.get('brNum') == System.Label.YBGeneric)
                    {
                        if(ags.get('q6') == true)
                        {
                            
                            //fxIndirectActuals = fxIndirectActuals + ags.get('amount');
                            indirectSum = indirectSum + (Decimal)ags.get('amount');
                            ifxInDirectActualMap.put((String)ags.get('teamId') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);

                        }
                        
                    }
                    else if(ags.get('brNum') == null )
                    {
                         indirectSum = indirectSum + (Decimal)ags.get('amount');
                        ifxInDirectActualMap.put((String)ags.get('teamId') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);
                    }
                }
                else if(ags.get('product') == 'Commodity')	
                {
					commSum = commSum + (Decimal)ags.get('amount');
                    icommActualMap.put((String)ags.get('teamId') + ',' + String.valueOf(ags.get('credMonth')), commSum);
                }
                
                else if(ags.get('product') == 'IRRM')	
                {
                    irrmSum = irrmSum + (Decimal)ags.get('amount');
                    iirrmActualMap.put((String)ags.get('teamId') + ',' + String.valueOf(ags.get('credMonth')), irrmSum);
                }
            
        }
        oldValue = '';
        for(AggregateResult agr : [SELECT SUM(TSMTar_FXDirectTarget__c) fxDirectTar, SUM(TSMTar_FXIndirectTarget__c)fxIndirectTar, 
                                   SUM(TSMTar_CommTarget__c)commTar, SUM(TSMTar_IRRMTarget__c)irrmTar, 
                                   SUM(TSMTar_FXDirectTargetTillDate__c)fxDirectTarTD, SUM(TSMTar_FXIndirectTargetTillDate__c)fxInDirectTarTD,
                                   SUM(TSMTar_CommTargetTillDate__c)commTarTD, SUM(TSMTar_IRRMTargetTillDate__c)irrmTarTD,
                                   SUM(TSMTar_FXDirectActual__c) fxDirectActTD, SUM(TSMTar_FXIndirectActual__c) fxInDirectActTD,
                                   SUM(TSMTar_CommActual__c)commActTD, SUM(TSMTar_IRRMActual__c)irrmActTD,
                                   TSMTar_Team__r.Name team, TSMTar_Team__c teamTar, calendar_month(CreatedDate) credMonth
                                   FROM TSMTarget__c 
                                   WHERE TSMTar_TSM__c IN :innerSet AND TSMTar_Team__c IN :outerSet AND 
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND
                                   TSMTar_TSM__c IN :jliListSet
                                   GROUP BY TSMTar_Team__r.Name, TSMTar_Team__c, calendar_month(CreatedDate) 
                                   ORDER BY TSMTar_Team__c, calendar_month(CreatedDate)])
        {
            if(oldValue != (String)agr.get('teamTar'))
            {
                oldValue = (String)agr.get('teamTar');
                sumifxDirectTargets = 0.00;
                sumifxInDirectTargets = 0.00;
                sumicommTargets = 0.00;
                sumiirrmTargets = 0.00;
                
                sumifxDirectTargetTD = 0.00;
                sumifxInDirectTargetTD = 0.00;
                sumiirrmTargetTD = 0.00;
                sumicommTargetTD = 0.00;
                
                sumifxDirectActualTD = 0.00;
                sumifxInDirectActualTD = 0.00;
                sumiirrmActualTD = 0.00;
                sumicommActualTD = 0.00;
            }
            sumifxDirectTargets = sumifxDirectTargets + (Decimal)agr.get('fxDirectTar');
            sumifxInDirectTargets = sumifxInDirectTargets + (Decimal)agr.get('fxIndirectTar');
            sumicommTargets = sumicommTargets + (Decimal)agr.get('commTar');
            sumiirrmTargets = sumiirrmTargets + (Decimal)agr.get('irrmTar');
            
            sumifxDirectTargetTD = sumifxDirectTargetTD + (Decimal)agr.get('fxDirectTarTD');
            sumifxInDirectTargetTD = sumifxInDirectTargetTD + (Decimal)agr.get('fxIndirectTarTD');
            sumiirrmTargetTD = sumiirrmTargetTD + (Decimal)agr.get('irrmTarTD');
            sumicommTargetTD = sumicommTargetTD + (Decimal)agr.get('commTarTD');
            
            sumifxDirectActualTD = sumifxDirectActualTD + (Decimal)agr.get('fxDirectActTD');
            sumifxInDirectActualTD = sumifxInDirectActualTD + (Decimal)agr.get('fxIndirectActTD');
            sumiirrmActualTD = sumiirrmActualTD + (Decimal)agr.get('irrmActTD');
            sumicommActualTD = sumicommActualTD + (Decimal)agr.get('commActTD');
                
            ifxDirectTargetMap.put((String)agr.get('teamTar'), sumifxDirectTargets);
            ifxInDirectTargetMap.put((String)agr.get('teamTar'), sumifxInDirectTargets);
            iirrmTargetMap.put((String)agr.get('teamTar'), sumiirrmTargets);
            icommTargetMap.put((String)agr.get('teamTar'), sumicommTargets);
            
            ifxDirectTargetTDMap.put((String)agr.get('teamTar'), sumifxDirectTargetTD);
            ifxInDirectTargetTDMap.put((String)agr.get('teamTar'), sumifxInDirectTargetTD);
            iirrmTargetTDMap.put((String)agr.get('teamTar'), sumiirrmTargetTD);
            icommTargetTDMap.put((String)agr.get('teamTar'), sumicommTargetTD);
            
            ifxDirectActualTDMap.put((String)agr.get('teamTar'), sumifxDirectActualTD);
            ifxInDirectActualTDMap.put((String)agr.get('teamTar'), sumifxInDirectActualTD);
            iirrmActualTDMap.put((String)agr.get('teamTar'), sumiirrmActualTD);
            icommActualTDMap.put((String)agr.get('teamTar'), sumicommActualTD);
            
     
        }
        
        for(TSMTarget__c eachID : Database.query(TSMQuery))
        {
            String combineID = (String)eachID.TSMTar_TSM__c + (String)eachID.TSMTar_Team__c;

            combineIdSet.add(combineID);
            
            fxDirectTargetTillDateMap.put(combineID, eachID.TSMTar_FXDirectTargetTillDate__c.setScale(2));
            fxInDirectTargetTillDateMap.put(combineID, eachID.TSMTar_FXIndirectTargetTillDate__c.setScale(2));

            commTargetTillDateMap.put(combineID, eachID.TSMTar_CommTargetTillDate__c.setScale(2));
            irrmTargetTillDateMap.put(combineID, eachID.TSMTar_IRRMTargetTillDate__c.setScale(2));
            
            fxDirectTargetMap.put(combineID, eachID.TSMTar_FXDirectTarget__c);
            fxInDirectTargetMap.put(combineID, eachID.TSMTar_FXIndirectTarget__c);

            commTargetMap.put(combineID, eachID.TSMTar_CommTarget__c);
            irrmTargetMap.put(combineID, eachID.TSMTar_IRRMTarget__c);
        }
        
        
        for(JournalLineItem__c eachRec : Database.query(JournalQuery))
        {
            String combineId = '';
            combineId = (String)eachRec.Journal_TSM__c + (String)eachRec.Journal_Team__c;
            
            
            Decimal fxDirectActuals = 0.00;
            Decimal fxIndirectActuals = 0.00;
            Decimal retailActuals = 0.00;

            Decimal commActuals = 0.00;
            Decimal irrmActuals = 0.00;
            Decimal fxDirectTargets = 0.00;
            Decimal fxIndirectTargets = 0.00;
            Decimal retailTargets = 0.00;

            Decimal commTargets = 0.00;
            Decimal irrmTargets = 0.00;
            Decimal fxDirectTargetTillDate = 0.00;
            Decimal fxIndirectTargetTillDate = 0.00;
            //Decimal retailTargetTillDate = 0;

            Decimal commTargetTillDate = 0.00;
            Decimal irrmTargetTillDate = 0.00;
            Decimal fxDirectActualTillDate = 0.00;
            Decimal fxIndirectActualTillDate = 0.00;
            //Decimal retailActualTillDate = 0;

            Decimal commActualTillDate = 0.00;
            Decimal irrmActualTillDate = 0.00;
            
            if(combineId != '')
            {
                fxDirectTargets = fxDirectTargetMap.get(combineId);
                fxIndirectTargets = fxInDirectTargetMap.get(combineId);
                retailTargets = 0;

                commTargets = commTargetMap.get(combineId);
                irrmTargets = irrmTargetMap.get(combineId);
                fxDirectTargetTillDate = fxDirectTargetTillDateMap.get(combineId);
                fxIndirectTargetTillDate = fxInDirectTargetTillDateMap.get(combineId);
                //retailTargetsTillDate = 0;

                commTargetTillDate = commTargetTillDateMap.get(combineId);
                irrmTargetTillDate = irrmTargetTillDateMap.get(combineId);
            }
            
            if(eachRec.Journal_BankerName__c != Null)
            {
                if(eachRec.Journal_ProductFamily__c == 'FX Cash')	
                {
                    if(eachRec.Journal_BranchNumber__c == System.Label.CBDirectDealingClient || 
                       eachRec.Journal_BranchNumber__c == System.Label.YBDirectDealingClient)
                    {
                        if(eachRec.Journal_IsQ6Available__c == true)
                        {
                            fxDirectActuals = fxDirectActuals + eachRec.Journal_Amount__c;
                        }
                    }
                    else if(eachRec.Journal_BranchNumber__c == System.Label.CBCardedRateSheet || eachRec.Journal_BranchNumber__c == System.Label.YBCardedRateSheet ||
                            eachRec.Journal_BranchNumber__c == System.Label.CBIndirect || eachRec.Journal_BranchNumber__c == System.Label.YBIndirect ||
                            eachRec.Journal_BranchNumber__c == System.Label.CBSortingCode || eachRec.Journal_BranchNumber__c == System.Label.YBSortingCode ||
                            eachRec.Journal_BranchNumber__c == System.Label.CBGeneric || eachRec.Journal_BranchNumber__c == System.Label.YBGeneric)
                    {
                        if(eachRec.Journal_IsQ6Available__c == true)
                        {
                            fxIndirectActuals = fxIndirectActuals + eachRec.Journal_Amount__c;
                        }
                        else
                        {
                            retailActuals = retailActuals + eachRec.Journal_Amount__c;
                        }
                    }
                    else if(eachRec.Journal_BranchNumber__c == null)
                    {
                        fxIndirectActuals = fxIndirectActuals + eachRec.Journal_Amount__c;
                    }
                }
                else if(eachRec.Journal_ProductFamily__c == 'Commodity')	
                {
                    commActuals = commActuals + eachRec.Journal_Amount__c;
                }
                
                else if(eachRec.Journal_ProductFamily__c == 'IRRM')	
                {
                    irrmActuals = irrmActuals + eachRec.Journal_Amount__c;
                }
            }
            else
            {
                retailActuals = retailActuals + eachRec.Journal_Amount__c;
            }
            //Decimal SumActuals = 0;
            for (String keys : combineIdSet)
            {
                Integer month = eachRec.CreatedDate.month();
                //SumActuals = 0;
                if(keys == combineId)
                {
                    combineIdMonthSet.add(keys+','+eachRec.CreatedDate.month());
                    
                }
            }
            
            for(String keys : combineIdMonthSet)
            {
                String[] Month = keys.split(',');
                Integer monthInt = Integer.valueOf(Month[1].trim());
                
                if(eachRec.createdDate.month() == monthInt && combineId == keys.split(',')[0])
                {
                    if(fxDirectActualMap.get(keys) == null)
                    {
                        fxDirectActualMap.put(keys, fxDirectActuals);
                    }
                    else
                    {
                        Decimal amount = 0;
                        amount = fxDirectActualMap.get(keys);
                        amount = amount + fxDirectActuals;
                        //commActualMap.remove(keys);
                        fxDirectActualMap.put(keys, amount);
                        
                    }
                    
                    if(fxInDirectActualMap.get(keys) == null)
                    {
                        fxInDirectActualMap.put(keys, fxInDirectActuals);
                        
                    }
                    else
                    {
                        Decimal amount = 0;
                        amount = fxInDirectActualMap.get(keys);
                        amount = amount + fxInDirectActuals;
                        //commActualMap.remove(keys);
                        fxInDirectActualMap.put(keys, amount);
                        
                    }
                    
                    if(commActualMap.get(keys) == null)
                    {
                        commActualMap.put(keys, commActuals);
                    }
                    else
                    {
                        Decimal amount = 0;
                        amount = commActualMap.get(keys);
                        amount = amount + commActuals;
                        //commActualMap.remove(keys);
                        commActualMap.put(keys, amount);
                        
                    }
                    if(irrmActualMap.get(keys) == null)
                    {
                        irrmActualMap.put(keys, irrmActuals);
                    }
                    else
                    {
                        Decimal amount = 0;
                        amount = irrmActualMap.get(keys);
                        amount = amount + irrmActuals;
                        //commActualMap.remove(keys);
                        irrmActualMap.put(keys, amount);
                        
                    }
                }
            }
            
            outerMap.put(combineId, eachRec.Journal_TeamName__c);
            innerMap.put(combineId, eachRec.Journal_TSMName__c);
            
        }
        for(String keys : combineIdSet)
        {
            Decimal amount = 0;
            
            amount=0;
            for(String internalKey : fxDirectActualMap.keySet())
            {
                if(keys == internalKey.split(',')[0] && fxDirectActualMap.get(internalKey)!=null)
                {
                    amount = amount + fxDirectActualMap.get(internalKey);
                }
            }
            fxDirectActualTillDateMap.put(keys, amount);
            
            amount=0;
            for(String internalKey : fxInDirectActualMap.keySet())
            {
                if(keys == internalKey.split(',')[0] && fxInDirectActualMap.get(internalKey)!=null)
                {
                    amount = amount + fxInDirectActualMap.get(internalKey);
                }
            }
            fxInDirectActualTillDateMap.put(keys, amount);
            
            
            amount=0;
            for(String internalKey : commActualMap.keySet())
            {
                if(keys == internalKey.split(',')[0] && commActualMap.get(internalKey)!=null)
                {
                    amount = amount + commActualMap.get(internalKey);
                }
            }
            commActualTillDateMap.put(keys, amount);
            
            amount=0;
            for(String internalKey : irrmActualMap.keySet())
            {
                if(keys == internalKey.split(',')[0] && irrmActualMap.get(internalKey)!=null)
                {
                    amount = amount + irrmActualMap.get(internalKey);
                }
            }
            irrmActualTillDateMap.put(keys, amount);
        }
        
        // for(String keys : combineIdSet)
        //{
        for(String out : outerSet)
        {
            List<String> iteamsandTSM = new List<String>();
            List<Decimal> itargets = new List<Decimal>();
            List<Decimal> itargetsTillDate = new List<Decimal>();
            List<Decimal> iactualsTillDate = new List<Decimal>();
            Decimal ifxDirectVariance = 0.00;
            Decimal ifxInDirectVariance = 0.00;
            Decimal icommVariance = 0.00;
            Decimal iirrmVariance = 0.00;
            counter = 0;
            grouper = false;
            iteamsandTSM.add(TeamNameMap.get(out));
            iteamsandTSM.add('Subtotal');
            List<String> ifxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> ifxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};

                        List<String> icommActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            List<String> iirrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                
                           
                                for(String inn : innerSet)
                            {
                                
                                String keys = inn + out;
                                List<Decimal> targets = new List<Decimal>();
                                List<Decimal> actuals = new List<Decimal>();
                                List<Decimal> targetsTillDate = new List<Decimal>();
                                List<Decimal> actualsTillDate = new List<Decimal>();
                                List<String> teamsandTSM = new List<String>();
                                if(combineIdSet.contains(keys))
                                {
                                    
                                    Decimal fxDirectVariance = 0.00;
                                    Decimal fxInDirectVariance = 0.00;

                                    Decimal commVariance = 0.00;
                                    Decimal irrmVariance = 0.00;
                                    
                                    
                                    
                                    Decimal fxdact = 0.00;
                                    Decimal fxidact = 0.00;

                                    Decimal commact = 0.00;
                                    Decimal irrmact = 0.00;
                                    
                                    
                                    List<String> fxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                        List<String> fxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};

                                                List<String> commActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                                    List<String> irrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                                        
                                                       
                                                        teamsandTSM.add((String)outerMap.get(keys));
                                    teamsandTSM.add((String)innerMap.get(keys));
                                    targets.add((Decimal)fxDirectTargetMap.get(keys));
                                    targets.add((Decimal)fxInDirectTargetMap.get(keys));

                                    targets.add((Decimal)commTargetMap.get(keys));
                                    targets.add((Decimal)irrmTargetMap.get(keys));
                                    actuals.add((Decimal)fxDirectActualMap.get(keys));
                                    actuals.add((Decimal)fxInDirectActualMap.get(keys));

                                    actuals.add((Decimal)commActualMap.get(keys));
                                    actuals.add((Decimal)irrmActualMap.get(keys));
                                    targetsTillDate.add((Decimal)fxDirectTargetTillDateMap.get(keys));
                                    targetsTillDate.add((Decimal)fxInDirectTargetTillDateMap.get(keys));

                                    targetsTillDate.add((Decimal)commTargetTillDateMap.get(keys));
                                    targetsTillDate.add((Decimal)irrmTargetTillDateMap.get(keys));
                                    actualsTillDate.add((Decimal)fxDirectActualTillDateMap.get(keys));
                                    actualsTillDate.add((Decimal)fxInDirectActualTillDateMap.get(keys));

                                    actualsTillDate.add((Decimal)commActualTillDateMap.get(keys));
                                    actualsTillDate.add((Decimal)irrmActualTillDateMap.get(keys));
                                    for(String eachKey : combineIdMonthSet)
                                    {
                                        
                                        if(eachKey.split(',')[0] == keys)
                                        {
                                            
                                            fxDirectActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(fxDirectActualMap.get(eachKey));
                                            fxInDirectActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(fxInDirectActualMap.get(eachKey));

                                            commActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(commActualMap.get(eachKey));
                                            irrmActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(irrmActualMap.get(eachKey));
                                            fxdact = fxdact + fxDirectActualMap.get(eachKey);
                                            fxidact = fxidact + fxInDirectActualMap.get(eachKey);

                                            commact = commact + commActualMap.get(eachKey);
                                            irrmact = irrmact + irrmActualMap.get(eachKey);
                                            
                                        }
                                        
                                    }   

                                    if((Decimal)fxDirectTargetMap.get(keys) != 0.00 && (Decimal)fxDirectActualTillDateMap.get(keys) != 0)
                                    {
                                        fxDirectVariance = (((Decimal)fxDirectActualTillDateMap.get(keys)
                                                             / (Decimal)fxDirectTargetMap.get(keys))).setScale(2);
                                    }
                                    if((Decimal)fxInDirectTargetMap.get(keys) != 0 &&  (Decimal)fxInDirectActualTillDateMap.get(keys) != 0)
                                    {
                                        fxInDirectVariance = (((Decimal)fxInDirectActualTillDateMap.get(keys)
                                                               / (Decimal)fxInDirectTargetMap.get(keys))).setScale(2);
                                    }
                                    
                                    if((Decimal)commTargetMap.get(keys) != 0 && (Decimal)commActualTillDateMap.get(keys)!=0)
                                    {
                                        commVariance = (((Decimal)commActualTillDateMap.get(keys)
                                                         / (Decimal)commTargetMap.get(keys))).setScale(2);
                                    }
                                    if((Decimal)irrmTargetMap.get(keys) != 0  && (Decimal)irrmActualTillDateMap.get(keys)!=0)
                                    {
                                        irrmVariance = (((Decimal)irrmActualTillDateMap.get(keys)
                                                         / (Decimal)irrmTargetMap.get(keys))).setScale(2);
                                    }
                                    
                                    
                                    if(outerMap.get(keys) != null)
                                    {
                                        grouper = true;
                                        counter = counter + 1;
                                        Decimal ytdPipeline = 0.00;
                                        if((Decimal)oppMap.get(keys) != null)
                                            ytdPipeLine = (Decimal)oppMap.get(keys);
                                        else
                                            ytdPipeLine = 0.00;
                                        
                                        System.debug('CombineIds'+keys);
                                        wrappedDataList.add(new WrapperClass((String[])teamsandTSM, (String[])descriptionList, (Decimal[])targets, (String[])fxDirectActuals,
                                                                             (String[])fxInDirectActuals,  (String[])commActuals,
                                                                             (String[])irrmActuals,
                                                                             (Decimal[])targetsTillDate, (Decimal[])actualsTillDate,
                                                                             (Decimal)fxDirectVariance, (Decimal)fxInDirectVariance,
                                                                             (Decimal)commVariance, (Decimal)irrmVariance,
                                                                             (Decimal)fxDirectVariance * 100, (Decimal)fxInDirectVariance * 100,
                                                                             (Decimal)commVariance * 100, (Decimal)irrmVariance * 100, 
                                                                             (Decimal)ytdPipeLine, false));
                                    }
                                }
                            }


            if(grouper == true && counter > 1)
            {
                

				Decimal tPipeLine = 0.00;
                itargets.add((ifxDirectTargetMap.get(out)).setScale(2));
                itargets.add((ifxInDirectTargetMap.get(out)).setScale(2));
                itargets.add((icommTargetMap.get(out)).setScale(2));
                itargets.add((iirrmTargetMap.get(out)).setScale(2));
                
                itargetsTillDate.add((ifxDirectTargetTDMap.get(out)).setScale(2));
                itargetsTillDate.add((ifxInDirectTargetTDMap.get(out)).setScale(2));
                itargetsTillDate.add((icommTargetTDMap.get(out)).setScale(2));
                itargetsTillDate.add((iirrmTargetTDMap.get(out)).setScale(2));
                    
                        
                iactualsTillDate.add((ifxDirectActualTDMap.get(out)).setScale(2));
                iactualsTillDate.add((ifxInDirectActualTDMap.get(out)).setScale(2));
                iactualsTillDate.add((icommActualTDMap.get(out)).setScale(2));
                iactualsTillDate.add((iirrmActualTDMap.get(out)).setScale(2));
                
				
                if(itargets[0] != 0.00 && iactualsTillDate[0] != 0.00)
                	ifxDirectVariance = (iactualsTillDate[0] / itargets[0]).setScale(2);
                if(itargets[1] != 0.00 && iactualsTillDate[1] != 0.00)
                	ifxInDirectVariance = (iactualsTillDate[1] / itargets[1]).setScale(2);
                if(itargets[2] != 0.00 && iactualsTillDate[2] != 0.00)
                	icommVariance = (iactualsTillDate[2] / itargets[2]).setScale(2);
                if(itargets[3] != 0.00 && iactualsTillDate[3] != 0.00)
                	iirrmVariance = (iactualsTillDate[3] / itargets[3]).setScale(2);
                
                if(totalPipeLineMap.get(out) != null)
                    tPipeLine = totalPipeLineMap.get(out);
                
                for(Integer i=0; i<=12; i++)
                {
                    if(ifxDirectActualMap.get(out + ',' + i) != null)
                        ifxDirectActuals[i] = String.valueOf(ifxDirectActualMap.get(out + ',' + i));
                    if(ifxInDirectActualMap.get(out + ',' + i) != null)
                        ifxInDirectActuals[i] = String.valueOf(ifxInDirectActualMap.get(out + ',' + i));
                    if(iirrmActualMap.get(out + ',' + i) != null)
                        iirrmActuals[i] = String.valueOf(iirrmActualMap.get(out + ',' + i));
                    
                    if(icommActualMap.get(out + ',' + i) != null)
                        icommActuals[i] = String.valueOf(icommActualMap.get(out + ',' + i));
                }
                
                
                
                    wrappedDataList.add(new WrapperClass((String[])iteamsandTSM, (String[])descriptionList,  
                                                         (Decimal[])itargets, (String[])ifxDirectActuals, 
                                                         (String[])ifxInDirectActuals,  (String[])icommActuals, 
                                                         (String[])iirrmActuals,
                                                         (Decimal[])itargetsTillDate, (Decimal[])iactualsTillDate, ifxDirectVariance, ifxInDirectVariance, 
                                                         icommVariance, iirrmVariance, ifxDirectVariance * 100, ifxInDirectVariance *100,
                                                         icommVariance * 100, iirrmVariance * 100, tPipeLine,true));
                                
                
                
            }
        }
        
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceVFPDld');
        return nextpage;
    }
    public PageReference submitBusCen() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceVFP');
        return nextpage;
    }
    public PageReference submitRegions() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceRegion');
        return nextpage;
    }
    public PageReference submitDivisions() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceDivision');
        return nextpage;
    }
    public PageReference submitGroups() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceGroup');
        return nextpage;
    }
    public PageReference submitBanks() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceBank');
        return nextpage;
    }
    Public class WrapperClass{
        Public String BusinessCentre {get; set;}
        Public String[] descriptionList {get; set;}
        Public String TSM {get; set;}
        Public Decimal FXDirectTarget {get; set;}
        Public String[] FXDirectActual {get; set;}
        Public Decimal CommTarget {get; set;}
        Public String[] CommActual {get; set;}
        Public Decimal FXIndirectTarget {get; set;}
        Public String[] FXIndirectActual {get; set;}
        Public Decimal IRRMTarget {get; set;}
        Public String[] IRRMActual {get; set;}
        
        Public Decimal FXDirectTargetTillDate {get; set;}
        Public Decimal FXIndirectTargetTillDate {get; set;}

        Public Decimal CommTargetTillDate {get; set;}
        Public Decimal IRRMTargetTillDate {get; set;}
        Public Decimal FXDirectActualTillDate {get; set;}
        Public Decimal FXIndirectActualTillDate {get; set;}

        Public Decimal CommActualTillDate {get; set;}
        Public Decimal IRRMActualTillDate {get; set;}
        Public Decimal fxDirectVariance {get; set;}
        Public Decimal fxIndirectVariance {get; set;}

        Public Decimal commVariance {get; set;}
        Public Decimal irrmVariance {get; set;}
        Public Decimal fxDirectVariancePercent {get; set;}
        Public Decimal fxIndirectVariancePercent {get; set;}

        Public Decimal commVariancePercent {get; set;}
        Public Decimal irrmVariancePercent {get; set;}
        Public Decimal ytdPipeLine {get; set;}
        
        Public Boolean groupIt {get; set;}
        Public WrapperClass(List<String> teamandTSM, List<String>descriptionList, List<Decimal> targets, List<String> fxDirectActuals, List<String> fxInDirectActuals,
                             List<String> commActuals, List<String> irrmActuals, List<Decimal> targetsTillDate,
                            List<Decimal> actualsTillDate, Decimal fxDirectVariance, Decimal fxInDirectVariance, 
                            Decimal commVariance, Decimal irrmVariance, Decimal fxDirectVariancePercent, Decimal fxInDirectVariancePercent,
                            Decimal commVariancePercent, Decimal irrmVariancePercent, Decimal ytdPipeLine, Boolean groupIt)
        {
            
            
            this.BusinessCentre = teamandTSM[0]; 
            this.descriptionList = descriptionList;
            this.TSM =  teamandTSM[1];
            this.FXDirectTarget =  targets[0];
            this.FXDirectActual = fxDirectActuals;
            this.FXIndirectTarget = targets[1];
            this.FXIndirectActual = fxInDirectActuals;
            this.CommTarget =  targets[2];
            this.CommActual = commActuals;
            this.IRRMTarget = targets[3];
            this.IRRMActual = irrmActuals;
            
            this.FXDirectTargetTillDate =  targetsTillDate[0];
            this.FXIndirectTargetTillDate =  targetsTillDate[1];
            
            this.CommTargetTillDate =  targetsTillDate[2];
            this.IRRMTargetTillDate =  targetsTillDate[3];
            this.FXDirectActualTillDate = actualsTillDate[0];
            this.FXIndirectActualTillDate = actualsTillDate[1];

            this.CommActualTillDate = actualsTillDate[2];
            this.IRRMActualTillDate = actualsTillDate[3];
            this.fxDirectVariance = fxDirectVariance;
            this.fxIndirectVariance = fxIndirectVariance;

            this.commVariance = commVariance;
            this.irrmVariance = irrmVariance;
            this.fxDirectVariancePercent = fxDirectVariancePercent;
            this.fxIndirectVariancePercent = fxIndirectVariancePercent;

            this.commVariancePercent = commVariancePercent;
            this.irrmVariancePercent = irrmVariancePercent; 
            this.ytdPipeLine = ytdPipeLine;
            this.groupIt = groupIt;
        }
    }
}