from __future__ import (
	nested_scopes,
	generators,
	division,
	absolute_import,
	with_statement,
	print_function,
	unicode_literals
)
import os
import shutil
from os.path import join as join_paths
import pygit2 as git
import tarfile

def open_repository(path):
	repo = git.Repository(path)
	vault = git.Repository(vault_path(repo))
	return (repo, vault)

def init(url, path):
	repo, vault = clone_fresh(url, path)
	if not vault.is_empty:
		raise Exception("remote vault was not empty")
	with open(join_paths(path, ".gitignore"), 'w') as f:
		print(".vault/", file=f)
	repo.index.add(".gitignore")
	commit(repo, "initialized empty vault repository")
	return (repo, vault)

def clone(url, path):
	repo, vault = clone_fresh(url, path)
	fetch(repo, vault)
	commit = repo.get(origin_master(repo).target)
	repo.create_branch("master", commit)
	repo.checkout("refs/heads/master")

def push(repo, vault):
	vault.index.add("vault")
	commit(vault, "vault: " + str(repo.head.target))
	print("pushing to", origin(vault).url)
	origin(vault).push("refs/heads/master")

def pull(repo, vault):
	fetch(repo, vault)
	oid = origin_master(repo).target
	print("checking to see if a merge is required", repo.path)
	merge_result, _ = repo.merge_analysis(oid)
	if merge_result & git.GIT_MERGE_ANALYSIS_UP_TO_DATE:
		print("pull: up to date")
		return
	elif merge_result & git.GIT_MERGE_ANALYSIS_FASTFORWARD:
		print("pull: fast-forwarding")
		repo.head.set_target(oid)
		repo.checkout_head()
	elif merge_result & git.GIT_MERGE_ANALYSIS_NORMAL:
		raise Exception("conflicts encountered during pull. please resolve against origin/master by using git rebase or merge")
	else:
		raise Exception("merge analysis returned an unexpected result")

def fetch(repo, vault):
	print("fetching from", origin(vault).url)
	origin(vault).fetch()
	vault.reset(origin_master(vault).target, git.GIT_RESET_HARD)
	decrypt(vault, lambda path: origin(repo).fetch())

def vault_path(repo):
	return join_paths(repo.workdir, ".vault")

def staging_path(vault):
	return join_paths(vault.workdir, ".staging")

def origin(repo):
# repo.remotes is supposed to support
# repo.remotes["origin"], but doesn't work
	return next(r for r in repo.remotes if r.name == "origin")

def origin_master(repo):
	return repo.lookup_reference("refs/remotes/origin/master")

def commit(repo, msg, parents = []):
	if not repo.head_is_unborn:
		parents.insert(0, repo.head.target)
	repo.index.write()
	return repo.create_commit(
		"refs/heads/master",
		repo.default_signature,
		repo.default_signature,
		msg,
		repo.index.write_tree(),
		parents
	)

def encrypt(repo, vault):
# TODO currently just writes a tar archive
# need to additionally encrypt this archive
	path = join_paths(vault.workdir, "vault")
	with tarfile.open(path, "w") as archive:
		archive.add(repo.path, ".staging")
	return path

def decrypt(vault, cb):
# TODO implement actual decryption once encrypt is actually encrypting
	safe = join_paths(vault.workdir, "vault")
	staging = join_paths(vault.workdir, ".staging")
	with tarfile.open(safe, "r") as archive:
		archive.extractall(vault.workdir)
	try:
		cb(staging)
	finally:
		shutil.rmtree(staging)

def clone_fresh(url, path):
	# TODO calling discover_repository throws an exception
	#if git.discover_repository(path):
		#raise Exception("directory is already a git directory or subdirectory thereof")
	repo = git.init_repository(path)
	print("cloning from", url, "into", vault_path(repo))
	vault = git.clone_repository(url, vault_path(repo))
	repo.create_remote("origin", "file://" + staging_path(vault))
	return (repo, vault)
