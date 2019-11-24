/*
  @Author        : Sushant
  @Name          : AccountComplianceMergeController
  @Created Date  : 10th July 2017
  @Description   : Controller class for VFP_AccountComplianceMerge page
                   merge the compliance records attached to a particular account
  @version       : 1.0
*/ 

public class AccountComplianceMergeController {
    private final Account relatedAccount;
    public boolean showMerge {get; set;}
    public boolean showAllRecords {get;Set;}
    Compliance__c selectedRec1;
    Compliance__c selectedRec2;
    @TestVisible List<ComplianceWrapper> complianceWrapperList {get; set;}    
    @TestVisible public List<SelectedComplianceWrapper> selectedCompWrapList {get; set;}
    List<ID> selectedCompList;
    public AccountComplianceMergeController(ApexPages.StandardController controller) {
        this.relatedAccount = (Account)controller.getRecord();
        showMerge = false;
        showAllRecords = true;        
    }
    
    /**
     * @description       Method to get the all the compliance records attached to account and convert it to ComplianceWrapper records
     * @name              getComplianceWrapperList
     * @param             None
     * @return            List<ComplianceWrapper>     
     */     
    public List<ComplianceWrapper> getComplianceWrapperList(){
        complianceWrapperList = new List<ComplianceWrapper>();
        List<Compliance__c> compList = new List<Compliance__c>();
        compList = [select Id, Name, Customer__c, Customer__r.Name from Compliance__c where Customer__c =: relatedAccount.id ORDER BY Name DESC limit 50];
        for(Compliance__c compliance : compList )
        {
            complianceWrapperList.add(new ComplianceWrapper(compliance));
        }        
        return complianceWrapperList;
    }   
    /**
     * @description       Method to get the selected ComplianceWrapper records and convert it to SelectedComplianceWrapper records
     * @name              next
     * @param             None
     * @return            PageReference     
     */ 
    
