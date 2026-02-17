package javacc;

import java.io.*;
import java.util.List;

/**
 * Driver for the JavaCC-based Java 1.2 invocation finder.
 */
public class JavaccInvocationFinder {

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java javacc.JavaccInvocationFinder <file1.java> [file2.java ...]");
            System.exit(1);
        }

        int totalInvocations = 0;
        java.util.List<Java1_2JavaCCParserAnalysis.InvocationInfo> allInvocations =
            new java.util.ArrayList<Java1_2JavaCCParserAnalysis.InvocationInfo>();

        for (String filePath : args) {
            File file = new File(filePath);
            String fileName = file.getName();

            try {
                FileInputStream fis = new FileInputStream(file);
                Java1_2JavaCCParserAnalysis parser = new Java1_2JavaCCParserAnalysis(fis);
                parser.setFileName(fileName);
                parser.CompilationUnit();

                allInvocations.addAll(parser.getInvocations());
            } catch (ParseException e) {
                System.err.println("Parse error in " + fileName + ": " + e.getMessage());
            }
        }

        System.out.println(allInvocations.size()
            + " method/constructor invocation(s) found in the input file(s)");
        System.out.println();
        for (Java1_2JavaCCParserAnalysis.InvocationInfo inv : allInvocations) {
            System.out.println(inv);
        }
    }
}
