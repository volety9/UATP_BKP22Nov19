trigger TaskCountForEachTSM on Task (after insert, after update, after delete, after undelete) {
    Repository__c reposObject;
    List<Repository__c> reposUpdateList = new List<Repository__c>();
    Map<String, String> reposMap = new Map<String, String>();
    Map<String, Integer> quickCallsMap = new Map<String, Integer>();
    //Set<String> ownerSet = new Set<String>();
    
    Id RecordTypeIdEventAndTask = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('Event and Task').getRecordTypeId();
    
    AggregateResult[] taskAgr = [select count(Id) cnt,owner.name owner, OwnerId ownerId
                                 From task 
                                 where activitydate = this_fiscal_year AND recordtype.name = 'Quick Call'
                                 group by owner.name, OwnerId Order By Owner.Name];
    for(AggregateResult eachTaskAgr : taskAgr)
    {
        System.debug('Owner '+(String)eachTaskAgr.get('owner'));
        //ownerSet.add((String)eachTaskAgr.get('ownerId'));
        if(quickCallsMap.containsKey((String)eachTaskAgr.get('owner')))
            quickCallsMap.put((String)eachTaskAgr.get('owner'), (Integer)eachTaskAgr.get('cnt') + quickCallsMap.get((String)eachTaskAgr.get('owner')));
        else
        	quickCallsMap.put((String)eachTaskAgr.get('owner'), (Integer)eachTaskAgr.get('cnt'));
    }
    List<Repository__c> reposList = [SELECT Id, Rep_TSMName__c 
                                     FROM Repository__c 
                                     WHERE Rep_TSMName__c IN :quickCallsMap.keySet() AND RecordType.Name = 'Event and Task'];
    
    for(Repository__c each : reposList)
    {
        reposMap.put(each.Rep_TSMName__c, each.Id);
    }
    for(String each : quickCallsMap.keySet())
    {
        reposObject = new Repository__c();
        if(reposMap.containsKey(each))
            reposObject.Id = reposMap.get(each);
        reposObject.Rep_CombineId__c = each + 'ETQC';
        reposObject.Rep_TSMName__c = each;
        reposObject.RecordTypeId = RecordTypeIdEventAndTask;
        reposObject.Rep_QuickCalls__c = quickCallsMap.get(each);
        reposUpdateList.add(reposObject);
    }
    System.debug('REPOS>>>>'+reposObject);
    upsert reposUpdateList;
}