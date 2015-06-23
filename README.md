# Dev Machine

A simple automated setup for an OS X dev workstation.

## Prerequisites

Install the Xcode command line developer tools:
`xcode-select --install`

In the dialog, just choose the command line tools. You won't
need the full Xcode unless you're building Cocoa apps.

## Installation

The installation script will attempt to download your `emacs.d` and `dotfiles`
repositories from an account on github, presumably yours.

The installation script will attempt to download your `emacs.d`
and `dotfiles` repositories from an account on github, presumably yours.
If you don't already have these, you can fork mine: [dotfiles](https://github.com/bobbyno/dotfiles) [emacs.d](https://github.com/bobbyno/emacs.d).

Set a GITHUB_USER environment variable to the name of the account: `export GITHUB_USER=user_name`

To install everything: `make bootstrap`

Have a look at the `makefile` to see what's included.

## Components

#### Python

To ensure repeatablity, `make python` starts with a clean slate by removing any
Python libraries previously installed by OS X or homebrew.

When the script completes, add the following to your .bashrc if you don't already have it:

```
# python env: virtualenv, virtualenvwrapper, and autoenv
export WORKON_HOME=$HOME/dev/.virtualenvs
export PROJECT_HOME=$HOME/dev
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
source /usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/activate.sh
# end python env
```

Open a new shell to start with a fresh env. Close your old shell.

You now have virtual environments with a few libraries installed.

common-requirements.txt contains concerns _truly common_ to all python projects.
Add sparingly to this list.

emacs-requirements.txt contains flake8 and jedi and assumes you're using elpy.

The libraries installed in this top-level brew python installation will be visible in
virtualenv's.

#### `virtualenv` workflow

Here's an example of how to use virtual environments to create a stats workspace.

```
mkvirtualenv stats
pip install --upgrade pip setuptools
```

Add a requirements.txt that installs the dependencies in setup.py, if applicable,
along with dev/test dependencies pegged to a specific version:

```
--index-url https://pypi.python.org/simple/

# equivalent to python setup.py develop
-e .

numpy==1.9.2
scipy==0.15.1
matplotlib==1.4.3
statsmodels==0.6.1
pandas==0.15.2
ipython[notebook]==3.0.0
pytest==2.6.4
networkx==1.9.1
scikit-learn==0.15.2
moto==0.4.1
pytest==2.6.4
httmock==1.2.3
```

Create a .env file for autoenv to enter the virtualenv whenever you cd into
this project directory:

```
#!/usr/bin/env bash

name=stats

if [[ "`dirname "${BASH_SOURCE}"`" == "`pwd`" && -z "`echo $VIRTUAL_ENV | grep $name`" ]]; then workon $name; fi
```

Now cd into the project directory, or `cd .` if you're already there.
Answer `y` to allow the `.env` file to be sourced; you'll only need
to do this the first time.

`pip install -r requirements.txt`

`pip list` should show you only the dependencies for this project.

Read more about a `virtualenv` workflow in the [Python Guide](http://docs.python-guide.org/en/latest/dev/virtualenvs/#id3).

#### Updating dependencies in requirements.txt

Use the update_requirements script to generate an updated requirements.txt from
a manifest file that lists dependencies without versions, then install the new requirements:

`make install-latest-requirements`

This allows the requirements files to be updated in discrete intervals.
