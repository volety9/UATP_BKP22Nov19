@isTest
public class ytdPerformanceControllerGroup_FRS_Test {
    static TestMethod void createOpportunity_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFX = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdOpportunityComm = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeRepositoryGroup = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser.Location__c);
        insert tsmUser;
        
        Group__c groups = TestData.createGroup();
        insert groups;
        Group__c groupscly = TestData.createGroup();
        groupscly.Name = 'Clydesdale';
        insert groupscly;
        Group__c groupsyor = TestData.createGroup();
        groupsyor.Name = 'Yorkshire';
        insert groupsyor;
        
        Division__c division = TestData.createDivision();
        division.Name = 'Yorkshire';
        division.Div_Group__c = groups.Id;
        insert division;
        Division__c divisioncly = TestData.createDivision();
        divisioncly.Name = 'Clydesdale';
        divisioncly.Div_Group__c = groupscly.Id;
        insert divisioncly;
        
        
        Region__c region = TestData.createRegion();
        region.Name = 'Yorkshire';
        region.Region_Division__c = division.id;
        insert region;
        Region__c regioncly = TestData.createRegion();
        regioncly.Name = 'Clydesdale';
        regioncly.Region_Division__c = divisioncly.id;
        insert regioncly;
        
        Centre__c centre = TestData.createCentre();
        centre.Name = 'Yorkshire';
        centre.Centre_Region__c = region.Id;
        insert centre;
        Centre__c centrecly = TestData.createCentre();
        centrecly.Centre_Region__c = regioncly.Id;
        centrecly.Name = 'Clydesdale';
        insert centrecly;
        
        Team__c team = TestData.createTeam();
        team.Name = 'Test Team';
        team.Team_Centre__c = centre.Id;
        insert team;
        Team__c teamcly = TestData.createTeam();
        teamcly.Name = 'CB_Retail';
        teamcly.Team_Centre__c = centrecly.Id;
        insert teamcly;
        
        TSMTarget__c testTarget =  new TSMTarget__c();
        testTarget = TestData.createTSMTarget();
        testTarget.TSMTar_Team__c = team.id;
        testTarget.TSMTar_TSM__c = tsmUser.Id;
        testTarget.TSMTar_StartDate__c = System.Today();
        testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
        insert testTarget;
        TSMTarget__c testTargetcly =  new TSMTarget__c();
        testTargetcly = TestData.createTSMTarget();
        testTargetcly.TSMTar_Team__c = teamcly.id;
        testTargetcly.TSMTar_TSM__c = tsmUser.Id;
        testTargetcly.TSMTar_StartDate__c = System.Today();
        testTargetcly.TSMTar_EndDate__c = System.Today().AddDays(1);
        insert testTargetcly;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        con.Officer_Code__c = '1234';
        insert con;
        Contact concly = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        concly.Con_Team__c = teamcly.id;
        concly.FirstName = 'Clydesdale';
        concly.LastName = 'Banker';
        concly.Officer_Code__c = '1234678';
        insert concly;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RM_Name__c = con.id;
        acc.Commodity_Manager__c=con.id;
        acc.IRRM_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        insert acc;
        Account acccly = TestData.createCalypsoAccount('CLydesdale Acc', '1245', '1234', concly.Id, RecordTypeIdAccountCustomer);
        acccly.FX_Manager__c=concly.id;
        acccly.RM_Name__c = concly.id;
        acccly.Commodity_Manager__c=concly.id;
        acccly.IRRM_Manager__c=concly.id;
        acccly.RecordType__c = 'Customer';
        insert acccly;
        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        Checklist__c chkListcly = TestData.createChecklist(acccly.id);
        chkListcly.File_Checker__c = testUser.Id;
        chkListcly.Product__c = 'FX';
        insert chkListcly;
        System.debug('HERE I CAME >>>>');
        List<Repository__c> repList = new List<Repository__c>();
        Repository__c rep1 = new Repository__c();
        rep1.Rep_GroupName__c = groups.Name;
        rep1.Rep_CombineId__c = groups.Name+','+division.Name+','+6;
        rep1.Rep_DivisionName__c = division.Name;
        rep1.Rep_Month__c = 6;
        rep1.Rep_MonthText__c = '6';
        rep1.Rep_FXDirectActual__c = 1200;
        rep1.Rep_FXIndirectActual__c = 1200; 
        rep1.Rep_CommodityActual__c = 1200;
        rep1.Rep_IRRMActual__c = 1200;
        rep1.RecordTypeId = RecordTypeRepositoryGroup;
        insert rep1;
        
        Repository__c repcly = new Repository__c();
        repcly.Rep_GroupName__c = 'Clydesdale';
        repcly.Rep_CombineId__c = 'Clydesdale'+','+divisioncly.Name+','+3;
        repcly.Rep_DivisionName__c = divisioncly.Name;
        repcly.Rep_Month__c = 3;
        repcly.Rep_MonthText__c = '3';
        repcly.Rep_FXDirectActual__c = 1200;
        repcly.Rep_FXIndirectActual__c = 1200; 
        repcly.Rep_CommodityActual__c = 1200;
        repcly.Rep_IRRMActual__c = 1200;
        repcly.RecordTypeId = RecordTypeRepositoryGroup;
        insert repcly;
        
        Repository__c repyor = new Repository__c();
        repyor.Rep_GroupName__c = 'Yorkshire';
        repyor.Rep_CombineId__c = 'Yorkshire'+','+'Yorkshire'+','+3;
        repyor.Rep_DivisionName__c = 'Yorkshire';
        repyor.Rep_Month__c = 3;
        repyor.Rep_MonthText__c = '3';
        repyor.Rep_FXDirectActual__c = 1200;
        repyor.Rep_FXIndirectActual__c = 1200; 
        repyor.Rep_CommodityActual__c = 1200;
        repyor.Rep_IRRMActual__c = 1200;
        repyor.RecordTypeId = RecordTypeRepositoryGroup;
        insert repyor;
        List<Repository__c> eacher = [SELECT Rep_CombineId__c, Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c];
        
        // wholeMap.put(each.Rep_CombineId__c,each);
        Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
        System.debug('EACH>>>'+eacher);
        
        for(Repository__c each : eacher)
        {
            wholeMap1.put(teamcly.Id+','+concly.Id+','+3, each);
            RepositoryBatch.wholeMap = wholeMap1;
        } 
        
        Test.startTest();
        
        
        ytdPerformanceControllerGroup_FRS obj = new ytdPerformanceControllerGroup_FRS();
        obj.downloadReport_FRS();
        Test.stopTest();
        

        
    }
    
}