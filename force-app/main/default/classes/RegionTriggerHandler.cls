/*
@Author        : Ramkumar M B
@Name          : RegionTriggerHandler
@Created Date  : 12th February 2018
@Description   : This is a Handler for RegionTrigger 
@version       : 1.0
*/
public class RegionTriggerHandler 
{
    /**
* @description       Method to do the Roll up summary on Division based for each Region .
* @name              onAfterUpdate
* @param             List<Region__c>
* @return            void
* @throws            NA
*/ 
    public static void onAfterUpdate(List<Region__c> regionRecordList)
    {
        List<Division__c> divisionListToUpdate = new List<Division__c>();
        List<Region__c> regionRecordListforDivisions = new List<Region__c>();
        List<Id>divisionIdList =  new List<Id>();
        Map<Id,Division__c>divisionMap ;
        
        // Capturing old and new Division Id for each updated Region        
        For(Region__c eachRegion : regionRecordList)
        {
            Region__c oldRegion = (Region__c)Trigger.oldMap.get(eachRegion.Id);            
            If(oldRegion.Region_Division__c!=eachRegion.Region_Division__c)
            {
                divisionIdList.add(oldRegion.Region_Division__c);
            }          
            divisionIdList.add(eachRegion.Region_Division__c);            
            Division__c divisionRecordForEachTeam = new Division__c();
            divisionRecordForEachTeam.id = eachregion.Region_Division__c;            
        }              
        // Get all Division details and Region Details for captured Division Id list
        divisionMap     = New Map<Id,Division__c>([Select Id,Div_FXDirectTarget__c,Div_FXIndirectTarget__c,
                                                   Div_FXDirectActual__c,Div_FXIndirectActual__c,Div_CommTarget__c,
                                                   Div_CommActual__c,Div_CRMTarget__c,Div_NumberofChilds__c,
                                                   Div_CRMActual__c,Div_IRRMTarget__c,Div_IRRMActual__c,
                                                   Div_FXRetail__c,Div_FXRetailActual__c
                                                   from Division__c where ID IN  :divisionIdList]);
        regionRecordListforDivisions =           [Select Id,Region_Division__c,Region_FXDirectTarget__c,
                                                  Region_FXIndirectTarget__c,Region_FXRetail__c,Region_FXRetailActual__c,
                                                  Region_FXDirectActual__c,Region_FXIndirectActual__c,
                                                  Region_CommTarget__c,Region_CommActual__c,Region_CRMTarget__c,
                                                  Region_CRMActual__c,
                                                  Region_IRRMTarget__c,Region_IRRMActual__c from Region__c 
                                                  where Region_Division__c IN  :divisionIdList AND Region_Status__c =: System.Label.Active];
        
        
        
        //Iterate all the Captured division and Region records,
        //do the roll up for all matched Division under all region records .
        
        For(Division__c eachDivision :divisionMap.values())
        { 
            Division__c divisionValueInMap = divisionMap.get(eachDivision.Id);
            divisionValueInMap.Div_FXDirectTarget__c = 0;
            divisionValueInMap.Div_FXIndirectTarget__c = 0;
            divisionValueInMap.Div_FXDirectActual__c = 0;
            divisionValueInMap.Div_FXIndirectActual__c = 0;                    
            divisionValueInMap.div_CRMTarget__c = 0;
            divisionValueInMap.Div_CRMActual__c = 0;
            divisionValueInMap.div_CommTarget__c = 0;
            divisionValueInMap.Div_CommActual__c = 0;
            divisionValueInMap.div_IRRMTarget__c = 0;
            divisionValueInMap.Div_IRRMActual__c = 0;
            divisionValueInMap.Div_FXRetail__c   = 0;
            divisionValueInMap.Div_FXRetailActual__c = 0; 
            divisionValueInMap.Div_NumberofChilds__c = 0;
            For(Region__c eachRegion : regionRecordListforDivisions)
            {
                if(eachDivision.Id  == eachRegion.Region_Division__c)
                {
                    divisionValueInMap.Div_FXDirectTarget__c      =   divisionValueInMap.Div_FXDirectTarget__c +
                        eachRegion.Region_FXDirectTarget__c;
                    divisionValueInMap.Div_FXDirectActual__c      =   divisionValueInMap.Div_FXDirectActual__c+
                        eachRegion.Region_FXDirectActual__c;
                    divisionValueInMap.Div_FXIndirectTarget__c    =   divisionValueInMap.Div_FXIndirectTarget__c +
                        eachRegion.Region_FXIndirectTarget__c;
                    divisionValueInMap.Div_FXIndirectActual__c    =   divisionValueInMap.Div_FXIndirectActual__c+
                        eachRegion.Region_FXIndirectActual__c;   
                    divisionValueInMap.div_CRMTarget__c           =   divisionValueInMap.Div_CRMTarget__c +
                        eachRegion.Region_CRMTarget__c;
                    divisionValueInMap.Div_CRMActual__c           =   divisionValueInMap.Div_CRMActual__c+
                        eachRegion.Region_CRMActual__c;
                    divisionValueInMap.div_CommTarget__c          =   divisionValueInMap.Div_CommTarget__c+
                        eachRegion.Region_CommTarget__c;
                    divisionValueInMap.Div_CommActual__c          =   divisionValueInMap.Div_CommActual__c+
                        eachRegion.Region_CommActual__c;
                    divisionValueInMap.div_IRRMTarget__c          =   divisionValueInMap.Div_IRRMTarget__c+
                        eachRegion.Region_IRRMTarget__c;
                    divisionValueInMap.Div_IRRMActual__c          =   divisionValueInMap.Div_IRRMActual__c+
                        eachRegion.Region_IRRMActual__c;
                    divisionValueInMap.Div_FXRetail__c          =   divisionValueInMap.Div_FXRetail__c+
                        eachRegion.Region_FXRetail__c;                    
                    divisionValueInMap.Div_FXRetailActual__c          =   divisionValueInMap.Div_FXRetailActual__c+
                        eachRegion.Region_FXRetailActual__c;                    
                    divisionValueInMap.Div_NumberofChilds__c      =   divisionValueInMap.Div_NumberofChilds__c + 1;
                       
                    divisionMap.put(eachRegion.Region_Division__c, divisionValueInMap);                    
                }
            } 
        }         
        divisionListToUpdate = divisionMap.values();
        Database.SaveResult[] updateResult = Database.Update(divisionListToUpdate, False);  
    }
    
