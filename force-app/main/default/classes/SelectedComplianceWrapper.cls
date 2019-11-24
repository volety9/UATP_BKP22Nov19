/*
  @Author        : Sushant
  @Name          : SelectedComplianceWrapper
  @Created Date  : 25th July 2017
  @Description   : Wrapper class used in the VFC_AccountComplianceMerge controller
  @version       : 1.0
*/

public class SelectedComplianceWrapper{
    public string label {get;set;}
    public string parentValue {get; set;}
    public string childValue {get; set;}
    public boolean parentSelected {get;set;}
    public boolean childSelected {get;set;}
    public SelectedComplianceWrapper()
    {
        label = null;
        parentValue = null;
        childValue = null;
        parentSelected = false;
        childSelected = false;        
    }
    public SelectedComplianceWrapper(string fieldLabel, string fieldValueR1, string fieldValueR2)
    {
        label = fieldLabel;
        parentValue = fieldValueR1;
        childValue = fieldValueR2;
        parentSelected = false;
        childSelected = false;        
    }
}