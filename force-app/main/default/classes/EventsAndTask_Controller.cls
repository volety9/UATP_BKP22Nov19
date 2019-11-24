public class EventsAndTask_Controller {
    Map<String, Integer> quickCallsMap = new Map<String, Integer>();
    Map<String, Integer> defaultEventMap = new Map<String, Integer>();
    Set<String> ownerSet = new Set<String>();
    Map <String, Integer> totManQcMap = new Map<String, Integer>();
    Map <String, Integer> totManDeMap = new Map<String, Integer>();

    Integer totQc = 0;
    Integer totDe = 0;
    public List<WrapperClass> wrapper{get; set;}
    public EventsAndTask_Controller(){
        wrapper = new List<WrapperClass>();
        exec();
    }
    public void Exec()
    {
        Set<String> userSet = new Set<String>();

        AggregateResult[] eventAgr = [select count(Id) cnt,owner.name owner, OwnerId ownerId
                                      From Event 
                                      where activitydate = this_fiscal_year AND recordtype.name = 'Default Event' AND Owner.isActive = True
                                      group by owner.name, OwnerId];
        AggregateResult[] taskAgr = [select count(Id) cnt,owner.name owner, OwnerId ownerId
                                     From task 
                                     where activitydate = this_fiscal_year AND recordtype.name = 'Quick Call' AND Owner.isActive = True
                                     group by owner.name, OwnerId Order By Owner.Name];
        for(AggregateResult eachEventAgr : eventAgr)
        {
            defaultEventMap.put((String)eachEventAgr.get('owner'), (Integer)eachEventAgr.get('cnt'));
            ownerSet.add((String)eachEventAgr.get('owner'));
            totDe = totDe + (Integer)eachEventAgr.get('cnt');
            
        }
        for(AggregateResult eachTaskAgr : taskAgr)
        {
            quickCallsMap.put((String)eachTaskAgr.get('owner'), (Integer)eachTaskAgr.get('cnt'));
            ownerSet.add((String)eachTaskAgr.get('owner'));
            totQc = totQc + (Integer)eachTaskAgr.get('cnt');
            
        }
        
        Map<String, String> userMap = new Map<String, String>();
        for(User eachUser :  [SELECT Id, Name, Manager.Name, isActive FROM User WHERE Name IN :ownerSet AND isActive = True ORDER BY Manager.Name])
        {
            //@Check - isActive = True - Please comment in SIT in case of Testing and Uncomment it while moving to Prod
                userMap.put(eachUser.Name, eachUser.Manager.Name);
        }
        for(String eachOwner : ownerSet)
        {
            Integer totManDe = 0;
            Integer totManQc = 0;
            Integer De = 0;
            Integer Qc = 0;
            
            if(totManDeMap.get(userMap.get(eachOwner)) != null)
                totManDe = (Integer)totManDeMap.get(userMap.get(eachOwner));
            if(totManQcMap.get(userMap.get(eachOwner)) != null)		
                totManQc = (Integer)totManQcMap.get(userMap.get(eachOwner));
            if((Integer)defaultEventMap.get(eachOwner) != null)
                De = (Integer)defaultEventMap.get(eachOwner);
            if((Integer)quickCallsMap.get(eachOwner) != null)
                Qc = (Integer)quickCallsMap.get(eachOwner);
            
            if(totManDeMap.containsKey(userMap.get(eachOwner)))
                totManDeMap.put(userMap.get(eachOwner), (totManDe + De));
            else
                totManDeMap.put(userMap.get(eachOwner), De);
            
            if(totManQcMap.containsKey(userMap.get(eachOwner)))
                totManQcMap.put(userMap.get(eachOwner), totManQc + Qc);
            else
                totManQcMap.put(userMap.get(eachOwner), Qc);
        }
        for(String each : userMap.keySet())
        {
            System.debug('User>>> '+each);
            System.debug('Manager>>> '+userMap.get(each));
        }
        
        String temp = '';
        for(String each : userMap.keySet())
        {
            if(temp != userMap.get(each))
            {
                wrapper.add(new WrapperClass(userMap.get(each), totManDeMap.get(userMap.get(each)), totManQcMap.get(userMap.get(each)), true));
                temp = userMap.get(each);
            }
            wrapper.add(new WrapperClass(each, defaultEventMap.get(each), quickCallsMap.get(each)));
        }
        wrapper.add(new WrapperClass('Total', totDe, totQc, true));
    }
    public PageReference downloadReport() {
        PageReference nextpage = new PageReference('/apex/EventsAndTask_Dld');
        return nextpage;
    }
    public Class WrapperClass{
        public String ownerName{get; set;}
        public Integer defaultEvent{get; set;}
        public Integer quickCalls{get; set;}
        public Boolean grouper{get; set;}
        
        public WrapperClass(String ownerName, Integer defaultEvent, Integer quickCalls){
            this.ownerName = ownerName;
            this.defaultEvent = defaultEvent;
            this.quickCalls = quickCalls;
        }
        public WrapperClass(String ownerName, Boolean grouper){
            this.ownerName = ownerName;
            this.grouper = grouper;
        }
        public WrapperClass(String ownerName, Integer defaultEvent, Integer quickCalls, Boolean grouper){
            this.ownerName = ownerName;
            this.defaultEvent = defaultEvent;
            this.quickCalls = quickCalls;
            this.grouper = grouper;
        }
    }
}