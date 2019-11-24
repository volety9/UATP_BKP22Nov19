/*
@Author        : Sushant
@Name          : TestData
@Created Date  : 25th July 2017
@Description   : Util class for creating the test data
@version       : 1.0
*/ 

Public class TestData{
    public static User createUser(string profileName){
        Profile p = [select id from profile where name=:profileName];
        User u = new User(alias = 'cybu', 
                          email='cybuser@testorg.com', 
                          emailencodingkey='UTF-8', 
                          lastname='cybUser', 
                          languagelocalekey='en_US',                           
                          localesidkey='en_US', 
                          profileid = p.Id, 
                          location__c = 'England',
                          timezonesidkey='America/Los_Angeles', 
                          username='cybuser@testorg.com');
        return u;
    }
    public static User createMGRUser(string profileName){
        Profile p = [select id from profile where name=:profileName];
        User u = new User(alias = 'cybu', 
                          email='mgruser@testorg.com', 
                          emailencodingkey='UTF-8', 
                          lastname='mgrUser', 
                          languagelocalekey='en_US',                           
                          localesidkey='en_US', 
                          profileid = p.Id, 
                          location__c = 'England',
                          timezonesidkey='America/Los_Angeles', 
                          username='mgruser@testorg.com');
        return u;
    }
    public static Account createAccount(string accName){
        Account acc = new Account(Name = accName);
        return acc;
    }
    public static Compliance__c createComp(string compName){
        Compliance__c complaince = new Compliance__c(Name = compName);
        return complaince ;                                         
    }
    public static Attachment createAttach(string attachName){
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        Attachment attach = new Attachment(Name = attachName,
                                           body = bodyBlob);
        return attach;
    }
    //Creating new Method for Calypso Data Related Testing
    
    
    public static Account createCalypsoAccount(string accName, String wid, String cif, Id conId, Id recId){
        Account acc = new Account();
        acc.BillingStreet='123';
        acc.BillingCity ='London';
        acc.BillingPostalCode='5602132';
        acc.Branch__c='Clydesdale Bank';
        acc.RecordTypeId=recId;
        acc.RM_Name__c=conId;
        acc.Name = accName;
        acc.US_Persons__c='No';        
        acc.Treasury_Solutions_Area__c='North';
        acc.Commodity_Manager__c = conId;
        acc.WID__c=wid;
        acc.CIF__c=cif;
       acc.FCTMA_Date_of_Agreement__c=System.today();
        acc.ISDA_Date_of_Agreement__c=System.today();
        acc.LEI_Obtained__c=System.today();
        acc.FX_Annual_Review_Date__c = System.today();
        acc.IRRM_Annual_Review_Date__c  = System.today();
        acc.Commodity_Annual_Review_Date__c  = System.today();
        acc.FX_3_Month_Review_Date__c  = System.today();
        acc.Commodity_3_Month_Review_Date__c = System.today();
        acc.IRRM_3_Month_Review_Date__c = System.today();
        return acc;
    }
    public static Account createCalypsoAccountInternal(string accName, Id recId){
        Account acc = new Account();
        
        acc.Name = accName;
        acc.RecordTypeId = recId;
        
        return acc;
    }
    
    public static Account createCustomerAccount(string accName, Id recId){
        Account acc = new Account();
        acc.US_Persons__c= 'No';
        acc.Name = accName;
        acc.RecordTypeId = recId;
        acc.Branch__c = 'Clydesdale Bank';
        acc.Treasury_Solutions_Area__c = 'North';
        acc.BillingCity = 'Test City';
        acc.BillingStreet = 'Test Street';
        acc.BillingPostalCode = '12345';
         acc.FCTMA_Date_of_Agreement__c=System.today();
        acc.ISDA_Date_of_Agreement__c=System.today();
        acc.LEI_Obtained__c=System.today();
        acc.FX_Annual_Review_Date__c = System.today();
        acc.IRRM_Annual_Review_Date__c  = System.today();
        acc.Commodity_Annual_Review_Date__c  = System.today();
        acc.FX_3_Month_Review_Date__c  = System.today();
        acc.Commodity_3_Month_Review_Date__c = System.today();
        acc.IRRM_3_Month_Review_Date__c = System.today();
        return acc;
    }
    public static CalypsoData__c createCalypsoData(){
        CalypsoData__c cd = new CalypsoData__c();       
        cd.CD_ConversionStatus__c='Failed';
        cd.CD_BankName__c='CB';
        cd.CD_TradeID__c='123444111';
        cd.CD_ETREUTERSPNL__c=1200;  
        cd.CD_ETRef__c='123444222';
        cd.CD_TransactionDate__c = system.today();
        cd.CD_DealType__c='FXNDF';
        cd.CD_BranchNumber__c=System.Label.CBSortingCode;
        return cd;
    }
    public static Contact createContactInternal(String offCode, id recId, id accId){
    	Contact con =  new Contact();
        con.FirstName = 'Santhoshan';
        con.LastName = 'Banker';
        con.Contact_Status__c = 'Active';
        con.RecordTypeId=recId;
        con.AccountId=accId;
        return con;
    }
    public static Contact createContact(String offCode, id recId, id accId){
        
        Contact con = new Contact();
        
        con.FirstName='Santhoshan';
        con.LastName='Banker';
        con.Officer_Code__c=offCode;
        con.Contact_Status__c='Active';
        con.RecordTypeId=recId;
        con.AccountId=accId;
        con.Customer_Banking_Centre__c='Birmingham';
        return con; 
    }
    public static Contact createContactContact(String lastName, id recId, id accId){
        Contact con = new Contact();
        con.LastName=lastName;
        con.Contact_Status__c='Active';
        con.RecordTypeId=recId;
        con.AccountId=accId;
        return con; 
    }
    public static Checklist__c createChecklist(id accId){
        Checklist__c chkList = new Checklist__c();
        chkList.Customer_Name__c = accId;
        chkList.Checklist_Status__c = 'Completed';
        chkList.Risk_Rating__c = 'Green';
        chkList.Remedial_Action_Required__c = 'No';
        chkList.Authorisation_Valid_Until_Date__c = System.today();
        chkList.Product_Authorised__c = 'Retail';
        chkList.Strategy_Paper_Issued__c = System.today();
        return chkList;
    }
    public static Opportunity createOpportunity(id accId, Contact con, Id chkListId, id recId, integer fva, integer amt){
        Opportunity opp = new Opportunity();
        opp.Name='Sample Opp 4';
        opp.AccountId=accId;
        opp.RecordTypeId=recId;
        opp.CloseDate=System.today();
        opp.Deal_Executed_By__c=con.Id;
        opp.Maturity_Date__c=Date.parse('02/02/2018');
        opp.Opportunity_Currency__c='GBP';
        opp.Pre_Deal_Checklist__c=chkListId;
        opp.Face_Value_Amount__c=fva;
        opp.Amount=amt;
        
        return opp;
    }
    public static Opportunity createOpportunityTradeID(id accId, Contact con, Id chkListId, id recId, integer fva, integer amt, String tradeID){
        Opportunity opp = new Opportunity();
        opp.Name='Sample Opp 4';
        opp.AccountId=accId;
        opp.RecordTypeId=recId;
        opp.CloseDate=System.today();
        opp.Deal_Executed_By__c=con.Id;
        opp.Maturity_Date__c=Date.parse('02/02/2018');
        opp.Opportunity_Currency__c='GBP';
        opp.Pre_Deal_Checklist__c=chkListId;
        opp.Face_Value_Amount__c=fva;
        opp.Amount=amt;
        
        return opp;
    }
    //End of Calypso Data Test
    //Creating Records for Banker Hierarchy
    public static Group__c createGroup(){
        Group__c testGroup = new Group__c();
        testGroup.Name = 'Test Group';
        testGroup.Group_Status__c='Active';
        
        return testGroup;
    }
    
    public static Division__c createDivision(){
        Division__c testDivision = new Division__c();
        testDivision.Name='Test Division';
        testDivision.Div_Status__c='Active';
        return testDivision;
    }
    public static Region__c createRegion(){
        Region__c testRegion = new Region__c();
        testRegion.Name = 'Test Region';
        testRegion.Region_Status__c='Active';
        
        return testRegion;        
    }
    public static Centre__c createCentre(){
        Centre__c testCentre = new Centre__c();
        testCentre.Name = 'Test Centre';
        testCentre.Centre_Status__c='Active';
        
        return testCentre;
    }
    public static Team__c createTeam(){
        Team__c testTeam = new Team__c();
        testTeam.Name = 'Test Team';
        testTeam.Team_Status__c = 'Active';
        return testTeam;
        
    }
    public static TSMTarget__c createTSMTarget()
    {
        Date todayDate1 = system.today();
        Integer monthval = todayDate1.month();
        Integer yearval = todayDate1.Year();
        Integer nextMonth = monthval+1;
        Date myDate = Date.newInstance(yearval, nextMonth, 1);
        TSMTarget__c testTarget = new TSMTarget__c();
        
        testTarget.TSMTar_StartDate__c = System.today();
        testTarget.TSMTar_EndDate__c = System.today().AddDays(1);
        testTarget.TSMTar_FXDirectTarget__c = 500;
        testTarget.TSMTar_FXIndirectTarget__c = 500;
        testTarget.TSMTar_CRMTarget__c = 500;
        testTarget.TSMTar_CommTarget__c = 500;
        testTarget.TSMTar_IRRMTarget__c = 500;
        testTarget.TSMTar_FXDirectActual__c = 0;
        testTarget.TSMTar_FXIndirectActual__c = 0;
        testTarget.TSMTar_CRMActual__c = 0;
        testTarget.TSMTar_CommActual__c = 0;
        testTarget.TSMTar_IRRMActual__c = 0;
        testTarget.TSMTar_IsCurrentFY__c = True;
        return testTarget;
    }
    
    public static PMTarget__c createPMMTarget(){
        Date todayDate1 = system.today();
        Integer monthval = todayDate1.month();
        Integer yearval = todayDate1.Year();
        Integer nextMonth = monthval+1;
        Date myDate = Date.newInstance(yearval, nextMonth, 1);
       
        
        PMTarget__c testPMTarget = new PMTarget__c();
        
        testPMTarget.PMTar_StartDate__c = System.today();
        testPMTarget.PMTar_EndDate__c = System.today().AddDays(1);
        testPMTarget.PMTar_FXDirectActual__c = 500;
        testPMTarget.PMTar_CRMTarget__c = 500;
        testPMTarget.PMTar_CommTarget__c = 500;
        testPMTarget.PMTar_IRRMTarget__c = 500;
        testPMTarget.PMTar_FXDirectActual__c = 0;
        testPMTarget.PMTar_CRMActual__c = 0;
        testPMTarget.PMTar_CommActual__c = 0;
        testPMTarget.PMTar_IRRMActual__c = 0;
        testPMTarget.PMTar_IsCurrentFY__c = True;
        return testPMTarget;
    }
    
    public static JournalLineItem__c createJournal(Id opportunityId,Decimal amount)
    {
        JournalLineItem__c eachJournal = new JournalLineItem__c();
        eachJournal.Journal_Opportunity__c = opportunityId;
        eachJournal.Journal_Amount__c  = amount;
        return eachJournal;
    }
    
}