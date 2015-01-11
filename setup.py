from setuptools import setup

setup(
	name = "vault",
	url = "github.com/haywood/vault",
	version = "0.1.0",
	packages=["vault"],
	entry_points={
		"console_scripts": [
			"vault = vault.cli:main"
		]
	},
	install_requires = [
			"docopt",
			"pygit2",
			"python-gnupg"
	]
)
