/*
@Author        : Santhoshan
@Name          : CalypsoDataProcess_VFP_Controller_Test
@Created Date  : 10th Jun 2018
@Description   : This is a Test Class for CalypsoDataProcess_VFP_Controller
@version       : 1.0
*/
@isTest
public class CalypsoDataProcess_VFP_Controller_Test {
	static testMethod void testclass(){
        CalypsoDataProcess_VFP_Controller cntrlr= new CalypsoDataProcess_VFP_Controller();
        cntrlr.updateCalypso();
    }
}