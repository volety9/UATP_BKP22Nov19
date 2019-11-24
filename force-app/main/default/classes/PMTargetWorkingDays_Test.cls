@isTest
public class PMTargetWorkingDays_Test 
{
    
    static testMethod void createTargetData() 
    {
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdCustomerInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        Integer countActive = 0;
        Integer countInactive = 0;
        Integer startYear = Date.Today().Year();
        Integer endYear = Date.Today().Year()+1;
        Date startDate = Date.newInstance(startYear,10,01);
        Date endDate = Date.newInstance(endYear,09,30);
        
        List<PMTarget__c> PMTarList = new List<PMTarget__c>();
        List<Team__c> teamList = new List<Team__c>();
        List<Contact> conList = new List<Contact>();
        List<PMTarget__c> testQueryList = new List<PMTarget__c>();
        
        User testUser1 = TestData.createUser('CYB');
        testUser1.Location__c = 'England';
        testUser1.username = 'testUser1@usernametestorg.com';
        insert testUser1;
        User testUser2 = TestData.createUser('CYB');
        testUser2.Location__c = 'Scotland';
        testUser1.username = 'testUser2@usernametestorg.com';
        insert testUser2;
        
        Account accCus = TestData.createCustomerAccount('Test Data Demo', RecordTypeIdCustomer);
        accCus.BillingCity = 'Test City';
        accCus.BillingStreet = 'Test Street';
        accCus.BillingPostalCode = '12345';
        accCus.RecordType__c = 'Customer';
        insert accCus;
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdCustomerInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        for(Integer i=0; i<20; i++)
        {
            Contact con = TestData.createContactContact('Test Contact'+i, RecordTypeIdContact, accCus.Id);
            conList.add(con);
        }
        insert conList;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        User testUser = TestData.createUser('CYB');
        testUser.Username = 'testUsersample@usernametestorg.com';
        insert testUser;
        
        for(Integer i=0;i<20;i++)
        {
            countActive = countActive +1;
            PMTarget__c testPMTar  = TestData.createPMMTarget();
            testPMTar.PMTar_PMContact__c = conint.Id;
            testPMTar.OwnerId = testUser.id;
            testPMTar.PMTar_TotalWorkingDays__c = 0;
            testPMTar.PMTar_WorkingDays__c = 0;
            if(math.mod(i,2)==0){
                testPMTar.PMTar_PMUser__c = testUser1.Id;
                testPMTar.PMTar_Status__c = 'Active';
            }
            else
            {
                testPMTar.PMTar_Status__c = 'Terminated';
                testPMTar.PMTar_PMUser__c = testUser2.Id;
                testPMTar.PMTar_TerminationDate__c=System.today();
            }
            PMTarList.add(testPMTar);
        }
        insert PMTarList;
        
        Test.startTest();
        
        PMTargetWorkingDays testObj = new PMTargetWorkingDays();
        DataBase.executeBatch(testObj); 
        
        Test.stopTest();
        List<PMTarget__c> list1 = [Select Id,Name,PMTar_TotalWorkingDays__c from PMTarget__c where PMTar_TotalWorkingDays__c>0];
        system.debug('----list1---'+list1);
        System.assertEquals(countActive, list1.size());
    }

}