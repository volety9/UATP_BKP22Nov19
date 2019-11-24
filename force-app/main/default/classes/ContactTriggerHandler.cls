/*
  @Author        : SUHAS BARGI
  @Name          : ContactTriggerHandler
  @Created Date  : 30th MARCH 2018
  @Description   : TriggerHandler for ContactTrigger
  @version       : 1.0
*/ 
public class ContactTriggerHandler {
    
    
    /**
* @description       To set First Name, Last Name & Customer Banking Centre
* @name              onBeforeInsert
* @param             List<Contact>
* @return            void
* @throws            NA
*/ 
    public static void onBeforeInsert(List<Contact> contactDataList) { 

        Map<String,String> CustNameMap = new Map<String,String>();
        For(Customer_Name__mdt eachCustName : [SELECT ID,Customer_Type__c,CustomerName__c FROM Customer_Name__mdt])
        {
            CustNameMap.put((String)eachCustName.CustomerName__c.trim(), (String)eachCustName.Customer_Type__c);
            
        }
        
        for(Contact eachCData : contactDataList){
            
                if(eachCData.TDM_Name__c != null){
                    if(eachCData.TDM_Name__c.lastIndexOf(' ') !=null && eachCData.TDM_Name__c.lastIndexOf(' ')>0){
                        Integer lastIndex = eachCData.TDM_Name__c.lastIndexOf(' ');            
                        eachCData.FirstName = eachCData.TDM_Name__c.substring(0, lastIndex);
                        eachCData.MiddleName='';
                        if(eachCData.TDM_Name__c.substring(eachCData.TDM_Name__c.lastIndexOf(' ')+1) !=null){
                            eachCData.LastName = eachCData.TDM_Name__c.substring(eachCData.TDM_Name__c.lastIndexOf(' ')+1);
                        }
                    }else{ 
                        eachCData.LastName =eachCData.TDM_Name__c;
                        eachCData.FirstName ='';
                        eachCData.MiddleName='';
                    }
                    eachCData.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
                }else if(eachCData.LastName == null){
                    eachCData.LastName='Reserved Banker';
                    eachCData.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
                }
            if(eachCData.Customer_Banking_Centre__c != Null || eachCData.TDM_BankingCenter__c != Null)
            	eachCData.Customer_Banking_Centre__c = (eachCData.TDM_BankingCenter__c==Null?eachCData.Customer_Banking_Centre__c:eachCData.TDM_BankingCenter__c);
            else
                eachCData.Customer_Banking_Centre__c = null;
            
            eachCData.Contact_Status__c='Active';
            if(eachCData.TDM_Cust_Name__c!=null && ! CustNameMap.isEmpty() && CustNameMap.containsKey(eachCData.TDM_Cust_Name__c.trim())){
                eachCData.AccountId=(Id)CustNameMap.get(eachCData.TDM_Cust_Name__c.trim());
            }

            eachCData.TDM_Name__c='';
            eachCData.TDM_BankingCenter__c='';
            eachCData.TDM_Cust_Name__c='';
        }
    }
    /**
* @description       To Update First Name, Last Name & Customer Banking Centre
* @name              onBeforeUpdate
* @param             List<Contact>
* @return            void
* @throws            NA
*/
    public static void onBeforeUpdate(List<Contact> contactDataList) { 
        Map<String,String> CustNameMap = new Map<String,String>();
        For(Customer_Name__mdt eachCustName : [SELECT ID,Customer_Type__c,CustomerName__c FROM Customer_Name__mdt])
        {
            CustNameMap.put((String)eachCustName.CustomerName__c.trim(), (String)eachCustName.Customer_Type__c);
            
        }

     	for(Contact eachCData : contactDataList){

            if(eachCData.TDM_Name__c != null){
                if(eachCData.TDM_Name__c.lastIndexOf(' ') !=null && eachCData.TDM_Name__c.lastIndexOf(' ')>0){
                    Integer lastIndex = eachCData.TDM_Name__c.lastIndexOf(' ');            
                    eachCData.FirstName = eachCData.TDM_Name__c.substring(0, lastIndex);
                    eachCData.MiddleName='';
                    if(eachCData.TDM_Name__c.substring(eachCData.TDM_Name__c.lastIndexOf(' ')+1) !=null){
                    eachCData.LastName = eachCData.TDM_Name__c.substring(eachCData.TDM_Name__c.lastIndexOf(' ')+1);
                    }
                }else{
                    eachCData.LastName =eachCData.TDM_Name__c;
                    eachCData.FirstName ='';
                    eachCData.MiddleName='';
                }
            }
            if(eachCData.Customer_Banking_Centre__c != Null || eachCData.TDM_BankingCenter__c != Null)
            	eachCData.Customer_Banking_Centre__c = (eachCData.TDM_BankingCenter__c==Null?eachCData.Customer_Banking_Centre__c:eachCData.TDM_BankingCenter__c);
            else
                eachCData.Customer_Banking_Centre__c = Null;
            if(eachCData.TDM_Cust_Name__c!=null && ! CustNameMap.isEmpty() && CustNameMap.containsKey(eachCData.TDM_Cust_Name__c.trim())){


            }

            eachCData.TDM_Name__c='';
            eachCData.TDM_BankingCenter__c='';
            eachCData.TDM_Cust_Name__c='';
        }
    }

}