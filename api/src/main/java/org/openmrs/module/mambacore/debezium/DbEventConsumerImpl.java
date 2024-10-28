/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.debezium;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.BaseOpenmrsData;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Objects;

public class DbEventConsumerImpl implements EventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(DbEventConsumerImpl.class);

    @Override
    public void accept(DbEvent dbEvent) {

        if (dbEvent.isSchemaEvent()) {

            DbSchemaEvent event = (DbSchemaEvent) dbEvent;
            logger.debug("DEBEZIUM Processing DbSchemaEvent - Operation: " + event.getOperation());

        } else {

            DbCrudEvent event = (DbCrudEvent) dbEvent;
            logger.debug("DEBEZIUM Processing DbSchemaEvent Table affected: " + event.getTableName()
                    + " - Operation: " + event.getOperation());

            //TODO: Process transactions in batches instead of single table events
            //sp_mamba_etl_database_event_insert(
            //    IN incremental_table_pkey INT,
            //    IN table_name VARCHAR(100),
            //    IN database_operation ENUM ('CREATE', 'UPDATE', 'DELETE')
            //)


//            DbEventTable table = DbEventTable.convertToEnum(event.getTableName());
//            DbOperation operation = event.getOperation();
//
//            switch (table) {
//                case OBS:
//                    if (Objects.requireNonNull(operation) == DbOperation.CREATE) {
//
//                        Obs transaction = (Obs) getNewDbObject(event, Obs.class);
//
//                    }
//
//                    break;
//                case ENCOUNTER:
//                    Encounter transaction = (Encounter) getNewDbObject(event, Encounter.class);
//
//                    break;
//                default:
//                    logger.debug("Ayinza Processing Unknown Table Event: " + event + " - Operation: " + operation);
//            }

            DataSource dataSource = ConnectionPoolManager
                    .getInstance()
                    .getEtlDataSource();

            try (Connection connection = dataSource.getConnection();
                 CallableStatement statement = connection.prepareCall("{CALL sp_mamba_incremental_batch_update(?)}")) {


                boolean hasResults = statement.execute();
                while (hasResults) {
                    ResultSet resultSet = statement.getResultSet();
                    while (resultSet.next()) {

                    }
                    hasResults = statement.getMoreResults();
                }
            } catch (SQLException e) {

            }
        }
    }

    private BaseOpenmrsData getNewDbObject(DbCrudEvent event, Class<? extends BaseOpenmrsData> clazz) {
        ObjectMap createObject = event.getNewState();
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.convertValue(createObject, clazz);
    }

    @Override
    public void preStartup() {
        EventConsumer.super.preStartup();
    }

    @Override
    public void preShutdown() {
        EventConsumer.super.preShutdown();
    }

    @Override
    public void preReset() {
        EventConsumer.super.preReset();
    }
}
