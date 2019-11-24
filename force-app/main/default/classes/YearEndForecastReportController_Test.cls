/*
  @Author        : Suhas
  @Name          : BrokenDownByProductYOYController_Test
  @Created Date  : 29th May 2018
  @Description   : Test Class for BrokenDownByProductYOYController
  @version       : 1.0
*/
@isTest
public class YearEndForecastReportController_Test {
	 static testMethod void testclass(){
         
         Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
         List<Opportunity> oppList = new List<Opportunity>();
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
            
            for(integer i=0;i<10;i++)
            {
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
            opp.StageName = 'Closed Won';
            opp.Opp_TradeID__c='1234'+i;
                if(i==2)
                    opp.CloseDate=System.today().AddDays(-365);
            oppList.add(opp);
            }
            insert oppList;
            
            List<Opportunity> oppList3 = new List<Opportunity>();
            Integer currentMonth = Date.Today().Month();
            Integer yearvalue   =  Date.Today().Year();
            Date createdDateFrom = date.newInstance(yearvalue-1, currentMonth, 5);
            Date createdDateTo;
            
            for(integer i=0;i<10;i++)
            {
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
            opp.StageName = 'New Opportunity';
            opp.Opp_TradeID__c='4567'+i;
              
                if(i==2)
                    opp.CloseDate =  createdDateFrom;
               createdDateFrom = createdDateFrom +1;
            oppList3.add(opp);
            }
            
            
            insert oppList3;
            
            
        }
        YearEndForecastReportController yearEndForecastReport = new YearEndForecastReportController();
		yearEndForecastReport.fetchReportData();
         yearEndForecastReport.downloadReport();

         
    }
}