    public static void onAfterInsert(List<Region__c> regionRecordList)
    {
        List<Division__c> divisionListToUpdate = new List<Division__c>();
        List<Region__c> regionRecordListforDivisions = new List<Region__c>();
        List<Id>divisionIdList =  new List<Id>();
        Map<Id,Division__c>divisionMap ;
        
        // Capturing old and new Division Id for each updated Region        
        For(Region__c eachRegion : regionRecordList)
        {/*
            Region__c oldRegion = (Region__c)Trigger.oldMap.get(eachRegion.Id);            
            If(oldRegion.Region_Division__c!=eachRegion.Region_Division__c)
            {
                divisionIdList.add(oldRegion.Region_Division__c);
            }       
*/
            divisionIdList.add(eachRegion.Region_Division__c);            
            Division__c divisionRecordForEachTeam = new Division__c();
            divisionRecordForEachTeam.id = eachregion.Region_Division__c;            
        }              
        // Get all Division details and Region Details for captured Division Id list
        divisionMap     = New Map<Id,Division__c>([Select Id,Div_FXDirectTarget__c,Div_FXIndirectTarget__c,
                                                   Div_FXDirectActual__c,Div_FXIndirectActual__c,Div_CommTarget__c,
                                                   Div_CommActual__c,Div_CRMTarget__c,Div_NumberofChilds__c,
                                                   Div_CRMActual__c,Div_IRRMTarget__c,Div_IRRMActual__c,
                                                   Div_FXRetail__c,Div_FXRetailActual__c
                                                   from Division__c where ID IN  :divisionIdList]);
        regionRecordListforDivisions =           [Select Id,Region_Division__c,Region_FXDirectTarget__c,
                                                  Region_FXIndirectTarget__c,Region_FXRetail__c,Region_FXRetailActual__c,
                                                  Region_FXDirectActual__c,Region_FXIndirectActual__c,
                                                  Region_CommTarget__c,Region_CommActual__c,Region_CRMTarget__c,
                                                  Region_CRMActual__c,
                                                  Region_IRRMTarget__c,Region_IRRMActual__c from Region__c 
                                                  where Region_Division__c IN  :divisionIdList AND Region_Status__c =: System.Label.Active];
        
        
        
        //Iterate all the Captured division and Region records,
        //do the roll up for all matched Division under all region records .
        
        For(Division__c eachDivision :divisionMap.values())
        { 
            Division__c divisionValueInMap = divisionMap.get(eachDivision.Id);
            divisionValueInMap.Div_FXDirectTarget__c = 0;
            divisionValueInMap.Div_FXIndirectTarget__c = 0;
            divisionValueInMap.Div_FXDirectActual__c = 0;
            divisionValueInMap.Div_FXIndirectActual__c = 0;                    
            divisionValueInMap.div_CRMTarget__c = 0;
            divisionValueInMap.Div_CRMActual__c = 0;
            divisionValueInMap.div_CommTarget__c = 0;
            divisionValueInMap.Div_CommActual__c = 0;
            divisionValueInMap.div_IRRMTarget__c = 0;
            divisionValueInMap.Div_IRRMActual__c = 0;
            divisionValueInMap.Div_FXRetail__c   = 0;
            divisionValueInMap.Div_FXRetailActual__c = 0; 
            divisionValueInMap.Div_NumberofChilds__c = 0;
            For(Region__c eachRegion : regionRecordListforDivisions)
            {
                if(eachDivision.Id  == eachRegion.Region_Division__c)
                {
                    divisionValueInMap.Div_FXDirectTarget__c      =   divisionValueInMap.Div_FXDirectTarget__c +
                        eachRegion.Region_FXDirectTarget__c;
                    divisionValueInMap.Div_FXDirectActual__c      =   divisionValueInMap.Div_FXDirectActual__c+
                        eachRegion.Region_FXDirectActual__c;
                    divisionValueInMap.Div_FXIndirectTarget__c    =   divisionValueInMap.Div_FXIndirectTarget__c +
                        eachRegion.Region_FXIndirectTarget__c;
                    divisionValueInMap.Div_FXIndirectActual__c    =   divisionValueInMap.Div_FXIndirectActual__c+
                        eachRegion.Region_FXIndirectActual__c;   
                    divisionValueInMap.div_CRMTarget__c           =   divisionValueInMap.Div_CRMTarget__c +
                        eachRegion.Region_CRMTarget__c;
                    divisionValueInMap.Div_CRMActual__c           =   divisionValueInMap.Div_CRMActual__c+
                        eachRegion.Region_CRMActual__c;
                    divisionValueInMap.div_CommTarget__c          =   divisionValueInMap.Div_CommTarget__c+
                        eachRegion.Region_CommTarget__c;
                    divisionValueInMap.Div_CommActual__c          =   divisionValueInMap.Div_CommActual__c+
                        eachRegion.Region_CommActual__c;
                    divisionValueInMap.div_IRRMTarget__c          =   divisionValueInMap.div_IRRMTarget__c+
                        eachRegion.Region_IRRMTarget__c;
                    divisionValueInMap.Div_IRRMActual__c          =   divisionValueInMap.Div_IRRMActual__c+
                        eachRegion.Region_IRRMActual__c;
                    divisionValueInMap.Div_FXRetail__c          =   divisionValueInMap.Div_FXRetail__c+
                        eachRegion.Region_FXRetail__c;                    
                    divisionValueInMap.Div_FXRetailActual__c          =   divisionValueInMap.Div_FXRetailActual__c+
                        eachRegion.Region_FXRetailActual__c;                                    
                    
                    divisionValueInMap.Div_NumberofChilds__c      =   divisionValueInMap.Div_NumberofChilds__c + 1;
                       
                    divisionMap.put(eachRegion.Region_Division__c, divisionValueInMap);                    
                }
            } 
        }         
        divisionListToUpdate = divisionMap.values();
        Database.SaveResult[] updateResult = Database.Update(divisionListToUpdate, False);  
    }
}