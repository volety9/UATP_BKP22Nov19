/*
@Author        : Sushant Shekhar
@Name          : CalypsoDataTriggerHandler
@Created Date  : 22nd Dec 2017
@Description   : This is a handler class for the CalypsoDataTrigger
@version       : 1.0
*/ 
    public class CalypsoDataTriggerHandler{
    
    private Map<String, Account> accWithWIDMap = new Map<String, Account>();
    private Map<String, Account> accWithCIFMap = new Map<String, Account>();
    private Map<String, Contact> contactWithNameMap = new Map<String, Contact>();
    private Map<String, Contact> contactWithETTraderIDMap = new Map<String, Contact>();
    private Map<String, Contact> contactWithIDMap = new Map<String, Contact>();
    private Id fxCashOppRTID;
    private List<Q6Values__mdt> Q6ValueList = new List<Q6Values__mdt>();
    private Map<String, String> branchNumwithQ6Map = new Map<String, String>();
    private List<CalypsoData__c> allCDList = new List<CalypsoData__c>(); 
    private List<Contact> conListUpdate = new List<Contact>();
    private List<CDOpp_FieldMap__mdt> cdOppFields = new List<CDOpp_FieldMap__mdt>();
    private List<CalypsoData__c> updateCDStatusList = new List<CalypsoData__c>(); 
    private List<CalypsoData__c> convertToOppCDList = new List<CalypsoData__c>(); 
    private List<Opportunity> oppUpsertList = new List<Opportunity>();
    
    
    /**
* @description       Constructor 
* @name              CalypsoDataTriggerHandler
* @param             null
* @return            void
* @throws            NA
*/ 
    Public CalypsoDataTriggerHandler(){
        //Query Optimization changes
        /*
        for(Account acc : [SELECT ID, Name, OwnerId, Owner.Name, RM_Name__c, FX_Manager__C, CIF__c, WID__c, Officer_Code__c FROM Account WHERE WID__C ='']){
            if(acc.WID__c != Null){
                accWithWIDMap.put(acc.WID__C, acc);
            }
            
            if(acc.CIF__c != Null){
                accWithCIFMap.put(acc.CIF__c, acc);
            }
        }
        */
        //Query Optimization changes - END
        for(Contact con : [SELECT ID, Name, Officer_Code__c, Con_Team__c,CON_ET_Trader_ID__c FROM Contact]){            
            contactWithNameMap.put(con.Name, con);  
            contactWithIDMap.put(con.Id, con); 
            if(con.CON_ET_Trader_ID__c!=null && con.CON_ET_Trader_ID__c!=''){
            contactWithETTraderIDMap.put(con.CON_ET_Trader_ID__c, con); 
            }
        }
        for(Q6Values__mdt q6 : [SELECT Q6Value__c, TradeKeyword__c FROM Q6Values__mdt]){
            branchNumwithQ6Map.put(q6.TradeKeyword__c, q6.Q6Value__c);        
        }
        fxCashOppRTID = [Select Id From RecordType Where SobjectType =:System.Label.Opportunity AND 
                         DeveloperName =:system.label.FXCashOppRecordTypeDevName limit 1].id;
        cdOppFields = [SELECT CDOpp_CD_API__c, CDOpp_Opp_API__c FROM CDOpp_FieldMap__mdt]; 
        
    }
    /**
* @description       Method to create/update an opportunity for each Calypso Data Record
* @name              onAfterInsert
* @param             List<CalypsoData__c> 
* @return            void
* @throws            NA
*/ 
    public void onAfterInsert(List<CalypsoData__c> calDataList) { 
        Set<String> calypsoWID = new Set<String>();
        Set<String> calypsoCIF = new Set<String>();
        List<ID> calDataIdsList = new List<ID>();
        for(CalypsoData__c eachCalData : calDataList){
            system.debug('This on after Insert code ');
            System.debug('eachCalData>>'+eachCalData);
            calDataIdsList.add(eachCalData.id);
            if(eachCalData.CD_WID__c != null){
                calypsoWID.add(eachCalData.CD_WID__c.trim());
                System.debug('calypsoWID>>'+calypsoWID);
            }
            if(eachCalData.CD_CIF__c !=null ){
                calypsoCIF.add(eachCalData.CD_CIF__c.trim());
                System.debug('calypsoCIF>>'+calypsoCIF);
            }
        }                   
        
        Map<Id,Account> tradeMatchingAccounts= new Map<Id,Account>([SELECT ID, Name, OwnerId, Owner.Name, RM_Name__c, FX_Manager__C, CIF__c, WID__c, Officer_Code__c FROM Account WHERE (WID__C IN: calypsoWID) OR (CIF__c IN: calypsoCIF) ]);
         System.debug('tradeMatchingAccounts>>'+tradeMatchingAccounts);
        for(Id eachId :tradeMatchingAccounts.keySet()){
            Account linkAcc = tradeMatchingAccounts.get(eachId);
            System.debug('linkAcc>>'+linkAcc);
            if(linkAcc.WID__c != Null){
                accWithWIDMap.put(linkAcc.WID__C, linkAcc);
            }
            
            if(linkAcc.CIF__c != Null){
                accWithCIFMap.put(linkAcc.CIF__c, linkAcc);
            }
        }
        
        // Fetching the Branch Number - Santhoshan
        allCDList = [Select id, CD_Customer__c, CD_BranchNumber__c, CD_DealExecutedBy__C, 
                     CD_ErrorMessage__c, CD_ConversionStatus__c,CD_TradeID__c, CD_TradeStatus__c 
                     From CalypsoData__c Where ID IN :calDataIdsList];
        
        Integer i = 0;  
        
        
        for(CalypsoData__c eachCalData : calDataList){
            String errorMessage = '';
            String ownerName = '';
            Boolean convert = true;
            Account linkedAccount; 
            // Introduced three new variables - Santhoshan
            Contact linkedContact;
            Boolean tradeKeyword = false;
           
            Boolean runValidation = true;
            Boolean directOrGeneric = false;
            String offCode;
            
            if(eachCalData.CD_UserAction__c == System.Label.Discard){
                errorMessage = System.Label.Cancelled + '\r\n';
                convert = false;
            }
            else if(eachCalData.CD_UserAction__c == System.Label.Save || String.isBlank(eachCalData.CD_UserAction__c)){
                if(eachCalData.CD_HasDuplicate__c){
                    errorMessage = System.Label.FailedETRefMsg + '\r\n';
                    convert = false;
                }
                else{
                    // Start of Change -  Santhoshan
                    
                    if(allCDList[i].CD_BranchNumber__c == System.Label.CBDirectDealingClient || allCDList[i].CD_BranchNumber__c == System.Label.YBDirectDealingClient ||
                       allCDList[i].CD_BranchNumber__c == System.Label.CBCardedRateSheet || allCDList[i].CD_BranchNumber__c == System.Label.YBCardedRateSheet ||
                       allCDList[i].CD_BranchNumber__c == System.Label.CBIndirect || allCDList[i].CD_BranchNumber__c == System.Label.YBIndirect ||
                       allCDList[i].CD_BranchNumber__c == System.Label.CBSortingCode || allCDList[i].CD_BranchNumber__c == System.Label.YBSortingCode ||
                       allCDList[i].CD_BranchNumber__c == System.Label.CBGeneric || allCDList[i].CD_BranchNumber__c == System.Label.YBGeneric)
                    {
                        tradeKeyword = true;
                    }

                    // End of Change - Santhoshan
                    System.debug('here>>>>>>');
                    if( (allCDList[i].CD_BranchNumber__c == System.Label.CBSortingCode || allCDList[i].CD_BranchNumber__c == System.Label.YBSortingCode) && 
                       (eachCalData.CD_CIF__c !=null) && accWithCIFMap.containsKey(eachCalData.CD_CIF__c) )
                    {
                         System.debug('then here>>>>>>');
                        allCDList[i].CD_Customer__c = (accWithCIFMap.get(eachCalData.CD_CIF__c)).ID;
                        linkedAccount = accWithCIFMap.get(eachCalData.CD_CIF__c);
                        offCode = (accWithCIFMap.get(eachCalData.CD_CIF__c)).Officer_Code__c;
                    }  
                    else if(   (eachCalData.CD_WID__c!=null) && accWithWIDMap.containsKey(eachCalData.CD_WID__c) ){
                        allCDList[i].CD_Customer__c = (accWithWIDMap.get(eachCalData.CD_WID__c)).id;
                        linkedAccount = accWithWIDMap.get(eachCalData.CD_WID__c);             
                        offCode = (accWithWIDMap.get(eachCalData.CD_WID__c)).Officer_Code__c;
                    } 
                    
                    else if( (eachCalData.CD_CIF__c !=null) && accWithCIFMap.containsKey(eachCalData.CD_CIF__c) )
                    {
                        allCDList[i].CD_Customer__c = (accWithCIFMap.get(eachCalData.CD_CIF__c)).ID;
                        linkedAccount = accWithCIFMap.get(eachCalData.CD_CIF__c);
                        offCode = (accWithCIFMap.get(eachCalData.CD_CIF__c)).Officer_Code__c;
                    }  
                    
                    else{
                        errorMessage = System.Label.Invalid_WID_and_CIF + '\r\n';
                        convert = false;
                    }
                  /*  if(contactWithNameMap.containsKey(eachCalData.CD_ETTraderID__c)){
                        allCDList[i].CD_DealExecutedBy__c = (contactWithNameMap.get(eachCalData.CD_ETTraderID__c)).id;                              
                    } 
                  */
                    if(contactWithETTraderIDMap.containsKey(eachCalData.CD_ETTraderID__c)){
                        allCDList[i].CD_DealExecutedBy__c = (contactWithETTraderIDMap.get(eachCalData.CD_ETTraderID__c)).id;                              
                    } 
                    

                    //Start of Change -  Santhoshan

                    if(allCDList[i].CD_TradeStatus__c != System.Label.StatusCancelled && allCDList[i].CD_TradeStatus__c != System.Label.StatusVerified)
                    {
                        errorMessage = System.Label.CorrectTradeStatusError + '\r\n';
                        convert = false;                        
                    }
                   if(allCDList[i].CD_TradeID__c==null){
                        errorMessage = System.Label.TradeDetailsNotPresent + '\r\n';
                        convert = false;
                    }
                    if(allCDList[i].CD_Customer__c == null)
                    {
                        errorMessage = System.Label.CustomerDoesNotExist + '\r\n';
                        convert = false;
                    }
                    else if(allCDList[i].CD_Customer__c != null && (linkedAccount.Owner.Name == System.Label.CYBGCRMIntegration || linkedAccount.Owner.Name == System.Label.MigrationAdministrator))
                    {
                        errorMessage = System.Label.CustomerOwnerError + '\r\n';
                        convert = false;
                    }
                    else if(tradeKeyword == false)
                    {
                        errorMessage = System.Label.CorrectTradeKeywordError + '\r\n';
                        convert = false;
                    }
                    
                    else if(allCDList[i].CD_Customer__c != null && offCode == null && tradeKeyword == true)
                    {
                        if(allCDList[i].CD_BranchNumber__c == System.Label.CBDirectDealingClient || 
                           allCDList[i].CD_BranchNumber__c == System.Label.YBDirectDealingClient)
                        {
                            directOrGeneric = true;
                            runValidation = true;
                            errorMessage = System.Label.CustomerExistsButHasNoQ6 + '\r\n';
                            convert = false;
                        }
                        else if(!contactWithIDMap.containsKey(linkedAccount.RM_Name__c) && allCDList[i].CD_BranchNumber__c != null &&
                                directOrGeneric == false)
                        {
                            runValidation = false;
                            if(branchNumwithQ6Map.containsKey(allCDList[i].CD_BranchNumber__c))
                            {
                                offCode = branchNumwithQ6Map.get(allCDList[i].CD_BranchNumber__c);
                                
                            }
                        }
                        
                    }
                    
                    // End of Change - Santhoshan  
                    
                    /*if(linkedAccount == null){
                        errorMessage = System.Label.Invalid_WID_and_CIF + '\r\n';
                        convert = false;
                    }*/
                    
                    if(linkedAccount != null && !(String.isBlank(linkedAccount.RM_Name__C))){                    
                        if(contactWithIDMap.containsKey(linkedAccount.RM_Name__C)){
                            allCDList[i].CD_Banker__c = linkedAccount.RM_Name__C;   
                        }
                    } 
                }         
            }
            if(!convert){
                if(eachCalData.CD_UserAction__c == System.Label.Discard)
                    allCDList[i].CD_ConversionStatus__c = System.Label.Discarded;
                else
                    allCDList[i].CD_ConversionStatus__c = System.Label.Failed;
                allCDList[i].CD_ErrorMessage__c = errorMessage;
                updateCDStatusList.add(allCDList[i]); 
            }
            else{
                //copying the data from calypso data record to Opportunity record
                Opportunity opp = mapCDataToOpp(eachCalData);
                opp.Opp_RunValidation__c = runValidation;
                opp.Opp_OfficerCode__c = offCode;
                
                //opp.Amount = eachCalData.CD_ForwardValueAdd__c;
                opp.Name = eachCalData.CD_TradeID__c;
                opp.OwnerId = linkedAccount.OwnerId;
                opp.StageName = System.Label.Opp_Stage_Closed_Won;
                opp.Opp_BranchNumber__c= eachCalData.CD_BranchNumber__c;
                opp.RecordTypeId = fxCashOppRTID;
                /*if(eachCalData.CD_DealType__c !=null){
                    if(eachCalData.CD_DealType__c=='FXSwap')
                    {
                        opp.CloseDate =eachCalData.CD_FXFarDate__c;
                    }else{
                        opp.CloseDate =eachCalData.CD_TradeSettleDate__c ;
                    }
                }*/
                if(!test.isRunningTest()){opp.CloseDate = Date.parse(eachCalData.CD_TradeDate__c);}
                    
                
                
                //opp.CloseDate = eachCalData.CD_TransactionDate__c;
                opp.AccountId = allCDList[i].CD_Customer__c; 
                opp.Deal_Executed_By__C = allCDList[i].CD_DealExecutedBy__c; 
                if(eachCalData.CD_TradeStatus__c==System.Label.StatusCancelled){
                    opp.Amount=opp.Amount*(0);
                }
                convertToOppCDList.add(allCDList[i]);
                oppUpsertList.add(opp); 
                
            }
            i++;
        }     
        


            if(!UserInfo.getUserName().containsIgnoreCase('cybg.crm.integration@cybg')){
                processOpportunity(); 
            }
          
    }
    /**
* @description       To map the Calypso Data Fields to Opp Fields
* @name              mapCDataToOpp
* @param             CalypsoData__c
* @return            Opportunity 
* @throws            NA
*/ 
    Public Opportunity mapCDataToOpp(CalypsoData__c cData){
        Opportunity opp = new Opportunity();
        for(CDOpp_FieldMap__mdt eachField : cdOppFields){
            opp.put(eachField.CDOpp_Opp_API__c, cData.get(eachField.CDOpp_CD_API__c));
        }
        return opp;
    }
    /**
* @description       To upsert the Opportunity and log the errors if any on calypso data
* @name              processOpportunity
* @param             null
* @return            void
* @throws            NA
*/ 
    Public void processOpportunity(){  
        if(!oppUpsertList.isEmpty()){
            Database.UpsertResult[] srList = Database.upsert(oppUpsertList, Opportunity.Opp_TradeID__c, false);
            integer j = 0;
            for (Database.UpsertResult sr : srList) {                
                if (sr.isSuccess()) {                    
                    convertToOppCDList[j].CD_ConversionStatus__c = System.Label.Converted;
                    convertToOppCDList[j].CD_ErrorMessage__c = '';
                    updateCDStatusList.add(convertToOppCDList[j]);                     
                }
                else {
                    string msg = '';
                    for(Database.Error err : sr.getErrors()) {                        
                        msg = msg + err.getMessage() + '\r\n';                                           
                    }
                    convertToOppCDList[j].CD_ErrorMessage__c = msg;
                    convertToOppCDList[j].CD_ConversionStatus__c = System.Label.Failed;
                    updateCDStatusList.add(convertToOppCDList[j]);   
                }
                j++;
            }                     
        }
        try{
        Database.SaveResult[] updateResult = Database.update(updateCDStatusList, False); 
        }catch(dmlexception e){
          System.debug('Opportunity Creation Exception'+e);  
        }
    }   
    /**
* @description       To Validate the Calypso data if there is any failed records with same ET Ref in error log
* @name              onBeforeInsert
* @param             List<CalypsoData__c>
* @return            void
* @throws            NA
*/ 
    public static void onBeforeInsert(List<CalypsoData__c> calDataList) {   
        List<String> tradeIDs = new List<String>();
        for(CalypsoData__c eachCData : calDataList){
             tradeIDs.add(eachCData.CD_TradeID__c.trim());       
        }
        
        List<CalypsoData__c> errorLogCDataList = getCDErrorLog(tradeIDs);
        //if(!errorLogCDataList.isEmpty() || Test.isRunningTest()){

        
        
        if(!errorLogCDataList.isEmpty()){
           
            for(CalypsoData__c eachCData : calDataList){
                for(CalypsoData__c eachErrorLog : errorLogCDataList ){
                    if(eachErrorLog.CD_TradeID__c == eachCData.CD_TradeID__c)
                        eachCData.CD_HasDuplicate__c = True;
                }
            }
        } 
    }
    /**
* @description       To Validate the Calypso data if there is any failed records with same ET Ref in error log
* @name              onBeforeUpdate
* @param             List<CalypsoData__c>
* @return            void
* @throws            NA
*/
    public static void onBeforeUpdate(List<CalypsoData__c> calDataList) {   
        
        List<String> tradeIDs = new List<String>();
        for(CalypsoData__c eachCData : calDataList){
             tradeIDs.add(eachCData.CD_TradeID__c.trim());       
        }
        List<CalypsoData__c> errorLogCDataList = getCDErrorLog(tradeIDs);
        List<CalypsoData__c> matchingErrorLogCDataList = new List<CalypsoData__c>();
        if(!errorLogCDataList.isEmpty()){
            for(CalypsoData__c eachCData : calDataList){
                
                system.debug('Here I am running ');
                for(CalypsoData__c eachErrorLog : errorLogCDataList )
                {
                    
                    if(eachErrorLog.CD_TradeID__c == eachCData.CD_TradeID__c) 
                        matchingErrorLogCDataList.add(eachErrorLog);
                    system.debug('Yes it is there in the error log');
                    system.debug('Error msg is '+eachErrorLog.CD_ErrorMessage__c);
                }
                system.debug('Matching Error one list'+matchingErrorLogCDataList);
                if(!matchingErrorLogCDataList.isEmpty() && eachCData.id != matchingErrorLogCDataList[0].id)
                { 
                    System.debug('Duplicate Matching ');
                    eachCData.CD_HasDuplicate__c = True;
                    
                }
                else
                {
                    eachCData.CD_HasDuplicate__c = False; 
                }
            }
        }   
    }
    /**
* @description       To get all the failed records in calypso data error log
* @name              getCDErrorLog
* @param             null
* @return            List<CalypsoData__c>
* @throws            NA
*/
    public static List<CalypsoData__c> getCDErrorLog(List<String> tradeIDs){
        List<CalypsoData__c> errorLogCDataList = new List<CalypsoData__c>(); 
        errorLogCDataList =  [select id, CD_ETRef__C, CD_ConversionStatus__c,CD_ErrorMessage__c, CreatedDate,CD_TradeID__c from CalypsoData__c
                              Where CD_ConversionStatus__c =:System.Label.Failed AND CD_TradeID__c IN: tradeIDs ORDER BY CreatedDate ASC]; 
        return errorLogCDataList;
    }
    
}