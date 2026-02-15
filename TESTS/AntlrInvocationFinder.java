import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;
import java.util.*;

/**
 * ANTLR-based analysis tool for Java 1.2.
 * Identifies method and constructor invocations in input files.
 */
public class AntlrInvocationFinder {

    /**
     * Represents a found method/constructor invocation.
     */
    static class InvocationInfo {
        String expression;
        String fileName;
        int line;
        int column;

        InvocationInfo(String expression, String fileName, int line, int column) {
            this.expression = expression;
            this.fileName = fileName;
            this.line = line;
            this.column = column;
        }

        @Override
        public String toString() {
            return expression + ": file " + fileName + ", line " + line + ", column " + column;
        }
    }

    /**
     * Listener that walks the parse tree and collects method/constructor invocations.
     */
    static class InvocationListener extends Java12ParserBaseListener {
        List<InvocationInfo> invocations = new ArrayList<>();
        String fileName;
        CommonTokenStream tokens;

        InvocationListener(String fileName, CommonTokenStream tokens) {
            this.fileName = fileName;
            this.tokens = tokens;
        }

        /**
         * Detect method invocations in postfixExpression.
         * A method invocation is: primary (. Identifier)* arguments
         * We look for the pattern where 'arguments' appears as a suffix.
         */
        @Override
        public void enterPostfixExpression(Java12Parser.PostfixExpressionContext ctx) {
            // Walk through the children to find argument lists (method calls)
            // The postfixExpression rule is:
            //   primary (DOT Identifier | DOT THIS | ... | arguments | ...)*
            // We need to detect each 'arguments' child and reconstruct the expression

            List<ParseTree> children = ctx.children;
            if (children == null) return;

            // Build expression prefix as we go
            StringBuilder exprBuilder = new StringBuilder();
            // Start with the primary
            Java12Parser.PrimaryContext primary = ctx.primary();
            if (primary != null) {
                exprBuilder.append(getExpressionText(primary));
            }

            for (int i = 1; i < children.size(); i++) {
                ParseTree child = children.get(i);
                String childText = child.getText();

                if (child instanceof Java12Parser.ArgumentsContext) {
                    // This is a method/constructor invocation
                    Java12Parser.ArgumentsContext args = (Java12Parser.ArgumentsContext) child;
                    String callExpr = exprBuilder.toString();

                    // Reconstruct the full invocation expression with arguments
                    String fullExpr = callExpr + getArgumentsText(args);

                    // Get position - use the start of the expression
                    Token startToken = getPrimaryStartToken(ctx, primary);
                    if (startToken != null) {
                        invocations.add(new InvocationInfo(
                            fullExpr,
                            fileName,
                            startToken.getLine(),
                            startToken.getCharPositionInLine() + 1 // 1-based column
                        ));
                    }
                } else if (childText.equals(".")) {
                    exprBuilder.append(".");
                } else if (child instanceof TerminalNode) {
                    TerminalNode tn = (TerminalNode) child;
                    int tokenType = tn.getSymbol().getType();
                    if (tokenType == Java12Lexer.Identifier ||
                        tokenType == Java12Lexer.THIS ||
                        tokenType == Java12Lexer.SUPER ||
                        tokenType == Java12Lexer.CLASS) {
                        exprBuilder.append(childText);
                    } else if (tokenType == Java12Lexer.LBRACKET) {
                        // Array access - just append
                        exprBuilder.append("[");
                    } else if (tokenType == Java12Lexer.RBRACKET) {
                        exprBuilder.append("]");
                    } else if (tokenType == Java12Lexer.INC) {
                        exprBuilder.append("++");
                    } else if (tokenType == Java12Lexer.DEC) {
                        exprBuilder.append("--");
                    }
                } else if (child instanceof Java12Parser.ExpressionContext) {
                    // Array index expression
                    exprBuilder.append(child.getText());
                } else if (child instanceof Java12Parser.InnerCreatorContext) {
                    // inner new - record as constructor invocation
                    Java12Parser.InnerCreatorContext inner = (Java12Parser.InnerCreatorContext) child;
                    String newExpr = exprBuilder.toString() + "new " + inner.getText();
                    Token newToken = ((TerminalNode) children.get(i - 1)).getSymbol(); // NEW token
                    // This is handled in enterCreator
                }
            }
        }

