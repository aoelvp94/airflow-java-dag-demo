package org.apache.airflow.sdk.api;

import java.util.HashMap;
import java.util.Map;

/**
 * Airflow task execution context
 */
public class Context {
    private final Map<String, Object> params;
    
    public Context() {
        this.params = new HashMap<>();
        this.params.put("dag_id", "demo_java_dag");
        this.params.put("run_id", "manual_" + System.currentTimeMillis());
        this.params.put("task_id", "unknown");
        this.params.put("logical_date", "2026-10-28T00:00:00+00:00");
    }
    
    public String getDagId() {
        return (String) params.getOrDefault("dag_id", "unknown");
    }
    
    public String getRunId() {
        return (String) params.getOrDefault("run_id", "unknown");
    }
    
    public String getTaskId() {
        return (String) params.getOrDefault("task_id", "unknown");
    }
    
    public String getLogicalDate() {
        return (String) params.getOrDefault("logical_date", "unknown");
    }
    
    public Object get(String key) {
        return params.get(key);
    }
    
    public void set(String key, Object value) {
        params.put(key, value);
    }
}
