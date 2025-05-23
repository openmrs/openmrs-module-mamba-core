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

import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class DbEventConsumerImpl implements EventConsumer {

    private static final Logger logger = LoggerFactory.getLogger(DbEventConsumerImpl.class);

    @Override
    public void accept(DbEvent dbEvent) {

        if (dbEvent.isSchemaEvent()) {

            DbSchemaEvent event = (DbSchemaEvent) dbEvent;
            logger.debug("DEBEZIUM Processing DbSchemaEvent - Operation: " + event.getOperation());

        } else {

            DbCrudEvent event = (DbCrudEvent) dbEvent;

            Integer primaryKey = event.getPrimaryKey().getInteger("id");
            String tableName = event.getTableName();
            DbOperation operation = event.getOperation();

            logger.debug("DEBEZIUM Processing DbSchemaEvent Table affected: " + event.getTableName()
                    + " - Operation: " + event.getOperation());

            switch (operation) {
                case CREATE:
                case UPDATE:
                case DELETE:
                    DataSource dataSource = ConnectionPoolManager
                            .getInstance()
                            .getEtlDataSource();

                    try (Connection connection = dataSource.getConnection();
                         CallableStatement statement = connection.prepareCall("{CALL sp_mamba_etl_database_event_insert(?,?,?)}")) {
                        statement.setInt("incremental_table_pkey", primaryKey);
                        statement.setString("table_name", tableName);
                        statement.setString("database_operation", operation.name());
                        statement.execute();
                    } catch (SQLException e) {
                        logger.error("Error updating _mamba_etl_database_event table: ", e);
                    }
                    break;

                default:
                    break;
            }
        }
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
