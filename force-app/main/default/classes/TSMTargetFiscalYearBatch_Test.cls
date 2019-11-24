/*
@Author        : Santhoshan
@Name          : TSMTargetFiscalYearBatch_Test
@Created Date  : 28th Feb 2018
@Description   : This is a Test Class for TSMTargetFiscalYearBatchClass
@version       : 1.0
*/
@isTest
public class TSMTargetFiscalYearBatch_Test {
    /**
* @description       Test method to check if Active TSM Targets are cloned to New Fiscal Year.
* @name              TSMTargetsToNewFiscalYear
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void TSMTargetsToNewFiscalYear() 
    {
        List<TSMTarget__c> TSMTarList = new List<TSMTarget__c>();
        List<Team__c> teamList = new List<Team__c>();
        List<TSMTarget__c> testQueryList = new List<TSMTarget__c>();
        
        Integer countActive = 0;
        Integer countInactive = 0;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date endDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);        
        
        User mgrUser = TestData.createMGRUser('CYB');
        insert mgrUser;
        
       
        
        Group__c groups = TestData.createGroup();
        insert groups;
        
        Division__c division = TestData.createDivision();
        division.Div_Group__c = groups.Id;
        insert division;
        
        Region__c region = TestData.createRegion();
        region.Region_Division__c = division.id;
        insert region;
        
        Centre__c centre = TestData.createCentre();
        centre.Centre_Region__c = region.Id;
        insert centre;

        User testUser = TestData.createUser('CYB');
        testUser.ManagerId  = mgrUser.id;
        insert testUser;
        
        for(Integer i=0;i<20;i++)
        {
            Team__c team = TestData.createTeam();
            team.Name = 'Test Team '+i;
            team.Team_Centre__c = centre.Id;
            teamList.add(team);
        }
        insert teamList;
        
        for(Integer i=0; i<20; i++)
        {
            TSMTarget__c testTSMTar = TestData.createTSMTarget();
            testTSMTar.TSMTar_TSM__c = testUser.Id;
            testTSMTar.TSMTar_Team__c = teamList[i].Id;
            testTSMTar.TSMTar_TSMManager__c = testUser.Id;
            testTSMTar.TSMTar_Status__c = 'Active';
            testTSMTar.TSMTar_EndDate__c = endDate;
            TSMTarList.add(testTSMTar);
        }
        insert TSMTarList;
        Test.startTest();
        List<TSMTarget__c> newTargetList = [SELECT Id, TSMTar_Status__c,TSMTar_EndDate__c FROM TSMTarget__c limit 10];
        system.debug('inserted list ' +newTargetList.size());
        for(TSMTarget__c tsmTar : newTargetList)
        {
            tsmTar.TSMTar_Status__c = 'Terminated';
            tsmTar.TSMTar_TerminationDate__c = System.today();             
        }            
        update newTargetList;        
        system.debug('before batch');
        TSMTargetFiscalYearBatch testObj = new TSMTargetFiscalYearBatch();
        DataBase.executeBatch(testObj); 
        system.debug('after batch');
        Test.stopTest();
        
        testQueryList = [SELECT TSMTar_CRMTarget__c, TSMTar_CRMActual__c, TSMTar_StartDate__c,
                         TSMTar_EndDate__c, TSMTar_Status__c
                         FROM TSMTarget__c];
        system.debug('After Batch list size ' +testQueryList.size());
        for(TSMTarget__c eachTSM : testQueryList)
        {
            if(eachTSM.TSMTar_Status__c == 'Active')
            {
                System.assertEquals(eachTSM.TSMTar_CRMTarget__c, 500);
                System.assertEquals(eachTSM.TSMTar_CRMActual__c, 0);
                System.assertEquals(eachTSM.TSMTar_StartDate__c, startDate);
                System.assertEquals(eachTSM.TSMTar_EndDate__c, endDate);
                countActive++;
            }
            else if(eachTSM.TSMTar_Status__c == 'Inactive')
            {
                countInactive++;
            }
        }
        System.assertEquals(10, countActive);
        System.assertEquals(20, countInactive);
    }
}