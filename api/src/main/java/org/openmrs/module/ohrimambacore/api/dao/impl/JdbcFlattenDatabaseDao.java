package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.openmrs.module.ohrimambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.ohrimambacore.db.ConnectionPoolManager;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * date: 01/03/2023
 */
public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    @Override
    public void executeFlatteningScript() {

        DataSource dataSource = ConnectionPoolManager
                .getInstance()
                .getDataSource();

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{call sp_mamba_data_processing_etl()}")) {

            String sql = statement.toString();
            statement.execute();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
