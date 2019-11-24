global class ReportRepOppty_Batch implements Database.Batchable<sObject>, Database.stateful{ 
    
    global List<Opportunity> oppList;
   
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        oppList = new List<Opportunity>();
        Date endLastYear = System.today().Addyears(-1);
        Date endThisYear = System.today();
        
        Integer startMonth =  CYBGUtilClass.fiscalYearStartMonth();
        
        Date startLastYear = CYBGUtilClass.findStartDateOfFY(endLastYear, startMonth ) ;
        Date startThisYear = CYBGUtilClass.findStartDateOfFY(endThisYear, startMonth ) ;
        
        /*String query = 'SELECT Id, account.id, account.name, account.owner.name, account.Commodity_Manager__c, '+
                        'account.FX_Manager__c, account.IRRM_Manager__c, RecordType.Name, Opp_ETBranchNumber__c, '+
                        'Account.RM_Name__r.Name, Account.RM_Name__r.Con_Team__r.Name, Account.WID__c, '+
                        'Opp_PrimaryCurrency__c, Opp_PrimaryAmount__c, Opp_SecondaryCurrency__c, Opp_SecondaryAmount__c, '+
                        'account.Commodity_Manager__r.Name, account.FX_Manager__r.Name, account.IRRM_Manager__r.Name '+
                        'FROM Opportunity WHERE StageName = \'Closed Won\' AND CloseDate >= :startLastYear AND CloseDate <= :endThisYear';
                            */
        Database.QueryLocator oppScope = Database.getQueryLocator([SELECT Id, account.id, account.name, account.owner.name, account.Commodity_Manager__c, 
                        account.FX_Manager__c, account.IRRM_Manager__c, RecordType.Name, Opp_ETBranchNumber__c, 
                        Account.RM_Name__r.Name, Account.RM_Name__r.Con_Team__r.Name, Account.WID__c, 
                        Opp_PrimaryCurrency__c, Opp_PrimaryAmount__c, Opp_SecondaryCurrency__c, Opp_SecondaryAmount__c, 
                        account.Commodity_Manager__r.Name, account.FX_Manager__r.Name, account.IRRM_Manager__r.Name 
                        FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate >= :startLastYear AND CloseDate <= :endThisYear]);
        
        return oppScope; 
     } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        oppList.addAll((List<Opportunity>)scope);
        //System.debug('List '+oppList.size());
    } 
    global void finish(Database.BatchableContext BC){ 
        //System.debug('List Last'+oppList.size());
        ReportRep_Batch obj = new ReportRep_Batch(oppList);
        Database.executeBatch(obj,100);
    } 
}