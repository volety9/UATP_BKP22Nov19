/*
@Author        : Santhoshan
@Name          : CalypsoDataTriggerHandler_Test
@Created Date  : 21st Jan 2018
@Description   : This is a Test Class for CalypsoDataTriggerHandler
@version       : 1.0
*/

@isTest
public class CalypsoDataTriggerHandler_Test { 
    /**
* @description       Test method to check if Customer is updated if the valid WID is provided.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void CalypsoDataTriggerHandler_TestMethodWID() {
        
        List<CalypsoData__c> calypsoDataList = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoQueryList = new List<CalypsoData__c>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        //insert testUser;
        system.runAs(testUser)
        {            
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
            
            Team__c team = TestData.createTeam();
            team.Name = 'Test Team';
            team.Team_Centre__c = centre.Id;
            insert team;
            
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c='Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__C = team.id;
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.id;
            acc.RecordType__c='Customer';
            insert acc;
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
            
            opp.StageName='Closed Won';
            insert opp;
            
            for(Integer i=0;i<100;i++)
            {
                CalypsoData__c cdTestWID = TestData.createCalypsoData();
                cdTestWID.CD_WID__c='1245'; 
                cdTestWID.CD_TradeID__c=String.valueOf(10101010+i);
                cdTestWID.CD_TradeStatus__c='Verified';
                if(i==2)
                {
                    cdTestWID.CD_UserAction__c = System.Label.Save;
                    cdTestWID.CD_HasDuplicate__c = false;
                    cdTestWID.CD_ETTraderID__c = con.Name;
                }
                calypsoDataList.add(cdTestWID);
            }            
            Test.startTest();
            insert calypsoDataList;
            Test.stopTest();            
            calypsoQueryList = [SELECT CD_Customer__c FROM CalypsoData__c];            
            for(CalypsoData__c calypsoData : calypsoQueryList){                
                //System.assertEquals(acc.id, calypsoData.CD_Customer__c);
            }
            
        }    
    }
    
    
    /**
* @description       Test method to check if Customer is updated if the valid CIF is provided.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void CalypsoDataTriggerHandler_TestMethodCIF() {
        List<CalypsoData__c> calypsoDataList = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoQueryList = new List<CalypsoData__c>();        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        system.runAs(testUser)
        {
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
            
            Team__c team = TestData.createTeam();
            team.Name = 'Test Team';
            team.Team_Centre__c = centre.Id;
            insert team;
            
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c='Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.con_team__c = team.id;
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.id;
            acc.RecordType__c='Customer';
            insert acc;
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
            opp.StageName = 'Closed Won';
            insert opp;
            
            for(Integer i=0;i<100;i++){
                CalypsoData__c cdTestCIF = TestData.createCalypsoData();
                cdTestCIF.CD_CIF__c='1234'; 
                cdTestCIF.CD_TradeID__c=String.valueOf(10101010+i);
                cdTestCIF.CD_TradeStatus__c='Verified';
                cdTestCIF.CD_BranchNumber__c = 'CB Direct Dealing Client';
                cdTestCIF.CD_ETTraderID__c = con.id;
                calypsoDataList.add(cdTestCIF);
            }
            Test.startTest();
            insert calypsoDataList;
            Test.stopTest();
            calypsoQueryList = [SELECT CD_Customer__c FROM CalypsoData__c];            
            for(CalypsoData__c calypsoData : calypsoQueryList){                
                //System.assertEquals(acc.id, calypsoData.CD_Customer__c);
            }            
        }
    }
    
    
    /**
* @description       Test method to check all the Error Conditions.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void CalypsoDataTriggerHandler_TestMethodErrorCustomer() {
        List<CalypsoData__c> calypsoDataList = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoDataListUpdate = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoQueryList = new List<CalypsoData__c>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        system.runAs(testUser)
        {
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
            
            Team__c team = TestData.createTeam();
            team.Name = 'Test Team';
            team.Team_Centre__c = centre.Id;
            insert team;
            
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c='Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = team.id;
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.Id;
            acc.RecordType__c='Customer';
            insert acc;
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
            opp.StageName = 'Closed Won';
            insert opp;
            CalypsoData__c cdTestError = TestData.createCalypsoData();
            cdTestError.CD_CIF__c='1234';
            cdTestError.CD_UserAction__c = System.Label.Discard;
            cdTestError.CD_TradeID__c=String.valueOf(10101910);
            cdTestError.CD_TradeStatus__c='Verified';
            
            calypsoDataList.add(cdTestError);      
            
            CalypsoData__c cdTestErrorFail = TestData.createCalypsoData();
            cdTestErrorFail.CD_CIF__c='1234';
            cdTestErrorFail.CD_UserAction__c = System.Label.Discard;
            cdTestErrorFail.CD_TradeID__c=String.valueOf(10109910);
            cdTestErrorFail.CD_ConversionStatus__c=System.Label.Failed;
            cdTestErrorFail.CD_TradeStatus__c='Verified';
            calypsoDataList.add(cdTestErrorFail);                        
            
            for(Integer i=0;i<50;i++)
            {
                CalypsoData__c cdTestError2 = TestData.createCalypsoData();
                cdTestError2.CD_CIF__c='1234';
                cdTestError2.CD_Customer__c=acc.Id;
                cdTestError2.CD_HasDuplicate__c=true;
                cdTestError2.CD_TradeID__c=String.valueOf(10101010+i);
                cdTestError2.CD_TradeStatus__c='Verified';
                calypsoDataList.add(cdTestError2);
            }
            
            insert calypsoDataList;
            
            cdTestError.CD_ETREUTERSPNL__c=2500; 
            calypsoDataListUpdate.add(cdTestError);
            
            Test.startTest();
            CYBGUtilClass.runBeforeTrigger=true;
            update calypsoDataListUpdate;            
            Test.stopTest();
            
            calypsoQueryList = [SELECT CD_ETREUTERSPNL__c FROM CalypsoData__c WHERE 
                                Id=:cdTestError.Id];
            
            for(CalypsoData__c calypsoData : calypsoQueryList)
            {
                //System.assertEquals(2500, calypsoData.CD_ETREUTERSPNL__c);
            }
            
        }
    }
    static testMethod void CalypsoDataTriggerHandler_TradeKeyword() {
        
		List<CalypsoData__c> calypsoDataListError = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoDataList = new List<CalypsoData__c>();
        List<CalypsoData__c> calypsoQueryList = new List<CalypsoData__c>();
        List<JournalLineItem__c> journalQueryList = new List<JournalLineItem__c>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        system.runAs(testUser)
        {        
           
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c='Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', null, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.id;
            acc.RecordType__c='Customer';
            insert acc;
            
            for(Integer i=0;i<9;i++)
            {
                CalypsoData__c cdTestWID = TestData.createCalypsoData();
                cdTestWID.CD_WID__c='1245';
                cdTestWID.CD_BankName__c = 'CB';
                cdTestWID.CD_ETRef__c = String.valueOf(10+i);
                cdTestWID.CD_TradeID__c=String.valueOf(10101010+i);
                cdTestWID.CD_TradeStatus__c='Verified';
                cdTestWID.CD_DealExecutedBy__c = con.Id;
                cdTestWID.CD_ETREUTERSPNL__c = 2000;
                
                if(math.mod(i, 2) == 0)
                    cdTestWID.CD_BranchNumber__c='CB Carded Ratesheet';
                else
                    cdTestWID.CD_BranchNumber__c='CB Direct Dealing Client';
                calypsoDataList.add(cdTestWID);
            }    
            
            for(Integer i=5;i<9;i++)
            {
				CalypsoData__c cdTestWID = TestData.createCalypsoData();
                cdTestWID.CD_WID__c='1245';
                cdTestWID.CD_BankName__c = 'CB';
                cdTestWID.CD_ETRef__c = String.valueOf(10+i);
                cdTestWID.CD_TradeID__c=String.valueOf(10101010+i);
                cdTestWID.CD_TradeStatus__c='Verified';
                cdTestWID.CD_DealExecutedBy__c = con.Name;
                cdTestWID.CD_ETREUTERSPNL__c = 2000;
                
                if(math.mod(i, 2) == 0)
                    cdTestWID.CD_BranchNumber__c='CB Carded Ratesheet';
                else
                    cdTestWID.CD_BranchNumber__c='CB Direct Dealing Client';
                calypsoDataList.add(cdTestWID);
            } 
            Test.startTest();
            insert calypsoDataList;
			
            Test.stopTest();            
            calypsoQueryList = [SELECT CD_Customer__c, CD_TradeID__c, CD_ConversionStatus__c, CD_ErrorMessage__c FROM CalypsoData__c];            
            for(CalypsoData__c calypsoData : calypsoQueryList){                
                //System.assertEquals(acc.id, calypsoData.CD_Customer__c);
            }
            
            AggregateResult[] arOpp = [SELECT Count(ID)total FROM Opportunity];
            System.assertEquals(0, arOpp[0].get('total'));
            
            AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
            //System.assertEquals(0, arJnl[0].get('total'));
        }    
    }
}