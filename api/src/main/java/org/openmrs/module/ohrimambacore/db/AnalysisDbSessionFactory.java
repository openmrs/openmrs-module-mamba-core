package org.openmrs.module.ohrimambacore.db;

import org.openmrs.api.db.hibernate.DbSession;
import org.hibernate.SessionFactory;

/**
 * @author Arthur D. Mugume, Amos Laboso date: 28/09/2023
 */
public class AnalysisDbSessionFactory {
	
	private SessionFactory sessionFactory;
	
	public AnalysisDbSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}
	
	public DbSession getCurrentSession() {
		return new DbSession(sessionFactory);
	}
	
	public SessionFactory getHibernateSessionFactory() {
		return sessionFactory;
	}
}
