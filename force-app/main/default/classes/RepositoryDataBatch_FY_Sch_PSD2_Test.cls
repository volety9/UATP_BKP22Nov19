@isTest
public class RepositoryDataBatch_FY_Sch_PSD2_Test {
    
    public static testMethod void repositoryDataBatchFullYearSchduleTest(){
        Test.startTest();
        RepositoryDataBatch_FullYear_Sch_PSD2 reportRepSch = new RepositoryDataBatch_FullYear_Sch_PSD2();
        string sch = '0 0 22 * * ?';
        System.schedule('RepositoryDataBatch FullYear Schedule',sch,reportRepSch);
        Test.stopTest();
    }
}