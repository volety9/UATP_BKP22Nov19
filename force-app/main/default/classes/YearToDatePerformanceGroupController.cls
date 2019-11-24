public class YearToDatePerformanceGroupController {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Date pfyStartDate;
    Date pfyEndDate;
    
    String SetQuery = '';
    String JournalQuery = '';
    String TSMQuery = '';
    
    Boolean grouper = false;
    Integer counter = 0;
    String oldValue = '';
    Public Map<String, Decimal> ifxDirectActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> icommActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxDirectActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmActualTillDateMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> ifxDirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> icommActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> icommTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmTargetMap= new Map<String, Decimal>();
    //Public Map<String, String> GrouperNameMap= new Map<String, String>();
    Public Set<String> jliListSet = new Set<String>();
    
    Public List<WrapperClass> wrappedDataList{get; set;}
    Public List<String> completeList;
    
    Public Set<String> innerSet = new Set<String>();
    Public Set<String> outerSet = new Set<String>();
    Public Set<String> combineIdSet = new Set<String>();
    Public Set<String> combineIdMonthSet = new Set<String>();
    
    Public Map<String, String> outerMap= new Map<String, String>();
    Public Map<String, String> innerMap= new Map<String, String>();
    
    Public Map<String, Decimal> fxDirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmActualMap= new Map<String, Decimal>();
    
    Public Map<String, Decimal> fxDirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commTargetMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmTargetMap= new Map<String, Decimal>();
    Public List<String> descriptionList = new List<String>{'Sum of FX Direct Target', 'Sum of FX Direct Actual', 'Sum of FX Indirect Target', 'Sum of FX Indirect Actual',
        'Sum of Commodity Target', 'Sum of Commodity Actual',
        'Sum of IRRM Target', 'Sum of IRRM Actual'};
            
            
            //List<T> fullList = new List<T>();
            
            public YearToDatePerformanceGroupController(){
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
        
        Decimal sumifxDirectTargets = 0;
        Decimal sumifxIndirectTargets = 0;
        Decimal sumicommTargets = 0;
        Decimal sumiirrmTargets = 0;
        
        Decimal sumifxDirectActualTD = 0.00;
        Decimal sumifxInDirectActualTD = 0.00;
        Decimal sumiirrmActualTD = 0.00;
        Decimal sumicommActualTD = 0.00;
        
        Decimal indirectSum = 0.00;
        Decimal directSum = 0.00;
        Decimal commSum = 0.00;
        Decimal irrmSum = 0.00;
        
        SetQuery = 'SELECT Name, Region_Division__r.Name FROM Region__c ORDER BY Region_Division__r.Name, Name';
        
        for(Region__c eachID : Database.query(SetQuery))
        {
            innerSet.add(eachID.Name);
            outerSet.add(eachID.Region_Division__r.Name);
        }
        
        for(AggregateResult jliList : [SELECT Journal_Region__c division, 
                                       Journal_Division__c groupp
                                       FROM JournalLineItem__c
                                       WHERE Journal_Division__c IN :outerSet AND Journal_Region__c IN :innerSet
                                       AND Journal_TSMTarget__c != null
                                       GROUP BY Journal_Division__c, Journal_Region__c])
        {
            jliListSet.add((String)jliList.get('division'));
            //GrouperNameMap.put((String)jliList.get('teamId'), (String)jliList.get('teamName'));
        }
        JournalQuery = 'SELECT ID, Journal_ProductFamily__c, Journal_Amount__c, Journal_IsQ6Available__c, '+
            'Journal_BranchNumber__c, Journal_CorpCode__c, Journal_TransactionType__c, '+
            'Journal_TSMName__c, Journal_TSMTarget__c, Journal_BankerName__c, '+
            'Journal_Team__c, Journal_TeamName__c, Journal_Region__c, Journal_Centre__c, '+ 
            'Journal_Division__c, Journal_Group__c, Journal_TSM__c, CreatedDate  '+
            'FROM JournalLineItem__c '+
            'WHERE Journal_Region__c IN :innerSet AND Journal_Division__c IN :outerSet AND '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate '+
            'ORDER BY Journal_Division__c, Journal_Region__c, CreatedDate';
        
        TSMQuery = 'SELECT Region_FXDirectTarget__c, Region_FXIndirectTarget__c, '+
            'Region_CommTarget__c, Region_IRRMTarget__c, '+
            'Region_Division__r.Name, Name '+
            'FROM Region__c WHERE Name IN :innerSet AND Region_Division__r.Name IN :outerSet AND '+
            'Name In :jliListSet AND '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate ORDER BY Region_Division__r.Name, Name, CreatedDate';
        
        for(AggregateResult ags : [SELECT SUM(Journal_Amount__c) amount, Journal_Division__c groupp,
                                   Journal_Region__c division, Journal_IsQ6Available__c q6,
                                   Journal_ProductFamily__c product, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c  brNum,
                                   calendar_month(CreatedDate) credMonth
                                   FROM JournalLineItem__c
                                   WHERE  Journal_Division__c IN :outerSet AND 
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                   GROUP BY Journal_Division__c, Journal_Region__c, Journal_ProductFamily__c, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c, Journal_IsQ6Available__c, calendar_month(CreatedDate) 
                                   ORDER BY Journal_Division__c, calendar_month(CreatedDate)])
        {
            
if(oldValue != (String)ags.get('groupp'))
            {
                oldValue = (String)ags.get('groupp');
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
                        ifxDirectActualMap.put((String)ags.get('groupp') + ',' + String.valueOf(ags.get('credMonth')), directSum);
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
                        ifxInDirectActualMap.put((String)ags.get('groupp') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);

                    }
                    
                }
                else if(ags.get('brNum') == null)
                {
                    indirectSum = indirectSum + (Decimal)ags.get('amount');
                        ifxInDirectActualMap.put((String)ags.get('groupp') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);
                }
            }
            else if(ags.get('product') == 'Commodity')	
            {
                commSum = commSum + (Decimal)ags.get('amount');
                icommActualMap.put((String)ags.get('groupp') + ',' + String.valueOf(ags.get('credMonth')), commSum);
            }
            
            else if(ags.get('product') == 'IRRM')	
            {
                irrmSum = irrmSum + (Decimal)ags.get('amount');
                iirrmActualMap.put((String)ags.get('groupp') + ',' + String.valueOf(ags.get('credMonth')), irrmSum);
            }
            
        }
        oldValue = '';
        for(AggregateResult agr : [SELECT SUM(Region_FXDirectTarget__c) fxDirectTar, SUM(Region_FXIndirectTarget__c)fxIndirectTar, 
                                   SUM(Region_CommTarget__c)commTar, SUM(Region_IRRMTarget__c)irrmTar, 
                                   SUM(Region_FXDirectActual__c) fxDirectActTD, SUM(Region_FXIndirectActual__c) fxInDirectActTD,
                                   SUM(Region_CommActual__c)commActTD, SUM(Region_IRRMActual__c)irrmActTD,
                                   Region_Division__r.Name outerSetTar, calendar_month(CreatedDate) credMonth
                                   FROM Region__c 
                                   WHERE Name IN :innerSet AND Region_Division__r.Name IN :outerSet AND 
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate AND
                                   Name IN :jliListSet
                                   GROUP BY Region_Division__r.Name, Name, calendar_month(CreatedDate) 
                                   ORDER BY Region_Division__r.Name, calendar_month(CreatedDate)])
        {
            if(oldValue != (String)agr.get('outerSetTar'))
            {
                oldValue = (String)agr.get('outerSetTar');
                sumifxDirectTargets = 0.00;
                sumifxInDirectTargets = 0.00;
                sumicommTargets = 0.00;
                sumiirrmTargets = 0.00;
                
                sumifxDirectActualTD = 0.00;
                sumifxInDirectActualTD = 0.00;
                sumiirrmActualTD = 0.00;
                sumicommActualTD = 0.00;
            }
            sumifxDirectActualTD = sumifxDirectActualTD + (Decimal)agr.get('fxDirectActTD');
            sumifxInDirectActualTD = sumifxInDirectActualTD + (Decimal)agr.get('fxIndirectActTD');
            sumiirrmActualTD = sumiirrmActualTD + (Decimal)agr.get('irrmActTD');
            sumicommActualTD = sumicommActualTD + (Decimal)agr.get('commActTD');
            
            sumifxDirectTargets = sumifxDirectTargets + (Decimal)agr.get('fxDirectTar');
            sumifxInDirectTargets = sumifxInDirectTargets + (Decimal)agr.get('fxInDirectTar');
            sumicommTargets = sumicommTargets + (Decimal)agr.get('commTar');
            sumiirrmTargets = sumiirrmTargets + (Decimal)agr.get('irrmTar');
            
            ifxDirectTargetMap.put((String)agr.get('outerSetTar'), sumifxDirectTargets);
            ifxInDirectTargetMap.put((String)agr.get('outerSetTar'), sumifxInDirectTargets);
            iirrmTargetMap.put((String)agr.get('outerSetTar'), sumiirrmTargets);
            icommTargetMap.put((String)agr.get('outerSetTar'), sumicommTargets);
            
            ifxDirectActualTDMap.put((String)agr.get('outerSetTar'), sumifxDirectActualTD);
            ifxInDirectActualTDMap.put((String)agr.get('outerSetTar'), sumifxInDirectActualTD);
            iirrmActualTDMap.put((String)agr.get('outerSetTar'), sumiirrmActualTD);
            icommActualTDMap.put((String)agr.get('outerSetTar'), sumicommActualTD);
                      
        }
        for(Region__c eachID : Database.query(TSMQuery))
        {
            String combineID = (String)eachID.Region_Division__r.Name + (String)eachID.Name;
            
            combineIdSet.add(combineID);
            
            fxDirectTargetMap.put(combineID, eachID.Region_FXDirectTarget__c);
            fxInDirectTargetMap.put(combineID, eachID.Region_FXIndirectTarget__c);
            commTargetMap.put(combineID, eachID.Region_CommTarget__c);
            irrmTargetMap.put(combineID, eachID.Region_IRRMTarget__c);
        }

        for(JournalLineItem__c eachRec : Database.query(JournalQuery))
        {
            String combineId = '';
            combineId = (String)eachRec.Journal_Division__c + (String)eachRec.Journal_Region__c;
            
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
            
            if(combineId != '')
            {
                fxDirectTargets = fxDirectTargetMap.get(combineId);
                fxIndirectTargets = fxInDirectTargetMap.get(combineId);
                retailTargets = 0;
                commTargets = commTargetMap.get(combineId);
                irrmTargets = irrmTargetMap.get(combineId);
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
            
            for (String keys : combineIdSet)
            {
                Integer month = eachRec.CreatedDate.month();
                
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
            
            outerMap.put(combineId, eachRec.Journal_Division__c);
            innerMap.put(combineId, eachRec.Journal_Region__c);
            
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
        
        for(String out : outerSet)
        {
            List<String> icentresAndTeam = new List<String>();
            List<Decimal> itargets = new List<Decimal>();
            List<Decimal> igrandTotal = new List<Decimal>();
            
            counter = 0;
            grouper = false;
            icentresAndTeam.add(out);
            icentresAndTeam.add('Subtotal');
            List<String> ifxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> ifxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    
                    List<String> icommActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> iirrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            
                            
                            for(String inn : innerSet)
                        {
                            String keys = out + inn;
                            
                            List<Decimal> targets = new List<Decimal>();
                            List<Decimal> actuals = new List<Decimal>();
                            List<String> teamsandTSM = new List<String>();
                            List<Decimal> grandTotal = new List<Decimal>();
                            if(combineIdSet.contains(keys))
                            {
                                List<String> centresAndTeam = new List<String>();
                                
                                List<String> fxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                    List<String> fxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                        List<String> commActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                            List<String> irrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                                
                                                
                                                completeList = new List<String>();
                                
                                
                                centresAndTeam.add((String)outerMap.get(keys));
                                centresAndTeam.add((String)innerMap.get(keys));
                                targets.add((Decimal)fxDirectTargetMap.get(keys));
                                targets.add((Decimal)fxInDirectTargetMap.get(keys));
                                targets.add((Decimal)commTargetMap.get(keys));
                                targets.add((Decimal)irrmTargetMap.get(keys));
                                actuals.add((Decimal)fxDirectActualMap.get(keys));
                                actuals.add((Decimal)fxInDirectActualMap.get(keys));
                                actuals.add((Decimal)commActualMap.get(keys));
                                actuals.add((Decimal)irrmActualMap.get(keys));
                                
                                
                                grandtotal.add((Decimal)fxDirectTargetMap.get(keys));
                                grandtotal.add((Decimal)fxDirectActualTillDateMap.get(keys));
                                grandtotal.add((Decimal)fxInDirectTargetMap.get(keys));
                                grandtotal.add((Decimal)fxInDirectActualTillDateMap.get(keys));
                                grandtotal.add((Decimal)commTargetMap.get(keys));
                                grandtotal.add((Decimal)commActualTillDateMap.get(keys));
                                grandtotal.add((Decimal)irrmTargetMap.get(keys));
                                grandtotal.add((Decimal)irrmActualTillDateMap.get(keys));
                                
                                for(String eachKey : combineIdMonthSet)
                                {
                                    
                                    if(eachKey.split(',')[0] == keys)
                                    {
                                        
                                        fxDirectActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(fxDirectActualMap.get(eachKey));
                                        fxInDirectActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(fxInDirectActualMap.get(eachKey));
                                        commActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(commActualMap.get(eachKey));
                                        irrmActuals[Integer.valueOf(eachKey.split(',')[1])] = String.valueOf(irrmActualMap.get(eachKey));
                                        
                                    }
                                    
                                }   
                                if(innerMap.get(keys) != null)
                                {
                                    grouper = true;
                                    counter = counter + 1;
                                    wrappedDataList.add(new WrapperClass((String[])centresAndTeam, (String[])descriptionList, (Decimal[])targets, (String[])fxDirectActuals,
                                                                         (String[])fxInDirectActuals, (String[])commActuals,
                                                                         (String[])irrmActuals, (Decimal[])grandTotal,false));
                                }
                                
                                
                                
                            }
                        }
            if(grouper == true && counter > 1)
            {
                
                
                itargets.add((ifxDirectTargetMap.get(out)).setScale(2));
                itargets.add((ifxInDirectTargetMap.get(out)).setScale(2));
                itargets.add((icommTargetMap.get(out)).setScale(2));
                itargets.add((iirrmTargetMap.get(out)).setScale(2));
                
                igrandTotal.add((ifxDirectTargetMap.get(out)).setScale(2));
                igrandTotal.add((ifxDirectActualTDMap.get(out)).setScale(2));
                igrandTotal.add((ifxInDirectTargetMap.get(out)).setScale(2));
                igrandTotal.add((ifxInDirectActualTDMap.get(out)).setScale(2));
                igrandTotal.add((icommTargetMap.get(out)).setScale(2));
                igrandTotal.add((icommActualTDMap.get(out)).setScale(2));
                igrandTotal.add((iirrmTargetMap.get(out)).setScale(2));
                igrandTotal.add((iirrmActualTDMap.get(out)).setScale(2));
                
                
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
                
                wrappedDataList.add(new WrapperClass((String[])icentresAndTeam, (String[])descriptionList,  
                                                     (Decimal[])itargets, (String[])ifxDirectActuals, 
                                                     (String[])ifxInDirectActuals,  (String[])icommActuals, 
                                                     (String[])iirrmActuals, igrandTotal,true));
                
                
            }
        }
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/YearToDatePerformanceGroupDld');
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
        Public String Region {get; set;}
        Public String[] descriptionList {get; set;}
        Public String BusinessCentre {get; set;}
        Public Decimal FXDirectTarget {get; set;}
        Public String[] FXDirectActual {get; set;}
        Public Decimal CommTarget {get; set;}
        Public String[] CommActual {get; set;}
        Public Decimal FXIndirectTarget {get; set;}
        Public String[] FXIndirectActual {get; set;}
        Public Decimal IRRMTarget {get; set;}
        Public String[] IRRMActual {get; set;}
        Public Decimal[] grandTotal {get; set;}
        Public boolean groupIt{get; set;}
        Public WrapperClass(List<String> centresAndTeam, List<String>descriptionList, List<Decimal> targets, List<String> fxDirectActuals, List<String> fxInDirectActuals,
                            List<String> commActuals, List<String> irrmActuals, List<Decimal> grandTotal, Boolean groupIt)
        {
            
            
            this.Region = centresAndTeam[0]; 
            this.descriptionList = descriptionList;
            this.BusinessCentre =  centresAndTeam[1];
            this.FXDirectTarget =  targets[0];
            this.FXDirectActual = fxDirectActuals;
            this.FXIndirectTarget = targets[1];
            this.FXIndirectActual = fxInDirectActuals;
            this.CommTarget =  targets[2];
            this.CommActual = commActuals;
            this.IRRMTarget = targets[3];
            this.IRRMActual = irrmActuals;
            this.grandTotal = grandTotal;
            this.groupIt = groupIt;
        }
    }
}