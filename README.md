# Nasqueron dev workspace

Install a development workspace as a container. The container contains
a Go environment, ready to use.

## Built it, run it

```
$ git clone https://devcentral.nasqueron.org/source/docker-dev-workspace
$ docker build -t nasqueron/dev-workspace-go .
$ support/workspace.sh
```

The command `workspace` is a wrapper to run your container,
with the current directory as your workspace. It drops privileges
to the current user, building a specific image for your uid.

## Configuration

It uses the same volume than nasqueron/arcanist to share SSH, Git and
Arcanist configuration, but is built from a fresh Debian image, and
not from Nasqueron Arcanist or PHP image to be as neutral as possible.

## Flavours

Currently, we've a workspace intended for Go development, with Python
Git Arcanist in support.

It probably makes sense to create several flavours instead of trying
to package everything in one image.

### Go

Download the release specified in the GO_VERSION environment variable
at image build time, so we can provide an up-to-date Go version.

It also provides a current version of Node.js, as required by Hound build
process.

When the container is run, GOPATH is configured to `<current folder>/go`.
