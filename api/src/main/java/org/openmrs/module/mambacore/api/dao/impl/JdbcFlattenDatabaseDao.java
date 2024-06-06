/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.dao.impl;

import org.openmrs.api.context.Context;
import org.openmrs.module.mambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Objects;
import java.util.stream.Collectors;

public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcMambaReportItemDao.class);

    @Override
    public void executeFlatteningScript() {

        long scheduleInterval = Long.parseLong(Context.getAdministrationService().getGlobalProperty("mambaetl.schedule.interval.minutes"));

        try (InputStream stream = JdbcFlattenDatabaseDao.class.getResourceAsStream("/_core/database/mysql/events/mamba_etl_scheduler.sql")) {

            String eventSchedulerSQL = new BufferedReader(new InputStreamReader(Objects.requireNonNull(stream)))
                    .lines()
                    .collect(Collectors.joining("\n"));

            eventSchedulerSQL = eventSchedulerSQL.replaceAll("--.*(?=\\n)", "");

            DataSource dataSource = ConnectionPoolManager
                    .getInstance()
                    .getDataSource();

            try (Connection connection = dataSource.getConnection();
                 PreparedStatement statement = connection.prepareStatement(connection.nativeSQL(eventSchedulerSQL))) {

                statement.setLong(1, scheduleInterval);
                statement.execute();
                log.info("MambaETL Event Scheduler Created");

            } catch (SQLException e) {
                log.error("SQLException executing script", e);
            }
        } catch (IOException e) {
            log.error("IOException executing script", e);
        }
    }
}
