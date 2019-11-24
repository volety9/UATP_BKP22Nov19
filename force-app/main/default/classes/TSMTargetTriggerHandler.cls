/*
@Author        : Sushant Shekhar
@Name          : TSMTargetTriggerHandler
@Created Date  : 5th March 2018
@Description   : This is a Handler for TSMTargetTrigger 
@version       : 1.0
*/
public class TSMTargetTriggerHandler 
{
 /**
* @description       Method to process and Validate the TSM Target before Insert 
* @name              onAfterInsert
* @param             List<TSMTarget__c>
* @return            void
* @throws            NA
*/ 
    public static void onBeforeInsert(List<TSMTarget__c> tsmTargetsList){
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth(); 
        Set<ID> tsmIDsSet = new Set<ID>();
        For(TSMTarget__c eachTSMTarget : tsmTargetsList){
            tsmIDsSet.add(eachTSMTarget.TSMTar_TSM__c);
        }    
        Map<ID, User> tsmUserMap = new Map<ID, User>([Select id, Name, ManagerId From User Where ID IN :tsmIDsSet]);
        Map<String,TSMTarget__c> allActivetsmTargetMap = activeTSMTargets();
        For(TSMTarget__c eachTSMTarget : tsmTargetsList){
            eachTSMTarget.TSMTar_FiscalYear__c = CYBGUtilClass.findCurrentFY(System.Today(), fyStartMonth);
            eachTSMTarget.TSMTar_FYStartDate__c = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth);        
            eachTSMTarget.TSMTar_FYEndDate__c = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth); 
            if(tsmUserMap.get(eachTSMTarget.TSMTar_TSM__c).ManagerId != null)
            {
                eachTSMTarget.TSMTar_TSMManager__c = tsmUserMap.get(eachTSMTarget.TSMTar_TSM__c).ManagerId;
            }
            else
            {
                //eachTSMTarget.TSMTar_TSMManager__c = ''; //commented by krishna as test class for opportunity trigger handler is failing
            }
            
            if(allActivetsmTargetMap.containsKey((String)eachTSMTarget.TSMTar_TSM__c + (String)eachTSMTarget.TSMTar_Team__c))
            {
                eachTSMTarget.adderror(Label.TSMTargetDuplicateError+
                                      allActivetsmTargetMap.get((String)eachTSMTarget.TSMTar_TSM__c + 
                                                       (String)eachTSMTarget.TSMTar_Team__c).Name);
            }
        }
        List<TSMTarget__c> updatedList = WorkingDaysCalUtil.CalWorkingDaysForTSMTarget(tsmTargetsList); 
    }
    
   
    public static Map<String,TSMTarget__c> activeTSMTargets(){
        Map<String,TSMTarget__c> tsmTargetMap = new Map<String,TSMTarget__c>();
        For(TSMTarget__c eachTSMTarget :[Select TSMTar_TSM__c,TSMTar_Team__c, TSMTar_Status__c, Name
                                         From TSMTarget__c where TSMTar_Status__c =: System.Label.Active]){
            
            tsmTargetMap.put((String)eachTSMTarget.TSMTar_TSM__c + (String)eachTSMTarget.TSMTar_Team__c, eachTSMTarget);                       
        }
        return tsmTargetMap;
    }
    /**
* @description       Method to process and Validate the TSM Target before Update 
* @name              onBeforeUpdate
* @param             List<TSMTarget__c>
* @return            void
* @throws            NA
*/ 
    public static void onBeforeUpdate(List<TSMTarget__c> tsmTargetsList){
        List<TSMTarget__c> updatedList = WorkingDaysCalUtil.CalWorkingDaysForTSMTarget(tsmTargetsList);        
    }
}