package org.openmrs.module.ohrimambacore.web.resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportSearchField;
import org.openmrs.module.ohrimambacore.web.controller.MambaReportRestController;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.resource.api.Searchable;
import org.openmrs.module.webservices.rest.web.resource.impl.EmptySearchResult;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.util.Enumeration;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource implements Searchable {

    private static Log log = LogFactory.getLog(MambaReportResource.class);

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }

    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {

        System.out.println("Search resource hit.");
        log.info("Search resource hit..");

        context.setLimit(10);
        context.setStartIndex(0);

        MambaReportCriteria searchCriteria = new MambaReportCriteria();

        Enumeration<String> parameterNames = context.getRequest().getParameterNames();
        while (parameterNames.hasMoreElements()) {

            String paramName = parameterNames.nextElement();
            String paramValue = context.getRequest().getParameter(paramName);

            if (paramName.equals("report_id")) {
                searchCriteria.setReportId(paramValue);
            } else {
                searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
            }
        }

        if (searchCriteria.getReportId() == null) {
            System.err.println("Warning: Report ID is null");
            return new EmptySearchResult().toSimpleObject(null);
        }

        List<MambaReportItem> mambaReportItems = getService().getMambaReportByCriteria(searchCriteria);
        System.out.println("mambaReportItems: " + mambaReportItems);
        return new SimpleObject().add("results", mambaReportItems);
    }

    @Override
    public String getUri(Object o) {
        return null;
    }

    /*
    public Object retrieve(String reportId, RequestContext requestContext) throws ResponseException {

        log.info("retrieve - OHRI MambaETL Core");
        System.out.println("retrieve 2 - OHRI MambaETL Core: " + reportId);

        String mambaSearchFieldsString = requestContext.getParameter("mamba_search_fields");
        ObjectMapper objectMapper = new ObjectMapper();

        List<MambaReportItem> mambaReportItem = new ArrayList<>();
        try {
            MambaReportCriteria searchCriteria = objectMapper.readValue(mambaSearchFieldsString, MambaReportCriteria.class);
            mambaReportItem = getService().getMambaReportByCriteria(searchCriteria);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return new NeedsPaging<>(mambaReportItem, requestContext);
    }

    private SimpleObject getTestReports(RequestContext requestContext) throws ResponseException {

        List<MambaReportItem> mambaReportItems = new ArrayList<>();

        MambaReportItem reportItem = new MambaReportItem();
        reportItem.setSerialId(1);
        reportItem.getRecord().add(new MambaReportItemColumn("col_name_1", "row_value_1"));

        MambaReportItem reportItem2 = new MambaReportItem();
        reportItem2.setSerialId(2);
        reportItem2.getRecord().add(new MambaReportItemColumn("col_name_2", "row_value_2"));

        mambaReportItems.add(reportItem);
        mambaReportItems.add(reportItem2);

        System.out.println("Size: " + mambaReportItems.size());
        System.out.println("Records: " + mambaReportItems);

        //return (new NeedsPaging<>(mambaReportItems, requestContext)).toSimpleObject(this);
        return new SimpleObject().add("results", mambaReportItems);
    }

    */
}
