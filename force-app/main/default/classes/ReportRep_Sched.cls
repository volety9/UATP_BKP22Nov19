global class ReportRep_Sched implements Schedulable{

    global void execute (SchedulableContext ctx){ 
        Date endLastYear = System.today().Addyears(-1);
        Date endThisYear = System.today();
        
        Integer startMonth =  CYBGUtilClass.fiscalYearStartMonth();
        
        Date startLastYear = CYBGUtilClass.findStartDateOfFY(endLastYear, startMonth ) ;
        Date startThisYear = CYBGUtilClass.findStartDateOfFY(endThisYear, startMonth ) ;
        
        List<Repository__c> repList = [SELECT Id FROM Repository__c WHERE RecordType.Name = 'CustomerAndPM'];
        if(repList.size() > 0)
            delete repList;
        
        List<AggregateResult> queryLast = [SELECT Count(ID) cnt, SUM(Amount) amt, SUM(Opp_PrimaryAmount__c)prmAmount, SUM(Opp_SecondaryAmount__c) scndAmount,
                                           Opp_PrimaryCurrency__c prmCurr, Opp_SecondaryCurrency__c scndCurr, Account.Name accName, Account.Id accId, 
                                           Account.FX_Manager__c fxm, Account.Commodity_Manager__c commm, Account.IRRM_Manager__c irrmm, RecordType.Name rcd,
                                           MAX(CloseDate) csd
                                           FROM Opportunity WHERE CloseDate >= :startLastYear AND CloseDate <= :endLastYear
                                           AND StageName = 'Closed Won'
                                           GROUP BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c
                                           ORDER BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c]; 
        
        List<AggregateResult> queryCurr = [SELECT Count(ID) cnt, SUM(Amount) amt, SUM(Opp_PrimaryAmount__c)prmAmount, SUM(Opp_SecondaryAmount__c) scndAmount,
                                           Opp_PrimaryCurrency__c prmCurr, Opp_SecondaryCurrency__c scndCurr, Account.Name accName, Account.Id accId, 
                                           Account.FX_Manager__c fxm, Account.Commodity_Manager__c commm, Account.IRRM_Manager__c irrmm, RecordType.Name rcd,
                                           MAX(CloseDate) csd
                                           FROM Opportunity WHERE CloseDate >= :startThisYear AND CloseDate <= :endThisYear
                                           AND StageName = 'Closed Won'
                                           GROUP BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c
                                           ORDER BY Account.Id, Account.Name, RecordType.Name, Account.FX_Manager__c, Account.Commodity_Manager__c, Account.IRRM_Manager__c, Opp_PrimaryCurrency__c, Opp_SecondaryCurrency__c]; 
        
        
        
        ReportRepOld_Batch obj = new ReportRepOld_Batch(queryLast, queryCurr);
        
        Database.executeBatch(obj,50);
    } 
}