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

import java.util.function.Consumer;

/**
 * Implementations should provide an implemnentation to handle the processing of DbEvents
 */
public interface EventConsumer extends Consumer<DbEvent> {

    /**
     * Executed at startup (prior to any Event processing)
     */
    default void preStartup() {
    }

    /**
     * Executed at shutdown
     */
    default void preShutdown() {
    }

    /**
     * Executed at engine reset
     */
    default void preReset() {
    }
}