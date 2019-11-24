public class TargetTransferController 
{
    Public Account acct;   
    Public List<Opportunity> opportunityList ;
    Public List<Opportunity> opportunityForJournal ;    
    Public List<Id>opportunityIdList ; 
    Public List<Id>accountIdList ;
    Public Map<Id,Opportunity> opportunityDetails;
    Public Map<Id,Account> customerDetailsMap ;
    Public Set<Id>productManagerIdsList = new Set<Id>();
    Public Set<Id>tsmIdsList = new Set<Id>();
    Public Map<String,TSMTarget__c> pseudoTargetMap  = new Map<String,TSMTarget__c>();
    Public Map<String,TSMTarget__c> tsmTargetMap   =   new Map<String,TSMTarget__c>();
    Public Map<Id,PMTarget__c> pmTargetMap = new Map<Id,PMTarget__c>();
    Public Map<Id,Contact>oldManagers = new Map<Id,Contact>();
    Public boolean pbMsg {get; set;}
    Public boolean pbOpp {get; set;}
    Id oldTsm;
    public List<OpportunityWrapper> OpportunityWrapperList {get; set;}
    public List<Opportunity> OpportunityToUpdate = new List<Opportunity>();
    Opportunity opportunityRecord = new Opportunity();
    Account customerAccount = new Account();
    Account targetAccount;
    public String oldTSMName {get; set;}
    public String newTSMName {get; set;}
    OpportunityTriggerHandler handlerObject;
    String currentFiscalYear;   
    List<JournalLineItem__c> journalLineList;    
    String officerCode;   
    Id pmTarget;
    Id tsmTarget;
    Id oldTSMId;
    Id oldFXManager;
    Id oldCommodityManager;
    Id oldIRRMMnager;
    Id productManagerContact;    
    String productManagerContactName;    
    Id businessRecordTypeId;
    Id vanillaRecordTypeId;
    Id fxRecordTypeId;
    Id commodityRecordTypeId;
    Id irrmRecordTypeId;
    Id crmRecordTypeId;
    Id oldTSMTarget;
    Id oldPMTarget;
    Public boolean tsmTransfer;
    Public boolean pmTransfer;
    Id oldproductManagerContact;
    String oldproductManagerContactName;
    
    Public TargetTransferController(ApexPages.StandardController stdController)
    {
        opportunityForJournal = new List<opportunity>();
        opportunityList = new List<opportunity>();
        opportunityIdList = new List<Id>();
        accountIdList     = new List<Id>();
        opportunityDetails = new Map<Id,Opportunity>();
        customerDetailsMap = new Map<Id,Account>();
        //pbMsg = false;
        //pbOpp = false;
        currentFiscalYear = CYBGUtilClass.findCurrentFY(System.Today(), CYBGUtilClass.fiscalYearStartMonth());
        OpportunityWrapperList = new List<OpportunityWrapper>();
        journalLineList        = new List<JournalLineItem__c>();
        this.acct = (Account)stdController.getRecord();
        system.debug('Account value'+acct);
        Id AccountidValue = apexpages.currentpage().getparameters().get('id');
        system.debug('Id Value '+AccountidValue);
        handlerObject = new OpportunityTriggerHandler();
        businessRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRMBusinessLoan).getRecordTypeId();
        vanillaRecordTypeId   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeVanilaFX).getRecordTypeId();
        fxRecordTypeId        = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeFXCash).getRecordTypeId();        
        commodityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCommodity).getRecordTypeId();
        irrmRecordTypeId      = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeIRRM).getRecordTypeId();
        crmRecordTypeId       = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRM).getRecordTypeId();
        
        
        system.debug('Old TSM Manager'+oldTsmID);
        opportunityList = [Select Id,Name,Amount,Maturity_Date__c,AccountId,Account.OwnerId
                           ,Product__c,RecordType.Name,Account.OldTSMId__c,Account.OldFXManagerId__c,Owner.id,Owner.FirstName,Owner.LastName,
                            Owner.Manager.Id,Opp_CorpCode__c,Opp_ETRef__c,Account.OldCommManagerId__c,Opp_OfficerCode__c,
                            Owner.Manager.FirstName,Opp_GLAccountNumber__c,isQ6Available__c,Account.OldIRRMManagerId__c,
                            Owner.Manager.LastName,Opp_TradeID__c from Opportunity where Accountid=:acct.id];
        
       targetAccount = [Select OldTSMId__c,OwnerId,OldFXManagerId__c,
                                 OldCommManagerId__c,OldIRRMManagerId__c,Owner.FirstName,Owner.LastName,
                                 Owner.ManagerId,Owner.Manager.FirstName,Owner.Manager.LastName From Account where id=:acct.id];
        
        //oldTSMUser = [Select Id,FirstName,LastName,ManagerId,Manager.FirstName,Manager.LastName from User where ID =:targetAccount.OldTSMId__c];
        oldTSMName = targetAccount.Owner.FirstName + targetAccount.Owner.LastName;
        newTSMName = opportunityList[0].Owner.FirstName + opportunityList[0].Owner.LastName;
        oldTsmID = targetAccount.OldTSMId__c;
        oldFXManager = targetAccount.OldFXManagerId__c;
        system.debug('Old Manager Id in Constructor '+oldFXManager);
        oldCommodityManager = targetAccount.OldCommManagerId__c;
        oldIRRMMnager = targetAccount.OldIRRMManagerId__c;
        tsmIdsList.add(targetAccount.OldTSMId__c);
        tsmIdsList.add(targetAccount.OwnerId);
        productManagerIdsList.add(targetAccount.OldFXManagerId__c);
        productManagerIdsList.add(targetAccount.OldCommManagerId__c);
        productManagerIdsList.add(targetAccount.OldIRRMManagerId__c);
        addToWrapper();
    }
    Public Void addToWrapper()
    {
        For(Opportunity eachOpportunityRecord:opportunityList){
            OpportunityWrapperList.add(new OpportunityWrapper(eachOpportunityRecord));
        }   
    }
    
    
    Public PageReference  processSelectedforTSM()
    {
        pmTransfer = false;
        tsmTransfer = True;
        
        processRecords();
        Database.SaveResult[] updateResults = Database.Update(opportunityToUpdate, False);
        PageReference pf = new PageReference('/'+acct.id);
        pf.setRedirect(true);
        return pf;
        
    }
    Public PageReference  processSelectedforPM()
    {
        tsmTransfer = false;
        pmTransfer = True;
        processRecords();
        PageReference pf = new PageReference('/'+acct.id);
        pf.setRedirect(true);
        return pf;
    }
    
    Public Void processRecords()
    {
        system.debug('Called from the Button');
        for(OpportunityWrapper eachWrapper: OpportunityWrapperList) 
        {
            if(eachWrapper.selected == true) 
            {
                opportunityIdList.add(eachWrapper.opportunityRecord.Id);
                accountIdList.add(eachWrapper.opportunityRecord.Accountid);
                opportunityForJournal.add(eachWrapper.opportunityRecord);
            }
        }
        System.debug('Opportunity for Journal'+opportunityForJournal);
        opportunityDetails     = CYBGUtilClass.getOpportunityDetails(opportunityIdList);
        customerDetailsMap     = CYBGUtilClass.getAccountDetails(accountIdList);
        For(Account eachAccount:customerDetailsMap.values())
        {
            productManagerIdsList.add(eachAccount.FX_Manager__c);
            productManagerIdsList.add(eachAccount.IRRM_Manager__c);
            productManagerIdsList.add(eachAccount.Commodity_Manager__c);
        }
        system.debug('Product Manager Ids'+productManagerIdsList);
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
        
        For(Contact eachContact :[Select Id,FirstName,LastName from Contact where id In:productManagerIdsList])
        {
            oldManagers.put(eachContact.id, eachContact);
        }
        
        system.debug('TSM Target Map'+tsmTargetMap);
        system.debug('PM Target Map'+pmTargetMap);
        integer count = 0;
        For(Opportunity eachOpportunityRecord :opportunityForJournal)
        {  
            Count = count+1;
            System.debug('Count is'+Count);
            customerAccount  = customerDetailsMap.get(eachOpportunityRecord.accountId);       
            opportunityRecord = opportunityDetails.get(eachOpportunityRecord.id);
            system.debug('Customer Account'+customerAccount);
            system.debug('Opportunity Record'+opportunityRecord);
            if((eachOpportunityRecord.RecordTypeId == fxRecordTypeId )||(eachOpportunityRecord.RecordTypeId == crmRecordTypeId))
            {
                system.debug('Inside FX Manager Opp');
                pmTarget = getPMTargetId(customerAccount.FX_Manager__c);
                system.debug('Old FX Manager'+oldFXManager);
                oldpmTarget = getPMTargetId(oldFXManager);
                
                system.debug('OLD PM TARGET ID '+oldpmTarget);
                system.debug('New PM Target Record'+pmTarget);
                system.debug('Current Customer Owner Id'+customerAccount.ownerId);
                tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,customerAccount.ownerId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
                system.debug('New value for New TSM'+tsmTarget);
                oldTSMTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,oldTSMId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
                system.debug('OLd Tsm Target'+oldTSMTarget);
                productManagerContact = customerAccount.FX_Manager__c;
                oldproductManagerContact     = oldFXManager;
                productManagerContactName    = customerAccount.FX_Manager__r.FirstName +' '+  
                    customerAccount.FX_Manager__r.LastName;
                oldproductManagerContactName   = oldManagers.containsKey(oldFXManager)?(oldManagers.get(oldFXManager).FirstName + oldManagers.get(oldFXManager).LastName):Null; 


            }
            else if(eachOpportunityRecord.RecordTypeId == commodityRecordTypeId) 
            {   system.debug('Inside Commodity Manager Opp');
                pmTarget = getPMTargetId(customerAccount.Commodity_Manager__c);
                oldpmTarget = getPMTargetId(oldCommodityManager);
                tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,opportunityRecord.ownerId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
                oldTSMTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,oldTSMId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);  
             system.debug('OLd Tsm Target'+oldTSMTarget);
                productManagerContact        = customerAccount.Commodity_Manager__c;
                oldproductManagerContact     = oldCommodityManager;
                productManagerContactName    = customerAccount.Commodity_Manager__r.FirstName +' '+  
                    customerAccount.Commodity_Manager__r.LastName;

             oldproductManagerContactName   = oldManagers.containsKey(oldCommodityManager)?(oldManagers.get(oldCommodityManager).FirstName + oldManagers.get(oldCommodityManager).LastName):Null; 

            }
            else 
            { 
                system.debug('Inside IRRM Manager Opp');
                pmTarget = getPMTargetId(customerAccount.IRRM_Manager__c);
                
                oldpmTarget = getPMTargetId(oldIRRMMnager);
                
                tsmTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,opportunityRecord.ownerId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
                oldTSMTarget = getTSMTargetId(customerAccount.RM_Name__r.Con_Team__c,oldTSMId,
                                                         opportunityRecord.isQ6Available__c,opportunityRecord.Opp_CorpCode__c);
                system.debug('OLd Tsm Target'+oldTSMTarget);
                productManagerContact        = customerAccount.IRRM_Manager__c;
                oldproductManagerContact     = oldIRRMMnager;
                productManagerContactName    = customerAccount.IRRM_Manager__r.FirstName +' '+  
                    customerAccount.IRRM_Manager__r.LastName;

                oldproductManagerContactName   = oldManagers.containsKey(oldIRRMMnager)?(oldManagers.get(oldIRRMMnager).FirstName + oldManagers.get(oldIRRMMnager).LastName):Null; 
            }
            
            if(customerAccount != null && customerAccount.RM_Name__c != null)
            {
                officerCode = customerAccount.RM_Name__r.Officer_Code__c;
            }
            else
            {
                officerCode = eachOpportunityRecord.Opp_OfficerCode__c;
            }
            
            /*if(eachOpportunityRecord.RecordTypeId == crmRecordTypeId || eachOpportunityRecord.RecordTypeId == vanillaRecordTypeId)
            {*/
                system.debug('Inside the Function------');
                
                JournalLineItem__c journals = CYBGUtilClass.createJournalLineItemsRecords(eachOpportunityRecord.Id,
                                                                                customerAccount.RM_Name__c,
                                                                                eachOpportunityRecord.Amount,Label.Transaction_Type_Debit,NULL,
                                                                                currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                officerCode,customerAccount.CIF__c,
                                                                                opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                eachOpportunityRecord.Product__c,opportunityRecord.RecordType.Name,
                                                                                productManagerContact,productManagerContactName,                               
                                                                                customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                customerAccount.OwnerId,targetAccount.owner.FirstName + ' '+ 
                                                                                targetAccount.owner.LastName,targetAccount.owner.ManagerId,
                                                                                ((targetAccount.owner.Manager.FirstName!=Null)?targetAccount.owner.Manager.FirstName:'')+
                                                                                ' '+((targetAccount.owner.Manager.LastName!=Null)?targetAccount.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                customerAccount.RM_Name__r.Con_Centre__c,
                                                                                customerAccount.RM_Name__r.Con_Region__c,
                                                                                customerAccount.RM_Name__r.Con_Division__c,
                                                                                customerAccount.RM_Name__r.Con_Group__c,pmTarget,tsmTarget,Null);
                                    journals.Journal_TransferredforTargtes__c = True;
                                    journalLineList.add(journals);
                
                JournalLineItem__c journal = CYBGUtilClass.createJournalLineItemsRecords(eachOpportunityRecord.Id,
                                                                                customerAccount.RM_Name__c,
                                                                                (eachOpportunityRecord.Amount) *-1,Label.Transaction_Type_Credit,NULL,
                                                                                currentFiscalYear,opportunityRecord.Opp_TradeID__c,((customerAccount.RM_Name__r.FirstName!=Null)?customerAccount.RM_Name__r.FirstName:'')+
                                                                                ((customerAccount.RM_Name__r.LastName!=Null)?customerAccount.RM_Name__r.LastName:''),                                              
                                                                                officerCode,customerAccount.CIF__c,
                                                                                opportunityRecord.Opp_CorpCode__c,customerAccount.Id,
                                                                                opportunityRecord.Opp_ETRef__c,opportunityRecord.Opp_GLAccountNumber__c,
                                                                                eachOpportunityRecord.Product__c,opportunityRecord.RecordType.Name,
                                                                                (pmTransfer==True?oldproductManagerContact:productManagerContact),
                                                                                (pmTransfer==True?oldproductManagerContactName:productManagerContact),                               
                                                                                customerAccount.RM_Name__r.Con_Team__c,customerAccount.RM_Name__r.Con_Team__r.Name,                                             
                                                                                (tsmTransfer==True?oldTSMId:customerAccount.ownerId),opportunityRecord.owner.FirstName + ' '+ 
                                                                                opportunityRecord.owner.LastName,opportunityRecord.owner.ManagerId,
                                                                                ((opportunityRecord.owner.Manager.FirstName!=Null)?opportunityRecord.owner.Manager.FirstName:'')+
                                                                                ' '+((opportunityRecord.owner.Manager.LastName!=Null)?opportunityRecord.owner.Manager.LastName:''),customerAccount.WID__c,
                                                                                customerAccount.RM_Name__r.Con_Centre__c,
                                                                                customerAccount.RM_Name__r.Con_Region__c,
                                                                                customerAccount.RM_Name__r.Con_Division__c,
                                                                                customerAccount.RM_Name__r.Con_Group__c,(pmTransfer==True?oldpmTarget:pmTarget),(tsmTransfer==True?oldtsmTarget:tsmTarget),Null);
              journal.Journal_TransferredforTargtes__c = True;
              journalLineList.add(journal);
                
                
            //}
            
            eachOpportunityRecord.OwnerId = targetAccount.ownerid;
            opportunityToUpdate.add(eachOpportunityRecord);
            
        }
        system.debug('Journal List Values'+journalLineList);
        Database.SaveResult[] updateResult = Database.Insert(journalLineList, False);
        System.debug('Database Result'+updateResult);
        
    }
    
    Public Void ProcessTsm()
    {
        system.debug('This is inside Process Target method');
        pbMsg = True;
    }
    
    public Id getTSMTargetId(Id teamId,Id tsmId,Boolean q6Check,String corpcode)
    {
       SYSTEM.debug('TSM Target Inside Opportunity Handler'+tsmTargetMap);
        if(tsmTargetMap.containsKey((String)teamId+(String)tsmId))
        {
            tsmId = tsmTargetMap.get((String)teamId+(String)tsmId).Id;
            
            
        }else If((pseudoTargetMap.containsKey((String)tsmId+corpcode)) && q6Check !=True) 
        {
            
            tsmId = pseudoTargetMap.get((String)tsmId+corpcode).Id;
        }else{
            tsmId = null;
        }
        return tsmId;
    }
    
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
    
    public class OpportunityWrapper {
        public Opportunity opportunityRecord {get; set;}
        public Boolean selected {get; set;}
        
        public OpportunityWrapper(Opportunity eachOpportunityRecord) {
            opportunityRecord = eachOpportunityRecord;
            selected = false;
        }
    }
}