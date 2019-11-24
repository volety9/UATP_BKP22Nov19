trigger EventCountForEachTSM on Event (after insert, after update, after delete, after undelete) {
    Repository__c reposObject;
    List<Repository__c> reposUpdateList = new List<Repository__c>();
    Map<String, String> reposMap = new Map<String, String>();
    Map<String, Integer> defaultEventMap = new Map<String, Integer>();
    //Set<String> ownerSet = new Set<String>();
    
    Id RecordTypeIdEventAndTask = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('Event and Task').getRecordTypeId();
    
    AggregateResult[] eventAgr = [select count(Id) cnt,owner.name owner, OwnerId ownerId
                                 From Event 
                                 where activitydate = this_fiscal_year AND recordtype.name = 'Default Event' 
                                 group by owner.name, OwnerId];
    for(AggregateResult eachEventAgr : eventAgr)
    {
        //ownerSet.add((String)eachTaskAgr.get('ownerId'));
        defaultEventMap.put((String)eachEventAgr.get('owner'), (Integer)eachEventAgr.get('cnt'));
    }
    List<Repository__c> reposList = [SELECT Id, Rep_TSMName__c 
                                     FROM Repository__c 
                                     WHERE Rep_TSMName__c IN :defaultEventMap.keySet() AND RecordType.Name = 'Event and Task'];
    
    for(Repository__c each : reposList)
    {
        reposMap.put(each.Rep_TSMName__c, each.Id);
    }
    for(String each : defaultEventMap.keySet())
    {
        reposObject = new Repository__c();
        if(reposMap.containsKey(each))
            reposObject.Id = reposMap.get(each);
        reposObject.Rep_CombineId__c = each + 'ETDE';
        reposObject.Rep_TSMName__c = each;
        reposObject.RecordTypeId = RecordTypeIdEventAndTask;
        reposObject.Rep_DefaultEvent__c = defaultEventMap.get(each);
        reposUpdateList.add(reposObject);
    }
    upsert reposUpdateList;
}