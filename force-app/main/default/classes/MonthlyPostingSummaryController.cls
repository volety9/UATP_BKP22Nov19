/*
@Author        : Suhas
@Name          : MonthlyPostingSummaryController 
@Created Date  : 26th March 2018
@Description   : This is a Controller class for Monthly Postal Summary 
@version       : 1.0
*/

public class MonthlyPostingSummaryController {
    
   public transient Id  MPSId;
   public  MonthlyPostingSummary__c mpsDetails{get; set;}
   
    
    public ApexPages.StandardController stdCntrlr {get; set;}
   
    public MonthlyPostingSummaryController(ApexPages.StandardController controller) {	
        
         stdCntrlr = controller;
         MPSId = controller.getRecord().id;
       mpsDetails = new MonthlyPostingSummary__c();

        mpsDetails = getMPSDetails();

        if(mpsDetails.MPS_Status__c=='Published'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Monthly Postal Summary has been Published. Cannot be published again'));
        }
    }
    
    //This Method returns Monthly Posting Summary with 
    public MonthlyPostingSummary__c getMPSDetails(){
         mpsDetails = [SELECT Id,Name,MPS_Fiscal_Year__c,MPS_Publish_Date__c,MPS_Status__c,MPS_Total_CB_Posting_Amount__c,MPS_Total_YB_Posting_Amount__c,MPS_Month__c,MPS_Current_Posting_Month__c,
                       (SELECT Name, PLI_Amount__c,PLI_Corporate_Code__c,PLI_Cost_Centre__c,PLI_Cr_Dr__c,PLI_Description__c,PLI_GL_Account__c,MonthlyPostingSummary__c FROM PostingLineItems__r) FROM MonthlyPostingSummary__c
                       WHERE Id=:MPSId];
        return mpsDetails;
        
    }
    
     public PageReference FileExport()
     {
         Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',
             6 => 'June',7 => 'July',8 => 'August',9 => 'Sept',10 => 'October',11 => 'November',12 => 'December'};
                 
