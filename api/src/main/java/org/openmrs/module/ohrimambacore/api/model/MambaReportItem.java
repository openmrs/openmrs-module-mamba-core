package org.openmrs.module.ohrimambacore.api.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author smallGod
 * date: 09/07/2023
 */
public class MambaReportItem implements Serializable {

    private static final long serialVersionUID = -8980686055469327763L;

    private MambaReportItemMetadata metaData;

    private List<MambaReportItemColumn> record = new ArrayList<>();

    public MambaReportItem() {
    }

    public MambaReportItemMetadata getMetaData() {
        return metaData;
    }

    public void setMetaData(MambaReportItemMetadata metaData) {
        this.metaData = metaData;
    }

    public List<MambaReportItemColumn> getRecord() {
        return record;
    }

    public void setRecord(List<MambaReportItemColumn> record) {
        this.record = record;
    }
}
