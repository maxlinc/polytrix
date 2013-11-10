import groovy.util.Eval;

code = System.in.withReader { it.getText() }.toString()
Binding binding = new Binding();
// binding.setProperty("out",new PrintWriter(System.out,true));
binding.setProperty("out",System.out);
binding.setProperty("stdin",System.out);
binding.setProperty("stdout",System.out);
binding.setProperty("stderr",System.err);
GroovyShell shell = new GroovyShell(binding);
shell.evaluate(code);
