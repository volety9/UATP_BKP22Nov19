/*
@Author        : Ramkumar M B
@Name          : OpportunityTriggerHandler
@Created Date  : 22th February 2018
@Description   : This is a Handler for OpportunityTrigger 
@version       : 1.0
*/
public class OpportunityTriggerHandler
{
    List<JournalLineItem__c> journalLineList;
    List<Opportunity> opportunityForJournal ;
    Map<Id,Account>updateAccounts = new Map<Id,Account>();

    List<ID> accountIdsList;
    List<ID> opportunityIdsList;
    Set<Id>productManagerIdsList;
    Set<Id>tsmIdsList;
    Id businessRecordTypeId;
    Id vanillaRecordTypeId;
    Id fxRecordTypeId;
    Id commodityRecordTypeId;
    Id irrmRecordTypeId;
    Id crmRecordTypeId;
    Map<Id,Opportunity> opportunityDetails;
    String fiscalYear;
    Map<Id,Account> customerDetailsMap ;
    Map<String,TSMTarget__c>tsmTargetMap;
    Map<String,TSMTarget__c>pseudoTargetMap;
    Map<Id,PMTarget__c>pmTargetMap;
    Account customerAccount ;
    Id productManagerContact;    
    String productManagerContactName;    
    Opportunity opportunityRecord;
    Id pmTarget;
    Id tsmTarget;
    String currentFiscalYear;
    Integer fyStartMonth;
    String officerCode;
    List<Opportunity> opportunityForupdate;
    public OpportunityTriggerHandler ()
    {   
        //currentFiscalYear = CYBGUtilClass.findCurrentFY(System.Today(), CYBGUtilClass.fiscalYearStartMonth());Updated By Ram
        journalLineList = new List<JournalLineItem__c>();
        opportunityForJournal = new List<Opportunity>();
        accountIdsList = new List<ID>();
        opportunityIdsList = new List<ID>();
        productManagerIdsList = new Set<Id>();
        tsmIdsList            = new Set<Id>();
        tsmTargetMap          = new Map<String,TSMTarget__c>();
        pseudoTargetMap       = new Map<String,TSMTarget__c>();
        pmTargetMap           = new Map<Id,PMTarget__c>();
        businessRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRMBusinessLoan).getRecordTypeId();
        vanillaRecordTypeId   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeVanilaFX).getRecordTypeId();
        fxRecordTypeId        = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeFXCash).getRecordTypeId();        
        commodityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCommodity).getRecordTypeId();
        irrmRecordTypeId      = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeIRRM).getRecordTypeId();
        crmRecordTypeId       = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRM).getRecordTypeId();
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
    }
    /**
* @description       Method to process opportunity before insert and get the value for GL Account number field
before getting inserted
* @name              onBeforeInsert
* @param             List<Opportunity> 
* @return            void
* @throws            NA
*/ 
    public static void onBeforeInsert(List<Opportunity>opportunityList)
    {
        Id fxRecordTypeId        = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeFXCash).getRecordTypeId();        
        Id commodityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCommodity).getRecordTypeId();
        Id irrmRecordTypeId      = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeIRRM).getRecordTypeId();
        Id crmRecordTypeId       = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRM).getRecordTypeId();
        Map<String,GLAccountDetails__mdt> GLAccountMap = new Map<String,GLAccountDetails__mdt>();
        Set<Id>tsmIdsList =  new Set<Id>();
        Set<Id>productManagerIdsList =  new Set<Id>();
        Set<Id>accountIdsList = new Set<Id>();
        Map<Id,Account> customerDetailsMap = new Map<Id,Account>();
        Map<String,TSMTarget__c>tsmTargetMap = new Map<String,TSMTarget__c>();
        Map<String,TSMTarget__c>pseudoTargetMap = new Map<String,TSMTarget__c>();
        Map<Id,PMTarget__c>pmTargetMap = new Map<Id,PMTarget__c>();
        For(GLAccountDetails__mdt eachGLAccount : [Select ID,MasterLabel,CorpCode__c,RecordType__c,
                                                   GLAccountNumber__c FROM GLAccountDetails__mdt])
        {
            GLAccountMap.put((String)eachGLAccount.CorpCode__c+(String)eachGLAccount.RecordType__c, eachGLAccount);
            
        }
        For(Opportunity eachOpportunity:opportunityList)
        {
            //tsmIdsList.add(eachOpportunity.OwnerId);// Added to accountowner Id
            accountIdsList.add(eachOpportunity.AccountId);
        }   
         /*   if(!String.isBlank(eachOpportunity.Opp_CorpCode__c)
              && (GLAccountMap.get((String)eachOpportunity.Opp_CorpCode__c+(String)eachOpportunity.RecordTypeId)) != null)                
                eachOpportunity.Opp_GLAccountNumber__c = GLAccountMap.get((String)eachOpportunity.Opp_CorpCode__c+
                                                                          (String)eachOpportunity.RecordTypeId).GLAccountNumber__c; */
        
        For(Account eachAccount : [Select Id,Owner.Name,OwnerId,RM_Name__c,RM_Name__r.Con_Team__c,FX_Manager__c,Commodity_Manager__c,IRRM_Manager__c, 
                                   FX_Manager__r.Name,Commodity_Manager__r.name,IRRM_Manager__r.name from Account where Id IN :accountIdsList])
        {
            productManagerIdsList.add(eachAccount.FX_Manager__c);
            productManagerIdsList.add(eachAccount.Commodity_Manager__c);
            productManagerIdsList.add(eachAccount.IRRM_Manager__c);
            tsmIdsList.add(eachAccount.OwnerId);
            customerDetailsMap.put(eachAccount.Id,eachAccount);
        }
         
        List<TSMTarget__c> tsmList = [Select Id,Name,TSMTar_TSM__c,TSMTar_Team__c,TSMTar_PseudoTarget__c,TSMTar_Team__r.Name from TSMTarget__c
                                         where (TSMTar_Status__c = :System.Label.Active OR (TSMTar_Status__c =:System.label.Terminated And TSMTar_EndDate__c >= Today ))and TSMTar_TSM__c IN :tsmIdsList];
        System.debug('Tsm List ===>'+tsmList.size());
        System.debug('Oppo List==>'+opportunityList[0].opp_TradeID__c);
        //System.debug('Oppo List==>'+opportunityList[1].opp_TradeID__c);
        For(TSMTarget__c eachtsmTarget :[Select Id,Name,TSMTar_TSM__c,TSMTar_Team__c,TSMTar_PseudoTarget__c,TSMTar_Team__r.Name from TSMTarget__c
                                         where (TSMTar_Status__c = :System.Label.Active OR (TSMTar_Status__c =:System.label.Terminated And TSMTar_EndDate__c >= Today ))and TSMTar_TSM__c IN :tsmIdsList])
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
            
            tsmTargetMap.put((String)eachtsmTarget.TSMTar_Team__c + (String)eachtsmTarget.TSMTar_TSM__c, eachtsmTarget);
        }
        
        For(PMTarget__c eachPMTarget :[Select Id,Name,PMTar_PMContact__c from PMTarget__c 
                                       where (PMTar_Status__c = :System.Label.Active OR (PMTar_Status__c =:System.label.Terminated And PMTar_EndDate__c >= Today )) and PMTar_PMContact__c IN :productManagerIdsList])
        {
            pmTargetMap.put(eachPMTarget.PMTar_PMContact__c, eachPMTarget);

        }
       if(!Test.isRunningTest()) 
       {
        For(Opportunity eachOpportunity:opportunityList)
        {
            Account customerAccount = customerDetailsMap.get(eachOpportunity.AccountId);
            eachOpportunity.ownerId = customerAccount.ownerId;
            system.debug('Customer owner  owner'+customerAccount.ownerId);
            system.debug('Each opp owner'+eachOpportunity.ownerId);
            If(customerAccount.RM_Name__c==Null && !pseudoTargetMap.containsKey((String)eachOpportunity.OwnerId+eachOpportunity.Opp_CorpCode__c))
            {
                eachOpportunity.adderror('FRSM '+customerAccount.owner.Name+ ' do not having any Planning record / Target record ');
            }else if (customerAccount.RM_Name__c!=Null &&
                      !tsmTargetMap.containsKey((String)customerAccount.RM_Name__r.Con_Team__c + (String)eachOpportunity.OwnerId))
            {
              eachOpportunity.adderror('FRSM '+customerAccount.owner.Name+ ' do not having any Planning record / Target record ');
    
            }else if((eachOpportunity.RecordTypeId==fxRecordTypeId ||eachOpportunity.RecordTypeId==crmRecordTypeId) 
                    && !pmTargetMap.containsKey(customerAccount.FX_Manager__c) && customerAccount.FX_Manager__c!=Null)
            {
              eachOpportunity.adderror('FX Manager ' +customerAccount.FX_Manager__r.Name+ ' do not having any Planning record / Target record ');

            }else if(eachOpportunity.RecordTypeId==commodityRecordTypeId &&
                    !pmTargetMap.containsKey(customerAccount.Commodity_Manager__c) && customerAccount.Commodity_Manager__c!=Null)
           {
              eachOpportunity.adderror('Commodity Manager ' +customerAccount.Commodity_Manager__r.Name+ ' do not having any Planning record / Target record ');
                         
           }else if (eachOpportunity.RecordTypeId==irrmRecordTypeId &&
                    !pmTargetMap.containsKey(customerAccount.IRRM_Manager__c) && customerAccount.Commodity_Manager__c!=Null)         
           {
            eachOpportunity.adderror('IRRM Manager ' +customerAccount.IRRM_Manager__r.Name+ ' do not having any Planning record / Target record ');
                         
           }else
           {
            String fixGLAccount ='';
           
            if(eachOpportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeFXCash).getRecordTypeId() || 
               eachOpportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeIRRM).getRecordTypeId() ||
               eachOpportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCommodity).getRecordTypeId())
                     {

                   if(eachOpportunity.Product__c=='FX' || eachOpportunity.Product__c=='FXForward'|| eachOpportunity.Product__c=='FXSwap' ||eachOpportunity.Product__c=='FXFlexiForward'){
                        eachOpportunity.Opp_GLAccountNumber__c =label.FX_GL_Account; 
                   }else{
                        eachOpportunity.Opp_GLAccountNumber__c =label.Common_GL_Account; 
                   } 
               }else{

                   if(!String.isBlank(eachOpportunity.Opp_CorpCode__c)
                      && (GLAccountMap.get((String)eachOpportunity.Opp_CorpCode__c+(String)eachOpportunity.RecordTypeId)) != null)                
                       eachOpportunity.Opp_GLAccountNumber__c = GLAccountMap.get((String)eachOpportunity.Opp_CorpCode__c+
                                                                                 (String)eachOpportunity.RecordTypeId).GLAccountNumber__c; 
               }        
        }
        }  
        }
    }
    /**
* @description       Method to process the valid closed won opportunity for Journal creation
* @name              onAfterInsert
* @param             List<Opportunity> 
* @return            void
* @throws            NA
*/ 
    public void onAfterInsert(List<opportunity> opporunityList)
    {

        opportunityForJournal = validateOpportunity(opporunityList);
        getOpportunityandAccountDetails();
        if(!opportunityForJournal.isEmpty())
        {
            createJournalLineItems();
        }
    }
    
    /**
* @description       Method to create the Jouranls for valid Opportunity records 
* @name              createJournalLineItems
* @param             void
* @return            void
* @throws            NA
*/ 
    public Void createJournalLineItems ()
    {
        For(Opportunity eachOpportunityRecord :opportunityForJournal)
        {
            getProductManagerDetails(eachOpportunityRecord);
            currentFiscalYear = CYBGUtilClass.findCurrentFY(eachOpportunityRecord.CloseDate, fyStartMonth);

            if(customerAccount != null && customerAccount.RM_Name__c != null)
            {
                    officerCode = customerAccount.RM_Name__r.Officer_Code__c;
            }
            else
            {
                officerCode = eachOpportunityRecord.Opp_OfficerCode__c;
            }
            
            if(eachOpportunityRecord.RecordTypeId == crmRecordTypeId || eachOpportunityRecord.RecordTypeId == vanillaRecordTypeId)
            {
                //getProductManagerDetails(eachOpportunityRecord);by Ram
                
                journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunityRecord.Id,
                                                                                customerAccount.RM_Name__c,eachOpportunityRecord.Amount,Label.Transaction_Type_Debit,Null,
                                                                                currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''), officerCode,                                              
                                                                                customerAccount.CIF__c,opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                eachOpportunityRecord.Product__c,opportunityRecord.RecordType.Name,
                                                                                productManagerContact,productManagerContactName,
                                                                                customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                eachOpportunityRecord.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                customerAccount.RM_Name__r.Con_Centre__c,
                                                                                customerAccount.RM_Name__r.Con_Region__c,
                                                                                customerAccount.RM_Name__r.Con_Division__c,
                                                                                customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));   
                
                journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunityRecord.Id,
                                                                                customerAccount.RM_Name__c,(eachOpportunityRecord.Amount) *-1,Label.Transaction_Type_Credit,Null,
                                                                                currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''), officerCode,                                              
                                                                                customerAccount.CIF__c,opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                eachOpportunityRecord.Product__c,opportunityRecord.RecordType.Name,
                                                                                productManagerContact,productManagerContactName,
                                                                                customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                eachOpportunityRecord.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+
                                                                                ' '+((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                customerAccount.RM_Name__r.Con_Centre__c,
                                                                                customerAccount.RM_Name__r.Con_Region__c,
                                                                                customerAccount.RM_Name__r.Con_Division__c,
                                                                                customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));  
           
            //system.debug('Cancelled
            }
            
            
            else if(eachOpportunityRecord.Amount!=0)
            {
                //getProductManagerDetails(eachOpportunityRecord);by Ram
                
                journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunityRecord.Id,
                                                                                customerAccount.RM_Name__c,eachOpportunityRecord.Amount,Label.Transaction_Type_Debit,Null,
                                                                                currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''), officerCode,                                              
                                                                                customerAccount.CIF__c,opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                eachOpportunityRecord.Product__c,opportunityRecord.RecordType.Name,
                                                                                productManagerContact,productManagerContactName,
                                                                                customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                eachOpportunityRecord.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+
                                                                                ' '+((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                customerAccount.RM_Name__r.Con_Centre__c,
                                                                                customerAccount.RM_Name__r.Con_Region__c,
                                                                                customerAccount.RM_Name__r.Con_Division__c,
                                                                                customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));             
            }
        }
        insertJournalLineItems(journalLineList);    
    }
    /**
* @description       Method to fetch all the Account and Opportunity details for inserted Opportunity 
* @name              getOpportunityandAccountDetails
* @param             void
* @return            void
* @throws            NA
*/ 
    public void getOpportunityandAccountDetails()
    {
        opportunityDetails     = CYBGUtilClass.getOpportunityDetails(opportunityIdsList);
        customerDetailsMap     = CYBGUtilClass.getAccountDetails(accountIdsList);
        For(Account eachAccount:customerDetailsMap.values())
        {
            productManagerIdsList.add(eachAccount.FX_Manager__c);
            productManagerIdsList.add(eachAccount.IRRM_Manager__c);
            productManagerIdsList.add(eachAccount.Commodity_Manager__c);
        }
        
        For(TSMTarget__c eachtsmTarget :[Select Id,Name,TSMTar_TSM__c,TSMTar_Team__c,TSMTar_PseudoTarget__c,TSMTar_Team__r.Name from TSMTarget__c
                                         where (TSMTar_Status__c = :System.Label.Active OR (TSMTar_Status__c =:System.label.Terminated And TSMTar_EndDate__c >= Today ))and TSMTar_TSM__c IN :tsmIdsList])
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
            
            tsmTargetMap.put((String)eachtsmTarget.TSMTar_Team__c + (String)eachtsmTarget.TSMTar_TSM__c, eachtsmTarget);
        }
        system.debug('TSM Target map contains values '+tsmTargetMap);
        For(PMTarget__c eachPMTarget :[Select Id,Name,PMTar_PMContact__c from PMTarget__c 
                                       where (PMTar_Status__c = :System.Label.Active OR (PMTar_Status__c =:System.label.Terminated And PMTar_EndDate__c >= Today )) and PMTar_PMContact__c IN :productManagerIdsList])
        {
            pmTargetMap.put(eachPMTarget.PMTar_PMContact__c, eachPMTarget);

        }
    }
    /**
* @description       Method to create the Jouranls for valid Updated Opportunity. 
* @name              onAfterUpdate
* @param             List<Opportunity>
* @return            void
* @throws            NA
*/ 
    
    public Void onAfterUpdate(List<Opportunity> updatedOpportunityList)
    {
        
         /*For(Opportunity actOpportunity :updatedOpportunityList)
        {
            
            system.debug('actOpportunity new name' +actOpportunity.name);
            system.debug('actOpportunity new record' +actOpportunity);
        }*/
        opportunityForJournal = validateOpportunity(updatedOpportunityList);
        system.debug('oppp list=======>' +updatedOpportunityList.size() );
        getOpportunityandAccountDetails();
        system.debug('oppp list' +updatedOpportunityList);
        system.debug('oppp list' +opportunityForJournal.size() );
        For(Opportunity eachOpportunity :opportunityForJournal)
        {
            
            system.debug('each oppty new name' +eachOpportunity.name);
            system.debug('each oppty new record' +eachOpportunity);
            currentFiscalYear = CYBGUtilClass.findCurrentFY(eachOpportunity.CloseDate, fyStartMonth);
            Opportunity olpOpportrunity = (Opportunity)Trigger.oldMap.get(eachOpportunity.id);
            system.debug('old oppty name' +olpOpportrunity.name);
            system.debug('old oppty record' +olpOpportrunity);
            system.debug('Old opportunity Q6 Value'+olpOpportrunity.isQ6Available__c);
            
            system.debug('Current opportunity Q6 Value'+eachOpportunity.isQ6Available__c);
            getProductManagerDetails(eachOpportunity);
            if(customerAccount != null && customerAccount.RM_Name__c != null)
            {
                    officerCode = customerAccount.RM_Name__r.Officer_Code__c;
            }
            else
            {
                officerCode = eachOpportunity.Opp_OfficerCode__c;
            }
            if(eachOpportunity.RecordTypeId == crmRecordTypeId || eachOpportunity.RecordTypeId == vanillaRecordTypeId)
            {
				System.debug('CRM And Vanilla Record Type Loop');                
               journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    eachOpportunity.Amount,Label.Transaction_Type_Debit,NULL,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                               ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+
                                                                               ' '+((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                
                journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    (eachOpportunity.Amount) *-1,Label.Transaction_Type_Credit,NULL,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+
                                                                                    ' '+((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                
                  //system.debug('Failed ID'+journalLineitemList.get(i).Id);  
                  system.debug('cancelled journallist1' +journalLineList);                 
            }
            
       
            
            else if(eachOpportunity.StageName != olpOpportrunity.StageName)
            {
                System.debug('eachOpportunity.StageName != olpOpportrunity.StageName');
                if(eachOpportunity.Amount!=0)
                {
                    System.debug('eachOpportunity.Amount!=0');
                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,eachOpportunity.Amount,Label.Transaction_Type_Debit,Null,                                                                            
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                }
            }
            else if(eachOpportunity.Amount != olpOpportrunity.Amount)
            {
                System.debug('eachOpportunity.Amount != olpOpportrunity.Amount');                
                Decimal amountValue = olpOpportrunity.Amount;
                
                List<JournalLineItem__c> JournalIdList = opportunityDetails.get(eachOpportunity.id).Journal_Line_Items__R;
                Integer journalSize = JournalIdList.size();
                
                if(JournalIdList.isEmpty())
                {
                    System.debug('JournalIdList.isEmpty()');
                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,eachOpportunity.Amount,Label.Transaction_Type_Debit,Null,                                                                            
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                }
                else if(eachOpportunity.Amount == 0)
                {
                     System.debug('eachOpportunity.Amount == 0' +eachOpportunity.name);
                    if(JournalIdList[0].Journal_Banker__c==Null){
                         System.debug('eachOpportunity.Amount == 0 && JournalIdList[0].Journal_Banker__c==Null');
                          System.debug('eachOpportunity.Amount == 0' +eachOpportunity.name);
                     journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    Null,
                                                                                    (olpOpportrunity.Amount)*-1,Label.Transaction_Type_Credit,JournalIdList[0].id,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,                                                                                    
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    JournalIdList[0].Journal_Team__c,JournalIdList[0].Journal_TeamName__c,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    JournalIdList[0].Journal_Centre__c,
                                                                                    JournalIdList[0].Journal_Region__c,
                                                                                    JournalIdList[0].Journal_Division__c,
                                                                                    JournalIdList[0].Journal_Group__c,
                                                                                    JournalIdList[0].Journal_PMTarget__c,JournalIdList[0].Journal_TSMTarget__c,(eachOpportunity.RecordTypeId ==fxRecordTypeId?Label.ReversalReasonUpdatedByCalypso:Label.ReversalReasonTreasuryUser)));
                         
                        
                     system.debug('cancelled journallist2' +journalLineList);   
                    }else{
                         System.debug('eachOpportunity.Amount == 0 && JournalIdList[0].Journal_Banker__c != Null');
                        // Code Changed to handle Null Pointer Exception in  Journal -  Santhoshan - 25-10-2018
                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    (olpOpportrunity.Amount!=null?(olpOpportrunity.Amount)*-1:0),Label.Transaction_Type_Credit,JournalIdList[0].id,    
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,(eachOpportunity.RecordTypeId ==
                                                                                                                                                fxRecordTypeId?Label.ReversalReasonUpdatedByCalypso:Label.ReversalReasonTreasuryUser)));
                   
                    system.debug('cancelled journallist3' +journalLineList);
                    }
                }else if(olpOpportrunity.amount==0)
                {
                    System.debug('olpOpportrunity.amount==0');

                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,eachOpportunity.Amount,Label.Transaction_Type_Debit,Null,                                                                            
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                }
                else
                {
                    System.debug('olpOpportrunity.amount!=0');
                    system.debug('Journal with Index value of '+JournalIdList[journalSize-1]);
                    If(JournalIdList[0].Journal_Banker__c==Null)
                    {
                        System.debug('olpOpportrunity.amount !=0 && JournalIdList[0].Journal_Banker__c==Null');
                        System.debug('Old Banker is Null && New Banker is added ');
                      journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    Null,
                                                                                    (olpOpportrunity.Amount)*-1,Label.Transaction_Type_Credit,JournalIdList[0].id,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,Null,
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,                                                                                    
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    JournalIdList[0].Journal_Team__c,JournalIdList[0].Journal_TeamName__c,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    JournalIdList[0].Journal_Centre__c,
                                                                                    JournalIdList[0].Journal_Region__c,
                                                                                    JournalIdList[0].Journal_Division__c,
                                                                                    JournalIdList[0].Journal_Group__c,
                                                                                    JournalIdList[0].Journal_PMTarget__c,JournalIdList[0].Journal_TSMTarget__c,(eachOpportunity.RecordTypeId ==fxRecordTypeId?Label.ReversalReasonUpdatedByCalypso:Label.ReversalReasonTreasuryUser)));
                        system.debug('TSM Target value '+tsmTarget);
                        system.debug('cancelled journallist4' +journalLineList);
                        journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    eachOpportunity.Amount,Label.Transaction_Type_Debit,JournalIdList[0].id,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                      
                        
                    }else{
                        System.debug('olpOpportrunity.amount !=0 && JournalIdList[0].Journal_Banker__c != Null');
                        System.debug('Updating******--------Here My code');
                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    (olpOpportrunity.Amount!=null?(olpOpportrunity.Amount)*-1:0),Label.Transaction_Type_Credit,JournalIdList[0].id,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,                                                                                    
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    JournalIdList[0].Journal_Team__c,JournalIdList[0].Journal_TeamName__c,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    JournalIdList[0].Journal_Centre__c,
                                                                                    JournalIdList[0].Journal_Region__c,
                                                                                    JournalIdList[0].Journal_Division__c,
                                                                                    JournalIdList[0].Journal_Group__c,
                                                                                    pmTarget,tsmTarget,(eachOpportunity.RecordTypeId ==fxRecordTypeId?Label.ReversalReasonUpdatedByCalypso:Label.ReversalReasonTreasuryUser)));
                                                                                                                                                
                    system.debug('cancelled journallist5' +journalLineList);
                    journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    customerAccount.RM_Name__c,
                                                                                    eachOpportunity.Amount,Label.Transaction_Type_Debit,JournalIdList[0].id,
                                                                                    currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+' '+
                                                                                    ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                    officerCode,customerAccount.CIF__c,
                                                                                    opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                    opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                    eachOpportunity.Product__c,opportunityRecord.RecordType.Name,
                                                                                    productManagerContact,productManagerContactName,                               
                                                                                    customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,opportunityRecord.owner.FirstName + ' '+ 
                                                                                    opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                    ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+ ' '+
                                                                                    ((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                    customerAccount.RM_Name__r.Con_Centre__c,
                                                                                    customerAccount.RM_Name__r.Con_Region__c,
                                                                                    customerAccount.RM_Name__r.Con_Division__c,
                                                                                    customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null));
                    }
                    }
            }
        }
        insertJournalLineItems(journalLineList);
    }     
    
    /**
* @description       Validate the Opportunity for Journal creation .
* @name              validateOpportunity
* @param             List<Opportunity>
* @return            List<Opportunity>
* @throws            NA
*/ 
    
    
    public List<Opportunity> validateOpportunity(List<Opportunity> opportunityRecords)
    {
        List<Opportunity>validOpportunityListforJournal = new List<Opportunity>();
        for(Opportunity eachOpportunity : opportunityRecords)
        { 
          //  if(eachOpportunity.RECORDTYPEID != businessRecordTypeId
            //   && eachOpportunity.RECORDTYPEID !=vanillaRecordTypeId && eachOpportunity.StageName == System.Label.Opp_Stage_Closed_Won)
           if(eachOpportunity.StageName == System.Label.Opp_Stage_Closed_Won)
            {
                opportunityIdsList.add(eachOpportunity.id);               
                validOpportunityListforJournal.add(eachOpportunity);
                accountIdsList.add(eachOpportunity.AccountId);
                tsmIdsList.add(eachOpportunity.ownerId);
                system.debug('Incoming TSM '+eachOpportunity.ownerId);
            }            
        }
        system.debug('TSM Id List'+tsmIdsList);
        return validOpportunityListforJournal;
    }
    
    /**
* @description       This Method will fetch the TSM and PM Target details for the Opportunity
* @name              getProductManagerDetails
* @param             Opportunity
* @return            void
* @throws            NA
*/ 
    
     public void getProductManagerDetails(Opportunity eachOpportunityRecord)
    {       
        customerAccount  = customerDetailsMap.get(eachOpportunityRecord.accountId);       
        opportunityRecord = opportunityDetails.get(eachOpportunityRecord.id);         
        if((eachOpportunityRecord.RecordTypeId == fxRecordTypeId )||(eachOpportunityRecord.RecordTypeId == crmRecordTypeId))
        {
            pmTarget = getPMTargetId(customerAccount.FX_Manager__c);
            tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,opportunityRecord.ownerId,
                                       opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
            productManagerContact = customerAccount.FX_Manager__c;
            
            productManagerContactName    = ((customerAccount.FX_Manager__r.FirstName!=Null)?customerAccount.FX_Manager__r.FirstName:'') +' '+  
                ((customerAccount.FX_Manager__r.LastName!=Null)?customerAccount.FX_Manager__r.LastName:'');                
        }
        else if(eachOpportunityRecord.RecordTypeId == commodityRecordTypeId) 
        {   
            pmTarget = getPMTargetId(customerAccount.Commodity_Manager__c);
            tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,opportunityRecord.ownerId,
                                       opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);                
            productManagerContact        = customerAccount.Commodity_Manager__c;
            
            productManagerContactName    = ((customerAccount.Commodity_Manager__r.FirstName!=Null)?customerAccount.Commodity_Manager__r.FirstName:'') +' '+  
                ((customerAccount.Commodity_Manager__r.LastName!=Null)?customerAccount.Commodity_Manager__r.LastName:'');
        }
        else 
        { 
            pmTarget = getPMTargetId(customerAccount.IRRM_Manager__c);
            tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,opportunityRecord.ownerId,
                                       opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
            productManagerContact        = customerAccount.IRRM_Manager__c;
            productManagerContactName    = ((customerAccount.IRRM_Manager__r.FirstName!=Null)?customerAccount.IRRM_Manager__r.FirstName:'') +' '+  
               ((customerAccount.IRRM_Manager__r.LastName!=Null)?customerAccount.IRRM_Manager__r.LastName:'');            
        }
    }
    
    /**
* @description       Inserting Journal for valid processed Opportunity. 
* @name              insertJournalLineItems
* @param             List<JournalLineItem__c> 
* @return            void
* @throws            NA
*/ 
    
    public Void insertJournalLineItems(List<JournalLineItem__c> journalLineList)
    {
        
        Database.SaveResult[] updateResult = Database.Insert(journalLineList, False); 
        //List<Account>accountsToUpdate = updateAccounts.values();
        //Database.SaveResult[] updateResultforAccount = Database.Update(accountsToUpdate, False);
         for(Integer i=0;i<updateResult.size();i++){
    if (updateResult.get(i).isSuccess()){
        updateResult.get(i).getId();

    }else if (!updateResult.get(i).isSuccess()){
        // DML operation failed
        Database.Error error = updateResult.get(i).getErrors().get(0);
        String failedDML = error.getMessage();
        journalLineList.get(i);//failed record from the list
        system.debug('Failed ID'+journalLineList.get(i).Id);
     }
        
    }
    }
    /**
* @description       This method will return the PM Target Id for given Manager 
* @name              getPMTargetId
* @param             Id 
* @return            Id
* @throws            NA
*/ 
    
    public Id getPMTargetId(Id productManagerId)
    {   
        
        if(pmTargetMap.containsKey(productManagerId))
        {
            productManagerId  = pmTargetMap.get(productManagerId).Id;
        }else 
        {
            productManagerId = Null;
        }
        return productManagerId;
        
    }
    
    /**
* @description       This method will return the TSM Target Id for given TSM User and Team 
* @name              getTSMTargetId
* @param             Id 
* @return            Id
* @throws            NA
*/ 
    
    public Id getTSMTargetId(Id teamId,Id tsmId,Boolean q6Check,String corpcode)
    {
       SYSTEM.debug('TSM Target Inside Opportunity Handler'+tsmTargetMap);
        system.debug('This is TSM id'+tsmId);
        system.debug('This is team id'+teamId);
        system.debug('This is corp code'+corpcode);
        system.debug('This is Boolean q6'+q6Check);
        system.debug('Is Psedu contains value'+pseudoTargetMap.containsKey((String)tsmId+corpcode));
        system.debug('Pseudo map'+pseudoTargetMap);             
        if(tsmTargetMap.containsKey((String)teamId+(String)tsmId))
        {
            System.debug('iNSIDE nORMAL TARGET');
            tsmId = tsmTargetMap.get((String)teamId+(String)tsmId).Id;
            
            
        }else If((pseudoTargetMap.containsKey((String)tsmId+corpcode)) && q6Check !=True) 
        {
            System.debug('Inside Pseudo Target');
            tsmId = pseudoTargetMap.get((String)tsmId+corpcode).Id;
        }else{
            tsmId = null;
        }
        return tsmId;
    } 
}