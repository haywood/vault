from setuptools import setup

setup(
	name = "vault",
	url = "github.com/haywood/vault",
	version = "0.1.0",
	install_requires = [
			'docopt',
			'pygit2',
			'python-gnupg'
	]
)
