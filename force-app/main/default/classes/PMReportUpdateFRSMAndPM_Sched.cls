global class PMReportUpdateFRSMAndPM_Sched implements Schedulable {
    /**
* @description       Method to Schedule a PMReportUpdateFRSMAndPM_Sched class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/
    global void execute(SchedulableContext ctx) {
        
        List<Repository__c> replist=[select Rep_AccountId__C,Rep_CombineId__c,Opportunity_RecordType__c from repository__c
                                     where recordtype.name='CustomerAndPM' and Rep_TSMName__c=null and Rep_PMName__c=null and Rep_RMName__c=null 
                                     and Rep_BusinessCentre__c=null and Rep_WID__c=null];
        
        System.debug('replist size======>'+replist.size());
        Map<String,List<Repository__c>> repMapList = new Map<String,List<Repository__c>>();
        for(Repository__c rep:replist){
            if(repMapList.containskey(rep.Rep_AccountId__C)){
                repMapList.get(rep.Rep_AccountId__c).add(rep);
            }else{
                repMapList.put(rep.Rep_AccountId__c,new List<Repository__c>{rep});
            }   
        }
        List<Repository__c> repList1 = new List<Repository__c>();
        for(Account acc :[SELECT Id, name, owner.name,RM_Name__r.Name,RM_Name__r.Con_Team__r.Name,WID__c,IRRM_Manager__r.name,Commodity_Manager__r.name,FX_Manager__r.name,recordtype.name
                          FROM Account Where id IN : repMapList.keySet()]){
                              if(repMapList.containskey(acc.id)){
                                  for(Repository__c rep1 : repMapList.get(acc.id)){
                                      if(rep1.Opportunity_RecordType__c=='FX Cash'){
                                          rep1.Rep_PMName__c=acc.FX_Manager__r.name;
                                      }
                                      else if(rep1.Opportunity_RecordType__c=='IRRM'){
                                          rep1.Rep_PMName__C=acc.IRRM_Manager__r.name;
                                      }
                                      else if(rep1.Opportunity_RecordType__c=='Commodity'){
                                          rep1.Rep_PMName__C=acc.Commodity_Manager__r.name;
                                      }
                                      rep1.Rep_TSMName__c = acc.Owner.Name;
                                      rep1.Rep_RMName__c = acc.RM_Name__r.Name;
                                      rep1.Rep_BusinessCentre__c = acc.RM_Name__r.Con_Team__r.Name;
                                      rep1.Rep_WID__c = acc.WID__c;
                                      repList1.add(rep1);
                                  }
                                  
                              }
                              
                          }
        update repList1;  
    }   
}