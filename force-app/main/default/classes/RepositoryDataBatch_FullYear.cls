/*
@Author        : Santhoshan
@Name          : RepositoryBatch
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to convert the TSM Targets to the Current Fiscal Year
@version       : 1.0
*/
global class RepositoryDataBatch_FullYear implements Database.Batchable<sObject>{
    Public static Map<String, Repository__c> wholeMap;
    Public static Map<String, Repository__c> wholeMap1;
    Public static List<Map<String, Repository__c>> listValues;
    Public static List<Map<String, Repository__c>> listValues1;
    Public static List<Map<String, Repository__c>> listValues2;
    Public static List<Map<String, Repository__c>> listValues3;
    Public static List<Map<String, Repository__c>> listValues4;
    Public static List<Map<String, Repository__c>> listValues5;
    Public static List<Map<String, Repository__c>> listValues7;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('HELLO');
        
        /* @Santhoshan - Batch Calculation for Current Month - Start */
        Integer currMonth = System.today().month();
        Integer daysInMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date endDate = Date.newInstance(System.today().year(), System.today().month(), daysInMonth);
        
        Date fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        
        List<Repository__c> del = new List<Repository__c>();
        
        //if(System.today().month() == fyStartMonth) 
            del = [SELECT Id FROM Repository__c WHERE RecordType.Name NOT IN ('CustomerAndPM', 'Event and Task')];
        /*else 
            del = [SELECT Id FROM Repository__c WHERE RecordType.Name NOT IN ('CustomerAndPM', 'EventAndTask') AND Rep_Month__c = :currMonth];
        */
        
        if(!del.isEmpty())
            delete del;
        /* @Santhoshan - Batch Calculation for Current Month - End */
        
        String query = 'SELECT ID, RecordType.Name, Amount, isQ6Available__c, '+
            'Opp_BranchNumber__c, Opp_CorpCode__c, StageName, Account.Name, Account.FX_Manager__r.Name, '+
            'OwnerId, Owner.Name, Banker__c, Account.RM_Name__r.Con_Centre__c, Account.RM_Name__r.Officer_Code__c, '+
            'Account.RM_Name__c, Account.RM_Name__r.Name,Account.RM_Name__r.Con_Region__c, Account.RM_Name__r.Con_Division__c,'+
            'Account.RM_Name__r.Con_Team__c, Account.RM_Name__r.Con_Team__r.Name,Account.RM_Name__r.Con_Group__c, '+
            'CreatedDate, CloseDate FROM Opportunity WHERE StageName = \'Closed Won\' AND Amount != '+0+
            ' AND CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate '+
            ' ORDER BY CloseDate'; 
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        System.debug('OPPPPPP');
        System.debug('Opp Size'+scope.size());
        System.debug('Opp'+scope);
        String combineId = '';
        wholeMap= new Map<String, Repository__c>();
        Id BusinessRMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndRM').getRecordTypeId();
        Id BusinessTSMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndTSM').getRecordTypeId();
        Id RegionBusinessRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('RegionAndBusiness').getRecordTypeId();
        Id DivisionRegionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('DivisionAndRegion').getRecordTypeId();
        Id GroupDivisionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        Id BankGroupRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BankAndGroup').getRecordTypeId();
        Id BusinessCustomerRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndCustomer').getRecordTypeId();
        
        List<Repository__c> insertList;
        List<Repository__c> insertList1;
        
        for(Repository__c each : [SELECT Rep_CombineId__c, Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_BusinessActual__c, 
                                  Rep_CommodityActual__c, Rep_IRRMActual__c, Rep_RetailActual__c,Rep_FX_Manager__c,Rep_Total__c FROM Repository__c ORDER BY RecordTypeId])
        {
            wholeMap.put(each.Rep_CombineId__c,each);
        }
        
        System.debug('WHOLE MAP>>>>>>>>>>'+wholeMap);
        wholeMap1= new Map<String, Repository__c>();
        Map<String, Decimal> fxDirectActualMap = new Map<String, Decimal>();
        Map<String, Decimal> fxIndirectActualMap = new Map<String, Decimal>();
        Map<String, Decimal> commActualMap = new Map<String, Decimal>();
        Map<String, Decimal> irrmActualMap = new Map<String, Decimal>();
        Map<String, Decimal> retailActualMap = new Map<String, Decimal>();
        List<Repository__c> reposList = new List<Repository__c>();
        
        for(Opportunity eachOpp : scope)
        {
        
            insertList = new List<Repository__c>();
            insertList1 = new List<Repository__c>();
            
            Repository__c reposObj = new Repository__c();
            Repository__c reposObj1 = new Repository__c();
            Repository__c reposObj2 = new Repository__c();
            Repository__c reposObj3 = new Repository__c();
            Repository__c reposObj4 = new Repository__c();
            Repository__c reposObj5 = new Repository__c();
            Repository__c reposObj6 = new Repository__c();
            Repository__c reposObj7 = new Repository__c();
            
            /*if(eachOpp.Account.RM_Name__r.Con_Team__r.Name =='CB_St Albans' && eachOpp.Account.RM_Name__r.name=='IAN APPS' 
&& eachOpp.RecordType.Name == 'FX Cash' && eachOpp.createddate.month()==8){
system.debug('This is check ABC'+eachOpp.RecordType.Name);
system.debug('This is check XYZ'+eachOpp.Amount);
}*/
            
            // Condition checking Starts  Here
            //Codes Start Here
            
            combineId = reposObj.Rep_CombineId__c = (String)eachOpp.Account.RM_Name__r.Con_Team__c +','+ (String)eachOpp.Account.RM_Name__c +','+ eachOpp.CloseDate.month()+','+'TR';
            if(Test.isRunningTest())
            {
                listValues = RespsitoryData.dataInsert(wholeMap,wholeMap,eachOpp,combineId,BusinessRMRecordType);
                listValues = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,BusinessRMRecordType);
            }
            else
            {
                listValues = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,BusinessRMRecordType);
            }
            System.debug('wholeMap'+listValues);
            System.debug('wholeMap[0]'+listValues[0]);
                
            /*if(listValues.size() > 1)
            {
                wholeMap = listValues[0];
                wholeMap1 = listValues[1];
                insertList = wholeMap1.values();
                insertList1 = wholeMap.values();
            }
            else
            {*/
               if(!wholeMap.containsKey(combineId))
            {
                wholeMap1 = listValues[0];
                
                //insertList = wholeMap1.values();
            }
            else
            {
                System.debug('WHOLEMAP NEW DEBUG>>>>>>>>');
                System.debug('NEW ID?>>>>>>'+wholeMap.get(combineId));
                wholeMap = listValues[0];
                System.debug('NEW ID AFTER?>>>>>>'+wholeMap.get(combineId));
                
            }
           // }
            
            
            
            combineId = reposObj1.Rep_CombineId__c = eachOpp.Account.RM_Name__r.Con_Team__r.Name +','+ eachOpp.Owner.Name +','+ eachOpp.CloseDate.month()+','+'TF';
            listValues1 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,BusinessTSMRecordType);
            System.debug('wholeMap'+listValues1);
            System.debug('wholeMap[0]'+listValues1[0]);

            /*if(listValues.size() > 1)
            {
                wholeMap = listValues[0];
                wholeMap1 = listValues[1];
                insertList = wholeMap1.values();
                insertList1 = wholeMap.values();
            }
            else
            {*/
                if(!wholeMap.containsKey(combineId))
            {
                wholeMap1 = listValues1[0];
                //insertList = wholeMap1.values();
            }
            else
            {
                wholeMap = listValues1[0];
            }
            //}    
            
          
            combineId = '';
            combineId = reposObj2.Rep_CombineId__c = eachOpp.Account.RM_Name__r.Con_Centre__c +','+ eachOpp.Account.RM_Name__r.Con_Team__r.Name +','+ eachOpp.CloseDate.month()+','+'RT';
            listValues2 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,RegionBusinessRecordType);
            System.debug('wholeMap'+listValues2);
            System.debug('wholeMap[0]'+listValues2[0]);

            /*if(listValues.size() > 1)
            {
                wholeMap = listValues[0];
                wholeMap1 = listValues[1];
                insertList = wholeMap1.values();
                insertList1 = wholeMap.values();
            }
            else
            {*/
            
            if(!wholeMap.containsKey(combineId))
            {
                wholeMap1 = listValues2[0];
                //insertList = wholeMap1.values();
            }
            else
            {
                wholeMap = listValues2[0];
            }
                
                
            //}
            
              combineId = reposObj3.Rep_CombineId__c = eachOpp.Account.RM_Name__r.Con_Region__c +','+ eachOpp.Account.RM_Name__r.Con_Centre__c +','+ eachOpp.CloseDate.month()+','+'DR';
            listValues3 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,DivisionRegionRecordType);
            System.debug('wholeMap DivisionRegionRecordType'+listValues3);
            System.debug('wholeMap[0] DivisionRegionRecordType'+listValues3[0]);

            /*if(listValues.size() > 1)
            {
                wholeMap = listValues[0];
                wholeMap1 = listValues[1];
                insertList = wholeMap1.values();
                insertList1 = wholeMap.values();
            }
            else
            {*/
            System.debug('Before FINAL List'+listValues3[0]);
            System.debug('Before FINAL combineId'+combineId);
            System.debug('Before FINAL Boolean'+wholeMap.containsKey(combineId));
            
            if(!wholeMap.containsKey(combineId))
            {
                wholeMap1 = listValues3[0];
                //insertList = wholeMap1.values();
            }
            else
            {
                wholeMap = listValues3[0];
            }
            //}
            
            String groupName;
            String divisionName;
            
            //
            if(eachOpp.Account.RM_Name__r.Con_Division__c != null && eachOpp.Account.RM_Name__r.Con_Region__c != null)
            {
                groupName = eachOpp.Account.RM_Name__r.Con_Division__c;
                divisionName = eachOpp.Account.RM_Name__r.Con_Region__c;
            }
            else if(eachOpp.Opp_CorpCode__c != null)
            {
                if(eachOpp.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                {
                    groupName = System.Label.Retail_Group;
                    divisionName = System.Label.Retail_Division;
                }
                else if(eachOpp.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                {
                    groupName = System.Label.YB_Retail_Group;
                    divisionName = System.Label.YB_Retail_Division;
                }
            }
            
            if(groupName != null && divisionName != null)
            {
                combineId = reposObj4.Rep_CombineId__c = groupName +','+ divisionName +','+ eachOpp.CloseDate.month()+','+'GD';
                listValues4 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,GroupDivisionRecordType);
                System.debug('wholeMap'+listValues4);
                System.debug('wholeMap[0]'+listValues4[0]);
                
                /*if(listValues.size() > 1)
{
wholeMap = listValues[0];
wholeMap1 = listValues[1];
insertList = wholeMap1.values();
insertList1 = wholeMap.values();
}
else
{*/
                if(!wholeMap.containsKey(combineId))
                {
                    wholeMap1 = listValues4[0];
                    //insertList = wholeMap1.values();
                }
                else
                {
                    wholeMap = listValues4[0];
                }
                //}
                
            }
            
            
            
            
            //Business Centre and Customer - Santhoshan
            String bcName;
            String cusName;
            
            //
            if(eachOpp.Account.RM_Name__r.Con_Team__r.Name != null && eachOpp.Account.Name != null)
            {
                bcName = eachOpp.Account.RM_Name__r.Con_Team__r.Name;
                cusName = eachOpp.Account.Name;
            }
            else if(eachOpp.Opp_CorpCode__c != null)
            {
                if(eachOpp.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                {
                    bcName = 'CB_Retail';
                }
                else if(eachOpp.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                {
                    bcName = 'YB Retail';
                }
            }
            
            if(bcName != null && cusName != null)
            {
                combineId = reposObj7.Rep_CombineId__c = bcName +','+ cusName +','+'TC';
                listValues7 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,BusinessCustomerRecordType);
                System.debug('wholeMap'+listValues7);
                System.debug('wholeMap[0]'+listValues7[0]);
                
                /*if(listValues.size() > 1)
{
wholeMap = listValues[0];
wholeMap1 = listValues[1];
insertList = wholeMap1.values();
insertList1 = wholeMap.values();
}
else
{*/
                if(!wholeMap.containsKey(combineId))
                {
                    wholeMap1 = listValues7[0];
                    //insertList = wholeMap1.values();
                }
                else
                {
                    wholeMap = listValues7[0];
                }
                //}
                
            }
            //Ends Business Centre and Customer
            
            
            String bankName;
            String groupNamebg;
            
            // 
            if(eachOpp.Account.RM_Name__r.Con_Group__c != null && eachOpp.Account.RM_Name__r.Con_Division__c != null)
            {
                bankName = eachOpp.Account.RM_Name__r.Con_Group__c;
                groupNamebg = eachOpp.Account.RM_Name__r.Con_Division__c;
            }
            else if(eachOpp.Opp_CorpCode__c != null)
            {
                if(eachOpp.Opp_CorpCode__c == System.Label.CB_Corp_Code)
                {
                    groupNamebg = System.Label.Retail_Group;
                    bankName = System.Label.Retail_Bank;
                }
                else if(eachOpp.Opp_CorpCode__c == System.Label.YB_Corp_Code)
                {
                    groupNamebg = System.Label.YB_Retail_Group;
                    bankName = System.Label.Retail_Bank;
                }
            }
            
            if(groupNamebg != null && bankName != null)
            {
                combineId = reposObj5.Rep_CombineId__c = bankName +','+ groupNamebg +','+ eachOpp.CloseDate.month()+','+'BG';
                listValues5 = RespsitoryData.dataInsert(wholeMap,wholeMap1,eachOpp,combineId,BankGroupRecordType);
                System.debug('wholeMap'+listValues5);
                System.debug('wholeMap[0]'+listValues5[0]);
                
                /*if(listValues.size() > 1)
{
wholeMap = listValues[0];
wholeMap1 = listValues[1];
insertList = wholeMap1.values();
insertList1 = wholeMap.values();
}
else
{*/
                if(!wholeMap.containsKey(combineId))
                {
                    wholeMap1 = listValues5[0];
                    //insertList = wholeMap1.values();
                }
                else
                {
                    wholeMap = listValues5[0];
                }
            }
        }
        System.debug('Whole >>>>'+wholeMap);
        //insert reposList;
        //insertList1 = wholeMap.values();
        upsert insertList1;
        insertList = wholeMap1.values();

        Database.SaveResult[] updateResult = Database.Insert(insertList, False); 
        System.debug('WHOLEMAP NEW FINAL>>>>>>>>>'+wholeMap);
        System.debug('WHOLEMAP 1 NEW FINAL>>>>>>>'+wholeMap1);
        //update wholeMap.values();
        Database.SaveResult[] updateResult1 = Database.Update(wholeMap.values(), False); 
        System.debug('Insert Result'+updateResult);
        //System.debug('Update Result'+updateResult1);
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}