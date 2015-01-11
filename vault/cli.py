"""Vault
Usage: vault [options] [command]
	vault init <url> [<path>]
	vault clone <url> [<path>]
	vault push
	vault pull
	vault fetch
	vault checkout
	vault clean

Options:
	--debug Enable debugging output
"""
from __future__ import (
	nested_scopes,
	generators,
	division,
	absolute_import,
	with_statement,
	print_function,
	unicode_literals
)
from docopt import docopt

import os
from os.path import basename
import sys
import urllib
from vault import core

def error(msg):
	print("error: " + msg, file=sys.stderr)

def init(args):
	url = args["<url>"]
	path = args["<path>"]
	path = path or os.getcwd()
	repo, vault = core.init(url, path)
	core.encrypt(repo, vault)
	core.push(repo, vault)
	print("initialized empty vault repository in", path)

def clone(args):
	url = args["<url>"]
	path = args["<path>"]
	path = path or re.sub('\.git$', '', basename(urlib.parse(url).path))
	core.clone(args["<url>"], args["<path>"])
	print("cloned vault repository in", path)

def push(args):
	path = os.getcwd()
	repo, vault = core.open_repository(path)
	core.pull(repo, vault)
	core.encrypt(repo, vault)
	core.push(repo, vault)

def pull(args):
	path = os.getcwd()
	repo, vault = core.open_repository(path)
	core.pull(repo, vault)

def fetch(args):
	path = os.getcwd()
	repo, vault = core.open_repository(path)
	core.fetch(repo, vault)

cmds = {
	"init": init,
	"clone": clone,
	"push": push,
	"pull": pull,
	"fetch": fetch
}

def main():
	args = docopt(__doc__, version="0.1.0")
	try:
		[cmds[k](args) for k in cmds if args[k]]
	except Exception as e:
		if os.environ["DEBUG"]:
			raise
		else:
			error(e.message)
		sys.exit(1)

if __name__ == "__main__":
	main()
