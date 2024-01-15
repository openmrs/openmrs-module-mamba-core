package org.openmrs.module.ohrimambacore.api.model;

import org.openmrs.BaseOpenmrsObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * date: 09/07/2023
 */
public class MambaReportItem implements Serializable {

    private static final long serialVersionUID = -8980686055469327763L;

//    private MambaReportItemMetadata metaData;

    private Integer serialId;

    private List<MambaReportItemColumn> record = new ArrayList<>();

    public MambaReportItem() {
    }

    public Integer getSerialId() {
        return serialId;
    }

    public void setSerialId(Integer serialId) {
        this.serialId = serialId;
    }

    public List<MambaReportItemColumn> getRecord() {
        return record;
    }

    public void setRecord(List<MambaReportItemColumn> record) {
        this.record = record;
    }
}
