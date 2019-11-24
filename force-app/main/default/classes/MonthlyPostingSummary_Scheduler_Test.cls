/*
  @Author        : SUHAS BARGI
  @Name          : MonthlyPostingSummary_Scheduler_Test
  @Created Date  : 30th MARCH 2018
  @Description   : Test Class for MonthlyPostingSummary_Scheduler_Test & MonthlyPostingSummaryCls
  @version       : 1.0
*/ 
@isTest
public class MonthlyPostingSummary_Scheduler_Test {
    
    public static testMethod void testschedule() {
        Test.StartTest();
        MonthlyPostingSummary_Scheduler shCls = new MonthlyPostingSummary_Scheduler();
        
        String sch = '0 0 0 1 10 ? *'; 
        system.schedule('Test Batch Run', sch, shCls); 
        Test.stopTest(); 
    }
    
}