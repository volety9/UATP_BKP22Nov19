@isTest
public class RepositoryDataDeleteBatch_FY_PSD2_Test {
    
    public static testMethod void repositoryDataDeleteBatchFullYearTest(){
        List<Repository__c> repositoryList = new List<Repository__c>();
        Id RecordTypeIdRepositroyGroupANDDivison = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        Id RecordTypeIdRepositroyBusinessAndCustomer= Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndCustomer').getRecordTypeId();
        for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '1234'+i;
            rep1.RecordTypeId = RecordTypeIdRepositroyGroupANDDivison;
            rep1.Rep_BusinessCentreId__c = '1234'+i;
            rep1.Rep_CombineId__c = '12341234'+i;
            rep1.Rep_RMName__c = '2344'+i;
            rep1.Rep_RMId__c = '2344'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 1200;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
        for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '2345'+i;
            rep1.RecordTypeId = RecordTypeIdRepositroyBusinessAndCustomer;
            rep1.Rep_BusinessCentreId__c = '2346'+i;
            rep1.Rep_CombineId__c = '2341235'+i;
            rep1.Rep_RMName__c = '25678'+i;
            rep1.Rep_RMId__c = '4567'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 1200;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
        insert repositoryList;
        Test.startTest();
        RepositoryDataDeleteBatch_FullYear_PSD2 reportRepDeleteRecords = new RepositoryDataDeleteBatch_FullYear_PSD2();
        Database.executeBatch(reportRepDeleteRecords, 100);
        Test.stopTest();        
    }
}