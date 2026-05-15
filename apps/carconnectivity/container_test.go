package main

import (
	"context"
	"testing"

	"github.com/swagner-de/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/swagner-de/containers/carconnectivity:rolling")
	// Verify the carconnectivity module loads and can import its entry point
	testhelpers.TestCommandSucceeds(t, ctx, image, nil,
		"python", "-c", "from carconnectivity.carconnectivity_base import main; print('ok')")
}
