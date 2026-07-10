package main

import (
	"context"
	"io"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/swagner-de/containers/testhelpers"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

const sambaImageDefault = "ghcr.io/swagner-de/containers/samba:rolling"

func TestSmbdVersion(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage(sambaImageDefault)
	testhelpers.TestCommandSucceeds(t, ctx, image, nil,
		"smbd", "--version")
}

func TestAuthenticatedShare(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage(sambaImageDefault)

	const (
		user = "testuser"
		pass = "TestPass1234"
	)
	usersConf := user + ":1000:1000:" + user + "\n"
	smbConf := `[global]
	workgroup = TEST
	server min protocol = SMB2
	log level = 1
	map to guest = never
	passdb backend = tdbsam

[testshare]
	path = /tmp
	read only = yes
	guest ok = no
	valid users = ` + user + "\n"

	c, err := testcontainers.Run(ctx, image,
		testcontainers.WithFiles(
			testcontainers.ContainerFile{Reader: strings.NewReader(usersConf), ContainerFilePath: "/config/users.conf", FileMode: 0644},
			testcontainers.ContainerFile{Reader: strings.NewReader(pass), ContainerFilePath: "/run/secrets/" + user, FileMode: 0400},
			testcontainers.ContainerFile{Reader: strings.NewReader(smbConf), ContainerFilePath: "/etc/samba/smb.conf", FileMode: 0644},
		),
		testcontainers.WithExposedPorts("445/tcp"),
		testcontainers.WithWaitStrategy(wait.ForListeningPort("445/tcp")),
	)
	testcontainers.CleanupContainer(t, c)
	require.NoError(t, err)

	// Correct credentials: listing must succeed and include our share.
	code, r, err := c.Exec(ctx, []string{
		"smbclient", "-L", "localhost", "-U", user + "%" + pass,
	})
	require.NoError(t, err)
	out, _ := io.ReadAll(r)
	require.Equalf(t, 0, code, "smbclient -L should succeed: %s", string(out))
	require.Containsf(t, string(out), "testshare", "expected share not listed:\n%s", string(out))

	// Wrong password must be rejected.
	badCode, badR, err := c.Exec(ctx, []string{
		"smbclient", "-L", "localhost", "-U", user + "%wrong",
	})
	require.NoError(t, err)
	badOut, _ := io.ReadAll(badR)
	require.NotEqualf(t, 0, badCode, "smbclient -L should fail with wrong password:\n%s", string(badOut))
}

// TestAuthenticatedShareUsersConfNoTrailingNewline covers the case where
// /config/users.conf's last line has no trailing newline (as emitted by the
// samba Helm chart's ConfigMap). The entrypoint's `while read` loop must not
// silently drop that last user.
func TestAuthenticatedShareUsersConfNoTrailingNewline(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage(sambaImageDefault)

	const (
		firstUser  = "alice"
		firstPass  = "AlicePass1234"
		secondUser = "bob"
		secondPass = "BobPass1234"
	)
	// No trailing newline on the last (bob) line — mirrors what the chart mounts.
	usersConf := firstUser + ":1000:1000:" + firstUser + "\n" +
		secondUser + ":1001:1001:" + secondUser
	smbConf := `[global]
	workgroup = TEST
	server min protocol = SMB2
	log level = 1
	map to guest = never
	passdb backend = tdbsam

[testshare]
	path = /tmp
	read only = yes
	guest ok = no
	valid users = ` + firstUser + " " + secondUser + "\n"

	c, err := testcontainers.Run(ctx, image,
		testcontainers.WithFiles(
			testcontainers.ContainerFile{Reader: strings.NewReader(usersConf), ContainerFilePath: "/config/users.conf", FileMode: 0644},
			testcontainers.ContainerFile{Reader: strings.NewReader(firstPass), ContainerFilePath: "/run/secrets/" + firstUser, FileMode: 0400},
			testcontainers.ContainerFile{Reader: strings.NewReader(secondPass), ContainerFilePath: "/run/secrets/" + secondUser, FileMode: 0400},
			testcontainers.ContainerFile{Reader: strings.NewReader(smbConf), ContainerFilePath: "/etc/samba/smb.conf", FileMode: 0644},
		),
		testcontainers.WithExposedPorts("445/tcp"),
		testcontainers.WithWaitStrategy(wait.ForListeningPort("445/tcp")),
	)
	testcontainers.CleanupContainer(t, c)
	require.NoError(t, err)

	// The user on the last (unterminated) line must still be able to authenticate.
	code, r, err := c.Exec(ctx, []string{
		"smbclient", "-L", "localhost", "-U", secondUser + "%" + secondPass,
	})
	require.NoError(t, err)
	out, _ := io.ReadAll(r)
	require.Equalf(t, 0, code, "smbclient -L as %s should succeed even without trailing newline in users.conf: %s", secondUser, string(out))
}
