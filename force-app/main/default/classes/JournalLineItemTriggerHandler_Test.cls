/*
@Author        : Ramkumar M B
@Name          : JournalLineItemTriggerHandler_Test
@Created Date  : 16th Feb 2018
@Description   : This is a test Class for JournalLineItemTriggerHandler
@version       : 1.0
*/ 

@isTest
public class JournalLineItemTriggerHandler_Test 
{
    /**
* @description       test method for check the actuals on journal insert
* @name              createJournalTestData
* @param             null
* @return            void
* @throws            NA
*/ 
    static TestMethod void createJournalTestData()
    {
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId(); 
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId(); 
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        insert tsmUser;
        System.runAs(tsmUser)
        {
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
            accint.RecordType__c= 'Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = testTeam.id;
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.Id;
            acc.IRRM_Manager__c=con.Id;
            acc.Commodity_Manager__c = con.Id;
            acc.RecordType__c= 'Customer';
            insert acc;
            
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            insert conint;
            
            Date todayDate = Date.today();
            Integer yearValue = todayDate.year();
            Integer monthValue = todayDate.month();
            Date newDate = Date.newInstance(yearValue, monthValue, 28);
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            Checklist__c chkLstCommodity = TestData.createChecklist(acc.Id);
            chkLstCommodity.File_Checker__c = testUser.Id;
            chkLstCommodity.Product__c = 'Commodity';
            insert chkLstCommodity;
            
            Checklist__c chkLstIRRM = TestData.createChecklist(acc.Id);
            chkLstIRRM.File_Checker__c = testUser.Id;
            chkLstIRRM.Product__c = 'IRRM';
            insert chkLstIRRM;
            
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            TSMTarget__c testTarget = TestData.createTSMTarget();
            	
            testTarget.TSMTar_Team__c = testTeam.id;
            testTarget.TSMTar_TSM__c = tsmUser.Id;
            testTarget.TSMTar_StartDate__c = system.today();
            //testTarget.TSMTar_StartDate__c = newDate;
            testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
            
            insert testTarget;
            PMTarget__c testPMTarget = TestData.createPMMTarget();
            testPMTarget.PMTar_StartDate__c = system.today();
            //testPMTarget.PMTar_EndDate__c = newDate;
            testPMTarget.PMTar_PMUser__c = tsmUser.Id;
            testPMTarget.PMTar_PMContact__c = conint.Id;
            testPMTarget.PMTar_EndDate__c = System.Today().AddDays(1);
            Insert testPMTarget;

            
            List<Opportunity>opportunityList = new List<Opportunity>();
            For(Integer i=0;i<5;i++)
            {
                Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,200,200);
                if(i==1)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityCommodity;
                    opp.Pre_Deal_Checklist__c = chkLstCommodity.Id;
                }else if(i==3)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityIRRM;
                    opp.Pre_Deal_Checklist__c = chkLstIRRM.Id;
                    opp.CloseDate=Date.newInstance(2018, 05, 09);
                }else if(i==4)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityFXCash;
                }
                
                opp.Opp_ETRef__c='123'+i;
                opp.StageName = 'Closed Won';                
                opp.OwnerId   = tsmUser.id;
                opportunityList.add(opp);
                opp.Opp_TradeID__c = String.valueOf(11*i);
            }
            
            insert opportunityList ;
            List<JournalLineItem__c>journalList = new  List<JournalLineItem__c>(); 
            
            For(Opportunity eachOpportunity :opportunityList)
            {
                JournalLineItem__c journal = TestData.createJournal(eachOpportunity.id,eachOpportunity.Amount);
                journal.Journal_PMContact__c = acc.FX_Manager__c;
                journal.Journal_ProductFamily__c = eachOpportunity.Recordtype.Name;
                journal.Journal_TSM__c       = eachOpportunity.OwnerId;

                journalList.add(journal);
            }
            

            Test.startTest();
            Insert journalList;   
            Test.stopTest();
            
            Decimal expectedAmount =0.0 ;
            Decimal actualAmount =0.0 ;
            For(JournalLineItem__c eachJournal :[Select Id,Journal_ProductFamily__c,Journal_Amount__c from JournalLineItem__c])
            {   
                if(eachJournal.Journal_ProductFamily__c =='CRM'){
                    expectedAmount = expectedAmount + eachJournal.Journal_Amount__c;
                }             
            }            
            For(PMTarget__c pmtarget :[Select Id,PMTar_CRMActual__c FROM PMTarget__c]){
                actualAmount = actualAmount + pmtarget.PMTar_CRMActual__c;
            }
            system.assertEquals(expectedAmount, actualAmount);
        }
        
    }
    
    
    
    static TestMethod void createEndOfMonthJournalTestData()
    {
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId(); 
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId(); 
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        insert tsmUser;
        System.runAs(tsmUser)
        {
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
            accint.RecordType__c= 'Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = testTeam.id;
            insert con;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.Id;
            acc.IRRM_Manager__c=con.Id;
            acc.Commodity_Manager__c = con.Id;
            acc.RecordType__c= 'Customer';
            insert acc;
            
            Contact conint = TestData.createContactInternal('23456', RecordTypeIdContactInternal, accint.Id);
            insert conint;
            
            Date todayDate = Date.today();
            Integer yearValue = todayDate.year();
            Integer monthValue = todayDate.month();
            Date newDate = Date.newInstance(yearValue, monthValue, 28);
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            Checklist__c chkLstCommodity = TestData.createChecklist(acc.Id);
            chkLstCommodity.File_Checker__c = testUser.Id;
            chkLstCommodity.Product__c = 'Commodity';
            insert chkLstCommodity;
            
            Checklist__c chkLstIRRM = TestData.createChecklist(acc.Id);
            chkLstIRRM.File_Checker__c = testUser.Id;
            chkLstIRRM.Product__c = 'IRRM';
            insert chkLstIRRM;
            
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            TSMTarget__c testTarget = TestData.createTSMTarget();
            
            testTarget.TSMTar_Team__c = testTeam.id;
            testTarget.TSMTar_TSM__c = tsmUser.Id;
            testTarget.TSMTar_StartDate__c = system.today();
            //testTarget.TSMTar_StartDate__c = newDate;
            testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
            
            insert testTarget;
            PMTarget__c testPMTarget = TestData.createPMMTarget();
            testPMTarget.PMTar_StartDate__c = system.today();
            //testPMTarget.PMTar_EndDate__c = newDate;
            testPMTarget.PMTar_PMUser__c = tsmUser.Id;
            testPMTarget.PMTar_PMContact__c = conint.Id;
            testPMTarget.PMTar_EndDate__c = System.Today().AddDays(1);
            Insert testPMTarget;

            /* insertOrUpdateEOMJournal Test Coverage Start*/
            Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',
                6 => 'June',7 => 'July',8 => 'August',9 => 'Sept',10 => 'October',11 => 'November',12 => 'December'};
                    integer startMonth = CYBGUtilClass.fiscalYearStartMonth();
            List<MonthlyPostingSummary__c> mpsList = new List<MonthlyPostingSummary__c>();
            String firstName = String.valueOf(System.today());
            
            for(integer i=0;i<13;i++){
                MonthlyPostingSummary__c mps = new MonthlyPostingSummary__c();
                if(startMonth<CYBGUtilClass.fiscalYearStartMonth()){
                    Integer year = Integer.valueOf(System.Today().Year())+1; 
                    mps.Name= monthMap.get(startMonth)+' '+String.valueOf(year);  
                }else{
                    mps.Name= monthMap.get(startMonth)+' '+System.Today().Year();
                }
                mps.MPS_Month__c=startMonth;
                if(startMonth==12){
                    startMonth=1;    
                }else{
                    startMonth++;
                } 
                if(i==5){
                 mps.MPS_Current_Posting_Month__c=true;   
                }else{
                mps.MPS_Current_Posting_Month__c=false;
                }
                mps.MPS_Fiscal_Year__c= CYBGUtilClass.findCurrentFY(System.Today(), 10);
                mps.MPS_Status__c='Not Published';            
                mpsList.add(mps);
            }
            
            insert mpsList;
            
            List<PostingLineItem__c>postingLineItemList = new List<PostingLineItem__c>();
            For(Integer i=0;i<2;i++)
            {
            PostingLineItem__c testPLI = new PostingLineItem__c();
            testPLI.MonthlyPostingSummary__c = mpsList.get(System.Today().Month()).Id;
            testPLI.PLI_Amount__c=200.00;
            testPLI.PLI_Corporate_Code__c=label.EOM_YB_Corp_Code;
            testPLI.PLI_GL_Account__c='101010101';
            testPLI.PLI_Cost_Centre__c='10101';
            testPLI.PLI_Cr_Dr__c='Debit';
            testPLI.PLI_Description__c='Test';
            postingLineItemList.add(testPLI);
            }
            insert postingLineItemList;
			/* insertOrUpdateEOMJournal Test Coverage end*/
            
            
            List<Opportunity>opportunityList = new List<Opportunity>();
            /*For(Integer i=0;i<5;i++)
            {
                Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,200,200);
                if(i==1)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityCommodity;
                    opp.Pre_Deal_Checklist__c = chkLstCommodity.Id;
                }else if(i==3)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityIRRM;
                    opp.Pre_Deal_Checklist__c = chkLstIRRM.Id;
                    opp.CloseDate=System.today();//Date.newInstance(2018, 05, 09);
                }else if(i==4)
                {
                    opp.RecordTypeId = RecordTypeIdOpportunityFXCash;
                }
                opp.Opp_ETRef__c='123'+i;
                opp.StageName = 'Closed Won';                
                opp.OwnerId   = tsmUser.id;
                
                opp.Opp_TradeID__c = String.valueOf(11*i);
                opportunityList.add(opp);
            }*/
            //insertOrUpdateEOMJournal Test Coverage- START
            Opportunity oppNewTest = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityIRRM,200,200);
            oppNewTest.CloseDate=System.today();//Date.newInstance(2018, 05, 09);
            oppNewTest.Opp_ETRef__c='1239';
            oppNewTest.StageName = 'Closed Won';                
            oppNewTest.OwnerId   = tsmUser.id;
            oppNewTest.Opp_TradeID__c = String.valueOf(112*2);
            opportunityList.add(oppNewTest);

            //insertOrUpdateEOMJournal Test Coverage- END
            insert opportunityList ;
            
            List<JournalLineItem__c>journalList = new  List<JournalLineItem__c>(); 
            
            For(Opportunity eachOpportunity :opportunityList)
            {
                JournalLineItem__c journal = TestData.createJournal(eachOpportunity.id,eachOpportunity.Amount);
                journal.Journal_PMContact__c = acc.FX_Manager__c;
                journal.Journal_ProductFamily__c = eachOpportunity.Recordtype.Name;
                journal.Journal_TSM__c       = eachOpportunity.OwnerId;
                journalList.add(journal);
            }
            //insertOrUpdateEOMJournal Test Coverage- START

                JournalLineItem__c journalYB = TestData.createJournal(oppNewTest.id,oppNewTest.Amount);
                journalYB.Journal_PMContact__c = acc.FX_Manager__c;
                journalYB.Journal_ProductFamily__c =  label.RecordTypeIRRM;
                journalYB.Journal_TSM__c       = oppNewTest.OwnerId;
                journalYB.Journal_CorpCode__c='YB';
                journalYB.Journal_BankerOfficerCode__c='10101'; 
                journalYB.Journal_GLAccount__c='101010101';
//              journalYB.Journal_Trade_date__c  = Date.newInstance(2018, 05, 09);
                journalList.add(journalYB);
            

            //insertOrUpdateEOMJournal Test Coverage- END

            Test.startTest();
            Insert journalList;   
            Test.stopTest();
            
            Decimal expectedAmount =0.0 ;
            Decimal actualAmount =0.0 ;
            For(JournalLineItem__c eachJournal :[Select Id,Journal_ProductFamily__c,Journal_Amount__c from JournalLineItem__c])
            {   
                if(eachJournal.Journal_ProductFamily__c =='CRM'){
                    expectedAmount = expectedAmount + eachJournal.Journal_Amount__c;
                }             
            }            
            For(PMTarget__c pmtarget :[Select Id,PMTar_CRMActual__c FROM PMTarget__c]){
                actualAmount = actualAmount + pmtarget.PMTar_CRMActual__c;
            }
            system.assertEquals(expectedAmount, actualAmount);
        }
        
    }
    
    
}