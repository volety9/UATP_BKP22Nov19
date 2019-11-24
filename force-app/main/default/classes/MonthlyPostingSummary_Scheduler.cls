/*
@Author        : Suhas
@Name          : MonthlyPostingSummary_Scheduler 
@Created Date  : 21st March 2018
@Description   : This is a Schedule class for MonthlyPostingSummary_Batch
@version       : 1.0
*/
global class MonthlyPostingSummary_Scheduler implements Schedulable { 
/**
* @description       Method to Schedule a MonthlyPostingSummary_Batch Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/ 
    global void execute(SchedulableContext ctx) {
        MonthlyPostingSummaryCls monthlyPostingSummaryRef = new MonthlyPostingSummaryCls();
        monthlyPostingSummaryRef.execute(ctx);
    }
    
}