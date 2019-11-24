/*
  @Author        : Sushant
  @Name          : SelectedComplianceWrapper_Test
  @Created Date  : 25th July 2017
  @Description   : Test Class for SelectedComplianceWrapper
  @version       : 1.0
*/

@isTest
private class SelectedComplianceWrapper_Test{
    static testMethod void testclass(){
        SelectedComplianceWrapper compWrapper = new SelectedComplianceWrapper();
        SelectedComplianceWrapper compWrap = new SelectedComplianceWrapper('Name','RM Referral','Compliance');    
    }
}