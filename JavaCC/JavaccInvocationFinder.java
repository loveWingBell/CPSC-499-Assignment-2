package javacc;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * JavaCC-based invocation analysis driver for Java 1.2.
 *
 * Usage:
 *   java javacc.JavaCCInvocationFinder <file1.java> [file2.java ...]
 *
 * Prints:
 *   <N> method/constructor invocation(s) found in the input file(s)
 *
 *   <expression>: file <id>, line <#>, column <#>
 *
 * Notes:
 * - Continues across files even if one file has parse errors.
 * - Column values are 1-based (JavaCC Token.beginColumn is 1-based).
 */
public final class JavaCCInvocationFinder {

    public static void main(String[] args) {
        if (args == null || args.length == 0) {
            System.err.println("Usage: java javacc.JavaCCInvocationFinder <file1.java> [file2.java ...]");
            System.exit(2);
        }

        final List all = new ArrayList();

        for (int i = 0; i < args.length; i++) {
            String fileName = args[i];
            if (fileName == null || fileName.trim().length() == 0) continue;

            // Reject files that don't have a .java extension
            if (!fileName.endsWith(".java")) {
                System.err.println("[JavaCC] Skipping non-Java file: " + fileName
                        + " (only .java files are supported)");
                continue;
            }

            InputStream in = null;
            try {
                in = new FileInputStream(fileName);
                Java1_2JavaCCParserAnalysis parser = new Java1_2JavaCCParserAnalysis(in);
                parser.setFileName(fileName);
                parser.CompilationUnit();
                all.addAll(parser.getInvocations());
            } catch (Throwable t) {
                // Keep going so the test harness can report invalid files without stopping the whole run.
                // (The harness can separately validate non-zero exit codes if desired.)
                System.err.println("[JavaCC] Failed to parse " + fileName + ": " + t.getClass().getSimpleName()
                        + (t.getMessage() != null ? (": " + t.getMessage()) : ""));
            } finally {
                if (in != null) {
                    try { in.close(); } catch (Exception e) { /* ignore */ }
                }
            }
        }

        System.out.println(all.size() + " method/constructor invocation(s) found in the input file(s)");
        System.out.println();

        for (int i = 0; i < all.size(); i++) {
            System.out.println(all.get(i).toString());
        }
    }
}