/*
  @Author        : Sushant
  @Name          : ComplianceWrapper_Test
  @Created Date  : 25th July 2017
  @Description   : Test Class for ComplianceWrapper_Test
  @version       : 1.0
*/

@isTest
private class ComplianceWrapper_Test{
    static testMethod void testclass(){
        ComplianceWrapper compWrapper = new ComplianceWrapper();
        Compliance__c comp = TestData.createComp('RM Referral');
        ComplianceWrapper compWrap = new ComplianceWrapper(comp);    
    }
}