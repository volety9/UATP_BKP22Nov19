/*
@Author        : Ramkumar M B
@Name          : AccountTriggerHandler
@Created Date  : 21st March 2018
@Description   : This is a Handler for Account Trigger 
@version       : 1.0
*/
public class AccountTriggerHandler 
{
    List<ID>accountIdList = new List<Id>();
    Set<Id>bankerIdList =  new Set<Id>();
    Set<Id>productManagerIdsList = new Set<Id>();
    Set<Id>oldBankerIdList =  new Set<Id>();
    Set<Id>tsmIdsList = new Set<Id>();
    Map<Id,String>recordtypedetails = new Map<Id,String>();
    Map<Id,Account> accountOpportunityMap = new Map<Id,Account>();
    List<opportunity>OpportunityList = new List<opportunity>();
    Map<String,TSMTarget__c> pseudoTargetMap = new Map<String,TSMTarget__c>();
    List<Id> opportunityIdsList = new List<Id>();
    Map<String,TSMTarget__c>tsmTargetMap = new Map<String,TSMTarget__c>();
    Map<Id,PMTarget__c>pmTargetMap = new Map<Id,PMTarget__c>();
    List<JournalLineItem__c> journalLineList = new List<JournalLineItem__c>();
    Map<Id,List<JournalLineItem__c>> opportunityListWithJournalMap = new Map<Id,List<JournalLineItem__c>>();
    Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
    Map<Id,Contact>bankerMap = new Map<Id,Contact>();
    List<JournalLineItem__c> journalListForUpdatedAccount = new List<JournalLineItem__c>();
    String currentFiscalYear;
    Id businessRecordTypeId;
    Id vanillaRecordTypeId;
    Id fxRecordTypeId;
    Id commodityRecordTypeId;
    Id irrmRecordTypeId;
    Id crmRecordTypeId;
    Id tsmId;
    Id productManagerId;
    Id pmTargetForOldBanker; 
    Id pmTargetForNewBanker;
    Id customerRecordTypeId;
    Id tsmTargetForOldBanker;
    Id tsmTargetForNewBanker;
    User loggedInUser;
    string userId ;
    Integer fyStartMonth;

