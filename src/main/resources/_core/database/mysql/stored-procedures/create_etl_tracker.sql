CREATE TABLE zzmamba_etl_tracker
(
    etl_tracker_id           INT                             NOT NULL AUTO_INCREMENT,
    initial_run_date         DATETIME                        NOT NULL,
    start_date               DATETIME                        NOT NULL,
    end_date                 DATETIME                        NOT NULL,
    time_taken_microsec      BIGINT                          NOT NULL,
    completion_status        CHAR(10) CHARACTER SET UTF8  NOT NULL,
    success_or_error_message CHAR(255) CHARACTER SET UTF8 NOT NULL,
    next_run_date            DATETIME                        NOT NULL,
    PRIMARY KEY (etl_tracker_id)
);