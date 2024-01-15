package org.openmrs.module.ohrimambacore.api.dao.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.db.ConnectionPoolManager;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * date: 09/07/2023
 */
public class JdbcMambaReportItemDao implements MambaReportItemDao {

    private static Log log = LogFactory.getLog(JdbcMambaReportItemDao.class);

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
            log.info("Arguments.: " + argumentsJson);
        } catch (Exception exc) {
            exc.printStackTrace();
        }

        List<MambaReportItem> mambaReportItems = new ArrayList<>();
        List<String> columnNames = new ArrayList<>();

        DataSource dataSource = ConnectionPoolManager
                .getInstance()
                .getDataSource();

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_mamba_get_report_column_names(?)}")) {

            statement.setString("report_identifier", criteria.getReportId());

            boolean hasResults = statement.execute();
            log.info("hasResults up: " + hasResults);
            while (hasResults) {

                ResultSet resultSet = statement.getResultSet();
                while (resultSet.next()) {
                    columnNames.add(resultSet.getString(1));
                }
                hasResults = statement.getMoreResults();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_mamba_generate_report_wrapper(?, ?, ?)}")) {

            statement.setInt("generate_columns_flag", 0);
            statement.setString("report_identifier", criteria.getReportId());
            statement.setString("parameter_list", argumentsJson);

            boolean hasResults = statement.execute();
            int updateCount = statement.getUpdateCount();

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
                        // reportItem.setMetaData(new MambaReportItemMetadata(serialId));
                        reportItem.setSerialId(serialId);
                        mambaReportItems.add(reportItem);
                        for (int i = 1; i <= columnCount; i++) {

                            String columnName = metaData.getColumnName(i);
                            Object columnValue = resultSet.getObject(i);
                            reportItem.getRecord().add(new MambaReportItemColumn(columnName, columnValue));

                            log.info("Column (metadata..) " + columnName + ": " + columnValue);
                        }
                        serialId++;
                    }
                }
                while (statement.getMoreResults());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return mambaReportItems;
    }
}
