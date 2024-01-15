/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
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
