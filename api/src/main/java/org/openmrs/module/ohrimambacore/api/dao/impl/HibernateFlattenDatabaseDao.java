package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.apache.commons.dbcp2.BasicDataSource;
import org.openmrs.module.ohrimambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.ohrimambacore.db.ConnectionPoolManager;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * @author smallGod
 * @date: 01/03/2023
 */
public class HibernateFlattenDatabaseDao implements FlattenDatabaseDao {

    @Override
    public void executeFlatteningScript() {

        BasicDataSource dataSource = ConnectionPoolManager.getDataSource();

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{CALL sp_mamba_data_processing_etl()}")) {
            statement.execute();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
