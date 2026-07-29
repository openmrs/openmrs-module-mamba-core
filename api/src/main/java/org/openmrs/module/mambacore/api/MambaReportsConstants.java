/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.api;

public class MambaReportsConstants {
	
	public final static String VIEW_MAMBA_REPORT = "View MambaReport";
	
	/**
	 * REST namespace for Mamba report endpoints
	 */
	public final static String MAMBA_REPORT_REST_NAMESPACE = "/mamba";
	
	/**
	 * Full REST API path for Mamba report endpoints
	 */
	public final static String REST_API_PATH = "/rest/" + org.openmrs.module.webservices.rest.web.RestConstants.VERSION_1
	        + MAMBA_REPORT_REST_NAMESPACE;
}
