package org.openmrs.module.ohrimambacore.web.controller;

import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.v1_0.controller.MainResourceController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/rest/" + RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE)
public class MambaReportRestController extends MainResourceController {
	
	public static final String MAMBA_REPORT_REST_NAMESPACE = "/mamba";
	
	/**
	 * @see org.openmrs.module.webservices.rest.web.v1_0.controller.BaseRestController#getNamespace()
	 */
	@Override
	public String getNamespace() {
		return RestConstants.VERSION_1 + MAMBA_REPORT_REST_NAMESPACE;
	}
}
