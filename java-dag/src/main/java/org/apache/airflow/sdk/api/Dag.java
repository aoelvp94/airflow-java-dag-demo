package org.apache.airflow.sdk.api;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to define an Airflow DAG
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Dag {
    String dagId();
    String description() default "";
    String schedule() default "@daily";
    String[] tags() default {};
}
