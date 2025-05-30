#!/usr/bin/env bats
load test_helper

setup() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l || true
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" service-with-dashes || true
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l || true
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" service-with-dashes || true
}

@test "($PLUGIN_COMMAND_PREFIX:create) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" l
  assert_contains "${lines[*]}" "container created: l"
}

@test "($PLUGIN_COMMAND_PREFIX:create) service with dashes" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" service-with-dashes
  assert_contains "${lines[*]}" "container created: service-with-dashes"
  assert_contains "${lines[*]}" "dokku-$PLUGIN_COMMAND_PREFIX-service-with-dashes"
  assert_contains "${lines[*]}" "service_with_dashes"
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:create) error when there is an invalid name specified" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" d.erp
  assert_failure
}

@test "($PLUGIN_COMMAND_PREFIX:create) SSL enabled by default" {
  run dokku "$PLUGIN_COMMAND_PREFIX:create" l
  assert_contains "${lines[*]}" "Securing connection to database"
  test -f /var/lib/dokku/services/bitnami-postgres/l/persistence/dokku-certs/server.crt
  test -f /var/lib/dokku/services/bitnami-postgres/l/persistence/dokku-certs/server.key
}

@test "($PLUGIN_COMMAND_PREFIX:create) SSL disabled" {
  run env POSTGRESQL_ENABLE_TLS=no dokku "$PLUGIN_COMMAND_PREFIX:create" l
  test ! -f /var/lib/dokku/services/bitnami-postgres/l/persistence/dokku-certs/server.crt
  test ! -f /var/lib/dokku/services/bitnami-postgres/l/persistence/dokku-certs/server.key
}
