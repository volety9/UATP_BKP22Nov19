public class RMPerformanceYTDController {
    Integer fyStartMonth;
    Date fyStartDate;
    Date fyEndDate;
    Date pfyStartDate;
    Date pfyEndDate;
    
    String SetQuery = '';
    String JournalQuery = '';
    String TSMQuery = '';
    
    String oldValue = '';
    
    Boolean grouper = false;
    Integer counter = 0;
    Decimal totalPipeLine = 0.00;
    Public Map<String, Decimal> totalPipeLineMap= new Map<String, Decimal>();

    Public Map<String, Decimal> ifxDirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> icommActualMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualMap= new Map<String, Decimal>();
     Public Set<String> jliListSet = new Set<String>();
    Public Map<String, Decimal> ifxDirectActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> ifxIndirectActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> icommActualTDMap= new Map<String, Decimal>();
    Public Map<String, Decimal> iirrmActualTDMap= new Map<String, Decimal>();
        
    Public List<WrapperClass> wrappedDataList{get; set;}
    Public List<String> completeList;
    
    Public Map<String, Decimal> fxDirectActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> fxIndirectActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> commActualTillDateMap= new Map<String, Decimal>();
    Public Map<String, Decimal> irrmActualTillDateMap= new Map<String, Decimal>();
    
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
    
    Public Map<String, Decimal> oppMap= new Map<String, Decimal>();
    Public List<String> descriptionList = new List<String>{'FX Direct', 'FX Indirect', 'Commodities', 'IRRM'};
        
        public RMPerformanceYTDController(){
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
        
        Decimal sumifxDirectActualTD = 0.00;
        Decimal sumifxInDirectActualTD = 0.00;
        Decimal sumiirrmActualTD = 0.00;
        Decimal sumicommActualTD = 0.00;
        Decimal totalPipeLine = 0.00;
        String oldValue2 = '';
        Decimal amountIn = 0.00;
        
        
        SetQuery = 'SELECT Journal_TeamName__c, Journal_BankerName__c FROM JournalLineItem__c ORDER BY Journal_TeamName__c, '+
            'Journal_BankerName__c';
        
        for(JournalLineItem__c eachID : Database.query(SetQuery))
        {
            
            innerSet.add(eachID.Journal_BankerName__c);
            outerSet.add(eachID.Journal_TeamName__c);
        }
        
        for(AggregateResult jliList : [SELECT Journal_BankerName__c rm, 
                                       Journal_TeamName__c team
                                       FROM JournalLineItem__c
                                       WHERE Journal_TeamName__c IN :outerSet AND 
                                       Journal_BankerName__c IN :innerSet
                                       AND Journal_TSMTarget__c != null
                                       GROUP BY Journal_TeamName__c, Journal_BankerName__c])
        {
            jliListSet.add((String)jliList.get('rm'));
            //GrouperNameMap.put((String)jliList.get('teamId'), (String)jliList.get('teamName'));
        }
        System.debug('JLILIst'+jliListSet);
        for(Opportunity oppList : [SELECT amount, Account.RM_Name__r.Name, Account.RM_Name__r.Con_Team__r.Name From Opportunity WHERE 
                                       CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND 
                                       StageName != 'Closed Won' AND StageName != 'Closed Lost'
                                   
                                  ORDER BY Account.RM_Name__r.Con_Team__r.Name, Account.RM_Name__c])
        {
            System.debug('KLJKLJLJL'+oppList.Account.RM_Name__c);
            if(jliListSet.contains(oppList.Account.RM_Name__r.Name) )
            {
            
            if(oldValue != (String)oppList.Account.RM_Name__r.Con_Team__r.Name)
            {
               oldValue = (String)oppList.Account.RM_Name__r.Con_Team__r.Name;
                totalPipeLine = 0.00;
            }
            if(oldValue2 != (String)oppList.Account.RM_Name__r.Name)
            {
                oldValue2 = (String)oppList.Account.RM_Name__r.Name;
                amountIn = 0.00;
            }
                
            amountIn = amountIn + oppList.amount;
            
            System.debug('amoutn'+amountIn);
                oppMap.put((String)oppList.Account.RM_Name__r.Con_Team__r.Name+(String)oppList.Account.RM_Name__r.Name, amountIn);
            System.debug('totalP'+oppMap);
            totalPipeLine = totalPipeLine + (Decimal)oppList.amount;
            totalPipeLineMap.put((String)oppList.Account.RM_Name__r.Con_Team__r.Name, totalPipeLine);
            System.debug('total'+totalPipeLine);
            }
        }
       
        
        
        
        
        oldValue = '';
        for(AggregateResult ags : [SELECT SUM(Journal_Amount__c) amount, Journal_TeamName__c teamName,
                                   Journal_BankerName__c rm, 
                                   Journal_IsQ6Available__c q6,
                                   Journal_ProductFamily__c product, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c  brNum,
                                   calendar_month(CreatedDate) credMonth
                                   FROM JournalLineItem__c
                                   WHERE  Journal_TeamName__c IN :outerSet AND 
                                   
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                   GROUP BY Journal_TeamName__c, 
                                   Journal_BankerName__c,
                                   Journal_ProductFamily__c, 
                                   Journal_Opportunity__r.Opp_BranchNumber__c, Journal_IsQ6Available__c, calendar_month(CreatedDate) 
                                   ORDER BY Journal_TeamName__c, calendar_month(CreatedDate)])
        {
            System.debug('HERE IN');
           
            if(oldValue != (String)ags.get('teamName'))
            {
                oldValue = (String)ags.get('teamName');
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
                            ifxDirectActualMap.put((String)ags.get('teamName') + ',' + String.valueOf(ags.get('credMonth')), directSum);
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
                            ifxInDirectActualMap.put((String)ags.get('teamName') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);

                        }
                        
                    }
                    else if(ags.get('brNum') == null)
                    {
                        indirectSum = indirectSum + (Decimal)ags.get('amount');
                            ifxInDirectActualMap.put((String)ags.get('teamName') + ',' + String.valueOf(ags.get('credMonth')), indirectSum);
                    }
                }
                else if(ags.get('product') == 'Commodity')	
                {
					commSum = commSum + (Decimal)ags.get('amount');
                    icommActualMap.put((String)ags.get('teamName') + ',' + String.valueOf(ags.get('credMonth')), commSum);
                }
                
                else if(ags.get('product') == 'IRRM')	
                {
                    irrmSum = irrmSum + (Decimal)ags.get('amount');
                    iirrmActualMap.put((String)ags.get('teamName') + ',' + String.valueOf(ags.get('credMonth')), irrmSum);
                }
            
        }

        oldValue = '';
        for(AggregateResult agr : [SELECT SUM(TSMTar_FXDirectActual__c) fxDirectActTD, 
                                   SUM(TSMTar_FXIndirectActual__c) fxInDirectActTD,
                                   SUM(TSMTar_CommActual__c)commActTD, SUM(TSMTar_IRRMActual__c)irrmActTD,
                                   TSMTar_Team__r.Name teamTar
                                   FROM TSMTarget__c 
                                   WHERE TSMTar_Team__r.Name IN :outerSet AND 
                                   
                                   CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate 
                                   GROUP BY TSMTar_Team__r.Name 
                                   ORDER BY TSMTar_Team__r.Name])
        {
            if(oldValue != (String)agr.get('teamTar'))
            {
                oldValue = (String)agr.get('teamTar');
                sumifxDirectActualTD = 0.00;
                sumifxInDirectActualTD = 0.00;
                sumiirrmActualTD = 0.00;
                sumicommActualTD = 0.00;
            }
            sumifxDirectActualTD = sumifxDirectActualTD + (Decimal)agr.get('fxDirectActTD');
            sumifxInDirectActualTD = sumifxInDirectActualTD + (Decimal)agr.get('fxIndirectActTD');
            sumiirrmActualTD = sumiirrmActualTD + (Decimal)agr.get('irrmActTD');
            sumicommActualTD = sumicommActualTD + (Decimal)agr.get('commActTD');
            
            ifxDirectActualTDMap.put((String)agr.get('teamTar'), sumifxDirectActualTD);
            ifxInDirectActualTDMap.put((String)agr.get('teamTar'), sumifxInDirectActualTD);
            iirrmActualTDMap.put((String)agr.get('teamTar'), sumiirrmActualTD);
            icommActualTDMap.put((String)agr.get('teamTar'), sumicommActualTD);
            
            
        }

        JournalQuery = 'SELECT ID, Journal_ProductFamily__c, Journal_Amount__c, Journal_IsQ6Available__c, '+
            'Journal_BranchNumber__c, Journal_CorpCode__c, Journal_TransactionType__c, '+
            'Journal_TSMName__c, Journal_TSMTarget__c, Journal_BankerName__c, '+
            'Journal_Team__c, Journal_TeamName__c, Journal_Centre__c, Journal_Region__c, '+ 
            'Journal_Division__c, Journal_Group__c, Journal_TSM__c, CreatedDate  '+
            'FROM JournalLineItem__c '+
            'WHERE Journal_BankerName__c IN :innerSet AND Journal_TeamName__c IN :outerSet AND '+
            'CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate '+
            'ORDER BY Journal_TeamName__c, Journal_BankerName__c, CreatedDate';
        
        
        for(JournalLineItem__c eachID : Database.query(SetQuery))
        {
            String combineID = (String)eachID.Journal_TeamName__c + (String)eachID.Journal_BankerName__c;
            
            combineIdSet.add(combineID);
            
        }

        for(JournalLineItem__c eachRec : Database.query(JournalQuery))
        {
            String combineId = '';
            combineId = (String)eachRec.Journal_TeamName__c + (String)eachRec.Journal_BankerName__c;

            Decimal fxDirectActuals = 0.00;
            Decimal fxIndirectActuals = 0.00;
            Decimal retailActuals = 0.00;
            Decimal commActuals = 0.00;
            Decimal irrmActuals = 0.00;
            
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
            
            outerMap.put(combineId, eachRec.Journal_BankerName__c);
            innerMap.put(combineId, eachRec.Journal_TeamName__c);
            
            
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
        //for(String keys : combineIdSet)
        //{
        for(String out : outerSet)  
        {
            List<String> icentresAndTeam = new List<String>();
            List<Decimal> iactualsTillDate = new List<Decimal>();
            grouper = false;
            counter = 0;
            icentresAndTeam.add('Subtotal');
            icentresAndTeam.add(out);
            
            List<String> ifxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                List<String> ifxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                    
                    List<String> icommActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                        List<String> iirrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                            
                            for(String inn : innerSet)
                        {
                            String keys = out + inn;
                            

                            List<Decimal> actuals = new List<Decimal>();
                            List<Decimal> actualsTillDate = new List<Decimal>();
                            List<String> centresAndTeam = new List<String>();
                            
                            List<String> fxDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                List<String> fxInDirectActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                        List<String> commActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                            List<String> irrmActuals = new List<String>{'0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00'};
                                                
                                                
                                                completeList = new List<String>();
                            
                            
                            centresAndTeam.add((String)outerMap.get(keys));
                            centresAndTeam.add((String)innerMap.get(keys));
                            actuals.add((Decimal)fxDirectActualMap.get(keys));
                            actuals.add((Decimal)fxInDirectActualMap.get(keys));
                            actuals.add((Decimal)commActualMap.get(keys));
                            actuals.add((Decimal)irrmActualMap.get(keys));
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
                                    
                                }
                                
                            }   
                            if(innerMap.get(keys) != null)
                            {
                                grouper = true;
                                counter = counter + 1;
                                Decimal ytdPipeline = 0.00;
                                if((Decimal)oppMap.get(keys) != null)
                                    ytdPipeLine = (Decimal)oppMap.get(keys);
                                else
                                    ytdPipeLine = 0.00;
                                wrappedDataList.add(new WrapperClass((String[])centresAndTeam, (String[])descriptionList, (String[])fxDirectActuals,
                                                                     (String[])fxInDirectActuals, (String[])commActuals,
                                                                     (String[])irrmActuals, (Decimal[])actualsTillDate, (Decimal)ytdPipeLine, false));
                            }
                            
                            
                            
                        }
            if(grouper == true && counter > 1)
            {
                Decimal tPipeLine = 0.00;
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
                
                if(totalPipeLineMap.get(out) != null)
                    tPipeLine = totalPipeLineMap.get(out);
                
                
				iactualsTillDate.add((Decimal)ifxDirectActualTDMap.get(out));
                iactualsTillDate.add((Decimal)ifxInDirectActualTDMap.get(out));
                iactualsTillDate.add((Decimal)icommActualTDMap.get(out));
                iactualsTillDate.add((Decimal)iirrmActualTDMap.get(out));
				System.debug('actualsTillDate'+iactualsTillDate);
                wrappedDataList.add(new WrapperClass((String[])icentresAndTeam, (String[])descriptionList,  
                                                     (String[])ifxDirectActuals, 
                                                     (String[])ifxInDirectActuals,  (String[])icommActuals, 
                                                     (String[])iirrmActuals, (Decimal[])iactualsTillDate, (Decimal)tPipeLine, true));
                
                
            }
        }
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/RMPerformanceYTDDld');
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
        Public Boolean groupIt {get; set;}
        Public WrapperClass(List<String> centresAndTeam, List<String>descriptionList, List<String> fxDirectActuals, List<String> fxInDirectActuals,
                            List<String> commActuals, List<String> irrmActuals, 
                            List<Decimal> actualsTillDate, Decimal ytdPipeLine, Boolean groupIt)
        {
            
            
            this.bc = centresAndTeam[1]; 
            this.rm =  centresAndTeam[0];
            this.descriptionList = descriptionList;
            this.FXDirectActual = fxDirectActuals;
            
            this.FXIndirectActual = fxInDirectActuals;
            
            this.CommActual = commActuals;
            
            this.IRRMActual = irrmActuals;
            this.fxDirectActualsTillDate = actualsTillDate[0];
            this.fxInDirectActualsTillDate = actualsTillDate[1];
            this.commActualsTillDate = actualsTillDate[2];
            this.irrmActualsTillDate = actualsTillDate[3];
            this.ytdPipeLine = ytdPipeLine;
            this.groupIt = groupIt;
        }
    }
}