    public PageReference next(){  
        selectedCompList = new List<ID>();      
        for (ComplianceWrapper cw : complianceWrapperList) {
             if(cw.checked){
                 selectedCompList.add(cw.comp.id);
             }
         }
         if(!(selectedCompList.size() == 2))
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.MergeCompSelectError));
         else{
             showMerge = true;
             showAllRecords = false;
             selectedCompWrapList = new List<SelectedComplianceWrapper>();
             List<Compliance__c> compList = new List<Compliance__c>();        
             compList =  [select Id, Name, Date_Provided__c, How_Provided__c, Compliance_Reason__c, Comment__c 
                          from Compliance__c where ID IN:selectedCompList ORDER BY Name DESC limit 2 ];        
             selectedRec1 = compList[0];
             selectedRec2 = compList[1];
             SelectedComplianceWrapper newCompWrap1 = new SelectedComplianceWrapper(System.Label.MasterRecord, selectedRec1.Name, selectedRec2.Name);
             selectedCompWrapList.add(newCompWrap1); 
             SelectedComplianceWrapper newCompWrap2 = new SelectedComplianceWrapper(System.Label.DateProvided, string.valueOf(selectedRec1.Date_Provided__c), string.valueOf(selectedRec2.Date_Provided__c));
             selectedCompWrapList.add(newCompWrap2);
             SelectedComplianceWrapper newCompWrap3 = new SelectedComplianceWrapper(System.Label.HowProvided, selectedRec1.How_Provided__c, selectedRec2.How_Provided__c);
             selectedCompWrapList.add(newCompWrap3);
             SelectedComplianceWrapper newCompWrap4 = new SelectedComplianceWrapper(System.Label.ComplianceReason, selectedRec1.Compliance_Reason__c, selectedRec2.Compliance_Reason__c);
             selectedCompWrapList.add(newCompWrap4);
             SelectedComplianceWrapper newCompWrap5 = new SelectedComplianceWrapper(System.Label.Comment, selectedRec1.Comment__c, selectedRec2.Comment__c);
             selectedCompWrapList.add(newCompWrap5);    
         }     
         return Null;
    } 
    
    /**
     * @description       Method to merge the SelectedComplianceWrapper records in the Master Compliance record
     * @name              mergeComp
     * @param             None
     * @return            PageReference     
     */ 
    
    public PageReference mergeComp(){
        showMerge = true;
        showAllRecords = false;
        Compliance__c masterRecord = new Compliance__c();
        Compliance__c childRecord = new Compliance__c();
        for(SelectedComplianceWrapper eachRow : selectedCompWrapList){  
            if(eachRow.label.equals(System.Label.MasterRecord) && ((eachRow.parentSelected == true && eachRow.childSelected== true ) || (eachRow.parentSelected == False && eachRow.childSelected==False))){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,System.Label.MergeCompMasterSelectErrorMsg));
                return Null;
            }                     
            if(eachRow.label.equals(System.Label.MasterRecord)){
                if(eachRow.parentSelected){
                    masterRecord = selectedRec1;
                    childRecord = selectedRec2;
                }
                else{
                    masterRecord = selectedRec2;
                    childRecord = selectedRec1;
                }
            }
            if(eachRow.label.equals(System.Label.DateProvided)){
                string dateProvided;
                if(eachRow.parentSelected && String.isNotEmpty(eachRow.parentValue))                    
                    dateProvided = eachRow.parentValue;
                if(eachRow.childSelected && String.isNotEmpty(eachRow.childValue))                    
                    dateProvided = eachRow.childValue;
                if(String.isNotEmpty(dateProvided))
                    masterRecord.Date_Provided__c = date.valueOf(dateProvided);
                else
                    masterRecord.Date_Provided__c = Null;
            }
            if(eachRow.label.equals(System.Label.HowProvided)){
                if(eachRow.parentSelected)
                    masterRecord.How_Provided__c = eachRow.parentValue;                   
                if(eachRow.childSelected)
                    masterRecord.How_Provided__c = eachRow.childValue;                                  
            }
            if(eachRow.label.equals(System.Label.ComplianceReason)){
                if(eachRow.parentSelected)
                    masterRecord.Compliance_Reason__c = eachRow.parentValue;
                if(eachRow.childSelected)
                    masterRecord.Compliance_Reason__c = eachRow.childValue;
            }
            if(eachRow.label.equals(System.Label.Comment)){
                if(eachRow.parentSelected)
                    masterRecord.Comment__c = eachRow.parentValue;
                if(eachRow.childSelected)
                    masterRecord.Comment__c = eachRow.childValue;
            }            
        } 
        try{ 
            update masterRecord;//updating a single record
        }
        Catch(DMLException excep){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,excep.getMessage()));
            return Null;
        }        
        List<Attachment> childRecAttach = [select id, Name, OwnerId, Body,IsPrivate, ParentId from Attachment where parentId=:childRecord.id];
        List<Attachment> insertList = new List<Attachment>();
        if(!childRecAttach.isEmpty()){
            for(Attachment eachAttach : childRecAttach){
                Attachment attach = new Attachment();
                attach.Name = eachAttach.Name;
                attach.OwnerId = eachAttach.OwnerId;
                attach.IsPrivate = eachAttach.IsPrivate;
                attach.Body = eachAttach.Body;
                attach.ParentId = masterRecord.id;
                insertList.add(attach);
            }
            try{
                insert insertList;
                //this will always have values if childRecAttach is not empty
                //inserting all or none
            }
            Catch(DMLException excep){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,excep.getMessage()));
                return Null;
            }
        }
        try{ 
            delete childRecord;//Deleting a single record
        }
        Catch(DMLException excep){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,excep.getMessage()));
            return Null;
        }
        return new PageReference('/'+relatedAccount.id);   
    }
    
    /**
     * @description       Method to merge all compliance records with matching names for an account
     * @name              mergeAllComp
     * @param             None
     * @return            PageReference     
     */ 
    
    Public PageReference mergeAllComp(){
        List<Compliance__c> compList = new List<Compliance__c>();
        compList = [select Id, Name, CreatedDate from Compliance__c where Customer__c =: relatedAccount.id ORDER BY CreatedDate DESC limit 500];
        if(!compList.isEmpty()){
            set<Compliance__c> allChildDeleteList = new set<Compliance__c>();
            map<id,set<id>> parentChildMap = new map<id,set<id>>();
            set<string> uniqueCompNames = new set<string>();
            set<id> childIDsSet;
            for(Integer i=0; i<compList.size(); i++){
                if(!uniqueCompNames.contains(compList[i].Name)){
                    uniqueCompNames.add(compList[i].Name);
                    childIDsSet = new set<id>();
                    for(Integer j=1; j<compList.size(); j++){
                        if((compList[i].Name == compList[j].Name) && (compList[i].id != compList[j].id)){
                            childIDsSet.add(compList[j].id);
                            allChildDeleteList.add(compList[j]);
                        }
                    }
                    parentChildMap.put(compList[i].id, childIDsSet);
                }                
            }
            List<Id> compIDList = new List<ID>();
            for(Compliance__c eachComp : compList){
                compIDList.add(eachComp.id);
            }
            List<Attachment> allAttachList = new List<Attachment>();
            allAttachList = [select id, Name, OwnerId, Body,IsPrivate, ParentId from Attachment where parentId IN:compIDList];
            if(!allAttachList.isEmpty()){
                List<Attachment> attachInsertList = new List<Attachment>();
                for(Id eachParentID : parentChildMap.keySet()){
                    for(Attachment eachAttach : allAttachList){
                        if(parentChildMap.get(eachParentID).contains(eachAttach.parentId)){
                            Attachment attach = new Attachment();
                            attach.Name = eachAttach.Name;
                            attach.OwnerId = eachAttach.OwnerId;
                            attach.IsPrivate = eachAttach.IsPrivate;
                            attach.Body = eachAttach.Body;
                            attach.ParentId = eachParentID;
                            attachInsertList.add(attach);
                        }
                    }
                }
                if(!attachInsertList.isEmpty()){
                    try{
                        insert attachInsertList;
                    }
                    Catch(DMLException excep){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,excep.getMessage()));
                        return Null;
                    }
                }                
            }  
            if(!allChildDeleteList.isEmpty()){
                try{
                    List<Compliance__c> deleteCompList = new List<Compliance__c>();
                    deleteCompList.addall(allChildDeleteList);
                    delete deleteCompList;
                }
                Catch(DMLException excep){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,excep.getMessage()));
                    return Null;
                }
            }          
        }
        return new PageReference('/'+relatedAccount.id);
    }
    
}