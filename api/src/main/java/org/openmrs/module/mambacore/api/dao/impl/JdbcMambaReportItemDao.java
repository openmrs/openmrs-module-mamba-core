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

import com.fasterxml.jackson.databind.ObjectMapper;
import org.openmrs.module.mambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.mambacore.api.model.MambaReportItem;
import org.openmrs.module.mambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.mambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.mambacore.db.ConnectionPoolManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcMambaReportItemDao implements MambaReportItemDao {

    private static final Logger log = LoggerFactory.getLogger(JdbcMambaReportItemDao.class);

    @Override
    public List<MambaReportItem> getMambaReport(String mambaReportId) {
        return getMambaReport(new MambaReportCriteria(mambaReportId));
    }

    @Override
    public List<MambaReportItem> getMambaReport(MambaReportCriteria criteria) {
        String argumentsJson = "";
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            argumentsJson = objectMapper.writeValueAsString(criteria.getSearchFields());
            log.debug("Query arguments {}", argumentsJson);
        } catch (Exception exc) {
            log.error("Failed to get MambaReport", exc);
        }

        List<MambaReportItem> mambaReportItems = new ArrayList<>();
        List<String> columnNames = new ArrayList<>();

        DataSource dataSource = ConnectionPoolManager
                .getInstance()
                .getEtlDataSource();

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_mamba_get_report_column_names(?)}")) {

            statement.setString("report_identifier", criteria.getReportId());

            boolean hasResults = statement.execute();
            log.debug("hasResults {}", hasResults);
            while (hasResults) {

                ResultSet resultSet = statement.getResultSet();
                while (resultSet.next()) {
                    columnNames.add(resultSet.getString(1));
                }
                hasResults = statement.getMoreResults();
            }
        } catch (SQLException e) {
            log.error("Failed to get MambaReport", e);
        }

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_mamba_generate_report_wrapper(?, ?, ?)}")) {

            statement.setInt("generate_columns_flag", 0);
            statement.setString("report_identifier", criteria.getReportId());
            statement.setString("parameter_list", argumentsJson);

            boolean hasResults = statement.execute();

            if (!hasResults) {

                MambaReportItem reportItem = new MambaReportItem();
                reportItem.setSerialId(1);
                mambaReportItems.add(reportItem);
                for (String columnName : columnNames) {
                    reportItem.getRecord().add(new MambaReportItemColumn(columnName, null));
                }

            } else {

                do {

                    ResultSet resultSet = statement.getResultSet();
                    ResultSetMetaData metaData = resultSet.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    int serialId = 1;
                    while (resultSet.next()) {

                        MambaReportItem reportItem = new MambaReportItem();
                        reportItem.setSerialId(serialId);
                        mambaReportItems.add(reportItem);
                        for (int i = 1; i <= columnCount; i++) {

                            String columnName = metaData.getColumnName(i);
                            Object columnValue = resultSet.getObject(i);
                            reportItem.getRecord().add(new MambaReportItemColumn(columnName, columnValue));
                            log.debug("Column (metadata..) {} : {}", columnName, columnValue);
                        }
                        serialId++;
                    }
                }
                while (statement.getMoreResults());
            }
        } catch (SQLException e) {
            log.error("Failed to get MambaReport", e);
        }
        return mambaReportItems;
    }
}
