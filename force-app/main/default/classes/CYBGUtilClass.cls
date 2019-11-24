/*
@Author        : Sushant
@Name          : CYBGUtilClass
@Created Date  : 12th Jan 2018
@Description   : This is a Util Class 
@version       : 1.0
*/

Public class CYBGUtilClass
{
    public static boolean runBeforeTrigger = True;
    public static boolean runAfterTrigger = True;
    public static boolean firstRun = true; 
    public static boolean beforeTriggerRun = true;
    public static boolean accountFirstRun = true;   
    
   /**
    * @description       Method to get the Current FY start month
    * @name              fiscalYearStartMonth
    * @param             null
    * @return            Integer
    * @throws            NA
    */ 
    public static Integer fiscalYearStartMonth(){
        Integer fiscalYearStartMonth = [select FiscalYearStartMonth from Organization 
                                        where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        return fiscalYearStartMonth;
    }
    
   /**
    * @description       Method to get the Current FY
    * @name              findCurrentFY
    * @param             Date, Integer
    * @return            String 
    * @throws            NA
    */     
    Public Static String findCurrentFY(Date todayDate, Integer fyStartMonth ){
        Integer currentMonth = todayDate.month();
        Integer currentYear = todayDate.year() ;
        String currentFY;
        if(currentMonth >= fyStartMonth ){            
            currentFY = Label.Fiscal_Year + (String.valueOf(currentYear + 1)).right(2);            
        }
        else{
            currentFY = Label.Fiscal_Year + (String.valueOf(currentYear)).right(2);
        }
        return currentFY;
    }
    
    /**
    * @description       Method to get the Start Date of FY
    * @name              findStartDateOfFy
    * @param             Date, Integer
    * @return            Date 
    * @throws            NA
    */     
    Public Static Date findStartDateOfFY(Date todayDate, Integer fyStartMonth ){
        Integer currentMonth = todayDate.month();
        Integer currentYear = todayDate.year();
        if(currentMonth >= fyStartMonth ){            
            currentYear = currentYear;            
        }
        else{
            currentYear = currentYear - 1;
        }   
        Date StartDate = date.newInstance(currentYear, fyStartMonth , 1 );
        return StartDate;
    }
    
    /**
    * @description       Method to get the Start Date of FY
    * @name              findStartDateOfFy
    * @param             Date, Integer
    * @return            Date 
    * @throws            NA
    */     
    Public Static Date findEndDateOfFY(Date todayDate, Integer fyStartMonth ){
        Integer currentMonth = todayDate.month();
        Integer currentYear = todayDate.year();
        if(currentMonth >= fyStartMonth ){            
            currentYear = currentYear + 1;            
        }
        else{
            currentYear = currentYear;
        }   
        Integer numberOfDays = Date.daysInMonth(currentYear , fyStartMonth -1);
        Date endDate = date.newInstance(currentYear, fyStartMonth -1 , numberOfDays );
        return endDate;
    }
    
   /**
    * @description       This Method will get the object field data for Journal Line Object 
    *                    and create a local copy of Journal and return the same .
    * @name              createJournalLineItemsRecords
    * @param              
    * @return            JournalLineItem__c
    * @throws            NA
    */ 
    Public static JournalLineItem__c createJournalLineItemsRecords(Id opportunityIdValue,Id bankerId,Decimal amount,
                                                                   String creditDebit,Id journalId,String fiscalYear,
                                                                   String tradeID,String bankerName,String bankerOfficerCode,
                                                                   String cif,String corpCode,Id customer,
                                                                   String etReference,String glAccountNo,String product,
                                                                   String productFamily,Id productManagerContact,
                                                                   String productManagerContactName,Id team,
                                                                   String teamName,Id tsm,String TSMName, 
                                                                   Id tsmManager,String tsmManagerName,
                                                                   String wid,String centreName,String regionName,
                                                                   String divisionName,String groupName,Id pmTarget,Id tsmTarget,String reversalReson)
    {
        
        system.debug('Inside Journal Creation');

        String fixGLAccount ='';
        if(productFamily == label.RecordTypeFXCash || 
           productFamily == label.RecordTypeIRRM || productFamily == label.RecordTypeCommodity){
               if(product=='FX' || product=='FXForward'|| product=='FXSwap' ||product=='FXFlexiForward'){
                   fixGLAccount =label.FX_GL_Account; 
                   System.debug('its a Fixed GL Account');
               }else{
                   fixGLAccount =label.Common_GL_Account; 
               } 
           }else{
                fixGLAccount =glAccountNo;
           }
        JournalLineItem__c journalLineItemObject = New JournalLineItem__c();
        journalLineItemObject.Journal_JournalLineItem__c = journalId;
        journalLineItemObject.Journal_Opportunity__c = opportunityIdValue;
        journalLineItemObject.Journal_Banker__c = bankerId;
        system.debug('Journal ******* Banker'+journalLineItemObject.Journal_Banker__c);
        journalLineItemObject.Journal_Amount__c = amount;
        system.debug('Journal ******* Amount'+journalLineItemObject.Journal_Amount__c);
        journalLineItemObject.Journal_TransactionType__c = creditDebit;
        journalLineItemObject.Journal_FiscalYear__c = fiscalYear;       
        journalLineItemObject.Journal_TradeID__c = tradeID;
        journalLineItemObject.Journal_BankerName__c = bankerName;
        journalLineItemObject.Journal_BankerOfficerCode__c = bankerOfficerCode;
        journalLineItemObject.Journal_CIF__c = cif;
        journalLineItemObject.Journal_CorpCode__c = corpCode;
        journalLineItemObject.Journal_Customer__c = customer;
        journalLineItemObject.Journal_ETReference__c = etReference;
        journalLineItemObject.Journal_GLAccount__c = fixGLAccount;
        journalLineItemObject.Journal_Product__c = product;
        journalLineItemObject.Journal_ProductFamily__c = productFamily;
        journalLineItemObject.Journal_PMContact__c = productManagerContact;
        journalLineItemObject.Journal_PMContactName__c = productManagerContactName;        
        journalLineItemObject.Journal_Team__c = team;
        journalLineItemObject.Journal_TeamName__c = teamName;
        journalLineItemObject.Journal_TSM__c = tsm;
        journalLineItemObject.Journal_TSMName__c = TSMName;
        journalLineItemObject.Journal_TSMManager__c = tsmManager;
        journalLineItemObject.Journal_TSMManagerName__c = tsmManagerName;
        journalLineItemObject.Journal_WID__c            = wid;
        journalLineItemObject.Journal_Centre__c         = centreName;
        journalLineItemObject.Journal_Region__c         = regionName;
        journalLineItemObject.Journal_Division__c       = divisionName;
        journalLineItemObject.Journal_Group__c          = groupName;
        journalLineItemObject.Journal_PMTarget__c       = pmTarget;
        journalLineItemObject.Journal_TSMTarget__c      = tsmTarget;
        journalLineItemObject.Journal_ReversalReason__c  = reversalReson;
        
        
        system.debug('Returning this value'+journalLineItemObject);
        return journalLineItemObject;
    }
   /**
    * @description       This Method will fetch and retrun the opportunity details as a Map for the requested Opportunity Ids
    * @name              getOpportunityDetails
    * @param             List<Id>
    * @return            Map<Id,Opportunity>
    * @throws            NA
    */ 
    Public static Map<Id,Opportunity> getOpportunityDetails(List<Id>opportunityIdList){        
        Map<Id,Opportunity> retrunOpportunityMap= new Map<Id,Opportunity>([Select Id,AccountId,Name,Amount,Product__c,RecordType.Name,
                                                                           Owner.id,ownerId,Owner.FirstName,Owner.LastName,
                                                                           Owner.Manager.Id,Opp_CorpCode__c,Opp_ETRef__c,CloseDate,
                                                                           Owner.Manager.FirstName,Opp_GLAccountNumber__c,isQ6Available__c,
                                                                           Owner.Manager.LastName,Opp_TradeID__c,(Select Id,Name,Journal_PMContact__c,Journal_PMContactName__c,
                                                                                                                     Journal_PMTarget__c,Journal_TSMTarget__c ,Journal_Banker__c,
                                                                                                                     Journal_Amount__c,Journal_Team__c,Journal_Centre__c,Journal_Region__c,
                                                                                                                     Journal_TeamName__c,Journal_Division__c,Journal_Group__c From Journal_Line_Items__R 
                                                                                                                     Order By Name DESC) from Opportunity 
                                                                           where Id IN :opportunityIdList]); 
        
        return retrunOpportunityMap;
    }
    
   /**
    * @description       This Method will fetch and retrun the Account details as a Map for the requested 
    *                     Account Ids
    * @name              getAccountDetails
    * @param             List<Id>
    * @return            Map<Id,Account>
    * @throws            NA
    */        
    Public static Map<Id,Account> getAccountDetails(List<Id>accountIdList){        
        Map<Id,Account> retrunAccountMap= new Map<Id,Account>([Select Id,Name,RM_Name__c,FX_Manager__c,
                                                               FX_Manager__r.FirstName,FX_Manager__r.LastName,
                                                               IRRM_Manager__c,IRRM_Manager__r.FirstName,
                                                               IRRM_Manager__r.LastName,WID__c,CIF__c,BankerAdded__c,
                                                               Commodity_Manager__c,Commodity_Manager__r.FirstName,
                                                               Commodity_Manager__r.LastName,RM_Name__r.Officer_Code__c,
                                                               RM_Name__r.Firstname,RM_Name__r.Lastname, 
                                                               RM_Name__r.Con_Team__c,RM_Name__r.Name,
                                                               RM_Name__r.Con_Team__r.Name,
                                                               RM_Name__r.Con_Centre__c,OwnerId,
                                                               RM_Name__r.Con_Region__c,
                                                               RM_Name__r.Con_Division__c,
                                                               RM_Name__r.Con_Group__c
                                                               From Account 
                                                               where Id In :accountIdList]); 
        return retrunAccountMap;
    }
    
   /**
    * @description       This Method will update the PM Target details based on the Journal Amount
    * @name              updatePMTarget
    * @param             PMTarget__c,JournalLineItem__c
    * @return            PMTarget__c
    * @throws            NA
    */        
    public static PMTarget__c updatePMTarget(PMTarget__c pmTargetRecord,JournalLineItem__c journalRecord){
        If(journalRecord.Journal_ProductFamily__c == label.RecordTypeCRM){
            pmTargetRecord.PMTar_CRMActual__c = pmTargetRecord.PMTar_CRMActual__c   + 
                journalRecord.Journal_Amount__c;                
        }
        else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeFXCash){
            
            System.debug('This is inside FX Cash');
              if(journalRecord.Journal_BranchNumber__c==System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c ==System.Label.YBDirectDealingClient){
            pmTargetRecord.PMTar_FXDirectActual__c = (pmTargetRecord.PMTar_FXDirectActual__c!=Null?pmTargetRecord.PMTar_FXDirectActual__c:0) + 
                journalRecord.Journal_Amount__c;
            }else if((journalRecord.Journal_BranchNumber__c!=System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c !=System.Label.YBDirectDealingClient) && journalRecord.Journal_IsQ6Available__c==True)
            {     system.debug('Inside Indirect FX');
              
                       if(journalRecord.Journal_Amount__c < 0 && journalRecord.Journal_Banker__c==Null)
                       {
                       pmTargetRecord.PMTar_FXRetailActual__c = pmTargetRecord.PMTar_FXRetailActual__c + journalRecord.Journal_Amount__c;

                       }else
                       {
                            pmTargetRecord.PMTar_FXIndirectActual__c = (pmTargetRecord.PMTar_FXIndirectActual__c!=Null?pmTargetRecord.PMTar_FXIndirectActual__c:0) + 
                            journalRecord.Journal_Amount__c;
                       }             
             
             
               
            }else if((journalRecord.Journal_BranchNumber__c!=System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c !=System.Label.YBDirectDealingClient) && journalRecord.Journal_IsQ6Available__c==false){
                SYSTEM.debug('Inside Retail');
                //pmTargetRecord.PMTar_FXRetailActual__c = (pmTargetRecord.PMTar_FXRetailActual__c!=Null?pmTargetRecord.PMTar_FXRetailActual__c:0) + 
                pmTargetRecord.PMTar_FXRetailActual__c = pmTargetRecord.PMTar_FXRetailActual__c + journalRecord.Journal_Amount__c;
                system.debug('PM Target After Update'+pmTargetRecord.PMTar_FXRetailActual__c);
            }         
        }
        else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeCommodity){
            pmTargetRecord.PMTar_CommActual__c = pmTargetRecord.PMTar_CommActual__c   + 
                journalRecord.Journal_Amount__c;            
        }
       else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeIRRM)
        {
            pmTargetRecord.PMTar_IRRMActual__c = pmTargetRecord.PMTar_IRRMActual__c  + 
                journalRecord.Journal_Amount__c;     
        }else
        {
            //Do not do anything
        }
        
        system.debug('rETURING THIS Target'+pmTargetRecord);
        return pmTargetRecord;
    }
    
   /**
    * @description       This Method will update the TSM Target details based on the Journal Amount
    * @name              updateTSMTarget
    * @param             TSMTarget__c,JournalLineItem__c
    * @return            TSMTarget__c
    * @throws            NA
    */   
    public static TSMTarget__c updateTSMTarget(TSMTarget__c tsmTargetRecord,JournalLineItem__c journalRecord){ 
        
        system.debug('TSM Target in CYBG Util class'+tsmTargetRecord);
        system.debug('TSM Target in CYBG Util class'+journalRecord);
        system.debug('Banker Updated value is '+journalRecord.Journal_BankerAdded__c);
        If(journalRecord.Journal_ProductFamily__c == label.RecordTypeCRM){
            tsmTargetRecord.TSMTar_CRMActual__c = tsmTargetRecord.TSMTar_CRMActual__c + 
                journalRecord.Journal_Amount__c;
        }
        else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeFXCash)
        {

            if(journalRecord.Journal_BranchNumber__c==System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c ==System.Label.YBDirectDealingClient){
            tsmTargetRecord.TSMTar_FXDirectActual__c = (tsmTargetRecord.TSMTar_FXDirectActual__c!=Null?tsmTargetRecord.TSMTar_FXDirectActual__c:0) + 
                journalRecord.Journal_Amount__c;
                
                
            }else if((journalRecord.Journal_BranchNumber__c!=System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c !=System.Label.YBDirectDealingClient) && journalRecord.Journal_IsQ6Available__c==True)
            {
                SYSTEM.debug('Fixed Q6 is under CYBG Utill'+journalRecord.Journal_IsQ6Available__c);
                if(journalRecord.Journal_Amount__c < 0 && journalRecord.Journal_Banker__c==Null)
                {
                    system.debug('Journal Amount is less than zero');
                    system.debug('Each Banker Updated '+journalRecord.Journal_BankerAdded__c);
                  tsmTargetRecord.TSMTar_FXRetailActual__c = (tsmTargetRecord.TSMTar_FXRetailActual__c!=Null?tsmTargetRecord.TSMTar_FXRetailActual__c:0) + 
                  journalRecord.Journal_Amount__c;                    
                }else{
                    system.debug('Positive amount and inside Else Condition');
                    tsmTargetRecord.TSMTar_FXIndirectActual__c = (tsmTargetRecord.TSMTar_FXIndirectActual__c!=Null?tsmTargetRecord.TSMTar_FXIndirectActual__c:0) + 
                    journalRecord.Journal_Amount__c;
                    
                }
                /*tsmTargetRecord.TSMTar_FXIndirectActual__c = (tsmTargetRecord.TSMTar_FXIndirectActual__c!=Null?tsmTargetRecord.TSMTar_FXIndirectActual__c:0) + 
                journalRecord.Journal_Amount__c;*/
            }else if((journalRecord.Journal_BranchNumber__c!=System.Label.CBDirectDealingClient || journalRecord.Journal_BranchNumber__c !=System.Label.YBDirectDealingClient) && journalRecord.Journal_IsQ6Available__c==false){
                
                tsmTargetRecord.TSMTar_FXRetailActual__c = (tsmTargetRecord.TSMTar_FXRetailActual__c!=Null?tsmTargetRecord.TSMTar_FXRetailActual__c:0) + 
                journalRecord.Journal_Amount__c;
            }
        }
        else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeCommodity)
        {
            tsmTargetRecord.TSMTar_CommActual__c = tsmTargetRecord.TSMTar_CommActual__c + 
                journalRecord.Journal_Amount__c;
        }
        else if(journalRecord.Journal_ProductFamily__c == label.RecordTypeIRRM)
        {
            tsmTargetRecord.TSMTar_IRRMActual__c = tsmTargetRecord.TSMTar_IRRMActual__c + 
                journalRecord.Journal_Amount__c;
        }else
        {
            //Do not do anything
        }
        
        
        return tsmTargetRecord;
    }
    
    
}