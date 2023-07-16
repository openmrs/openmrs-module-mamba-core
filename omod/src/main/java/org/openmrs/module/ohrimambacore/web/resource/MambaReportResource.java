package org.openmrs.module.ohrimambacore.web.resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemMetadata;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportSearchField;
import org.openmrs.module.ohrimambacore.web.controller.MambaReportRestController;
import org.openmrs.module.webservices.rest.SimpleObject;
import org.openmrs.module.webservices.rest.web.ConversionUtil;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.Representation;
import org.openmrs.module.webservices.rest.web.resource.api.Converter;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.api.Searchable;
import org.openmrs.module.webservices.rest.web.resource.impl.BaseDelegatingResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.EmptySearchResult;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ConversionException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.io.IOException;
import java.util.*;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource implements Searchable {

    private Log log = LogFactory.getLog(this.getClass());

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }


    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {


        String reportId = context.getRequest().getParameter("reportId");
        context.setLimit(10);
        context.setStartIndex(0);
        //get and compare other params from db with request ones

        System.out.println("retrieve 2 - OHRI Mamba Core: " + reportId);

        if (reportId == null) {
            return new EmptySearchResult().toSimpleObject(null);
        } else {

            MambaReportCriteria searchCriteria = new MambaReportCriteria(reportId);
            searchCriteria.setReportId(reportId);

            Enumeration<String> parameterNames = context.getRequest().getParameterNames();
            while (parameterNames.hasMoreElements()) {

                String paramName = parameterNames.nextElement();
                String paramValue = context.getRequest().getParameter(paramName);
                searchCriteria.getSearchFields().add(new MambaReportSearchField(paramName, paramValue));
                System.out.println("Parameter: " + paramName + ", Value: " + paramValue);
            }

            List<MambaReportItem> mambaReportItems = getService().getMambaReportByCriteria(searchCriteria);
            return new SimpleObject().add("results", mambaReportItems);
        }
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

    protected PageableResult doSearch(RequestContext context) {
        return new EmptySearchResult();
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
    */

}