    public AccountTriggerHandler(){
        
    	businessRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRMBusinessLoan).getRecordTypeId();
        vanillaRecordTypeId   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeVanilaFX).getRecordTypeId();
        fxRecordTypeId        = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeFXCash).getRecordTypeId();        
        commodityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCommodity).getRecordTypeId();
        irrmRecordTypeId      = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeIRRM).getRecordTypeId();
        crmRecordTypeId       = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.RecordTypeCRM).getRecordTypeId();
        customerRecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get(label.RecordTypeCustomer).getRecordTypeId();
        userId = userinfo.getUserId();
        //loggedInUser = [Select Id,CommunityNickname,Email,Username from User where Id =:userId];
        //fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        /*For(RecordType eachRecordType:[Select Id,Developername from RecordType where SobjectType = 'Account'])
      {
          recordtypedetails.put(eachRecordType.id, eachRecordType.DeveloperName);
      }*/
    }
    /**
     * @description       Create the Journals for the Banker Update
     * @name              afterAccountBankerUpdate
     * @param             List<Opportunity> 
     * @return            void
     * @throws            NA
     */ 
    
    public void onAfterUpdate(List<Account> accountList)
    {

        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        for(Account eachAccount :accountList)
        {   
            Account OldAccount = (Account)Trigger.oldMap.get(eachAccount.Id);
            
            system.debug('old Account RM Name'+OldAccount.RM_Name__c);
            system.debug('eachAccount Account RM Name'+eachAccount.RM_Name__c);
           
            if(OldAccount.RM_Name__c != eachAccount.RM_Name__c && OldAccount.RM_Name__c!=Null)
            {
                System.debug('Yes older Banker is differ than new banker Account');
                accountIdList.add(eachAccount.ID);
                bankerIdList.add(OldAccount.RM_Name__c);
                bankerIdList.add(eachAccount.RM_Name__c);
                oldBankerIdList.add(eachAccount.RM_Name__c);
                productManagerIdsList.add(eachAccount.FX_Manager__c);
                productManagerIdsList.add(eachAccount.IRRM_Manager__c);
                productManagerIdsList.add(eachAccount.Commodity_Manager__c);
            }
        }
        
        IF(!accountIdList.isEmpty() && !oldBankerIdList.isEmpty())
        {
            For(Account accountmap :[Select Id,Name,RM_Name__c,FX_Manager__c,
                                                               FX_Manager__r.FirstName,FX_Manager__r.LastName,
                                                               IRRM_Manager__c,IRRM_Manager__r.FirstName,
                                                               IRRM_Manager__r.LastName,WID__c,CIF__c,
                                                               Commodity_Manager__c,Commodity_Manager__r.FirstName,
                                                               Commodity_Manager__r.LastName,RM_Name__r.Officer_Code__c,
                                                               RM_Name__r.Firstname,RM_Name__r.Lastname, 
                                                               RM_Name__r.Con_Team__c,RM_Name__r.Name,
                                                               RM_Name__r.Con_Team__r.Name,
                                                               RM_Name__r.Con_Centre__c,
                                                               RM_Name__r.Con_Region__c,
                                                               RM_Name__r.Con_Division__c,
                                                               RM_Name__r.Con_Group__c,(SELECT ID,NAME,ownerId FROM 
                                                                                        OPPORTUNITIES where 
                                                                                        StageName ='Closed Won')
                                                               From Account 
                                                               where Id In :accountIdList])    
            {
                accountOpportunityMap.put(accountmap.id, accountmap);
                
                For (Opportunity eachopportunityMapValue:accountmap.Opportunities)
                {
                    opportunityIdsList.add(eachopportunityMapValue.id);
                    tsmIdsList.add(eachopportunityMapValue.ownerId);
                    
                }
                
            }
            bankerMap = new Map<Id,Contact>([Select Id,Firstname,Lastname,Con_Team__c,Con_Team__r.Name,Officer_Code__c,
                                              Con_Centre__c,Con_Region__c,Con_Division__c,Con_Group__c 
                                             From Contact where Id IN :bankerIdList ]);
            
            For(TSMTarget__c eachtsmTarget :[Select Id,Name,TSMTar_TSM__c,TSMTar_Team__c from TSMTarget__c
                                             where (TSMTar_Status__c = :System.Label.Active OR (TSMTar_Status__c =:System.label.Terminated And TSMTar_EndDate__c >= Today ))and TSMTar_TSM__c IN :tsmIdsList])
            {
                tsmTargetMap.put((String)eachtsmTarget.TSMTar_Team__c + (String)eachtsmTarget.TSMTar_TSM__c, eachtsmTarget);
            }
            
            For(PMTarget__c eachPMTarget :[Select Id,Name,PMTar_PMContact__c from PMTarget__c 
                                           where (PMTar_Status__c = :System.Label.Active OR (PMTar_Status__c =:System.label.Terminated And PMTar_EndDate__c >= Today )) and PMTar_PMContact__c IN :productManagerIdsList])
            {
                pmTargetMap.put(eachPMTarget.PMTar_PMContact__c, eachPMTarget);
                
            }
                
            
        // CYBGUtilClass.findCurrentFY(System.Today(), CYBGUtilClass.fiscalYearStartMonth());
        opportunityMap = CYBGUtilClass.getOpportunityDetails(opportunityIdsList);    
        If(!opportunityMap.IsEmpty())
        {  
            For(Opportunity eachOpportunity:opportunityMap.values())
            {   
                if(!eachOpportunity.Journal_Line_Items__R.IsEmpty())
                {
                    opportunityListWithJournalMap.put(eachOpportunity.id, eachOpportunity.Journal_Line_Items__R);
                    
                }
                currentFiscalYear = CYBGUtilClass.findCurrentFY(eachOpportunity.CloseDate, fyStartMonth);
                
                List<JournalLineItem__c> journalList = eachOpportunity.Journal_Line_Items__R;
                Account customerAccount = (Account)Trigger.oldMap.get(eachOpportunity.AccountId);
                Account updatedAccount = accountOpportunityMap.get(eachOpportunity.AccountId);
                Contact oldBanker = bankerMap.get(customerAccount.RM_Name__c);
                Contact newBanker = bankerMap.get(updatedAccount.RM_Name__c);
                tsmTargetForOldBanker = getTSMTargetId(oldBanker.Con_Team__c,eachOpportunity.OwnerId);
                tsmTargetForNewBanker = getTSMTargetId(oldBanker.Con_Team__c,eachOpportunity.OwnerId);
                
               
                //JournalLineItem__c journalRecord = (JournalLineItem__c)Trigger.newMap.get(journalList[0].id);
                
                if((eachOpportunity.RecordTypeId == fxRecordTypeId )||(eachOpportunity.RecordTypeId == crmRecordTypeId))
                {
                    pmTargetForOldBanker = getPMTargetId(customerAccount.FX_Manager__c);
                    pmTargetForNewBanker = getPMTargetId(updatedAccount.FX_Manager__c);
                    
                }else if(eachOpportunity.RecordTypeId == commodityRecordTypeId) {
                    
                    pmTargetForOldBanker = getPMTargetId(customerAccount.Commodity_Manager__c);
                    pmTargetForNewBanker = getPMTargetId(updatedAccount.Commodity_Manager__c);
                }else{
                    pmTargetForOldBanker = getPMTargetId(customerAccount.IRRM_Manager__c);
                    pmTargetForNewBanker = getPMTargetId(updatedAccount.IRRM_Manager__c); 
                }
                 journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    (oldBanker!=Null)?oldBanker.Id:null,(!journalList.isEmpty()?(journalList[0].Journal_Amount__c)*-1:Null),Label.Transaction_Type_Credit,(!journalList.isEmpty()?journalList[0].id:Null), 
                                                                                    currentFiscalYear,eachOpportunity.opp_TradeID__c,oldBanker.FirstName + 
                                                                                    oldBanker.LastName,                                              
                                                                                    oldBanker.Officer_Code__c,customerAccount.CIF__c,
                                                                                    eachOpportunity.Opp_CorpCode__c,customerAccount.Id,
                                                                                    eachOpportunity.Opp_ETRef__c,eachOpportunity.Opp_GLAccountNumber__c,eachOpportunity.Product__c,eachOpportunity.RecordType.Name,
                                                                                    (!journalList.isEmpty()?journalList[0].Journal_PMContact__c:Null),(!journalList.isEmpty()?journalList[0].Journal_PMContactName__c:Null),                               
                                                                                    oldBanker.Con_Team__c,oldBanker.Con_Team__r.Name,                                             
                                                                                    eachOpportunity.OwnerId,eachOpportunity.owner.FirstName + ' '+ 
                                                                                    eachOpportunity.owner.LastName,eachOpportunity.owner.ManagerId,
                                                                                    eachOpportunity.owner.Manager.FirstName + ' '+ 
                                                                                    eachOpportunity.owner.Manager.LastName,customerAccount.WID__c,
                                                                                    oldBanker.Con_Centre__c,
                                                                                    oldBanker.Con_Region__c,
                                                                                    oldBanker.Con_Division__c,
                                                                                    oldBanker.Con_Group__c,pmTargetForOldBanker,tsmTargetForOldBanker,Label.ReversalReasonThroughTDM));
                
                journalLineList.add(CYBGUtilClass.createJournalLineItemsRecords(eachOpportunity.Id,
                                                                                    (newBanker!=Null)?newBanker.Id:null,eachOpportunity.Amount,Label.Transaction_Type_Debit,(!journalList.isEmpty()?journalList[0].id:Null),                                                                            
                                                                                    currentFiscalYear,eachOpportunity.opp_TradeID__c,((newBanker!=Null)?newBanker.FirstName:null ) + 
                                                                                    ((newBanker!=Null)?newBanker.LastName:null) ,                                              
                                                                                    (newBanker!=Null)?newBanker.Officer_Code__c:null ,updatedAccount.CIF__c,
                                                                                    eachOpportunity.Opp_CorpCode__c,updatedAccount.Id,
                                                                                    eachOpportunity.Opp_ETRef__c,eachOpportunity.Opp_GLAccountNumber__c,eachOpportunity.Product__c,eachOpportunity.RecordType.Name,
                                                                                    (!journalList.isEmpty()?journalList[0].Journal_PMContact__c:Null),(!journalList.isEmpty()?journalList[0].Journal_PMContactName__c:Null),                               
                                                                                    //newBanker.Con_Team__c,newBanker.Con_Team__r.Name,
                                                                                    oldBanker.Con_Team__c,oldBanker.Con_Team__r.Name,  
                                                                                    eachOpportunity.OwnerId,eachOpportunity.owner.FirstName + ' '+ 
                                                                                    eachOpportunity.owner.LastName,eachOpportunity.owner.ManagerId,
                                                                                    eachOpportunity.owner.Manager.FirstName + ' '+ 
                                                                                    eachOpportunity.owner.Manager.LastName,updatedAccount.WID__c,
                                                                                    oldBanker.Con_Centre__c,
                                                                                    oldBanker.Con_Region__c,
                                                                                    oldBanker.Con_Division__c,
                                                                                    oldBanker.Con_Group__c,pmTargetForNewBanker,tsmTargetForNewBanker,Null)); 
                
            }
        }
       
         insertJournalLineItems(journalLineList);
            
        }
         Database.SaveResult[] updateResult = Database.Insert(journalLineList, False);
        
    }
    
