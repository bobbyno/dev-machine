# Dev Machine
A simple, highly opinionated automated setup for an OS X developer workstation.

## TLTR
1. Generate a new key for your computer and add it to github. You may use the `$: make generate-ssh-key KEY_NAME=MY_NEW_KEY` from this project
  1.1. `$: git config --global user.name "YOUR_NAME"`
  1.2. `$: git config --global user.email "YOUR_GIT_EMAILI"`
2. Install iterm
3. Create a common directory root for your software development
4. Find and replace `bashrc` in the `makefile`, if you use anything other than bashrc.
5. Update your command tool: softwareupdate --all --install --force
6. Update your `dotfiles` and put them to github
7. Export following env. variables:
  7.1. `export GITHUB_USER=user_name`
  7.2. Common directory root for your software development, i.e. for **~/dev** use `export DEV_HOME="~/dev"`
  7.3. Add the following to your **.bashrc**
    * ```
      # python env: virtualenv, virtualenvwrapper, and autoenv
      export WORKON_HOME=$DEV_HOME/.virtualenvs
      export PROJECT_HOME=$DEV_HOME
      export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
      export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
      source /usr/local/bin/virtualenvwrapper.sh
      source /usr/local/bin/activate.sh
      # end python env
      ```
  7.4. source `~/.bashrc`
  7.5. Run `$: make bootstrap` to install everything, or run individual targets by themselves

## Prerequisites
Install the Xcode command line developer tools:
`xcode-select --install`

In the dialog, just choose the command line tools. You won't
need the full Xcode unless you're building Cocoa apps.

## Installation

### Set GITHUB_USER for emacs.d and dotfiles
The installation script will attempt to download two repositories from Github called
`emacs.d` and `dotfiles`. Set a GITHUB_USER environment variable to the name of the
account where these repos can be found: `export GITHUB_USER=user_name`

If you don't already have these repos, and want to have something you can customize, 
you can [fork](https://github.com/bobbyno/dotfiles) [mine](https://github.com/bobbyno/emacs.d).

### Set DEV_HOME for the root directory of where you hack
This script assumes you use a common directory root for your software development.
If you want to use `~/dev`, for example, then `export DEV_HOME="~/dev"`.

### Running
To install everything: `$: make bootstrap`

Have a look at the `makefile` to see what's included. Run individual targets if you
don't need everything.

## What opinions are included?

#### Python
To ensure repeatablity, `$: make python` starts with a clean slate by removing any
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
pip3 install --upgrade pip3 setuptools
```

Add a requirements.txt that installs the dependencies in setup.py, if applicable,
along with dev/test dependencies pegged to a specific version:

```
--index-url https://pypi.python.org/simple/

# equivalent to python setup.py develop
-e .

numpy~=1.22.1
scipy~=1.7.3
matplotlib==3.5.1
statsmodels==0.13.1
pandas==1.4.0
notebook==6.4.7
pytest==6.2.5
networkx==2.6.3
scikit-learn==1.0.2
moto==3.0.0
httmock==1.4.0
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

`$: make install-latest-requirements`

This allows the requirements files to be updated in discrete intervals.

### ...and other opinionated choices
Check the `makefile` for more information.
