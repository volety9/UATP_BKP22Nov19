@isTest
public class PMTargetTriggerHandler_Test 
{
    @testSetup 
    static void setup() {
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser.Location__c);
        insert tsmUser;
        system.runAs(tsmUser){
            Group__c testGroup = TestData.createGroup();
            insert testGroup;        
            Division__c testDivision = TestData.createDivision();
            testDivision.Div_Group__c=testGroup.Id;       
            insert testDivision;        
            Region__c testRegion = TestData.createRegion();
            testRegion.Region_Division__c=testDivision.id;        
            insert testRegion;        
            Centre__c testCentre = TestData.createCentre();
            testCentre.Centre_Region__c=testRegion.id;        
            insert testCentre;
            Team__c testTeam = TestData.createTeam();
            testTeam.Team_Centre__c = testCentre.id; 
            insert testTeam;
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = testTeam.id;
            insert con;
            
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.Id;
            acc.IRRM_Manager__c=con.Id;
            acc.Commodity_Manager__c = con.Id;
            acc.RecordType__c = 'Customer';
            insert acc;
        }
    }
    
    static TestMethod void createPMMRecordsInvalidEndDate() { 
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        Contact con = [Select id from Contact]; 
        System.runAs(tsmUser)
        {
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            yearval = yearval +2;
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            List<PMTarget__c> pmTargetList = new List<PMTarget__c>();
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank1', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            insert conint;
            
            
            For(Integer i=0;i<3;i++)
            {
                PMTarget__c testTarget = TestData.createPMMTarget();
                testTarget.PMTar_PMUser__c = tsmUser.Id;
                testTarget.PMTar_PMContact__c = conint.Id;
                testTarget.PMTar_StartDate__c = System.Today();
                testTarget.PMTar_EndDate__c = System.Today().AddDays(1);
                testTarget.PMTar_Status__c = System.Label.Active;
                pmTargetList.add(testTarget);
                
            }
            
            Test.startTest();
            //insert pmTargetList;
            Database.SaveResult[] insertResultForPMTarget = Database.Insert(pmTargetList, False);
            For(Integer i=0;i<3;i++)
            {
                PMTarget__c testTarget = TestData.createPMMTarget();
                testTarget.PMTar_PMUser__c = tsmUser.Id;
                testTarget.PMTar_PMContact__c = conint.Id;
                testTarget.PMTar_StartDate__c = System.Today();
                testTarget.PMTar_EndDate__c = System.Today().AddDays(1);
                testTarget.PMTar_Status__c = System.Label.Active;
                pmTargetList.add(testTarget);
                
            }
            Database.SaveResult[] insertResultForPMTargetSec = Database.Insert(pmTargetList, False);
            pmTargetList[0].PMTar_EndDate__c = System.Today().AddDays(2);
            Database.SaveResult[] updateResultForPMTargetSec = Database.Update(pmTargetList, False);
            Test.stopTest();
            List<PMTarget__c> pm = [Select Id,PMTar_status__c,PMTar_StartDate__c,PMTar_EndDate__c from PMTarget__c];  
            System.debug('HEHEH'+pm);
            //system.assertEquals(3, pm.size());
            
        }
    }
    
    
    static TestMethod void createPMRecordsInvalidStartDate() {
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        Contact con = [Select id from Contact]; 
        System.runAs(tsmUser)
        {
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Banks', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            insert conint;
            List<PMTarget__c> pmTargetList = new List<PMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                PMTarget__c testTarget =  new PMTarget__c();
                testTarget = TestData.createPMMTarget();
                testTarget.PMTar_PMUser__c = tsmUser.Id;
                testTarget.PMTar_PMContact__c = conint.Id;
                testTarget.PMTar_StartDate__c = Date.ValueOf('2017-02-02');
                testTarget.PMTar_EndDate__c = Date.ValueOf('2018-03-21');
                pmTargetList.add(testTarget);
                
            }
            
            Test.startTest();
            Database.SaveResult[] insertResultForPMTarget = Database.Insert(pmTargetList, False);
            Test.stopTest();
            List<PMTarget__c> pm = [Select Id,PMTar_status__c,PMTar_StartDate__c,PMTar_EndDate__c from PMTarget__c]; 
            system.debug('PM Targets---'+pm);
            //system.assertEquals(0, pm.size());
            
        }
    }
    
    static TestMethod void createPMRecordsForDuplicate() {
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        Contact con = [Select id from Contact]; 
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Banks', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            insert conint;
        System.runAs(tsmUser)
        {
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            PMTarget__c testTarget1 =  new PMTarget__c();
            testTarget1 = TestData.createPMMTarget();
            testTarget1.PMTar_PMUser__c = tsmUser.Id;
            testTarget1.PMTar_PMContact__c = conint.Id;
            
            Insert testTarget1;
            PMTarget__c testTarget2 =  new PMTarget__c();
            testTarget2 = TestData.createPMMTarget();
            testTarget2.PMTar_PMUser__c = tsmUser.Id;
            testTarget2.PMTar_PMContact__c = con.Id;
            
            
            Test.startTest();
            try {
                Insert testTarget2;
            } catch (Exception e) {
                system.debug('This is in Catch block');
                System.debug('Exception ' + e);
            }
            Test.stopTest();
            List<PMTarget__c> pm = [Select Id,PMTar_status__c,PMTar_StartDate__c,PMTar_EndDate__c from PMTarget__c]; 
            system.debug('PM Targets---'+pm);
            //system.assertEquals(1, pm.size());
        }
    }
    static TestMethod void UpdatePMTarget() {
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        Contact con = [Select id from Contact]; 
        System.runAs(tsmUser)
        {
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Banks', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            insert conint;
            List<PMTarget__c> pmTargetList = new List<PMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                PMTarget__c testTarget =  new PMTarget__c();
                testTarget = TestData.createPMMTarget();
                testTarget.PMTar_PMUser__c = tsmUser.Id;
                testTarget.PMTar_PMContact__c = conint.Id;
                testTarget.PMTar_StartDate__c = system.today();
                testTarget.PMTar_EndDate__c = myDate;
                pmTargetList.add(testTarget);
                
            }
            Database.SaveResult[] insertResultForPMTarget = Database.Insert(pmTargetList, False);
            List<PMTarget__c> pmTargetupdateList = new List<PMTarget__c>();
            For(PMTarget__c pmtar :[Select Id,PMTar_status__c,PMTar_StartDate__c,PMTar_EndDate__c from PMTarget__c]){
                system.debug('pmtar Value UpdatePMTarget' +pmtar);
                pmtar.PMTar_status__c = 'Closed';
                myDate = Date.newInstance(yearval, nextMonth, 4);
                pmtar.PMTar_EndDate__c = myDate; 
                pmTargetupdateList.add(pmtar);
                system.debug('UpdatePMTarget ---pmTargetupdateList '+pmTargetupdateList);
            }
            Test.startTest();
            Database.SaveResult[] updateResultForPMMTarget = Database.update(pmTargetupdateList, False);
            Test.stopTest();
            List<PMTarget__c> pm = [Select Id,PMTar_status__c,PMTar_StartDate__c,PMTar_EndDate__c from PMTarget__c
                                   ];
            system.debug('PM Targets---'+pm);
            //system.assertEquals(False, pm.size()>1);
            
        }
    }

}