/*
@Author        : Ramkumar M B
@Name          : PMTargetTriggerHandler
@Created Date  : 5th March 2018
@Description   : This is a Handler for PMTargetTrigger 
@version       : 1.0
*/
public class PMTargetTriggerHandler 
{
/**
* @description       Method to process and Validate the PM Target before Insert 
* @name              onAfterInsert
* @param             List<PMTarget__c>
* @return            void
* @throws            NA
*/ 
     Public static Void onBeforeInsert(List<PMTarget__c>pmTargetList)
    {
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth(); 
        List<Id>pmIdList = new List<Id>();
        Map<Id,PMTarget__c> allActivePMTargetMap = activePMTargets();
        
        For(PMTarget__c eachPMTarget:pmTargetList)
        {
            eachPMTarget.PMTar_FiscalYear__c = CYBGUtilClass.findCurrentFY(System.Today(), fyStartMonth);
            eachPMTarget.PMTar_FYStartDate__c = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth);        
            eachPMTarget.PMTar_FYEndDate__c = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
            pmIdList.add(eachPMTarget.PMTar_PMContact__c);
            If(allActivePMTargetMap.containsKey(eachPMTarget.PMTar_PMContact__c))
            {
                eachPMTarget.adderror(Label.PMTargetDuplicateError+
                                      allActivePMTargetMap.get(eachPMTarget.PMTar_PMContact__c).Name);
            }
        }
        List<PMTarget__c> updatedList = WorkingDaysCalUtil.CalWorkingDaysForPMTarget(pmTargetList);        
    }
    public static Map<Id,PMTarget__c> activePMTargets(){
        Map<Id,PMTarget__c> pmTargetMap = new Map<Id,PMTarget__c>();
        For(PMTarget__c eachPMTarget :[Select PMTar_PMContact__c, Name, PMTar_Status__c
                                       From PMTarget__c where PMTar_Status__c =:System.Label.Active])
        {      
            pmTargetMap.put(eachPMTarget.PMTar_PMContact__c,eachPMTarget); 
        }
        return pmTargetMap;
    }
/**
* @description       Method to process and Validate the PM Target before Insert 
* @name              onBeforeUpdate
* @param             List<PMTarget__c>
* @return            void
* @throws            NA
*/  
    public static void onBeforeUpdate(List<PMTarget__c> pmTargetsList){
        List<PMTarget__c> updatedList = WorkingDaysCalUtil.CalWorkingDaysForPMTarget(pmTargetsList);        
    }

}