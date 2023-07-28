package org.openmrs.module.ohrimambacore.web.resource;

import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
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

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Random;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource implements Searchable {

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }


    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {

        String reportId = context.getRequest().getParameter("report_id");
        context.setLimit(10);
        context.setStartIndex(0);
        //get and compare other params from db with request ones
        System.out.println("retrieve 2 - OHRI Mamba Core: " + reportId);

        if (reportId == null) {
            return new EmptySearchResult().toSimpleObject(null);
        } else {
            //TODO: (non-business code) - Delete this after resolving module issues - only for unblocking purposes
            //return getPlaceHolderReport(reportId);
            return fetchReport(reportId, context);
        }
    }

    private SimpleObject fetchReport(String reportId, RequestContext context) {

        MambaReportCriteria searchCriteria = new MambaReportCriteria(reportId);
        searchCriteria.setReportId(reportId);

        Enumeration<String> parameterNames = context.getRequest().getParameterNames();
        while (parameterNames.hasMoreElements()) {

            String paramName = parameterNames.nextElement();
            String paramValue = context.getRequest().getParameter(paramName);
            searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
        }

        List<MambaReportItem> mambaReportItems = getService().getMambaReportByCriteria(searchCriteria);
        return new SimpleObject().add("results", mambaReportItems);
    }

    //TODO: (non-business code) - Delete this function after resolving module issues - only for unblocking purposes
    private SimpleObject getPlaceHolderReport(String reportId) throws ResponseException {

        switch (reportId) {

            case "total_deliveries":
                return getPlaceHolderData("total_deliveries", new Random().nextInt(1001));
            case "hiv_exposed_infants":
                return getPlaceHolderData("hiv_exposed_infants", new Random().nextInt(40));
            case "total_pregnant_women":
                return getPlaceHolderData("total_pregnant_women", new Random().nextInt(723));
            default:
                return new EmptySearchResult().toSimpleObject(null);
        }
    }

    //TODO: Only doing this till module issue is resolved - Remove all these hard-coded values/functions later
    private SimpleObject getPlaceHolderData(String columnName, Object rowValue) {

        List<MambaReportItem> mambaReportItems = new ArrayList<>();

        MambaReportItem reportItem = new MambaReportItem();
        reportItem.setSerialId(1);
        reportItem.getRecord().add(new MambaReportItemColumn(columnName, rowValue));
        mambaReportItems.add(reportItem);

        return new SimpleObject().add("results", mambaReportItems);
    }

    @Override
    public String getUri(Object o) {
        return null;
    }


    /*
    public Object retrieve(String reportId, RequestContext requestContext) throws ResponseException {

        log.info("retrieve - OHRI Mamba Core");
        System.out.println("retrieve 2 - OHRI Mamba Core: " + reportId);

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
