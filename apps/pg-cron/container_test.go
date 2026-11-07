package main

import "testing"

// pg-cron is a CloudNativePG ImageVolume extension built FROM scratch: it ships
// only the pg_cron /lib and /share files and has no runnable process, so there
// is nothing for testcontainers to start. End-to-end behaviour (mounting the
// extension, loading it via shared_preload_libraries and CREATE EXTENSION) is
// exercised by deploying it into a real CNPG cluster, not from here. This no-op
// test exists so the CI `go test ./apps/pg-cron/...` step has a package to run.
func TestNoop(t *testing.T) {}
