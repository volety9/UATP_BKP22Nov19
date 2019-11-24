/*
  @Author        : Suhas
  @Name          : ForecastingReportController_Test
  @Created Date  : 29th May 2018
  @Description   : Test Class for ForecastingReportController
  @version       : 1.0
*/
@isTest
public class ForecastingReportController_Test {
	 static testMethod void testclass(){
         
         
         
         Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
         List<Opportunity> oppList = new List<Opportunity>();
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
            Date createdDateFrom;
            Date createdDateTo;
            If(currentMonth>=1 && currentMonth <=3)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 1, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 3, 31);
        }else If(currentMonth>=4 && currentMonth <=6)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 4, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 6, 30);
        }else If(currentMonth>=7 && currentMonth <=9)
        {
            createdDateFrom = date.newInstance(yearvalue-1, 7, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 9, 30);
        }else 
        {
            createdDateFrom = date.newInstance(yearvalue-1, 10, 1);
            createdDateTo =   date.newInstance(yearvalue-1, 12, 31);
        }
            createdDateFrom = createdDateFrom +2;
            for(integer i=0;i<10;i++)
            {
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
            opp.StageName = 'New Opportunity';
            opp.Opp_TradeID__c='4567'+i;
              
                if(i==2)
                    opp.CloseDate =  createdDateFrom;
               
            oppList3.add(opp);
            }
            
            
            insert oppList3;
        }
        ForecastingReportController forecast = new ForecastingReportController();
        Integer yearvalueVal   =  Date.Today().Year(); 
        forecast.fetchReportData(2,yearvalueVal);
        forecast.fetchReportData(5,yearvalueVal);
        forecast.fetchReportData(8,yearvalueVal);
        forecast.fetchReportData(11,yearvalueVal);  
         
		forecast.downloadReport();
        forecast.accountList = new List<Account>();
         
    }
}