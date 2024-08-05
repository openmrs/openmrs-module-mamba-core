/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api.impl;

import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mambacore.api.FlattenDatabaseService;
import org.openmrs.module.mambacore.api.dao.FlattenDatabaseDao;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Transactional
public class FlattenDatabaseServiceImpl extends BaseOpenmrsService implements FlattenDatabaseService {

    private final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private FlattenDatabaseDao dao;

    public void setDao(FlattenDatabaseDao dao) {
        this.dao = dao;
    }

    @Override
    public void setupEtl() {
        executorService.submit(() -> {
            dao.deployMambaEtl();
        });
    }
}