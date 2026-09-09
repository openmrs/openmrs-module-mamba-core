package org.openmrs.module.mambacore.api.dao.impl;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Stream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/**
 * Unit tests for external ETL SQL file discovery. Plain JUnit 4 with real temporary directories: no
 * OpenMRS context and no database are required.
 */
public class JdbcFlattenDatabaseDaoDiscoveryTest {

    private Path rootDirectory;

    @Before
    public void setUp() throws IOException {
        rootDirectory = Files.createTempDirectory("mamba-etl-discovery");
    }

    @After
    public void tearDown() {
        deleteRecursively(rootDirectory);
    }

    @Test
    public void discoverSqlFiles_shouldFindSqlFilesInNestedDirectories() throws IOException {
        createFile("a.sql");
        createFile("sub/b.sql");
        createFile("sub/deep/c.sql");

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 5);

        assertEquals(3, sqlFiles.size());
        assertTrue(containsFile(sqlFiles, "a.sql"));
        assertTrue(containsFile(sqlFiles, "b.sql"));
        assertTrue(containsFile(sqlFiles, "c.sql"));
    }

    @Test
    public void discoverSqlFiles_shouldReturnFilesInSortedOrder() throws IOException {
        // created deliberately out of alphabetical order
        for (String name : new String[] { "c.sql", "a.sql", "d.sql", "b.sql" }) {
            createFile(name);
        }

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 5);

        assertEquals(4, sqlFiles.size());
        assertEquals("a.sql", sqlFiles.get(0).getFileName().toString());
        assertEquals("b.sql", sqlFiles.get(1).getFileName().toString());
        assertEquals("c.sql", sqlFiles.get(2).getFileName().toString());
        assertEquals("d.sql", sqlFiles.get(3).getFileName().toString());
    }

    @Test
    public void discoverSqlFiles_shouldExcludeNonSqlFiles() throws IOException {
        createFile("a.sql");
        createFile("README.md");
        createFile("notes.txt");
        createFile("b.sql.bak");
        createFile("sub/c.sql");

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 5);

        assertEquals(2, sqlFiles.size());
        assertTrue(containsFile(sqlFiles, "a.sql"));
        assertTrue(containsFile(sqlFiles, "c.sql"));
    }

    @Test
    public void discoverSqlFiles_shouldMatchExtensionCaseInsensitively() throws IOException {
        // names differ by more than case, so this also passes on case-insensitive filesystems (macOS APFS)
        createFile("lower.sql");
        createFile("UPPER.SQL");
        createFile("Mixed.Sql");

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 5);

        assertEquals(3, sqlFiles.size());
    }

    @Test
    public void discoverSqlFiles_shouldRespectMaxDepth() throws IOException {
        createFile("a.sql");
        createFile("sub/b.sql");
        createFile("sub/deep/c.sql");

        List<Path> depthOne = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 1);
        assertEquals(1, depthOne.size());
        assertEquals("a.sql", depthOne.get(0).getFileName().toString());

        List<Path> depthTwo = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 2);
        assertEquals(2, depthTwo.size());
        assertTrue(containsFile(depthTwo, "a.sql"));
        assertTrue(containsFile(depthTwo, "b.sql"));

        List<Path> depthThree = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 3);
        assertEquals(3, depthThree.size());
    }

    @Test
    public void discoverSqlFiles_shouldTreatDepthsBelowOneAsOne() throws IOException {
        createFile("a.sql");
        createFile("sub/b.sql");

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 0);

        assertEquals(1, sqlFiles.size());
        assertEquals("a.sql", sqlFiles.get(0).getFileName().toString());
    }

    @Test
    public void discoverSqlFiles_shouldReturnEmptyListForNonExistentDirectory() throws IOException {
        Path missing = rootDirectory.resolve("does-not-exist");

        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(missing.toString(), 5);

        assertNotNull(sqlFiles);
        assertTrue(sqlFiles.isEmpty());
    }

    @Test
    public void discoverSqlFiles_shouldReturnEmptyListForEmptyDirectory() throws IOException {
        List<Path> sqlFiles = JdbcFlattenDatabaseDao.discoverSqlFiles(rootDirectory.toString(), 5);

        assertNotNull(sqlFiles);
        assertTrue(sqlFiles.isEmpty());
    }

    @Test
    public void preflightScripts_shouldAcceptValidScripts() throws IOException {
        Path good = createFile("10_good.sql");
        Files.write(good, "CREATE TABLE t (id INT);\n~-~- \nCREATE TABLE u (id INT);\n"
            .getBytes(StandardCharsets.UTF_8));

        JdbcFlattenDatabaseDao.preflightScripts(Arrays.asList(good));
    }

    @Test
    public void preflightScripts_shouldRejectInvalidScriptBeforeAnyDatabaseWork() throws IOException {
        Path good = createFile("10_good.sql");
        Files.write(good, "CREATE TABLE t (id INT);".getBytes(StandardCharsets.UTF_8));
        Path bad = createFile("20_bad.sql");
        Files.write(bad, ("CREATE TABLE u (id INT);\n"
            + "DELIMITER //\n"
            + "CREATE PROCEDURE p() BEGIN SELECT 1; END//\n"
            + "DELIMITER ;\n").getBytes(StandardCharsets.UTF_8));

        try {
            JdbcFlattenDatabaseDao.preflightScripts(Arrays.asList(good, bad));
            fail("Expected pre-flight to reject the raw DELIMITER script");
        } catch (RuntimeException e) {
            // the error must name the offending file so the implementer can fix it
            assertTrue(e.getMessage(), e.getMessage().contains(bad.getFileName().toString()));
            assertTrue(e.getMessage(), e.getMessage().contains("DELIMITER"));
        }
    }

    private Path createFile(String relativePath) throws IOException {
        Path file = rootDirectory.resolve(relativePath);
        if (file.getParent() != null) {
            Files.createDirectories(file.getParent());
        }
        Files.createFile(file);
        return file;
    }

    private boolean containsFile(List<Path> sqlFiles, String fileName) {
        for (Path path : sqlFiles) {
            if (fileName.equals(path.getFileName().toString())) {
                return true;
            }
        }
        return false;
    }

    private static void deleteRecursively(Path root) {
        if (root == null || !Files.exists(root)) {
            return;
        }
        try (Stream<Path> paths = Files.walk(root)) {
            paths.sorted(Comparator.reverseOrder()).forEach(path -> {
                try {
                    Files.delete(path);
                }
                catch (IOException e) {
                    throw new IllegalStateException("Failed to delete " + path, e);
                }
            });
        }
        catch (IOException e) {
            // best effort: a leftover temp directory must not fail the test run
        }
    }
}
