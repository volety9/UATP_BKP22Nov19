/*
@Author        : Ramkumar M B
@Name          : TSMTargetTriggerHandler_Test
@Created Date  : 6th March 2018
@Description   : This is a test Class for TSMTargetTriggerHandler
@version       : 1.0
*/
@isTest
public class TSMTargetTriggerHandler_Test {
    
    @testSetup static void setup() {
        
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
    
    
    static TestMethod void createTSMRecordsInvalidEndDate() {
        
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        System.runAs(tsmUser)
        {
            /* Centre__c centre = [Select Id from Centre__c];
            List<Team__c>teamList = new List<Team__c>();
            For(integer i=0;i<3;i++)
            {
                Team__c testTeam = TestData.createTeam();
                testTeam.Team_Centre__c = centre.id;
                teamList.add(testTeam);
            }
            insert teamList;*/
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                //testTarget.TSMTar_Team__c = teamList[i].id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                testTarget.TSMTar_StartDate__c = System.Today();
                testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
                tsmTargetList.add(testTarget);
                
            }
            
            Test.startTest();
            Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
            Test.stopTest();
            List<TSMTarget__c> tc = [Select Id,TSMTar_status__c,TSMTar_StartDate__c,TSMTar_EndDate__c from TSMTarget__c];           
            //system.assertEquals(3, tc.size());
            
        }
        
    }
    static TestMethod void createTSMRecords() {
        
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        System.runAs(tsmUser)
        {
           /* Centre__c centre = [Select Id from Centre__c];
            List<Team__c>teamList = new List<Team__c>();
            For(integer i=0;i<3;i++)
            {
                Team__c testTeam = TestData.createTeam();
                testTeam.Team_Centre__c = centre.id;
                teamList.add(testTeam);
            }
            insert teamList;*/
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                //testTarget.TSMTar_Team__c = teamList[i].id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                tsmTargetList.add(testTarget);
                
            }
            
            Test.startTest();
            Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
            Test.stopTest();
            List<TSMTarget__c> tc = [Select Id,TSMTar_status__c,TSMTar_StartDate__c,TSMTar_EndDate__c from TSMTarget__c];           
            //system.assertEquals(3, tc.size());
        }
        
    }
    static TestMethod void createTSMRecordsInvalidStartDate() {
        
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        System.runAs(tsmUser)
        {
           /* Centre__c centre = [Select Id from Centre__c];
            List<Team__c>teamList = new List<Team__c>();
            For(integer i=0;i<3;i++)
            {
                Team__c testTeam = TestData.createTeam();
                testTeam.Team_Centre__c = centre.id;
                teamList.add(testTeam);
            }
            insert teamList; */
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                //testTarget.TSMTar_Team__c = teamList[i].id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                testTarget.TSMTar_StartDate__c = Date.ValueOf('2017-02-02');
                testTarget.TSMTar_EndDate__c = Date.ValueOf('2018-03-21');
                tsmTargetList.add(testTarget);
                
            }
            
            Test.startTest();
            Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
            Test.stopTest();
            List<TSMTarget__c> tc = [Select Id,TSMTar_status__c,TSMTar_StartDate__c,TSMTar_EndDate__c from TSMTarget__c];           
            system.debug('TSMTarget__c---'+tc);
            //system.assertEquals(0, tc.size());
            
        }
        
    }
    /*static TestMethod void createTSMRecordsForDuplicate() {
        User tsmUser = [Select id,Location__c from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        
        system.debug('Locationn'+tsmUser.Location__c);
        Team__c team = [Select Id from Team__c Limit 1];
        Team__c team2 = [Select Id from Team__c Limit 1];
        TSMTarget__c testTarget =  new TSMTarget__c();
        testTarget = TestData.createTSMTarget();
        testTarget.TSMTar_Team__c = team.id;        
        testTarget.TSMTar_TSM__c = tsmUser.Id;
        TSMTarget__c testTarget2 =  new TSMTarget__c();
        testTarget2 = TestData.createTSMTarget();
        testTarget2.TSMTar_Team__c = team2.id;
        testTarget2.TSMTar_TSM__c = tsmUser.Id;
        Test.startTest();
        Insert testTarget;
        try {
            Insert testTarget2;
        } catch (Exception e) {
            system.debug('This is in Catch block');
            System.debug('Exception ' + e);
        }
        
        Test.stopTest();
        
        List<TSMTarget__c> tc = [Select Id,TSMTar_status__c,TSMTar_StartDate__c,TSMTar_EndDate__c from TSMTarget__c];           
        system.debug('TSMTarget__c---'+tc);
        //system.assertEquals(1, tc.size());
        
        
    }*/
    static TestMethod void UpdateTSMRecords() {
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        System.runAs(tsmUser)
        {
            /*Centre__c centre = [Select Id from Centre__c];
            List<Team__c>teamList = new List<Team__c>();
            For(integer i=0;i<3;i++)
            {
                Team__c testTeam = TestData.createTeam();
                testTeam.Team_Centre__c = centre.id;
                teamList.add(testTeam);
            }
            insert teamList; */
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                //testTarget.TSMTar_Team__c = teamList[i].id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                tsmTargetList.add(testTarget);
                
            }
            Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
            List<TSMTarget__c> tsmTargetList2 = new List<TSMTarget__c>();
            For(TSMTarget__c tsmtar :[Select Id,TSMTar_status__c,TSMTar_EndDate__c from TSMTarget__c]){
                tsmtar.TSMTar_status__c = 'Terminated';
                tsmtar.TSMTar_TerminationDate__c = system.today();
                tsmTargetList2.add(tsmtar);
            }
            Test.startTest();
            Update tsmTargetList2;
            Test.stopTest();
            List<TSMTarget__c> tc = [Select Id,TSMTar_status__c,TSMTar_StartDate__c,TSMTar_EndDate__c from TSMTarget__c 
                                     where TSMTar_status__c = 'Terminated'];           
            system.debug('TSMTarget__c---'+tc);
            //system.assertEquals(3, tc.size());
            
        }
        
    }     
    
}