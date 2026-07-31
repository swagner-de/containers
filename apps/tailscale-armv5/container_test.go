package main

import (
	"context"
	"testing"

	"github.com/swagner-de/containers/testhelpers"
)

const tailscaleImageDefault = "ghcr.io/swagner-de/containers/tailscale-armv5:rolling"

// TestTailscaleVersion runs the cross-compiled armv5 binary and asserts it
// executes cleanly (exit 0) instead of dying with SIGILL — the whole reason
// this image exists. Requires arm/v5 binfmt/qemu on the test host.
func TestTailscaleVersion(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage(tailscaleImageDefault)
	testhelpers.TestCommandSucceeds(t, ctx, image, nil, "tailscale", "version")
}
