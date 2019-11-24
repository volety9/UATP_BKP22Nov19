@isTest
public class PMTargetWorkingDaysSch_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        PMTargetWorkingDaysSch sh1 = new PMTargetWorkingDaysSch();
        
        String sch = '0 0 0 * * ?'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}