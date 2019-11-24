/*
  @Author        : Sushant
  @Name          : ComplianceWrapper
  @Created Date  : 25th July 2017
  @Description   : Wrapper class used in the VFC_AccountComplianceMerge
  @version       : 1.0
*/

public class ComplianceWrapper{
    public Boolean checked {get; set;}
    public Compliance__c comp {get; set;}
    public ComplianceWrapper(){
        comp = new Compliance__c();
        checked = false;
    }
    public ComplianceWrapper(Compliance__c c){
        comp = c;
        checked = false;
    }
}