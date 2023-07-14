-- $BEGIN
-- TODO: put this in config file

INSERT INTO mamba_dim_report_definition (report_id,
                                         report_procedure_name,
                                         report_name)
VALUES ('pmtct_mother_hiv_status', 'sp_mamba_pmtct_mother_hiv_status_query', 'PMTCT Mother HIV Status');

-- $END