@isTest
public class TSMTargetWorkingDaysSch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        TSMTargetWorkingDaysSch sh1 = new TSMTargetWorkingDaysSch();
        
        String sch = '0 0 0 * * ?'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}