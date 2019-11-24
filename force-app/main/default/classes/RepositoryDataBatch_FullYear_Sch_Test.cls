@isTest
public class RepositoryDataBatch_FullYear_Sch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        RepositoryDataBatch_FullYear_Sch sh1 = new RepositoryDataBatch_FullYear_Sch();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run1', sch, sh1); 
        Test.stopTest();
    }
    
}