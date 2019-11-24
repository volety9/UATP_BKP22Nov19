@isTest
public class PMTargetFiscalYearBatchSch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        PMTargetFiscalYearBatchSch sh1 = new PMTargetFiscalYearBatchSch();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}