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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PreDestroy;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

@Transactional
public class FlattenDatabaseServiceImpl extends BaseOpenmrsService implements FlattenDatabaseService {

    private static final Logger log = LoggerFactory.getLogger(FlattenDatabaseServiceImpl.class);

    private final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private FlattenDatabaseDao dao;

    public void setDao(FlattenDatabaseDao dao) {
        this.dao = dao;
    }

    @Override
    public void setupEtl() {
        executorService.submit(() -> {
            try {
                dao.deployMambaEtl();
            } catch (Exception e) {
                log.error("Error deploying Mamba ETL", e);
            }
        });
    }


    @Override
    @PreDestroy
    public void shutdownEtlThread() {
        executorService.shutdown();
        try {
            if (!executorService.awaitTermination(60, TimeUnit.SECONDS)) {
                executorService.shutdownNow();
                if (!executorService.awaitTermination(60, TimeUnit.SECONDS)) {
                    log.error("ExecutorService did not terminate");
                }
            }
        } catch (InterruptedException e) {
            executorService.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
}