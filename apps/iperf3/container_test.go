package main

import (
	"context"
	"io"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/swagner-de/containers/testhelpers"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

const iperf3ImageDefault = "ghcr.io/swagner-de/containers/iperf3:rolling"

// TestServerRoundtrip starts the container in its default server mode and,
// from inside the same container, runs the iperf3 client against 127.0.0.1
// over both TCP and UDP. This exercises the compiled binary end-to-end
// without needing a second image or a custom docker network.
func TestServerRoundtrip(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage(iperf3ImageDefault)

	c, err := testcontainers.Run(ctx, image,
		testcontainers.WithExposedPorts("5201/tcp"),
		testcontainers.WithWaitStrategy(wait.ForListeningPort("5201/tcp")),
	)
	testcontainers.CleanupContainer(t, c)
	require.NoError(t, err)

	t.Run("TCP", func(t *testing.T) {
		code, r, err := c.Exec(ctx, []string{
			"/iperf3", "-c", "127.0.0.1", "-t", "1", "--json",
		})
		require.NoError(t, err)
		out, _ := io.ReadAll(r)
		require.Equalf(t, 0, code, "TCP client should succeed:\n%s", string(out))
	})

	t.Run("UDP", func(t *testing.T) {
		code, r, err := c.Exec(ctx, []string{
			"/iperf3", "-c", "127.0.0.1", "-u", "-t", "1", "--json",
		})
		require.NoError(t, err)
		out, _ := io.ReadAll(r)
		require.Equalf(t, 0, code, "UDP client should succeed:\n%s", string(out))
	})
}
