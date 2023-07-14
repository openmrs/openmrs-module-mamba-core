-- $BEGIN
-- TODO: put this in config file

INSERT INTO mamba_dim_report_definition (report_id,
                                         report_procedure_name,
                                         report_name)
VALUES ('mother_hiv_status', 'sp_mamba_pmtct_mother_hiv_status_query', 'PMTCT Mother HIV Status'),
       ('total_deliveries', 'sp_mamba_pmtct_total_deliveries_query', 'PMTCT Deliveries Total'),
       ('hiv_exposed_infants', 'sp_mamba_pmtct_hiv_exposed_infants_query', 'PMTCT HIV Exposed Infants Total'),
       ('total_pregnant_women', 'sp_mamba_pmtct_pregnant_women_query', 'PMTCT Pregnant Women Total');

-- $END