@isTest
public class TSMTargetFiscalYearBatchSch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        TSMTargetFiscalYearBatchSch sh1 = new TSMTargetFiscalYearBatchSch();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}