package io.github.aoelvp94.airflow.hello;

import org.apache.airflow.sdk.Bundle;
import org.apache.airflow.sdk.Server;

public class Main {
  public static void main(String[] args) {
    Server.create(args).serve(new Bundle().register(HelloDag.class));
  }
}
