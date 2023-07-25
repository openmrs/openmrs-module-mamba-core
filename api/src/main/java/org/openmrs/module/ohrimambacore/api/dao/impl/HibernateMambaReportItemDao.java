package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.hibernate.SQLQuery;
import org.hibernate.transform.Transformers;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportSearchField;

import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;

/**
 * @author smallGod
 * date: 09/07/2023
 */
public class HibernateMambaReportItemDao implements MambaReportItemDao {

    private DbSessionFactory sessionFactory;

    @Override
    public List<MambaReportItem> getMambaReport(String mambaReportId) {
        return getMambaReport(new MambaReportCriteria(mambaReportId));
    }

    @Override
    public List<MambaReportItem> getMambaReport(MambaReportCriteria criteria) {

        List<MambaReportSearchField> searchFields = criteria.getSearchFields();

        StringJoiner whereClause = new StringJoiner(" AND ", " WHERE ", "");

        if (searchFields != null && !searchFields.isEmpty()) {
            for (MambaReportSearchField searchField : searchFields) {
                String fieldName = searchField.getFieldName();
                whereClause.add(fieldName + " = :" + fieldName);
            }
        }

        String queryString = "CALL sp_mamba_generate_report(:report_id)" + whereClause;

        SQLQuery query = sessionFactory.getCurrentSession().createSQLQuery(queryString);

        query.setParameter("report_id", criteria.getReportId());
        for (MambaReportSearchField searchField : searchFields) {
            query.setParameter(searchField.getFieldName(), searchField.getFieldValue());
        }

        int pageNumber = 1;
        int pageSize = 10;

        int firstResult = (pageNumber - 1) * pageSize;
        //query.setFirstResult(firstResult); query.setMaxResults(pageSize);

        List<?> resultList = query.setResultTransformer(Transformers.TO_LIST).list();
        String[] columnNames = query.getReturnAliases();

        int serialId = 1;
        List<MambaReportItem> mambaReportItems = new ArrayList<>();

        for (Object result : resultList) {
            Object[] row = (Object[]) result;

            MambaReportItem reportItem = new MambaReportItem();
            // reportItem.setMetaData(new MambaReportItemMetadata(serialId));
            reportItem.setSerialId(serialId);
            mambaReportItems.add(reportItem);

            for (int i = 0; i < row.length; i++) {
                reportItem.getRecord().add(new MambaReportItemColumn(columnNames[i], row[i]));
            }
            serialId++;
        }
        return mambaReportItems;
    }

    public DbSessionFactory getSessionFactory() {
        return sessionFactory;
    }

    public void setSessionFactory(DbSessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }
}