        /**
         * Detect constructor invocations via 'new'.
         */
        @Override
        public void enterCreator(Java12Parser.CreatorContext ctx) {
            if (ctx.classCreatorRest() != null) {
                // This is a "new ClassName(...)" invocation
                String typeName = ctx.classOrInterfaceType().getText();
                String argsText = getClassCreatorRestArgsText(ctx.classCreatorRest());
                String fullExpr = "new " + typeName + argsText;

                // Get position of 'new' keyword - look at parent
                ParserRuleContext parent = ctx.getParent();
                Token newToken = findNewKeyword(parent);
                if (newToken != null) {
                    invocations.add(new InvocationInfo(
                        fullExpr,
                        fileName,
                        newToken.getLine(),
                        newToken.getCharPositionInLine() + 1
                    ));
                }
            }
        }

        /**
         * Detect explicit constructor invocations: this(...) and super(...)
         */
        @Override
        public void enterExplicitConstructorInvocation(Java12Parser.ExplicitConstructorInvocationContext ctx) {
            String expr;
            Token startToken;
            if (ctx.THIS() != null) {
                expr = "this(" + getArgumentListText(ctx.argumentList()) + ")";
                startToken = ctx.THIS().getSymbol();
            } else if (ctx.SUPER() != null) {
                // Could be simple super(...) or qualified primary.super(...)
                if (ctx.primary() != null) {
                    expr = getExpressionText(ctx.primary()) + ".super(" +
                           getArgumentListText(ctx.argumentList()) + ")";
                    startToken = ((ParserRuleContext) ctx.primary()).getStart();
                } else {
                    expr = "super(" + getArgumentListText(ctx.argumentList()) + ")";
                    startToken = ctx.SUPER().getSymbol();
                }
            } else {
                return;
            }

            invocations.add(new InvocationInfo(
                expr,
                fileName,
                startToken.getLine(),
                startToken.getCharPositionInLine() + 1
            ));
        }

        // ---- Helper methods ----

        private Token getPrimaryStartToken(Java12Parser.PostfixExpressionContext ctx,
                                           Java12Parser.PrimaryContext primary) {
            if (primary != null) {
                return primary.getStart();
            }
            return ctx.getStart();
        }

        private String getExpressionText(ParseTree tree) {
            if (tree == null) return "";
            return tokens.getText(
                ((ParserRuleContext) tree).getSourceInterval()
            );
        }

        private String getArgumentsText(Java12Parser.ArgumentsContext ctx) {
            if (ctx == null) return "()";
            return tokens.getText(ctx.getSourceInterval());
        }

        private String getArgumentListText(Java12Parser.ArgumentListContext ctx) {
            if (ctx == null) return "";
            return tokens.getText(ctx.getSourceInterval());
        }

        private String getClassCreatorRestArgsText(Java12Parser.ClassCreatorRestContext ctx) {
            if (ctx == null) return "()";
            // Reconstruct just the arguments portion
            StringBuilder sb = new StringBuilder("(");
            if (ctx.argumentList() != null) {
                sb.append(tokens.getText(ctx.argumentList().getSourceInterval()));
            }
            sb.append(")");
            return sb.toString();
        }

        private Token findNewKeyword(ParserRuleContext ctx) {
            if (ctx == null) return null;
            for (int i = 0; i < ctx.getChildCount(); i++) {
                ParseTree child = ctx.getChild(i);
                if (child instanceof TerminalNode) {
                    Token t = ((TerminalNode) child).getSymbol();
                    if (t.getType() == Java12Lexer.NEW) {
                        return t;
                    }
                }
            }
            // Try parent's parent if primary context
            return findNewKeyword(ctx.getParent());
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java AntlrInvocationFinder <file1.java> [file2.java ...]");
            System.exit(1);
        }

        List<InvocationInfo> allInvocations = new ArrayList<>();

        for (String filePath : args) {
            File file = new File(filePath);
            String fileName = file.getName();

            CharStream input = CharStreams.fromPath(file.toPath());
            Java12Lexer lexer = new Java12Lexer(input);
            CommonTokenStream tokenStream = new CommonTokenStream(lexer);
            Java12Parser parser = new Java12Parser(tokenStream);

            // Parse the compilation unit
            ParseTree tree = parser.compilationUnit();

            if (parser.getNumberOfSyntaxErrors() > 0) {
                System.err.println("Parse errors found in " + fileName);
                continue;
            }

            // Walk the tree and find invocations
            InvocationListener listener = new InvocationListener(fileName, tokenStream);
            ParseTreeWalker walker = new ParseTreeWalker();
            walker.walk(listener, tree);

            allInvocations.addAll(listener.invocations);
        }

        // Print results
        System.out.println(allInvocations.size() + " method/constructor invocation(s) found in the input file(s)");
        System.out.println();
        for (InvocationInfo inv : allInvocations) {
            System.out.println(inv);
        }
    }
}
