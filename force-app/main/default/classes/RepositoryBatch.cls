/*
@Author        : Santhoshan
@Name          : RepositoryBatch
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to convert the TSM Targets to the Current Fiscal Year
@version       : 1.0
*/
global class RepositoryBatch implements Database.Batchable<sObject>{
    Public static Map<String, Repository__c> wholeMap= new Map<String, Repository__c>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('HELLO');
        List<Repository__c> del = [SELECT Id FROM Repository__c];
       if(del.size() > 0)
            delete del;
        
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        
        String query = 'SELECT ID, RecordType.Name, Amount, isQ6Available__c, '+
            'Opp_BranchNumber__c, Opp_CorpCode__c, StageName, '+
            'OwnerId, Owner.Name, Banker__c, '+
            'Account.RM_Name__c, Account.RM_Name__r.Name, '+
            'Account.RM_Name__r.Con_Team__c, Account.RM_Name__r.Con_Team__r.Name, '+
            'CreatedDate FROM Opportunity WHERE StageName = \'Closed Won\' AND Amount != '+0+
            ' AND Account.RM_Name__c != '+null+' AND Account.RM_Name__r.Con_Team__c != '+null+
            ' AND CreatedDate >= :fyStartDate AND CreatedDate <= :fyEndDate '+
            ' ORDER BY CreatedDate';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        System.debug('OPPPPPP');
        System.debug('Opp Size'+scope.size());
        System.debug('Opp'+scope);
        String combineId = '';
        
        for(Repository__c each : [SELECT Rep_CombineId__c, Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c])
        {
            wholeMap.put(each.Rep_CombineId__c,each);
        }
        System.debug('WHOLE MAP SIZE>>>>>>>>>>'+wholeMap.size());
        Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
        Map<String, Decimal> fxDirectActualMap = new Map<String, Decimal>();
        Map<String, Decimal> fxIndirectActualMap = new Map<String, Decimal>();
        Map<String, Decimal> commActualMap = new Map<String, Decimal>();
        Map<String, Decimal> irrmActualMap = new Map<String, Decimal>();
        List<Repository__c> reposList = new List<Repository__c>();
        for(Opportunity eachOpp : scope)
        {
            combineId = (String)eachOpp.Account.RM_Name__r.Con_Team__c +','+ (String)eachOpp.Account.RM_Name__c +','+ eachOpp.CreatedDate.month();
            Repository__c reposObj = new Repository__c();
            /*if(eachOpp.Account.RM_Name__r.Con_Team__r.Name =='CB_St Albans' && eachOpp.Account.RM_Name__r.name=='IAN APPS' 
               && eachOpp.RecordType.Name == 'FX Cash' && eachOpp.createddate.month()==8){
                system.debug('This is check ABC'+eachOpp.RecordType.Name);
                system.debug('This is check XYZ'+eachOpp.Amount);
            }*/
            if(wholeMap.containsKey(combineId))
            {
                reposObj = wholeMap.get(combineId);
                if(eachOpp.RecordType.Name == 'FX Cash')    
                {
                    if(eachOpp.Opp_BranchNumber__c == System.Label.CBDirectDealingClient || 
                       eachOpp.Opp_BranchNumber__c == System.Label.YBDirectDealingClient)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            //fxDirectActuals = fxDirectActuals + ags.get('amount');
                            //directSum = directSum + (Decimal)eachOpp.Amount;
                            //   fxDirectActualMap.put(combineId, (Decimal)eachOpp.Amount + (Decimal)fxDirectActualMap.get(combineId));
                          
                            
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXDirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXDirectActual__c;
                            
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXDirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXDirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXDirectActual__c);
                            
                        }
                    }
                    else if(eachOpp.Opp_BranchNumber__c == System.Label.CBCardedRateSheet || eachOpp.Opp_BranchNumber__c == System.Label.YBCardedRateSheet ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBIndirect || eachOpp.Opp_BranchNumber__c == System.Label.YBIndirect ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBSortingCode || eachOpp.Opp_BranchNumber__c == System.Label.YBSortingCode ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBGeneric || eachOpp.Opp_BranchNumber__c == System.Label.YBGeneric)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            
                            //fxIndirectActuals = fxIndirectActuals + ags.get('amount');
                            //indirectSum = indirectSum + (Decimal)eachOpp.get('amount');
                            //fxInDirectActualMap.put((String)combineId, indirectSum);
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXIndirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXIndirectActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                        }
                        
                    }
                    else if(eachOpp.Opp_BranchNumber__c == null)
                    {
                        //indirectSum = indirectSum + (Decimal)ags.get('amount');
                        // fxInDirectActualMap.put((String)combineId, indirectSum);
                        Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXIndirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXIndirectActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c); 
                        //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                    }
                }
                else if(eachOpp.RecordType.Name == 'Commodity') 
                {
                    //commSum = commSum + (Decimal)ags.get('amount');
                    //commActualMap.put((String)combineId, commSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_CommodityActual__c != null)
                                tempVar = tempVar + reposObj.Rep_CommodityActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_CommodityActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_CommodityActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_CommodityActual__c);
                    //reposObj.Rep_CommodityActual__c = reposObj.Rep_CommodityActual__c!=null?reposObj.Rep_CommodityActual__c:0 + eachOpp.Amount;
                }
                
                else if(eachOpp.RecordType.Name == 'IRRM')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_IRRMActual__c != null)
                                tempVar = tempVar + reposObj.Rep_IRRMActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_IRRMActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_IRRMActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_IRRMActual__c);
                   // reposObj.Rep_IRRMActual__c = reposObj.Rep_IRRMActual__c!=null?reposObj.Rep_IRRMActual__c:0 + eachOpp.Amount;
                }
                System.debug('This is a check RESPOBJ'+reposObj);
                System.debug('This is a check Rep . reposObj'+reposObj.Rep_FXDirectActual__c);
                wholeMap.put(combineId, reposObj);
                System.debug('WHOLEMAP>>>>>>>>>>>>>>>>'+wholeMap);
            }
            else if(wholeMap1.containsKey(combineId))
            {
                System.debug('HERE IN ELSE IF>>>>>>>>>>>>>>>');
                reposObj = wholeMap1.get(combineId);
                if(eachOpp.RecordType.Name == 'FX Cash')    
                {
                    if(eachOpp.Opp_BranchNumber__c == System.Label.CBDirectDealingClient || 
                       eachOpp.Opp_BranchNumber__c == System.Label.YBDirectDealingClient)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            //fxDirectActuals = fxDirectActuals + ags.get('amount');
                            //directSum = directSum + (Decimal)eachOpp.Amount;
                            
                             //   fxDirectActualMap.put(combineId, (Decimal)eachOpp.Amount + (Decimal)fxDirectActualMap.get(combineId));
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXDirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXDirectActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXDirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXDirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXDirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            
                        }
                    }
                    else if(eachOpp.Opp_BranchNumber__c == System.Label.CBCardedRateSheet || eachOpp.Opp_BranchNumber__c == System.Label.YBCardedRateSheet ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBIndirect || eachOpp.Opp_BranchNumber__c == System.Label.YBIndirect ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBSortingCode || eachOpp.Opp_BranchNumber__c == System.Label.YBSortingCode ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBGeneric || eachOpp.Opp_BranchNumber__c == System.Label.YBGeneric)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXIndirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXIndirectActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                        }
                        
                    }
                    else if(eachOpp.Opp_BranchNumber__c == null)
                    {
                        //indirectSum = indirectSum + (Decimal)ags.get('amount');
                        // fxInDirectActualMap.put((String)combineId, indirectSum);
                        Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXIndirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXIndirectActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c);
                        //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                    }
                }
                else if(eachOpp.RecordType.Name == 'Commodity') 
                {
                    //commSum = commSum + (Decimal)ags.get('amount');
                    //commActualMap.put((String)combineId, commSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_CommodityActual__c != null)
                                tempVar = tempVar + reposObj.Rep_CommodityActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_CommodityActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_CommodityActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_CommodityActual__c);
                    //reposObj.Rep_CommodityActual__c = reposObj.Rep_CommodityActual__c!=null?reposObj.Rep_CommodityActual__c:0 + eachOpp.Amount;
                }
                
                else if(eachOpp.RecordType.Name == 'IRRM')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_IRRMActual__c != null)
                                tempVar = tempVar + reposObj.Rep_IRRMActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_IRRMActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            if(eachOpp.Amount != null)
                            reposObj.Rep_IRRMActual__c = tempVar + eachOpp.Amount;
                            system.debug('This is Check Query After  PQR '+reposObj.Rep_IRRMActual__c);
                    //reposObj.Rep_IRRMActual__c = reposObj.Rep_IRRMActual__c!=null?reposObj.Rep_IRRMActual__c:0 + eachOpp.Amount;
                }
                wholeMap1.put(combineId, reposObj);
                System.debug('WHOLEMAP>>>>>>>>>>>>>>>>'+wholeMap1);
            
            }
            else
            {
                System.debug('HERE IN ELSE>>>>>>>>>>>>>>>');
                reposObj.Rep_CombineId__c = combineId;
                reposObj.Rep_Month__c = eachOpp.CreatedDate.month();
                reposObj.Rep_BusinessCentreId__c = (String)eachOpp.Account.RM_Name__r.Con_Team__c;
                reposObj.Rep_RMId__c = (String)eachOpp.Account.RM_Name__c;
                reposObj.Rep_BusinessCentre__c = (String)eachOpp.Account.RM_Name__r.Con_Team__r.Name;
                reposObj.Rep_RMName__c = (String)eachOpp.Account.RM_Name__r.Name;
                reposObj.Rep_MonthText__c = String.valueOf(eachOpp.CreatedDate.month());
                if(eachOpp.RecordType.Name == 'FX Cash')    
                {
                    if(eachOpp.Opp_BranchNumber__c == System.Label.CBDirectDealingClient || 
                       eachOpp.Opp_BranchNumber__c == System.Label.YBDirectDealingClient)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            //fxDirectActuals = fxDirectActuals + ags.get('amount');
                            //directSum = directSum + (Decimal)eachOpp.Amount;
                            
                             //   fxDirectActualMap.put(combineId, (Decimal)eachOpp.Amount + (Decimal)fxDirectActualMap.get(combineId));
                             //   
                         
                            reposObj.Rep_FXDirectActual__c = eachOpp.Amount;
                        }
                    }
                    else if(eachOpp.Opp_BranchNumber__c == System.Label.CBCardedRateSheet || eachOpp.Opp_BranchNumber__c == System.Label.YBCardedRateSheet ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBIndirect || eachOpp.Opp_BranchNumber__c == System.Label.YBIndirect ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBSortingCode || eachOpp.Opp_BranchNumber__c == System.Label.YBSortingCode ||
                            eachOpp.Opp_BranchNumber__c == System.Label.CBGeneric || eachOpp.Opp_BranchNumber__c == System.Label.YBGeneric)
                    {
                        if(eachOpp.isQ6Available__c == true)
                        {
                            
                            //fxIndirectActuals = fxIndirectActuals + ags.get('amount');
                            //indirectSum = indirectSum + (Decimal)eachOpp.get('amount');
                            //fxInDirectActualMap.put((String)combineId, indirectSum);
                            reposObj.Rep_FXIndirectActual__c = eachOpp.Amount;
                        }
                        
                    }
                    else if(eachOpp.Opp_BranchNumber__c == null)
                    {
                        //indirectSum = indirectSum + (Decimal)ags.get('amount');
                        // fxInDirectActualMap.put((String)combineId, indirectSum);
                        reposObj.Rep_FXIndirectActual__c = eachOpp.Amount;
                    }
                }
                else if(eachOpp.RecordType.Name == 'Commodity') 
                {
                    //commSum = commSum + (Decimal)ags.get('amount');
                    //commActualMap.put((String)combineId, commSum);
                    reposObj.Rep_CommodityActual__c = eachOpp.Amount;
                }
                
                else if(eachOpp.RecordType.Name == 'IRRM')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    reposObj.Rep_IRRMActual__c = eachOpp.Amount;
                }
                wholeMap1.put(combineId, reposObj);
            }
            
            //reposList.add(wholeMap);
        }
        System.debug('Whole >>>>'+wholeMap);
        //insert reposList;
        List<Repository__c> insertList = new List<Repository__c>();
        insertList = wholeMap1.values();
        List<Repository__c> insertList1 = new List<Repository__c>();
        insertList1 = wholeMap.values();
        if(!Test.isRunningTest()) 
        {
        update insertList1;
        }
        insert insertList;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}