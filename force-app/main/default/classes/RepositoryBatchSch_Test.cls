@isTest
public class RepositoryBatchSch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        RepositoryDataBatchSch sh1 = new RepositoryDataBatchSch();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}