/**
* @description       Inserting Journal for valid processed Opportunity. 
* @name              insertJournalLineItems
* @param             List<JournalLineItem__c> 
* @return            void
* @throws            NA
*/ 
    
    public Void insertJournalLineItems(List<JournalLineItem__c> journalLineItemList)
    {
        
        Database.SaveResult[] updateResult = Database.Insert(journalLineItemList, False); 
        
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
    
    public Id getTSMTargetId(Id teamId,Id tsmId)
    {
        if(tsmTargetMap.containsKey((String)teamId+(String)tsmId))
        {
            tsmId = tsmTargetMap.get((String)teamId+(String)tsmId).Id;
            
        }else 
        {
            tsmId = null;
        }
        return tsmId;
    }
    
  public void onBeforeUpdate(List<Account> accountList)
  {
      loggedInUser = [Select Id,CommunityNickname,Email,Username from User where Id =:userId];
      For(Account eachAccount :accountList)
      {
         
              Account accountmap = (Account)Trigger.oldMap.get(eachAccount.id);
          
              If(eachAccount.RecordType__c =='Customer' && eachAccount.RecordType__c !=accountmap.RecordType__c)
              {
                  eachAccount.RecordTypeId = customerRecordTypeId;
                  if(eachAccount.ClientTier__c==null){
                  eachAccount.ClientTier__c = Label.ClientTier;
                  }
              }
          If(accountmap.RM_Name__c==Null && eachAccount.RM_Name__c!=Null)
          {
              eachAccount.BankerAdded__c = True;
          }
          
          String loggedInUserName = loggedInUser.UserName;
          
          If(loggedInUserName.contains('cybg.crm.integration') && (eachAccount.Customer_Status__c=='Dormant'||
             eachAccount.Customer_Status__c=='Lost') &&  (accountmap.Customer_Status__c=='Dormant' || 
                                                         accountmap.Customer_Status__c =='Lost'))
          {
              
              eachAccount.Lost_Reason__c = (accountmap.Lost_Reason__c!=Null?accountmap.Lost_Reason__c:Null);
          }
 
          
      }
  }
  
    public void onBeforeInsert(List<Account> accountList)
  {
      For(RecordType eachRecordType:[Select Id,Developername from RecordType where SobjectType = 'Account'])
      {
          recordtypedetails.put(eachRecordType.id, eachRecordType.DeveloperName);
      }
      
      For(Account eachAccount :accountList)
      {
          
              If(eachAccount.RecordType__c =='Customer')
              {
                  eachAccount.RecordTypeId = customerRecordTypeId;
                  if(eachAccount.ClientTier__c==null){
                  eachAccount.ClientTier__c = Label.ClientTier;
                  }
              }else
              {
               eachAccount.RecordType__c = recordtypedetails.get(eachAccount.RecordTypeId);   
              }
          
          }

          
      }
     
}