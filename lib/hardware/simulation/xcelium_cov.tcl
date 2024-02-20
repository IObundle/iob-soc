load -refinement iob_cov_waiver.vRefine
report -summary -inst -metrics all -covered -cumulative on -grading covered -out coverage_report_summary.rpt
report -detail -inst -metrics all -source on -out coverage_report_detail.rpt
report_metrics -summary -out report_metrics_summary
report_metrics -detail -all -inst *... -out report_metrics_detail
