package org.openmrs.module.ohrimambacore.api;

import org.openmrs.api.OpenmrsService;

/**
 * date: 01/03/2023
 */
public interface FlattenDatabaseService extends OpenmrsService {
	
	//@Authorized({ OrderTemplatesConstants.MANAGE_ORDER_TEMPLATES })
	void flattenDatabase();
}
