/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * <p>
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark of the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.mambacore.web.controller;

import org.openmrs.module.mambacore.api.MambaReportsConstants;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * REST controller for Mamba report endpoints.
 * <p>
 * This controller is currently empty. REST endpoints are implemented
 * by {@link org.openmrs.module.mambacore.web.resource.MambaReportResource}
 * which is registered via the OpenMRS REST Web Services module.
 * </p>
 * @see org.openmrs.module.mambacore.web.resource.MambaReportResource
 */
@Controller
@RequestMapping("/rest/" + RestConstants.VERSION_1 + MambaReportsConstants.MAMBA_REPORT_REST_NAMESPACE)
public class MambaReportRestController {
	// Add custom Spring MVC endpoints here if needed in the future
}
