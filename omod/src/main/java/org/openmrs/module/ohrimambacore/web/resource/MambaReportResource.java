package org.openmrs.module.ohrimambacore.web.resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.api.context.Context;
import org.openmrs.module.ohrimambacore.api.MambaReportService;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.web.controller.MambaReportRestController;
import org.openmrs.module.webservices.rest.web.RequestContext;
import org.openmrs.module.webservices.rest.web.RestConstants;
import org.openmrs.module.webservices.rest.web.annotation.PropertyGetter;
import org.openmrs.module.webservices.rest.web.annotation.Resource;
import org.openmrs.module.webservices.rest.web.representation.*;
import org.openmrs.module.webservices.rest.web.resource.api.PageableResult;
import org.openmrs.module.webservices.rest.web.resource.impl.BaseDelegatingReadableResource;
import org.openmrs.module.webservices.rest.web.resource.impl.DelegatingResourceDescription;
import org.openmrs.module.webservices.rest.web.resource.impl.NeedsPaging;
import org.openmrs.module.webservices.rest.web.response.ResourceDoesNotSupportOperationException;
import org.openmrs.module.webservices.rest.web.response.ResponseException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Resource(name = RestConstants.VERSION_1 + MambaReportRestController.MAMBA_REPORT_REST_NAMESPACE + "/report", supportedClass = MambaReportItem.class, supportedOpenmrsVersions = {"2.0 - 2.*"})
public class MambaReportResource extends BaseDelegatingReadableResource<MambaReportItem> {

    private Log log = LogFactory.getLog(this.getClass());

    @Override
    public MambaReportItem getByUniqueId(String s) {
        throw new ResourceDoesNotSupportOperationException("Search-only resource");
    }

    @Override
    public MambaReportItem newDelegate() {
        return new MambaReportItem();
    }

    @Override
    public DelegatingResourceDescription getRepresentationDescription(Representation representation) {
        DelegatingResourceDescription resourceDescription = new DelegatingResourceDescription();
        if (representation instanceof RefRepresentation) {
            this.addSharedResourceDescriptionProperties(resourceDescription);
            //resourceDescription.addProperty("drug", Representation.REF);
            //resourceDescription.addProperty("concept", Representation.REF);
            resourceDescription.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
        } else if (representation instanceof DefaultRepresentation) {
            this.addSharedResourceDescriptionProperties(resourceDescription);
            //resourceDescription.addProperty("drug", Representation.DEFAULT);
            //resourceDescription.addProperty("concept", Representation.DEFAULT);
            resourceDescription.addLink("full", ".?v=" + RestConstants.REPRESENTATION_FULL);
        } else if (representation instanceof FullRepresentation) {
            this.addSharedResourceDescriptionProperties(resourceDescription);
            //resourceDescription.addProperty("drug", Representation.FULL);
            //resourceDescription.addProperty("concept", Representation.FULL);
        } else if (representation instanceof CustomRepresentation) {
            resourceDescription = null;
        }
        return resourceDescription;
    }

    private void addSharedResourceDescriptionProperties(DelegatingResourceDescription resourceDescription) {
        resourceDescription.addSelfLink();
        //resourceDescription.addProperty("display");
        //resourceDescription.addProperty("name");
        //resourceDescription.addProperty("description");
        resourceDescription.addProperty("mamba_search_fields");
    }

    @Override
    public PageableResult doGetAll(RequestContext context) throws ResponseException {
        return doSearch(context);
    }

    @Override
    protected PageableResult doSearch(RequestContext requestContext) {

        log.info("doSearch - OHRI Mamba Core");
        System.out.println("doSearch 2 - OHRI Mamba Core");

        String mambaSearchFieldsString = requestContext.getParameter("mamba_search_fields");
        ObjectMapper objectMapper = new ObjectMapper();

        List<MambaReportItem> mambaReportItem;
        try {
            MambaReportCriteria searchCriteria = objectMapper.readValue(mambaSearchFieldsString, MambaReportCriteria.class);
            mambaReportItem = getService().getMambaReportByCriteria(searchCriteria);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return new NeedsPaging<>(mambaReportItem, requestContext);
    }

    private MambaReportService getService() {
        return Context.getService(MambaReportService.class);
    }

    /*
    wifie
    - she heard very well and she acted well - should never worry about owning a car or driving or material things.
    - let her watch the trend of the growth of her life - spiritually and physically

     */
}