                 if(Integer.valueOf(mpsDetails.MPS_Month__c)==System.today().Month()){
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,' Monthly Postal Summary has to be published after End of Month.'));
                     return null;
                 }else{
                     List<PostingLineItem__c> postingList = mpsDetails.PostingLineItems__r;
                     String  generatedCSVFileCB = '';
                     String  generatedCSVFileYB = '';
                     
                     String  fileHeader = '';
                     
                     String  fileRowCB = '';
                     String  fileRowYB = '';
                     
                     Id monthlyPostingSummaryCB;
                     //Id monthlyPostingSummaryYB;
                     
                     fileHeader = 'CORP' + '\t' + 'CC' + '\t' + 'GL A/C NO:' + '\t' + 'DESCRIPTION' + '\t' + 'AMTS' + '\t' + '0' + '\n';
                     

                     for(PostingLineItem__c eachPLI : postingList){
                         if(eachPLI.PLI_Corporate_Code__c == label.EOM_CB_Corp_Code)
                         {
                             
                             String cCode='\''+eachPLI.PLI_Corporate_Code__c;
                             String cCenter='\'' + eachPLI.PLI_Cost_Centre__c;
                             String gLAccount='\''+eachPLI.PLI_GL_Account__c;
                             Decimal pLIAmt = eachPLI.PLI_Amount__c.setScale(2);
                             Decimal dScale = pLIAmt - (long)pLIAmt;   
                             String pLIAmtStr = String.valueOf(pLIAmt);
                            /* if(!((dScale>0) || (dScale*(-1)>0))){

                                 pLIAmtStr = '="'+pLIAmtStr+'"'; 
                             }           */ 
                             
                             fileRowCB = fileRowCB + cCode + '\t'+cCenter  +'\t' 
                                 + gLAccount + '\t' + eachPLI.PLI_Description__c + '\t' + pLIAmtStr + '\t' + 
                                 eachPLI.PLI_Cr_Dr__c + '\n';

                             //monthlyPostingSummaryCB = eachPLI.MonthlyPostingSummary__c;
                         }
                         else if(eachPLI.PLI_Corporate_Code__c == label.EOM_YB_Corp_Code)
                         {
                             
                             String cCode='\''+eachPLI.PLI_Corporate_Code__c;
                             String cCenter='\'' + eachPLI.PLI_Cost_Centre__c;
                             String gLAccount='\''+eachPLI.PLI_GL_Account__c;
                             Decimal pLIAmt = eachPLI.PLI_Amount__c.setScale(2);
                             Decimal dScale = pLIAmt - (long)pLIAmt;
                             String pLIAmtStr = String.valueOf(pLIAmt);
                             /*if(!((dScale>0) || (dScale*(-1)>0))){

                                 pLIAmtStr = '="'+pLIAmtStr+'"'; 
                             } */
                             fileRowYB = fileRowYB + cCode + '\t' + cCenter +'\t'
                                 + gLAccount + '\t' + eachPLI.PLI_Description__c + '\t' + pLIAmtStr + '\t' + 
                                 eachPLI.PLI_Cr_Dr__c + '\n';
                             //monthlyPostingSummaryYB = eachPLI.MonthlyPostingSummary__c;
                         }
                     }
                     
                     generatedCSVFileCB = fileHeader + fileRowCB.toUpperCase();
                     generatedCSVFileYB = fileHeader + fileRowYB.toUpperCase();
                     
                     if(!String.isBlank(fileRowCB))
                     {
                         Attachment attachmentCB = new Attachment();
                         attachmentCB.Body = Blob.valueOf(generatedCSVFileCB);
                         
                         attachmentCB.Name = String.valueOf('CB Treasury Solns Jrnl '+(monthMap.get(Integer.valueOf(mpsDetails.MPS_Month__c))).left(3)+' '+(mpsDetails.Name).right(2)+'.xls');
                         attachmentCB.ParentId = MPSId; 
                         insert attachmentCB;
                         
                     }
                     
                     
                     
                     if(!String.isBlank(fileRowYB))
                     {
                         
                         
                         Attachment attachmentYB = new Attachment();
                         attachmentYB.Body = Blob.valueOf(generatedCSVFileYB);
                         attachmentYB.Name = String.valueOf('YB Treasury Solns Jrnl '+(monthMap.get(Integer.valueOf(mpsDetails.MPS_Month__c))).left(3)+' '+(mpsDetails.Name).right(2)+'.xls');
                         attachmentYB.ParentId = MPSId; 
                         insert attachmentYB;
                         
                     }
                     
                     mpsDetails.MPS_Publish_Date__c=System.today();
                     mpsDetails.MPS_Status__c='Published';
                     mpsDetails.MPS_Current_Posting_Month__c=false;
                     
                     update mpsDetails;
                     
                     Integer  nextMonth;
                     if(Integer.valueOf(mpsDetails.MPS_Month__c)<12){
                         nextMonth=Integer.valueOf(mpsDetails.MPS_Month__c)+1;
                     }else{
                         nextMonth=1;   
                     }
                     
                     List<MonthlyPostingSummary__c> monthlyPostingSummaryRecords = new List<MonthlyPostingSummary__c>([Select Id,Name,MPS_Fiscal_Year__c, MPS_Publish_Date__c,MPS_Status__c,MPS_Total_CB_Posting_Amount__c,
                                                                                                                       MPS_Total_YB_Posting_Amount__c,MPS_Current_Posting_Month__c,MPS_Month__c From MonthlyPostingSummary__c 
                                                                                                                       where MPS_Month__c= :nextMonth AND MPS_Status__c='Not Published'
                                                                                                                       ORDER BY MPS_Fiscal_Year__c ASC]);
                     
                     if(!monthlyPostingSummaryRecords.isEmpty()){
                         MonthlyPostingSummary__c monthlyPostingSummaryRecord = monthlyPostingSummaryRecords.get(0);
                         monthlyPostingSummaryRecord.MPS_Current_Posting_Month__c=true;
                         update monthlyPostingSummaryRecord;
                     }   
                     PageReference pg = new PageReference('/apex/MonthlyPostingSummary_VF?id='+mpsDetails.Id);        
                     pg.setRedirect(true);
                     return pg;
                 }
        
    }
    
    public PageReference cancelPublish()
    {

            Schema.DescribeSObjectResult result = MonthlyPostingSummary__c.SObjectType.getDescribe(); 
            PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o'); 
            pageRef.setRedirect(true); 
            return pageRef; 

        
    }
    
}