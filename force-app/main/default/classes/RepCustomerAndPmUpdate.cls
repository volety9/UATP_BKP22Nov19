global class RepCustomerAndPmUpdate implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Rep_AccountId__c,Rep_CombineId__c from Repository__c
                                         where recordtype.name='CustomerAndPM' and Rep_TSMName__c=null and Rep_PMName__c=null and Rep_RMName__c=null 
                                         and Rep_BusinessCentre__c=null and Rep_WID__c=null]);
    }
    global void execute(Database.BatchableContext BC, List<Repository__c> scope){
        Date endLastYear = System.today().Addyears(-1);
        Date endThisYear = System.today();        
        Integer startMonth =  CYBGUtilClass.fiscalYearStartMonth();        
        Date startLastYear = CYBGUtilClass.findStartDateOfFY(endLastYear, startMonth ) ;
        Date startThisYear = CYBGUtilClass.findStartDateOfFY(endThisYear, startMonth ) ;
        Map<String,List<Repository__c>> repMapList = new Map<String,List<Repository__c>>();
        Map<String,List<Repository__c>> repMapAccountList = new Map<String,List<Repository__c>>();
        for(Repository__c rep:scope){
            if(repMapList.containskey(rep.Rep_CombineId__c)){
                repMapList.get(rep.Rep_CombineId__c).add(rep);
            }else{
                repMapList.put(rep.Rep_CombineId__c,new List<Repository__c>{rep});
            }   
        }
        for(Repository__c rep:scope){
            if(repMapAccountList.containskey(rep.Rep_AccountId__c)){
                repMapAccountList.get(rep.Rep_AccountId__c).add(rep);
            }else{
                repMapAccountList.put(rep.Rep_AccountId__c,new List<Repository__c>{rep});
            }   
        }
        
        List<Repository__c> repList1 = new List<Repository__c>();
        for(Opportunity opp :[SELECT Id,account.id, account.name, account.owner.name, account.Commodity_Manager__c, 
                              account.FX_Manager__c, account.IRRM_Manager__c, RecordType.Name, Opp_ETBranchNumber__c, 
                              Account.RM_Name__r.Name, Account.RM_Name__r.Con_Team__r.Name, Account.WID__c, 
                              Opp_PrimaryCurrency__c, Opp_PrimaryAmount__c, Opp_SecondaryCurrency__c, Opp_SecondaryAmount__c, 
                              account.Commodity_Manager__r.Name, account.FX_Manager__r.Name, account.IRRM_Manager__r.Name 
                              FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate >= :startThisYear AND CloseDate <= :endThisYear and accountid in : repMapAccountList.keyset()]){
                                  
                                  String pmSuff = '';
                                  String pmId = '';
                                  String pmName = '';
                                  String repcombinedId='';
                                  if(opp.RecordType.Name == 'FX Cash')
                                  {
                                      pmId = opp.account.FX_Manager__c;
                                      pmName = opp.account.FX_Manager__r.Name;
                                      pmSuff = 'FX';
                                  }
                                  else if(opp.RecordType.Name == 'Commodity')
                                  {
                                      pmId = opp.account.Commodity_Manager__c;
                                      pmName = opp.account.Commodity_Manager__r.Name;
                                      pmSuff = 'COMM';
                                  }
                                  else if(opp.RecordType.Name == 'IRRM')
                                  {
                                      pmId = opp.account.IRRM_Manager__c;
                                      pmName = opp.account.IRRM_Manager__r.Name;
                                      pmSuff = 'IRRM';
                                  }
                                  repcombinedId = opp.account.id + pmId +'CP'+pmSuff+opp.Opp_PrimaryCurrency__c+opp.Opp_SecondaryCurrency__c;
                                  if(repMapList.containskey(repcombinedId)){
                                      for(Repository__c rep1 : repMapList.get(repcombinedId)){
                                          rep1.Rep_TSMName__c = opp.Account.Owner.Name;
                                          rep1.Rep_PMName__c = pmName;
                                          rep1.Rep_RMName__c = opp.Account.RM_Name__r.Name;
                                          rep1.Rep_BusinessCentre__c = opp.Account.RM_Name__r.Con_Team__r.Name;
                                          rep1.Rep_WID__c = opp.Account.WID__c;
                                          rep1.Rep_ETBranchNumber__c = opp.Opp_ETBranchNumber__c;
                                          repList1.add(rep1);
                                      }
                                      
                                  }
                                  
                              }
        update repList1;        
    }
    global void finish(Database.BatchableContext BC){ 
        
    } 
    
}