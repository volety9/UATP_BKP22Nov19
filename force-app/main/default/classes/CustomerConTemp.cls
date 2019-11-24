public class CustomerConTemp {
    public String oldTSM = '0050Y000002lsIV';
    public String currTSM = 'Richard Bowden';
    public Set<String> accSet = new Set<String>();
    public Map<String, String> rmMap = new Map<String, String>();
    public Map<String, String> tsmMap = new Map<String, String>();
    public List<WrapperClass> wrapList{get; set;}
    
    public void exec(){
        wrapList = new List<WrapperClass>();
        User usr = [SELECT ID, Name FROM User WHERE Id = :oldTSM];
        for(Account eachAcc : [SELECT ID, RM_Name__r.Name, Owner.Name FROM Account WHERE OldTSMId__c = :oldTSM AND Owner.Name = :currTSM])
        {
            accSet.add(eachAcc.ID);
            rmMap.put(eachAcc.ID, eachAcc.RM_Name__r.Name);
            tsmMap.put(eachAcc.ID, eachAcc.Owner.Name);
        }
        
        for(AggregateResult each : [SELECT Count(Id) cnt, Account.Name accName, AccountId accId, SUM(Amount) amt FROM Opportunity 
                                    WHERE AccountId IN :accSet
                                    GROUP BY Account.Name, AccountId
                                    ORDER BY Account.Name, AccountId])
        {
            wrapList.add(new WrapperClass((String)each.get('accName'), (Integer)each.get('cnt'), (Decimal)each.get('amt'), (String)rmMap.get((String)each.get('accId')),
                                         (String)tsmMap.get((String)each.get('accId')), (String)usr.Name));
        }
    }
    
    public class WrapperClass{
        public String accName{get; set;}
        public Integer count{get; set;}
        public Decimal amount{get; set;}
        public String rmName{get; set;}
        public String tsmName{get; set;}
        public String oldName{get; set;}
        public WrapperClass(String accName, Integer count, Decimal amount, String rmName, String tsmName, String oldName)
        {
            this.accName = accName;
            this.count = count;
            this.amount = amount;
            this.rmName = rmName;
            this.tsmName = tsmName;
            this.oldName = oldName;
        }
    }
}