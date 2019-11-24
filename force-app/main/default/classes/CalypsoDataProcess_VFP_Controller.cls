/*
@Author        : Santhoshan
@Name          : CalypsoDataProcess_VFP_Controller
@Created Date  : 10th Jun 2018
@Description   : This is a Apex Class to Refresh the Calypso Data
@version       : 1.0
*/
public class CalypsoDataProcess_VFP_Controller {
    public CalypsoDataProcess_VFP_Controller(){
        
    }
    /**
    * @description       Method to Process the Calypso Data
    * @name              updateCalypso
    * @param             null
    * @return            URL
    * @throws            NA
    */ 
    public PageReference updateCalypso(){
        Id id = apexpages.currentpage().getparameters().get('id');
        List<CalypsoData__c> calList = [SELECT Id FROM CalypsoData__c WHERE Id=:id];
        Update calList;
        PageReference retURL = new PageReference('/' + id);
        retURL.setRedirect(true);
        return retURL;
    }
}