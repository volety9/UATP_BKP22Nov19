@isTest
public class ReportRepOppty_Sched_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        ReportRepOppty_Sched sh1 = new ReportRepOppty_Sched();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run', sch, sh1); 
        Test.stopTest(); 
    }
    
}