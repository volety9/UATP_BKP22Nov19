public class RespsitoryData_PSD2 {
    
    Public static Map<String, Repository__c> wholeMap= new Map<String, Repository__c>();
    Public static Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
    Public static Map<String, Repository__c> wholeMapUpdatedList= new Map<String, Repository__c>();
    
    Public Static List<Map<String, Repository__c>> dataInsert(Map<String, Repository__c> map1,Map<String, Repository__c> map2,Opportunity eachopp,String combineId, String recId)
    {    
      Map<String, Repository__c> wholeMap= new Map<String, Repository__c>();
      Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
      List<Map<String, Repository__c>>wholemapList = new List<Map<String, Repository__c>>();  
        wholeMap = map1;
        wholeMap1 = map2;
        Repository__c reposObj = new Repository__c();
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
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_FXDirectActual__c != null)
                                tempVar = tempVar + reposObj.Rep_FXDirectActual__c;
                            
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_FXDirectActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXDirect>>>>'+reposObj.Rep_FXDirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXDirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN FXDirect After '+reposObj.Rep_FXDirectActual__c);
                            
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_FXDirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN FXIndirect '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                        }
                        else
                        {
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_RetailActual__c != null)
                                tempVar = tempVar + reposObj.Rep_RetailActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_RetailActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_RetailActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_RetailActual__c = tempVar + eachOpp.Amount;
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_FXIndirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c); 
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXCommodity>>>>'+reposObj.Rep_CommodityActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_CommodityActual__c = tempVar + eachOpp.Amount;
                    
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_CommodityActual__c);
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN IRRM>>>>'+reposObj.Rep_IRRMActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_IRRMActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_IRRMActual__c);
                   // reposObj.Rep_IRRMActual__c = reposObj.Rep_IRRMActual__c!=null?reposObj.Rep_IRRMActual__c:0 + eachOpp.Amount;
                }
                else if(eachOpp.RecordType.Name == 'Business Loan')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_BusinessActual__c != null)
                                tempVar = tempVar + reposObj.Rep_BusinessActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_BusinessActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN Rep_BusinessActual__c>>>>'+reposObj.Rep_BusinessActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_BusinessActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_BusinessActual__c);
                   // reposObj.Rep_BusinessActual__c = reposObj.Rep_BusinessActual__c!=null?reposObj.Rep_BusinessActual__c:0 + eachOpp.Amount;
                }
                System.debug('Rep_Total__c>>>>>&& '+reposObj.Rep_Total__c);
                System.debug('Amount>>>>>&& '+eachOpp.Amount);
                if(reposObj.Rep_Total__c != null)
                	reposObj.Rep_Total__c = reposObj.Rep_Total__c + eachOpp.Amount;
                
                System.debug('This is a check RESPOBJ'+reposObj);
                System.debug('This is a check Rep . reposObj'+reposObj.Rep_FXDirectActual__c);
                System.debug('INN WHOLE Map'+ wholeMap.get(combineId));
                //wholeMap.put(combineId, reposObj);
                wholeMapUpdatedList.put(combineId, reposObj);
                System.debug('INN Whole Map Ltr'+ wholeMap.get(combineId));
                
            wholemapList.add(wholeMapUpdatedList);
                System.debug('WHOLEMAP>>>>>>>>>>>>>>>>'+wholeMap);
            }   
        ////////////////////////////////////////
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_FXDirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXDirectActual__c = tempVar + eachOpp.Amount;
                            system.debug(' INN This is Check Query After  PQR '+reposObj.Rep_FXDirectActual__c);
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_FXIndirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c);
                            //reposObj.Rep_FXIndirectActual__c = reposObj.Rep_FXIndirectActual__c!=null?reposObj.Rep_FXIndirectActual__c:0 + eachOpp.Amount;
                        }
                        else
                        {
                            Decimal tempVar = 0.00;
                            if(reposObj.Rep_RetailActual__c != null)
                                tempVar = tempVar + reposObj.Rep_RetailActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_RetailActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_RetailActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_RetailActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_RetailActual__c);
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_FXIndirectActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_FXIndirectActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_FXIndirectActual__c);
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_CommodityActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_CommodityActual__c = tempVar + eachOpp.Amount;
                            system.debug('INN This is Check Query After  PQR '+reposObj.Rep_CommodityActual__c);
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
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_IRRMActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_IRRMActual__c = tempVar + eachOpp.Amount;
                            system.debug('Inn This is Check Query After  PQR '+reposObj.Rep_IRRMActual__c);
                    //reposObj.Rep_IRRMActual__c = reposObj.Rep_IRRMActual__c!=null?reposObj.Rep_IRRMActual__c:0 + eachOpp.Amount;
                }
                else if(eachOpp.RecordType.Name == 'Business Loan')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    Decimal tempVar = 0.00;
                            if(reposObj.Rep_BusinessActual__c != null)
                                tempVar = tempVar + reposObj.Rep_BusinessActual__c;
                            system.debug('This is Check Query Before  PQR '+reposObj.Rep_BusinessActual__c);
                            //reposObj.Rep_FXDirectActual__c = reposObj.Rep_FXDirectActual__c!=null?reposObj.Rep_FXDirectActual__c:0 + eachOpp.Amount;
                            System.debug('INN AMount>>>>'+eachOpp.Amount);
                            System.debug('INN FXIndirect>>>>'+reposObj.Rep_BusinessActual__c);
                            if(eachOpp.Amount != null)
                            reposObj.Rep_BusinessActual__c = tempVar + eachOpp.Amount;
                            system.debug('Inn This is Check Query After  PQR '+reposObj.Rep_BusinessActual__c);
                    //reposObj.Rep_BusinessActual__c = reposObj.Rep_BusinessActual__c!=null?reposObj.Rep_BusinessActual__c:0 + eachOpp.Amount;
                }
                
                if(reposObj.Rep_Total__c != null)
                	reposObj.Rep_Total__c = reposObj.Rep_Total__c + eachOpp.Amount;
                
                System.debug('INN WholeMap 1'+wholeMap1.get(combineId));
                wholeMap1.put(combineId, reposObj);
                System.debug('INN WholeMap 1 Aftr'+wholeMap1.get(combineId));
                wholemapList.add(wholeMap1);
                System.debug('WHOLEMAP>>>>>>>>>>>>>>>>'+wholeMap1);
            
            }
             /////////////////////// 
            else
            {
                System.debug('HERE IN ELSE>>>>>>>>>>>>>>>');
                //reposObj.Rep_CombineId__c = combineId;
                reposObj.Rep_Month__c = eachOpp.CloseDate.month();
                reposObj.Rep_BusinessCentreId__c = (String)eachOpp.Account.RM_Name__r.Con_Team__c;
                reposObj.Rep_RMId__c = (String)eachOpp.Account.RM_Name__c;
                reposObj.Rep_BusinessCentre__c = (String)eachOpp.Account.RM_Name__r.Con_Team__r.Name;
                reposObj.Rep_RMName__c = (String)eachOpp.Account.RM_Name__r.Name;
                reposObj.Rep_MonthText__c = String.valueOf(eachOpp.CloseDate.month());
                reposObj.Rep_TSMName__c = eachOpp.Owner.Name;
                reposObj.Rep_RegionName__c = eachOpp.Account.RM_Name__r.Con_Centre__c;
                reposObj.Rep_CustomerName__c = eachOpp.Account.Name;
                reposObj.Rep_FX_Manager__c = eachOpp.Account.FX_Manager__r.Name;
                reposObj.Rep_Total__c = 0.00;
                
                if(eachOpp.Account.RM_Name__r.Con_Region__c != null)
                    reposObj.Rep_DivisionName__c = eachOpp.Account.RM_Name__r.Con_Region__c;
                else if(eachOpp.Account.RM_Name__r.Con_Region__c == null  && eachOpp.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                    reposObj.Rep_DivisionName__c = System.Label.Retail_Division;
                else if(eachOpp.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                    reposObj.Rep_DivisionName__c = System.Label.YB_Retail_Division;
                
                if(eachOpp.Account.RM_Name__r.Con_Division__c != null)
                    reposObj.Rep_GroupName__c =  eachOpp.Account.RM_Name__r.Con_Division__c;
                else if(eachOpp.Account.RM_Name__r.Con_Division__c == null  && eachOpp.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                    reposObj.Rep_GroupName__c = System.Label.Retail_Group;
                else if(eachOpp.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                    reposObj.Rep_GroupName__c = System.Label.YB_Retail_Group;
                
                if(eachOpp.Account.RM_Name__r.Con_Group__c != null)
                    reposObj.Rep_BankName__c =  eachOpp.Account.RM_Name__r.Con_Group__c;
                else
                    reposObj.Rep_BankName__c = System.Label.Retail_Bank;
                
                reposObj.Rep_CombineId__c = combineId;
                reposObj.RecordTypeId = recId;
                reposObj.Rep_Q6Code__c = eachOpp.Account.RM_Name__r.Officer_Code__c;
                
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
                        else
                        {
                            System.debug('<<<<<<<<<<,HERE I AM >>>>>>>>>>>>');
                            reposObj.Rep_RetailActual__c = eachOpp.Amount;
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
                else if(eachOpp.RecordType.Name == 'Business Loan')  
                {
                    //irrmSum = irrmSum + (Decimal)ags.get('amount');
                    //irrmActualMap.put((String)combineId, irrmSum);
                    reposObj.Rep_BusinessActual__c = eachOpp.Amount;
                    
                }
                
                if(reposObj.Rep_Total__c != null)
                	reposObj.Rep_Total__c = reposObj.Rep_Total__c + eachOpp.Amount;
                
                wholeMap1.put(combineId, reposObj);
                wholemapList.add(wholeMap1);
                System.debug('wholeMap1'+wholeMap1);
            }
          
            // Condition checking ending Here
            //reposList.add(wholeMap);
        
        System.debug('WHOLEMAPLIST'+wholemapList);

        return wholemapList;
    }
}