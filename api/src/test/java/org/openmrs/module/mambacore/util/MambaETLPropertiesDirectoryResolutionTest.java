package org.openmrs.module.mambacore.util;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.stream.Stream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

/**
 * Unit tests for external ETL directory path resolution. Plain JUnit 4: calling the package-private static
 * resolver loads the class but never runs its constructor, so no OpenMRS context is needed. Expected values
 * are always derived with getCanonicalPath() because temporary directories are reached through symlinks on
 * macOS (/var -> /private/var, /tmp -> /private/tmp).
 */
public class MambaETLPropertiesDirectoryResolutionTest {

    private Path appDataDirectory;

    @Before
    public void setUp() throws IOException {
        appDataDirectory = Files.createTempDirectory("mamba-etl-properties");
    }

    @After
    public void tearDown() {
        deleteRecursively(appDataDirectory);
    }

    @Test
    public void resolveEtlDirectory_shouldResolveRelativePathUnderConfiguration() throws IOException {
        String resolved = MambaETLProperties.resolveEtlDirectory("etl-sql", appDataDirectory.toString());

        File expected = new File(new File(appDataDirectory.toFile(), "configuration"), "etl-sql");
        assertEquals(expected.getCanonicalPath(), resolved);
    }

    @Test
    public void resolveEtlDirectory_shouldKeepNestedRelativePathInsideConfiguration() throws IOException {
        String resolved = MambaETLProperties.resolveEtlDirectory("sub/dir/etl-sql", appDataDirectory.toString());

        File expected = new File(new File(appDataDirectory.toFile(), "configuration"), "sub/dir/etl-sql");
        assertEquals(expected.getCanonicalPath(), resolved);
    }

    @Test
    public void resolveEtlDirectory_shouldCollapseDotDotSegmentsThatStayInside() throws IOException {
        String resolved = MambaETLProperties.resolveEtlDirectory("sub/../etl-sql", appDataDirectory.toString());

        File expected = new File(new File(appDataDirectory.toFile(), "configuration"), "etl-sql");
        assertEquals(expected.getCanonicalPath(), resolved);
    }

    @Test
    public void resolveEtlDirectory_shouldRejectRelativePathEscapingConfiguration() {
        assertNull(MambaETLProperties.resolveEtlDirectory("../../etc", appDataDirectory.toString()));
        assertNull(MambaETLProperties.resolveEtlDirectory("../../../etc/passwd", appDataDirectory.toString()));
        assertNull(MambaETLProperties.resolveEtlDirectory("..", appDataDirectory.toString()));
    }

    @Test
    public void resolveEtlDirectory_shouldRejectSiblingDirectoryWithConfigurationPrefix() {
        // guards against a string-prefix containment check
        assertNull(MambaETLProperties.resolveEtlDirectory("../configuration-backup", appDataDirectory.toString()));
    }

    @Test
    public void resolveEtlDirectory_shouldCanonicalizeAbsolutePath() throws IOException {
        File configured = new File(appDataDirectory.toFile(), "sub/../etl-absolute");

        String resolved = MambaETLProperties.resolveEtlDirectory(configured.getAbsolutePath(),
            appDataDirectory.toString());

        assertEquals(new File(appDataDirectory.toFile(), "etl-absolute").getCanonicalPath(), resolved);
    }

    @Test
    public void resolveEtlDirectory_shouldUseAbsolutePathWithoutAppDataDirectory() throws IOException {
        String absolute = appDataDirectory.toFile().getCanonicalPath();

        assertEquals(absolute, MambaETLProperties.resolveEtlDirectory(absolute, null));
    }

    @Test
    public void resolveEtlDirectory_shouldReturnNullForNullAppDataDirectoryWithRelativePath() {
        assertNull(MambaETLProperties.resolveEtlDirectory("etl-sql", null));
        assertNull(MambaETLProperties.resolveEtlDirectory("etl-sql", "   "));
    }

    @Test
    public void resolveEtlDirectory_shouldReturnNullForBlankOrNullConfiguredDirectory() {
        assertNull(MambaETLProperties.resolveEtlDirectory(null, appDataDirectory.toString()));
        assertNull(MambaETLProperties.resolveEtlDirectory("", appDataDirectory.toString()));
        assertNull(MambaETLProperties.resolveEtlDirectory("   ", appDataDirectory.toString()));
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
