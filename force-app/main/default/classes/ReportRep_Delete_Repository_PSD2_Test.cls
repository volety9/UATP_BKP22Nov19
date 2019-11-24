@isTest
public class ReportRep_Delete_Repository_PSD2_Test {
    
    public static testmethod void repDeleteCustomerAndPmRepositoryRecordsTest(){
        List<Repository__c> customerAndPmRepositoryList = new List<Repository__c>();
        Id RecordTypeIdRepositroyCustomerAndPm = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('CustomerAndPM').getRecordTypeId();
        for(Integer i=0;i<=20;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '1234'+i;
            rep1.RecordTypeId = RecordTypeIdRepositroyCustomerAndPm;
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
            customerAndPmRepositoryList.add(rep1);                      
        }
        insert customerAndPmRepositoryList;
        Test.startTest();
        ReportRep_Delete_Repository_PSD2 reportRepDeleteCustomerAndPmRecords = new ReportRep_Delete_Repository_PSD2();
        Database.executeBatch(reportRepDeleteCustomerAndPmRecords, 100);
        Test.stopTest();        
    }
}