# Dev Machine

A simple automated setup for an OS X dev workstation.

## Prerequisites

### Xcode command line tools

Install the Xcode command line developer tools:
`xcode-select --install`

In the dialog, just choose the command line tools. You won't
need the full Xcode unless you're building Cocoa apps.

### Github user

The installation script will attempt to download your `emacs.d`
and `dotfiles` repositories from an account on github, presumably yours.
Set the GITHUB_USER environment variable to the name of the account:

`export GITHUB_USER=user_name`

## Installation

`make bootstrap`
