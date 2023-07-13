package org.openmrs.module.ohrimambacore.api.dao.impl;

import org.hibernate.SQLQuery;
import org.hibernate.transform.Transformers;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;

import java.util.ArrayList;
import java.util.List;

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

        SQLQuery query = sessionFactory.getCurrentSession()
                .createSQLQuery("CALL sp_mamba_generate_report(:report_id)");
        query.setParameter("report_id", criteria.getReportId());

        // Set pagination parameters
        int pageNumber = 1; // Page number (starting from 1)
        int pageSize = 10; // Number of rows per page

        int firstResult = (pageNumber - 1) * pageSize;
        //query.setFirstResult(firstResult);
        //query.setMaxResults(pageSize);

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
