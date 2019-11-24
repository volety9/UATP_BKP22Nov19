/*
@Author        : Sandeep
@Name          : ReportRep_Sched_PSD2
@Created Date  : 6th Aug 2019
@Updated Date  : 13th Aug 2019
@Description   : This is a Schedule class for ReportRep_Batch_ReDesign
@version       : 1.0
*/
global class ReportRep_Sched_PSD2 implements Schedulable{    
    
    global void execute (SchedulableContext ctx){        
        ReportRep_Delete_Repository_PSD2 reportRepDelRepository = new ReportRep_Delete_Repository_PSD2();        
        Database.executeBatch(reportRepDelRepository,100);
    }
}