@isTest
public class ReportRep_Sched_PSD2_Test {
    
    public static testMethod void scheduleTest(){
        Test.startTest();
        ReportRep_Sched_PSD2 reportRepSch = new ReportRep_Sched_PSD2();
        string sch = '0 0 10 * * ?';
        System.schedule('PM Portfolio',sch,reportRepSch);
        Test.stopTest();
    }
}