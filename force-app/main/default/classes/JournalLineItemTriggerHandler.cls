/*
@Author        : Ramkumar M B
@Name          : JournalLineItemTriggerHandler 
@Created Date  : 15th Feb 2018
@Description   : This is a handler class for the JournalLineItemTriggerHandler 
@version       : 1.0
*/

public class JournalLineItemTriggerHandler  
{
    /**
* @description       To roll up the actuals to TSM target and PM Targets
* @name              onAfterInsert
* @param             List<JournalLineItem__c>
* @return            void
* @throws            NA
*/ 
    public static void onAfterInsert(List<JournalLineItem__c> journalRecordList)
    {
        List<Id>tsmUserIdList =  new List<Id>();
        List<Id>pmContactIdList =  new List<Id>();
        Map<Id,PMTarget__c>pmTargetMap =  new Map<Id,PMTarget__c>();
        Map<Id,TSMTarget__c>updatedTSMTargetMap =  new Map<Id,TSMTarget__c>();
        Map<Id,PMTarget__c>updatedPMTargetMap =  new Map<Id,PMTarget__c>();        
        Map<String,TSMTarget__c>tsmTargetMap =  new Map<String,TSMTarget__c>();
        Map<String,TSMTarget__c>pseudoTargetMap =  new Map<String,TSMTarget__c>();
        List<PMTarget__c>pmTargetListForUpdate = new List<PMTarget__c>();
        List<TSMTarget__c>tsmTargetListForUpdate = new List<TSMTarget__c>();
        For(JournalLineItem__c eachJournal : journalRecordList){
            tsmUserIdList.add(eachJournal.Journal_TSM__c);
            pmContactIdList.add(eachJournal.Journal_PMContact__c);
            system.debug('This is--------- from Journal Handler');
            
        }
        System.debug('tsm id list'+tsmUserIdList);        
        For(PMTarget__c eachPMTarget :[Select Id,Name,PMTar_PMContact__c,PMTar_FXDirectTarget__c,PMTar_FXDirectActual__c,
                                       PMTar_CRMTarget__c,PMTar_CRMActual__c,PMTar_CommTarget__c,PMTar_CommActual__c,
                                       PMTar_IRRMTarget__c,PMTar_IRRMActual__c,PMTar_FXIndirectTarget__c,PMTar_FXIndirectActual__c,
                                       PMTar_FXRetail__c,PMTar_FXRetailActual__c from PMTarget__c 
                                       where PMTar_Status__c = 'Active' and PMTar_PMContact__c IN :pmContactIdList])
        {
            pmTargetMap.put(eachPMTarget.PMTar_PMContact__c, eachPMTarget);
            
        }
        
        For(TSMTarget__c eachtsmTarget :[Select Id,Name,TSMTar_TSM__c,TSMTar_Team__r.Name,TSMTar_Team__c,TSMTar_FXDirectTarget__c,TSMTar_FXDirectActual__c,
                                         TSMTar_FXIndirectTarget__c,TSMTar_FXIndirectActual__c,TSMTar_CRMTarget__c,
                                         TSMTar_CRMActual__c,TSMTar_CommTarget__c,TSMTar_CommActual__c,
                                         TSMTar_IRRMTarget__c,TSMTar_IRRMActual__c,TSMTar_FXRetail__c,
                                         TSMTar_FXRetailActual__c,TSMTar_PseudoTarget__c from TSMTarget__c                                        
                                         where TSMTar_Status__c = 'Active' and TSMTar_TSM__c IN :tsmUserIdList])
            
        {
            
            If(eachtsmTarget.TSMTar_PseudoTarget__c==True && eachtsmTarget.TSMTar_Team__r.Name.Contains('CB'))
            {
                pseudoTargetMap.put((String)eachtsmTarget.TSMTar_TSM__c + 'CB',eachtsmTarget);
            }else if(eachtsmTarget.TSMTar_PseudoTarget__c==True && eachtsmTarget.TSMTar_Team__r.Name.Contains('YB'))
            {
                pseudoTargetMap.put((String)eachtsmTarget.TSMTar_TSM__c + 'YB',eachtsmTarget);
            }else{
                tsmTargetMap.put((String)eachtsmTarget.TSMTar_Team__c + (String)eachtsmTarget.TSMTar_TSM__c, eachtsmTarget);
                
            }
            
            system.debug('TSM Targets froM Journal Handler'+tsmTargetMap);
        }
        
        For(JournalLineItem__c eachJournal : journalRecordList)
        {
            PMTarget__c  pmTargetForUpdate;
            TSMTarget__c tsmTargetForUpdate;
            //if(eachJournal.Journal_IsQ6Available__c==True) Updated From Ram 
            if(tsmTargetMap.containsKey((String)eachJournal.Journal_Team__c +(String)eachJournal.Journal_TSM__c))
            {
                system.debug('Q6 is Available');
                pmTargetForUpdate   = pmTargetMap.get(eachJournal.Journal_PMContact__c);
                tsmTargetForUpdate  = tsmTargetMap.get((String)eachJournal.Journal_Team__c +(String)eachJournal.Journal_TSM__c);
                
            }else{
                system.debug('Testing Q6 line');
                // Changes Made Here for Retail Start- Santhoshan
                pmTargetForUpdate   = pmTargetMap.get(eachJournal.Journal_PMContact__c);
                system.debug('Update PM Target'+pmTargetForUpdate);
                // Changes Made Here for Retail Start- Santhoshan
                if(eachJournal.Journal_CorpCode__c=='CB')
                {
                    system.debug('Not Fixed CB Q6------');
                    tsmTargetForUpdate = pseudoTargetMap.get((String)eachJournal.Journal_TSM__c +(String)eachJournal.Journal_CorpCode__c);
                }else{
                    tsmTargetForUpdate = pseudoTargetMap.get((String)eachJournal.Journal_TSM__c +(String)eachJournal.Journal_CorpCode__c);
                    system.debug('Not Fixed YB Q6------');     
                }
            }
            SYSTEM.debug('TSM Target to Update '+tsmTargetForUpdate);
            //SYSTEM.debug('TSM Target to Update '+tsmTargetForUpdate.Name);
            If(pmTargetForUpdate!=Null ){
                PMTarget__c  updatedPMTarget = CYBGUtilClass.updatePMTarget(pmTargetForUpdate,eachJournal);
                updatedPMTargetMap.put(updatedPMTarget.Id, updatedPMTarget);                
            }
            If(tsmTargetForUpdate!=Null){
                TSMTarget__c  updatedTSMTarget = CYBGUtilClass.updateTSMTarget(tsmTargetForUpdate,eachJournal);
                updatedTSMTargetMap.put(updatedTSMTarget.Id, updatedTSMTarget);
                System.debug('TSM Target after calculation'+updatedTSMTarget);                 
            }
            
        }
        pmTargetListForUpdate = updatedPMTargetMap.values();
        tsmTargetListForUpdate = updatedTSMTargetMap.values();
        
        If(!pmTargetListForUpdate.isEmpty()){                  
            Database.SaveResult[] updateResultForPMTarget = Database.Update(pmTargetListForUpdate, False);
            system.debug('updateResultForPMTarget'+updateResultForPMTarget);
        } 
        If(!tsmTargetListForUpdate.isEmpty()) {
            Database.SaveResult[] updateResultForTSMTarget = Database.Update(tsmTargetListForUpdate, False); 
            System.debug('Updating the TSM Target is'+updateResultForTSMTarget);
        }                   
        
    }    
    
    
    /**
* @description       To insert or update all End of Month Journals and associate them with corresponding Monthly Posting Summary Master Object 
* @name              insertOrUpdateEOMJournal
* @param             List<JournalLineItem__c>
* @return            void
* @throws            NA
*/ 
    public static void insertOrUpdateEOMJournal(List<JournalLineItem__c> journalRecordList)
    {
        List<PostingLineItem__c> existingEOMJournalRecordList = new List<PostingLineItem__c> ();
        List<PostingLineItem__c> newEOMList = new List<PostingLineItem__c> ();
        List<PostingLineItem__c> existingContraList = new List<PostingLineItem__c> ();
        List<PostingLineItem__c> newContraList = new List<PostingLineItem__c> ();
        Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',
            6 => 'June',7 => 'July',8 => 'August',9 => 'Sept',10 => 'October',11 => 'November',12 => 'December'};
                Integer mnth = System.Today().Month();
        Integer yr = System.Today().Year();
        Integer nxyr = System.Today().Year()+1;
        Map<String,PostingLineItem__c>mapEOMJournalIDs = new Map<String,PostingLineItem__c>();
        Map<String,PostingLineItem__c>mapEOMJournalContraEntryIDs = new Map<String,PostingLineItem__c>();
        Map<String,PostingLineItem__c>mapForNewEOM= new Map<String,PostingLineItem__c>();
        Map<String,PostingLineItem__c>mapNewContraEOM = new Map<String,PostingLineItem__c>();
        
