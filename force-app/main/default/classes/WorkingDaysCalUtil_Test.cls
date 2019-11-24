@isTest
public class WorkingDaysCalUtil_Test {
    static testMethod void CalWorkingDaysForTSMTargetTest() 
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
        
        User testUser = TestData.createUser('CYB');
        testUser.ManagerId  = mgrUser.id;
        insert testUser;
        
        User testUserScot = TestData.createUser('CYB');
        testUserScot.ManagerId  = mgrUser.id;
        testUserScot.Location__c = 'Scotland';
        testUserScot.lastname='cybUserScot';
        testUserScot.Username='cybuserScot@testorg.com';
        insert testUserScot;
        
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
            if(i==4)
                testTSMTar.TSMTar_TSM__c = testUserScot.Id;
            testTSMTar.TSMTar_Team__c = teamList[i].Id;
            testTSMTar.TSMTar_Status__c = 'Active';
            if(i==5)
            {
                testTSMTar.TSMTar_Status__c = 'Terminated';
            	testTSMTar.TSMTar_TerminationDate__c = System.today();   
            }
            testTSMTar.TSMTar_StartDate__c = startDate;
            testTSMTar.TSMTar_EndDate__c = endDate;
            if(i==2)
                testTSMTar.TSMTar_EndDate__c = System.today().addDays(1);
            testTSMTar.TSMTar_FXDirectTarget__c = 500;
            testTSMTar.TSMTar_FXIndirectTarget__c = 10000;
            testTSMTar.TSMTar_CRMTarget__c = 50000;
            testTSMTar.TSMTar_CommTarget__c = 40000;
            testTSMTar.TSMTar_IRRMTarget__c = 5000;
            testTSMTar.TSMTar_FXRetail__c = 5000;
            testTSMTar.TSMTar_FXRetailTillDate__c = 100;
            testTSMTar.TSMTar_IRRMTargetTillDate__c = 100;
            testTSMTar.TSMTar_CommTargetTillDate__c = 100;
            testTSMTar.TSMTar_CRMTargetTillDate__c = 100;
            testTSMTar.TSMTar_FXIndirectTargetTillDate__c = 100;
            testTSMTar.TSMTar_FXDirectTargetTillDate__c = 100;
            TSMTarList.add(testTSMTar);
        }
        insert TSMTarList;
        
        Test.startTest();
        //system.debug('inserted list'+newTargetList);
        WorkingDaysCalUtil.CalWorkingDaysForTSMTarget(TSMTarList);
        
        Test.stopTest();
        
    }
    static testMethod void CalWorkingDaysForPMTargetTest() 
    {
        Id RecordTypeIdBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdInternalAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        Integer countActive = 0;
        Integer countInactive = 0;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date endDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);        
        
        List<PMTarget__c> PMTarList = new List<PMTarget__c>();
        List<Team__c> teamList = new List<Team__c>();
        List<Contact> conList = new List<Contact>();
        List<PMTarget__c> testQueryList = new List<PMTarget__c>();
        
        Account accCus = TestData.createCalypsoAccountInternal('Test Data Account', RecordTypeIdInternalAccount);
        accCus.RecordType__c = 'Internal';
        insert accCus;
        
        for(Integer i=0; i<20; i++)
        {
            Contact con = TestData.createContactContact('Test Contact'+i, RecordTypeIdBanker, accCus.Id);
            conList.add(con);
        }
        insert conList;
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accCus.Id);
        insert conint;
        
        User mgrUser = TestData.createMGRUser('CYB');
        insert mgrUser;
        
        User testUser = TestData.createUser('CYB');
        testUser.ManagerId  = mgrUser.id;
        insert testUser;
        
        User testUserScot = TestData.createUser('CYB');
        testUserScot.ManagerId  = mgrUser.id;
        testUserScot.Location__c = 'Scotland';
        testUserScot.lastname='cybUserScot';
        testUserScot.Username='cybuserScot@testorg.com';
        insert testUserScot;
        
        for(Integer i=0;i<20;i++)
        {
            PMTarget__c testPMTar  = TestData.createPMMTarget();
            testPMTar.PMTar_PMContact__c = conint.Id;
            testPMTar.OwnerId = testUser.id;
            testPMTar.PMTar_PMUser__c = testUser.Id;
            if(i==4)
            {
                testPMTar.OwnerId = testUserScot.id;
                testPMTar.PMTar_PMUser__c = testUserScot.Id;
            }
            testPMTar.PMTar_EndDate__c=endDate;
            if(i==2)
                testPMTar.PMTar_EndDate__c = System.today().addDays(1);
            testPMTar.PMTar_Status__c = 'Active';
            if(i==5)
            {
                testPMTar.PMTar_Status__c = 'Terminated';
            	testPMTar.PMTar_TerminationDate__c = System.today();
            }
            testPMTar.PMTar_FXDirectTarget__c = 500;
            testPMTar.PMTar_CRMTarget__c = 50000;
            testPMTar.PMTar_CommTarget__c = 40000;
            testPMTar.PMTar_IRRMTarget__c = 5000;
            testPMTar.PMTar_FXIndirectTarget__c = 5000;
            testPMTar.PMTar_FXRetail__c = 5000;
            PMTarList.add(testPMTar);
        }
        insert PMTarList;
        
        Test.startTest();
        
        WorkingDaysCalUtil.CalWorkingDaysForPMTarget(PMTarList);
        
        Test.stopTest();
        
        
    }
}