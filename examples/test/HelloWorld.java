package com.example.test;

import java.util.Date;
import java.util.ArrayList;
import java.util.List;

/**
 * Sample HelloWorld class for testing JAR decompiler
 */
public class HelloWorld {
    private String message;
    private static final String VERSION = "1.0.0";

    public HelloWorld() {
        this.message = "Hello, World!";
    }

    public HelloWorld(String customMessage) {
        this.message = customMessage;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void printMessage() {
        System.out.println(message);
        System.out.println("Version: " + VERSION);
        System.out.println("Time: " + new Date());
    }

    public List<Integer> generateNumbers(int count) {
        List<Integer> numbers = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            numbers.add(i * 2);
        }
        return numbers;
    }

    public static void main(String[] args) {
        HelloWorld hw = new HelloWorld();

        if (args.length > 0) {
            hw = new HelloWorld(args[0]);
        }

        hw.printMessage();

        System.out.println("Generated numbers: " + hw.generateNumbers(10));

        // Test lambda expression (Java 8+)
        Runnable r = () -> System.out.println("Lambda test!");
        r.run();

        // Test try-with-resources
        try {
            performComplexOperation();
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void performComplexOperation() throws Exception {
        // Nested class example
        class LocalClass {
            void doSomething() {
                System.out.println("Local class method");
            }
        }

        LocalClass lc = new LocalClass();
        lc.doSomething();

        // Simulate some work
        Thread.sleep(100);
        System.out.println("Complex operation completed");
    }

    // Inner class example
    public static class InnerHelper {
        public static void help() {
            System.out.println("This is a helper class");
        }
    }
}