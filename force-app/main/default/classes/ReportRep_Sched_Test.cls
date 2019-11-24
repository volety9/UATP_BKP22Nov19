@isTest
public class ReportRep_Sched_Test {
	static testMethod void testclass(){
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFX = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> executeList = new List<Opportunity>();
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
            
            Account acc2 = TestData.createCalypsoAccount('Test Acc2', '2345', '2345', con.Id, RecordTypeIdAccountCustomer);
            acc2.FX_Manager__c=con.Id;
            acc2.RecordType__c='Customer';
            insert acc2;
            
            Account acc3 = TestData.createCalypsoAccount('Test Acc3', '3456', '3456', con.Id, RecordTypeIdAccountCustomer);
            acc3.FX_Manager__c=con.Id;
            acc3.RecordType__c='Customer';
            insert acc3;
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            for(integer i=0;i<10;i++)
            {
                Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCommodity,1500,1500);
                
                opp.StageName = 'Closed Won';
                opp.Opp_TradeID__c='1234'+i;
                if(i==2)
                    opp.CloseDate=System.today().AddYears(-1);
                if(i==3)
                {
                    opp.AccountId = acc2.id;
                    opp.Opp_BaseEquivalent__c = 500;
                }
                if(i==4)
                {
                    opp.AccountId = acc3.id;
                    opp.CloseDate=System.today().AddYears(-1);
                    opp.Opp_BaseEquivalent__c = 500;
                }
                oppList.add(opp);
            }
            insert oppList;
        }
        
        Test.startTest();
        
        ReportRep_Sched obj = new ReportRep_Sched(); 
        obj.execute(null);
        Test.stopTest();
        
        AggregateResult[] arOpp = [SELECT Count(ID)total, SUM(Opp_BaseEquivalent__c)sum FROM Opportunity];
        System.assertEquals(10, arOpp[0].get('total'));
        System.assertEquals(1000, arOpp[0].get('sum'));        
    }
}