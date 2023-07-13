package org.openmrs.module.ohrimambacore.web.resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
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
import org.openmrs.module.webservices.rest.web.resource.impl.EmptySearchResult;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ConversionException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.io.IOException;
import java.util.*;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource implements Searchable, Converter<MambaReportItem> {

    private Log log = LogFactory.getLog(this.getClass());

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }


//    public Object retrieve(String reportId, RequestContext requestContext) throws ResponseException {
//
//        log.info("retrieve - OHRI Mamba Core");
//        System.out.println("retrieve 2 - OHRI Mamba Core: " + reportId);
//
//        String mambaSearchFieldsString = requestContext.getParameter("mamba_search_fields");
//        ObjectMapper objectMapper = new ObjectMapper();
//
//        List<MambaReportItem> mambaReportItem = new ArrayList<>();
//        try {
//            MambaReportCriteria searchCriteria = objectMapper.readValue(mambaSearchFieldsString, MambaReportCriteria.class);
//            mambaReportItem = getService().getMambaReportByCriteria(searchCriteria);
//        } catch (IOException e) {
//            throw new RuntimeException(e);
//        }
//
//        return new NeedsPaging<>(mambaReportItem, requestContext);
//    }


    @Override
    public SimpleObject search(RequestContext context) throws ResponseException {


        String reportId = context.getRequest().getParameter("reportId");
        //get and compare other params from db with request ones

        log.info("retrieve - OHRI Mamba Core");
        System.out.println("retrieve 2 - OHRI Mamba Core: " + reportId);

        if (reportId == null) {
            PageableResult result = this.doSearch(context);
            return result.toSimpleObject(this);
        } else {
            //Date minStartDate = fromStartDate != null ? (Date) ConversionUtil.convert(fromStartDate, Date.class) : null;
            //return this.getVisits(context, patientParameter, includeInactiveParameter, minStartDate);
            return null;
        }
    }

//    private SimpleObject getVisits(RequestContext context, String patientParameter, String includeInactiveParameter, Date minStartDate) {
//        Collection<Patient> patients = patientParameter == null ? null : Arrays.asList(this.getPatient(patientParameter));
//        boolean includeInactive = includeInactiveParameter == null ? true : Boolean.parseBoolean(includeInactiveParameter);
//        return (new NeedsPaging(Context.getVisitService().getVisits((Collection) null, patients, (Collection) null, (Collection) null, minStartDate, (Date) null, (Date) null, (Date) null, (Map) null, includeInactive, context.getIncludeAll()), context)).toSimpleObject(this);
//    }

    protected PageableResult doSearch(RequestContext context) {
        return new EmptySearchResult();
    }

    @Override
    public String getUri(Object o) {
        return null;
    }

    @Override
    public MambaReportItem newInstance(String s) {
        return new MambaReportItem();
    }

    @Override
    public MambaReportItem getByUniqueId(String s) {
        return null;
    }

    @Override
    public SimpleObject asRepresentation(MambaReportItem mambaReportItem, Representation representation) throws ConversionException {
        return null;
    }

    @Override
    public Object getProperty(MambaReportItem mambaReportItem, String s) throws ConversionException {
        return null;
    }

    @Override
    public void setProperty(Object o, String s, Object o1) throws ConversionException {

    }
}
