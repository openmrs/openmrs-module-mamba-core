package org.openmrs.module.ohrimambacore.api.dao.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.hibernate.SQLQuery;
import org.hibernate.transform.Transformers;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.openmrs.module.ohrimambacore.api.dao.MambaReportItemDao;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItem;
import org.openmrs.module.ohrimambacore.api.model.MambaReportItemColumn;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportCriteria;
import org.openmrs.module.ohrimambacore.api.parameter.MambaReportSearchField;

import java.util.*;

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

        String argumentsJson = "";
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            argumentsJson = objectMapper.writeValueAsString(criteria.getSearchFields());
            System.out.println("Arguments: " + argumentsJson);
        } catch (Exception exc) {
            exc.printStackTrace();
        }

        String reportQuery = "CALL sp_mamba_generate_report_wrapper(:generate_columns_flag, :report_identifier, :parameter_list)";
        SQLQuery query = sessionFactory.getCurrentSession().createSQLQuery(reportQuery);
        query.setParameter("generate_columns_flag", 0);
        query.setParameter("report_identifier", criteria.getReportId());
        query.setParameter("parameter_list", argumentsJson);

        System.out.println("Generated SQL Query..: " + query.getQueryString());

        int pageNumber = 1;
        int pageSize = 10;
        int firstResult = (pageNumber - 1) * pageSize;
        //query.setFirstResult(firstResult); query.setMaxResults(pageSize);
        List<?> resultList = query.setResultTransformer(Transformers.TO_LIST).list();
        System.out.println("size: " + resultList.size());
        System.out.println("resultList: " + resultList);

        //Get the Columns
        String reportColumnsQuery = "CALL sp_mamba_get_report_column_names(:report_identifier)";
        SQLQuery columnsQuery = sessionFactory.getCurrentSession().createSQLQuery(reportColumnsQuery);
        columnsQuery.setParameter("report_identifier", criteria.getReportId());

        List<?> columnNamesList = columnsQuery.list();
        List<String> columnNames = new ArrayList<>();
        for (Object result : columnNamesList) {
            columnNames.add((String) result);
        }

        List<MambaReportItem> mambaReportItems = new ArrayList<>();
        if (resultList == null || resultList.isEmpty()) {
            MambaReportItem reportItem = new MambaReportItem();
            reportItem.setSerialId(1);
            mambaReportItems.add(reportItem);
            for (String columnName : columnNames) {
                reportItem.getRecord().add(new MambaReportItemColumn(columnName, null));
            }
        } else {

            int serialId = 1;
            for (Object result : resultList) {

                List<?> row = (List<?>) result;
                MambaReportItem reportItem = new MambaReportItem();
                // reportItem.setMetaData(new MambaReportItemMetadata(serialId));
                reportItem.setSerialId(serialId);
                mambaReportItems.add(reportItem);
                for (int i = 0; i < row.size(); i++) {
                    reportItem.getRecord().add(new MambaReportItemColumn(columnNames.get(i), row.get(i)));
                }
                serialId++;
            }
        }
        return mambaReportItems;
    }


    public List<MambaReportItem> getMambaReport2(MambaReportCriteria criteria) {


        StringJoiner whereClause = new StringJoiner(" AND ", " WHERE ", "");

        List<MambaReportSearchField> searchFields = criteria.getSearchFields();
        if (searchFields != null && !searchFields.isEmpty()) {
            for (MambaReportSearchField searchField : searchFields) {
                String fieldName = searchField.getColumn();
                whereClause.add(fieldName + " = :" + fieldName);
            }
        }

        String queryString = "CALL sp_mamba_generate_report(:report_id)" + whereClause;
        SQLQuery query = sessionFactory.getCurrentSession().createSQLQuery(queryString);

        query.setParameter("report_id", criteria.getReportId());
        for (MambaReportSearchField searchField : searchFields) {
            query.setParameter(searchField.getColumn(), searchField.getValue());
        }

        int pageNumber = 1;
        int pageSize = 10;

        int firstResult = (pageNumber - 1) * pageSize;
        //query.setFirstResult(firstResult); query.setMaxResults(pageSize);

        List<?> resultList = query.setResultTransformer(Transformers.TO_LIST).list();
        String[] columnNames = query.getReturnAliases();

        System.out.println("query list size: " + resultList.size());

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
