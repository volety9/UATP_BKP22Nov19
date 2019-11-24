global class RepositoryDataDeleteBatch_FullYear_PSD2 implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator([SELECT Id FROM Repository__c WHERE RecordType.Name NOT IN ('CustomerAndPM', 'Event and Task')]);
        
    }
    
    global void execute(Database.BatchableContext context, List<Repository__c> repo) {
        List<Repository__c> repositoryDataDeleteList = new List<Repository__c>();
        for(Repository__c rep:repo){           
            repositoryDataDeleteList.add(rep);            
        }
        if(!repositoryDataDeleteList.isEmpty()){
            //System.debug(' Delete List Size ======>'+repositoryDataDeleteList.size());
            delete repositoryDataDeleteList;
        }        
    }
    global void finish(Database.BatchableContext repo) {        
        RepositoryDataBatch_FullYear_PSD2 rdbc= new RepositoryDataBatch_FullYear_PSD2();
        Database.executeBatch(rdbc,100);
    }   
    

}