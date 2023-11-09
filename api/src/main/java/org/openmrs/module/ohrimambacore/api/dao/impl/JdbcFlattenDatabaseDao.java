package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.apache.commons.dbcp2.BasicDataSource;
import org.openmrs.module.ohrimambacore.api.dao.FlattenDatabaseDao;
import org.openmrs.module.ohrimambacore.db.ConnectionPoolManager;

import javax.sql.DataSource;
import java.sql.*;

/**
 * @author smallGod
 * @date: 01/03/2023
 */
public class JdbcFlattenDatabaseDao implements FlattenDatabaseDao {

    @Override
    public void executeFlatteningScript() {

        DataSource dataSource = ConnectionPoolManager
                .getInstance()
                .getDataSource();

        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{call sp_mamba_data_processing_etl()}")) {
             //CallableStatement statement = connection.prepareCall("{call sp_mamba_tester()}")) {

            String sql = statement.toString();
            System.out.println("SQL Statement: " + sql);
            statement.execute();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
