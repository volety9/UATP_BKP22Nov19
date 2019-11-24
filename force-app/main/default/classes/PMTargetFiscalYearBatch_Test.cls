/*
@Author        : Santhoshan
@Name          : PMTargetFiscalYearBatch_Test
@Created Date  : 28th Feb 2018
@Description   : This is a Test Class for PMTargetFiscalYearBatchClass
@version       : 1.0
*/
@isTest
public class PMTargetFiscalYearBatch_Test {
    /**
* @description       Test method to check if Active PM Targets are cloned to New Fiscal Year.
* @name              PMTargetsToNewFiscalYear
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void clonePMTargetToNewFiscalYear() 
    {
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
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
        
        User mgrUser = TestData.createMGRUser('CYB');
        insert mgrUser;
        
        Group__c groups = TestData.createGroup();
        insert groups;
        
        Division__c division = TestData.createDivision();
        division.Div_Group__c = groups.Id;
        insert division;
        
        Account acc = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        acc.BillingCity = 'Test City';
        acc.BillingStreet = 'Test Street';
        acc.BillingPostalCode = '12345';
        acc.RecordType__c = 'Internal';
        insert acc;
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank Internal', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        
        for(Integer i=0; i<20; i++)
        {
            Contact con = TestData.createContactContact('Test Contact'+i, RecordTypeIdContact, acc.Id);
            conList.add(con);
        }
        insert conList;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
            List<Contact> con = [Select Id,LastName from Contact LIMIT 1];
            Account accCus = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con[0].Id, RecordTypeIdAccountCustomer);
            accCus.FX_Manager__c=con[0].Id;
            accCus.IRRM_Manager__c=con[0].Id;
            accCus.Commodity_Manager__c = con[0].Id;
        	accCus.RecordType__c = 'Customer';
            insert accCus;
        
        
        
        User testUser = TestData.createUser('CYB');
        testUser.ManagerId  = mgrUser.id;
        insert testUser;
        
        
        
        for(Integer i=0;i<20;i++)
        {
            PMTarget__c testPMTar  = TestData.createPMMTarget();
            testPMTar.PMTar_PMContact__c = conint.Id;
            testPMTar.OwnerId = testUser.id;
            testPMTar.PMTar_PMUser__c = testUser.Id;
            testPMTar.PMTar_StartDate__c=System.today();
            testPMTar.PMTar_EndDate__c=System.today().AddDays(1);
            //testPMTar.PMTar_EndDate__c=endDate;
            testPMTar.PMTar_Status__c = 'Active';
            PMTarList.add(testPMTar);
        }
        insert PMTarList;
        List<PMTarget__c> newTargetList = [SELECT Id FROM PMTarget__c];
        System.debug('HERE'+newTargetList);
        List<PMTarget__c> newTargetListUpdate = new List<PMTarget__c>();
        for(Integer i=10; i<20; i++)
        {
            newTargetList[i].PMTar_Status__c = 'Terminated';
            newTargetList[i].PMTar_TerminationDate__c = System.today();
            newTargetListUpdate.add(newTargetList[i]);
        }
        update newTargetListUpdate;
        Test.startTest();
        
        PMTargetFiscalYearBatch testObj = new PMTargetFiscalYearBatch();
        DataBase.executeBatch(testObj); 
        
        Test.stopTest();
        
        testQueryList = [SELECT PMTar_CRMTarget__c, PMTar_CRMActual__c, 
                         PMTar_StartDate__c, PMTar_EndDate__c, PMTar_Status__c
                         FROM PMTarget__c];
        
        for(PMTarget__c eachPM : testQueryList)
        {
            if(eachPM.PMTar_Status__c == 'Active')
            {
                System.assertEquals(eachPM.PMTar_CRMTarget__c, 500);
                System.assertEquals(eachPM.PMTar_CRMActual__c, 0);
                System.assertEquals(eachPM.PMTar_StartDate__c, startDate);
                System.assertEquals(eachPM.PMTar_EndDate__c, endDate);
                countActive++;
            }
            else if(eachPM.PMTar_Status__c == 'Inactive')
            {
                countInactive++;
            }
        }
        System.assertEquals(countActive, 10);
        System.assertEquals(countInactive, 20);
    }

}