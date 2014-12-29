# Vault

This repository is for my experimentation with encrypting git repositories.
It is not recommended for use by anyone at the moment.

The purpose of vault is to manage encrypted git repositories. The end user uses
vault to gain access to this encrypted git repository, and make changes to it
using normal git commands. When done making changes the user runs `vault push`
in order to encrypt and transmit their changes to a normal git server, in
the form of a single toplevel file named `vault`.

# Concepts

## Content

The decrytped contents of the git repository.

## Vault

The local copy of the encrypted git repository.

## Remote

The remote copy of the encrypted git repository.

# Commands

## Init

Initializes the given remote as a new vault repository, and performs a clone
into the current working directory.

## Clone

Clone the given remote into either the given directory or a directory matching
the name of the remote repository. Sets up a `.vault` directory, which is a bare
git repository pointing to the remote. Also sets up `.vault.json`, which contains
configuration information about the remote.

## Push

Run [pull](#pull) to test that the histories are reconcilable.
Then encrypt the .git directory, commit it to [vault](#vault),
and push to [remote](#remote).

Expected workflow is something like:

    cd <content-repo>
    ... # do some work
    git add f1 f2 ...
    git commit -m 'did some work'
    vault push

## Pull

Run [fetch](#fetch), and then `git pull --rebase` from the temporary directory into [content](#content).

## Fetch

Fetch changes from `remote` into `vault`, decrypt into a temporary directory,
and then fetch from there to `content`. The temporary directory is removed
when the command exists.

## Reset

Reset `vault` to `remote` (this does not run fetch).

## Clean

Delete the work tree and .git directory in `content`. Requires that the
current checkout in `content` is clean.
