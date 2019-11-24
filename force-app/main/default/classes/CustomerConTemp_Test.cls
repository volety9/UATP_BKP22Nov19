@isTest
public class CustomerConTemp_Test {
    @testSetup static void setup() {
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
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
            acc.OldTSMId__c = '0050Y000002lsIV';
            acc.OwnerId = [Select id From user where user.name = 'Richard Bowden' Limit 1].Id;
            insert acc;
            Checklist__c chkList = TestData.createChecklist(acc.id);
            chkList.File_Checker__c = tsmUser.Id;
            chkList.Product__c = 'FX';
            insert chkList;
            
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
            opp.StageName = 'New Opportunity';
            opp.opp_TradeID__c='1234';
            opp.Deal_Executed_By__c = con.id;
            insert opp;
        }
    }
    
    static TestMethod void test(){
        User tsmUser = [Select id from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        System.runAs(tsmUser)
        {
          
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
            For(Integer i=0;i<3;i++)
            {
                TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                //testTarget.TSMTar_Team__c = testTeam.id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                tsmTargetList.add(testTarget);
                
            }
            Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
            
            Test.startTest();
            CustomerConTemp obj = new CustomerConTemp();
            obj.exec();
            Test.stopTest();
        }
    }
}