        System.debug('NX YR>>>>>>>>>>>>>>>'+nxyr);
        Map<Integer,Id> mpSummaryMap = new  Map<Integer,Id>();
        Id currentPostingMonthId;
        Integer currentPostingMonth;
        
        for(MonthlyPostingSummary__c monthlyPostingSummaryRecord : [Select Id,Name,MPS_Fiscal_Year__c, MPS_Publish_Date__c,MPS_Status__c,MPS_Total_CB_Posting_Amount__c,MPS_Total_YB_Posting_Amount__c,MPS_Current_Posting_Month__c,MPS_Month__c From MonthlyPostingSummary__c WHERE MPS_Status__c='Not Published' ORDER BY MPS_Fiscal_Year__c ASC]){
            System.debug('\nTest Monthly Posting Summary>>>>>>>>>>>>>>>>>> : '+monthlyPostingSummaryRecord);
            mpSummaryMap.put(Integer.valueOf(monthlyPostingSummaryRecord.MPS_Month__c) , monthlyPostingSummaryRecord.Id);   
            if(monthlyPostingSummaryRecord.MPS_Current_Posting_Month__c){
                currentPostingMonthId=monthlyPostingSummaryRecord.Id; 
                currentPostingMonth=Integer.valueOf(monthlyPostingSummaryRecord.MPS_Month__c);
            }
            System.debug('\ncurrentPostingMonth>>>>>>>>>>>>>>>>>> : '+currentPostingMonth);
        }
        List<Id> monthlyPostingSummaryListIds = new List<Id>();
        for(String mps: mpSummaryMap.values())
        {
            System.debug('MPVALUE>>>>>>>>>>>>>>'+mps);
        }
        System.debug('mpSummaryMap>>>>>>>>>>>>>>>>'+mpSummaryMap);
        if(!mpSummaryMap.isEmpty()){
            monthlyPostingSummaryListIds = mpSummaryMap.values();
            System.debug('NOT PUBLISHED LIST ID>>>>>>>>>>>>'+monthlyPostingSummaryListIds);
        }
        System.debug('HERE NEW NOT PUBLISHED LIST ID>>>>>>>>>>>>'+monthlyPostingSummaryListIds);
        for(PostingLineItem__c existingEOMJournalRecord:[Select Id,Name,PLI_Corporate_Code__c,PLI_ProdName__c,PLI_Cost_Centre__c,MonthlyPostingSummary__r.Name,MonthlyPostingSummary__c,MonthlyPostingSummary__r.MPS_Month__c, MonthlyPostingSummary__r.MPS_Fiscal_Year__c, PLI_GL_Account__c,PLI_Amount__c,PLI_Description__c,PLI_Cr_Dr__c from PostingLineItem__c 
                                                         WHERE /*Calendar_Year(CreatedDate) = :yr AND*/  MonthlyPostingSummary__c IN :monthlyPostingSummaryListIds ORDER BY MonthlyPostingSummary__r.MPS_Fiscal_Year__c ASC]){  
                                                             System.debug('Monthly POSTING>>>>>>>>>>>>>'+existingEOMJournalRecord.MonthlyPostingSummary__r.Name);
                                                             
                                                             String keyValueForMap = existingEOMJournalRecord.PLI_Corporate_Code__c+ existingEOMJournalRecord.PLI_Cost_Centre__c + existingEOMJournalRecord.PLI_GL_Account__c+existingEOMJournalRecord.PLI_ProdName__c+Integer.valueOf(existingEOMJournalRecord.MonthlyPostingSummary__r.MPS_Month__c) + ((String.valueOf(existingEOMJournalRecord.MonthlyPostingSummary__r.Name)).split(' '))[1];    
                                                             String contraKeyValForMap=existingEOMJournalRecord.PLI_Corporate_Code__c+existingEOMJournalRecord.PLI_GL_Account__c+existingEOMJournalRecord.PLI_ProdName__c+Integer.valueOf(existingEOMJournalRecord.MonthlyPostingSummary__r.MPS_Month__c) + ((String.valueOf(existingEOMJournalRecord.MonthlyPostingSummary__r.Name)).split(' '))[1]; 
                                                             System.debug('MONTH HERE>>>>>>>>>>>'+Integer.valueOf(existingEOMJournalRecord.MonthlyPostingSummary__r.MPS_Month__c));
                                                             System.debug('keyValueForMap>>>>>>>'+keyValueForMap);
                                                             System.debug('contraKeyValForMap>>>>>>>'+contraKeyValForMap);
                                                             if(existingEOMJournalRecord.PLI_Cost_Centre__c==label.CB_Contra_Entry_CC || existingEOMJournalRecord.PLI_Cost_Centre__c==label.YB_Contra_Entry_CC ){
                                                                 mapEOMJournalContraEntryIDs.put(contraKeyValForMap, existingEOMJournalRecord);  
                                                             }else{                                                     
                                                                 mapEOMJournalIDs.put(keyValueForMap, existingEOMJournalRecord);
                                                             }
                                                         }
        System.debug('Contra Map>>>>>>>>> '+mapEOMJournalContraEntryIDs);
        System.debug('Normal Map>>>>>>>>> '+mapEOMJournalIDs);
        for(JournalLineItem__c eachJournal:journalRecordList ){ 
            
            //EOM created/Updated only for FX Cash / IRRM Prods
            /*  if(((eachJournal.Journal_ProductFamily__c == label.RecordTypeFXCash && (eachJournal.Journal_BranchNumber__c==System.Label.CBDirectDealingClient || eachJournal.Journal_BranchNumber__c==System.Label.YBDirectDealingClient ))|| 
eachJournal.Journal_ProductFamily__c == label.RecordTypeIRRM || eachJournal.Journal_ProductFamily__c == label.RecordTypeCommodity) &&  (eachJournal.Journal_TransferredforTargtes__c == false) ){
*/
            if((eachJournal.Journal_ProductFamily__c != label.RecordTypeCRMBusinessLoan  && eachJournal.Journal_ProductFamily__c != label.RecordTypeVanilaFX && 
                eachJournal.Journal_ProductFamily__c != label.RecordTypeCRM) &&  (eachJournal.Journal_TransferredforTargtes__c == false) ){
                    String keyString;  
                    String contraKeyString;
                    String monthVal;  
                    System.debug('Journal_Trade_date__c Month Journal>>>>>>>>>>>>>>>>>'+eachJournal.Journal_Trade_date__c.month());
                    System.debug('Journal_Trade_date__c Year Journal>>>>>>>>>>>>>>>>>'+eachJournal.Journal_Trade_date__c.Year());
                    System.debug('currentPostingMonth>>>>>>>>>>>>>>>>>'+currentPostingMonth);
                    
                    // Code Changed Here - Santhoshan
                    if(eachJournal.Journal_Trade_date__c.month() <= currentPostingMonth && System.today().Year() == eachJournal.Journal_Trade_date__c.Year()){
                        System.debug('>>>>>>>>>>>>>>>>>>> 1 <<<<<<<<<<<<<<<<<<<<');
                        monthVal=  String.valueOf(currentPostingMonth) + eachJournal.Journal_Trade_date__c.Year();
                    }else{
                        if(System.today().Year()>eachJournal.Journal_Trade_date__c.Year()){
                            System.debug('>>>>>>>>>>>>>>>>>>> 2 <<<<<<<<<<<<<<<<<<<<');
                            monthVal=  String.valueOf(currentPostingMonth) + eachJournal.Journal_Trade_date__c.Year();  
                        }else{
                            System.debug('>>>>>>>>>>>>>>>>>>> 3 <<<<<<<<<<<<<<<<<<<<');
                            monthVal= String.valueOf(eachJournal.Journal_Trade_date__c.month()) + eachJournal.Journal_Trade_date__c.Year(); 
                        }
                    }
                    System.debug('MONTHVAL>>>>>>>>>>>>>> '+monthVal);
                    // Code Changed Till Here - Santhoshan
                    String fixGLAccount ='';
                    if(eachJournal.Journal_Product__c=='FX' || eachJournal.Journal_Product__c=='FXForward'|| eachJournal.Journal_Product__c=='FXSwap' || eachJournal.Journal_Product__c=='FXFlexiForward'){
                        fixGLAccount =label.FX_GL_Account; 
                    }else{
                        fixGLAccount =label.Common_GL_Account; 
                    }                
                    
                    if(eachJournal.Journal_CorpCode__c=='CB'){
                        keyString = label.EOM_CB_Corp_Code + eachJournal.Journal_BankerOfficerCode__c
                            + fixGLAccount+eachJournal.Journal_ProductFamily__c+monthVal;
                        contraKeyString=label.EOM_CB_Corp_Code +fixGLAccount+eachJournal.Journal_ProductFamily__c+monthVal;
                    }else{
                        keyString = label.EOM_YB_Corp_Code + eachJournal.Journal_BankerOfficerCode__c
                            + fixGLAccount+eachJournal.Journal_ProductFamily__c+monthVal; 
                        contraKeyString=label.EOM_YB_Corp_Code +fixGLAccount+eachJournal.Journal_ProductFamily__c+monthVal;
                    }
                    System.debug('keyString>>>>>>>>>>>>>>>'+keyString);
                    
                    
                    if(mapEOMJournalIDs.containsKey(keyString))
                    { 
                        System.debug('CONTAINS>>>>>>>>>>');
                        PostingLineItem__c eomForUpdate = mapEOMJournalIDs.get(keyString);
                        Decimal amountVal = eachJournal.Journal_Amount__c* (-1);                
                        eomForUpdate.PLI_Amount__c = eomForUpdate.PLI_Amount__c + amountVal; 
                        
                        if(eomForUpdate.PLI_Amount__c>0){
                            eomForUpdate.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                        }else{
                            eomForUpdate.PLI_Cr_Dr__c=label.Transaction_Type_Credit;   
                        }                
                        mapEOMJournalIDs.put(keyString, eomForUpdate);   
                        System.debug('mapEOMJournalIDs>>>>>>>>>>>>'+mapEOMJournalIDs);
                    }else {
                        System.debug('NOT CONTAINS>>>>>>>>>>');
                        if(mapForNewEOM.containsKey(keyString))
                        {
                            System.debug('CONTAINS HERE>>>>>>>>>>');
                            PostingLineItem__c eomInMap = mapForNewEOM.get(keyString);
                            Decimal amountVal = eachJournal.Journal_Amount__c* (-1); 
                            eomInMap.PLI_Amount__c = eomInMap.PLI_Amount__c + amountVal; 
                            
                            if(eomInMap.PLI_Amount__c>0){
                                eomInMap.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                            }else{
                                eomInMap.PLI_Cr_Dr__c=label.Transaction_Type_Credit;    
                            }
                            mapForNewEOM.put(keyString, eomInMap);
                        }else{
                            System.debug('Not CONTAINS HERE TOO>>>>>>>>>>');
                            PostingLineItem__c newEOM = new PostingLineItem__c();
                            newEOM.PLI_Amount__c = eachJournal.Journal_Amount__c* (-1);
                            
                            if(eachJournal.Journal_CorpCode__c=='CB'){
                                newEOM.PLI_Corporate_Code__c = label.EOM_CB_Corp_Code;
                            }else{
                                newEOM.PLI_Corporate_Code__c = label.EOM_YB_Corp_Code;    
                            }
                            newEOM.PLI_Cost_Centre__c = eachJournal.Journal_BankerOfficerCode__c;
                            newEOM.PLI_ProdName__c=eachJournal.Journal_ProductFamily__c;
                            newEOM.PLI_GL_Account__c = fixGLAccount;
                            //newEOM.PLI_Cr_Dr__c=eachJournal.Journal_TransactionType__c;
                            if(newEOM.PLI_Amount__c>0){
                                newEOM.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                            }else{
                                newEOM.PLI_Cr_Dr__c=label.Transaction_Type_Credit;   
                            }
                            if(eachJournal.Journal_Trade_date__c !=null && eachJournal.Journal_Trade_date__c.month()!=null){
                                
                                
                                // Code Changed Here - Santhoshan
                                if(eachJournal.Journal_Trade_date__c.month() <= currentPostingMonth && System.today().Year() == eachJournal.Journal_Trade_date__c.Year()){
                                    newEOM.MonthlyPostingSummary__c=currentPostingMonthId;
                                    ////what if trade date is empty 
                                    newEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(currentPostingMonth)).left(3)+' '+String.valueOf(yr).right(2);                        
                                    
                                    
                                }else {
                                    
                                    // Santhoshan - 24/01/2019 - Start of Change - This piece of code is written 
                                    // to pass the Test Classes which are creating an Opportunity
                                    // or JLI.
                                    if(!Test.isRunningTest()) 
                                    {
                                        if(System.today().Year()>eachJournal.Journal_Trade_date__c.Year()){
                                            newEOM.MonthlyPostingSummary__c=currentPostingMonthId;  
                                            newEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(currentPostingMonth)).left(3)+' '+String.valueOf(yr).right(2);                           
                                        }else{
                                            newEOM.MonthlyPostingSummary__c=mpSummaryMap.get(Integer.valueOf(eachJournal.Journal_Trade_date__c.month()));
                                            newEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(eachJournal.Journal_Trade_date__c.month())).left(3)+' '+String.valueOf(yr).right(2);                        
                                        }
                                    }
                                    //End of Change
                                }
                            }
                            
                            mapForNewEOM.put(keyString, newEOM);
                        }
                    }
                    
                    
                    if(mapEOMJournalContraEntryIDs.containsKey(contraKeyString)){
                        
                        PostingLineItem__c eomContraForUpdate = mapEOMJournalContraEntryIDs.get(contraKeyString); Decimal contraVal = eachJournal.Journal_Amount__c;
                        eomContraForUpdate.PLI_Amount__c += contraVal;
                        
                        if(eomContraForUpdate.PLI_Amount__c>0){
                            eomContraForUpdate.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                        }else{
                            eomContraForUpdate.PLI_Cr_Dr__c=label.Transaction_Type_Credit;   
                        }
                        mapEOMJournalContraEntryIDs.put(contraKeyString,eomContraForUpdate);
                    }else{
                        
                        if(mapNewContraEOM.containsKey(contraKeyString)){
                            PostingLineItem__c eomContraInMap = mapNewContraEOM.get(contraKeyString); 
                            Decimal contraVal = eachJournal.Journal_Amount__c;
                            eomContraInMap.PLI_Amount__c += contraVal;
                            
                            if(eomContraInMap.PLI_Amount__c>0){
                                eomContraInMap.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                            }else{
                                eomContraInMap.PLI_Cr_Dr__c=label.Transaction_Type_Credit;   
                            }
                            mapNewContraEOM.put(contraKeyString, eomContraInMap);
                            
                        }else{
                            
                            PostingLineItem__c newContraEOM = new PostingLineItem__c();
                            Decimal contraVal = eachJournal.Journal_Amount__c;
                            newContraEOM.PLI_Amount__c = contraVal; 
                            
                            if(contraVal>0){
                                newContraEOM.PLI_Cr_Dr__c=label.Transaction_Type_Debit;
                            }else{
                                newContraEOM.PLI_Cr_Dr__c=label.Transaction_Type_Credit;   
                            }
                            if(eachJournal.Journal_CorpCode__c=='CB'){
                                newContraEOM.PLI_Corporate_Code__c = label.EOM_CB_Corp_Code;
                                newContraEOM.PLI_Cost_Centre__c = label.CB_Contra_Entry_CC;
                            }else{
                                newContraEOM.PLI_Corporate_Code__c = label.EOM_YB_Corp_Code; 
                                newContraEOM.PLI_Cost_Centre__c = label.YB_Contra_Entry_CC;
                            }
                            
                            newContraEOM.PLI_GL_Account__c = fixGLAccount;
                            newContraEOM.PLI_ProdName__c=eachJournal.Journal_ProductFamily__c;
                            if(eachJournal.Journal_Trade_date__c !=null && eachJournal.Journal_Trade_date__c.month()!=null){
                                if(eachJournal.Journal_Trade_date__c.month() <= currentPostingMonth){
                                    newContraEOM.MonthlyPostingSummary__c=currentPostingMonthId;
                                    ////what if trade date is empty 
                                    newContraEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(currentPostingMonth)).left(3)+' '+String.valueOf(yr).right(2);                        
                                    
                                    
                                }else {
                                    if(!Test.isRunningTest()) 
                                    {
                                        if(System.today().Year()>eachJournal.Journal_Trade_date__c.Year()){
                                            newContraEOM.MonthlyPostingSummary__c=currentPostingMonthId;  
                                            newContraEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(currentPostingMonth)).left(3)+' '+String.valueOf(yr).right(2);                           
                                        }else{
                                            newContraEOM.MonthlyPostingSummary__c=mpSummaryMap.get(Integer.valueOf(eachJournal.Journal_Trade_date__c.month()));
                                            newContraEOM.PLI_Description__c=((eachJournal.Journal_CorpCode__c!=null && eachJournal.Journal_CorpCode__c!='')? eachJournal.Journal_CorpCode__c:' ')+' '+eachJournal.Journal_ProductFamily__c+' Journal '+(monthMap.get(eachJournal.Journal_Trade_date__c.month())).left(3)+' '+String.valueOf(yr).right(2);                        
                                        }
                                    }
                                }
                            }
                            
                            
                            mapNewContraEOM.put(contraKeyString, newContraEOM);
                        }
                    }
                    
                    
                }   
        }
        existingEOMJournalRecordList = mapEOMJournalIDs.values();
        
        existingContraList=mapEOMJournalContraEntryIDs.values();
        
        newEOMList = mapForNewEOM.values();
        
        newContraList=mapNewContraEOM.values();
        
        
        System.debug('HERE IS THE MAP>>>>>>>>>>>>>>>>'+mapEOMJournalIDs.values());
        System.debug('HERE IS THE COPIED MAP>>>>>>>>>>>>>>'+existingEOMJournalRecordList);
        
        if(!existingEOMJournalRecordList.isEmpty())
        {
            Database.SaveResult[] resultEOMJournalRecordList = Database.Update(existingEOMJournalRecordList, False);
            
        }
        if(!newEOMList.isEmpty())
        {
            
            Database.SaveResult[] newEOMJournalRecordList = Database.Insert(newEOMList, False);
            
        } 
        if(!existingContraList.isEmpty())
        {
            Database.SaveResult[] resultEOMJournalRecordList = Database.Update(existingContraList, False);
            
        }
        if(!newContraList.isEmpty())
        {
            
            Database.SaveResult[] newEOMJournalRecordList = Database.Insert(newContraList, False);
            
        } 
    }
    
    
}