SHELL := /usr/bin/env bash

emacsd = $(DEV_HOME)/emacs.d
oldemacs = /tmp/emacs

help:
	@echo make bootstrap

.SILENT: check-env
check-env:
	[ ! -z "$(GITHUB_USER)" ] || { echo "You need to export GITHUB_USER" ; exit 1 ; }
	[ ! -z "$(DEV_HOME)" ]    || { echo "You need to export DEV_HOME"    ; exit 1 ; }

$(oldemacs):
	if [ ! -d $(oldemacs) ]; then mkdir $(oldemacs); fi

clean-old-emacs: $(oldemacs)
	-sudo mv /usr/bin/emacs $(oldemacs)
	-sudo mv /usr/share/emacs $(oldemacs)/share-emacs
	-sudo mv /usr/bin/emacs-undumped $(oldemacs)
	if [ -d /Applications/Emacs.app ]; then mv /Applications/Emacs.app $(oldemacs); fi

emacs: clean-old-emacs $(emacsd)
	brew install emacs --with-cocoa --with-ctags
	brew linkapps emacs
	@echo MANUAL STEP:
	@echo "Now you need to update the list of packages in emacs."
	@echo "Run emacs, then run M-x list-packages."
	@echo "Close emacs, then open it again. When it loads this time, it will be able to install the packages."

$(emacsd): check-env $(DEV_HOME)
	if [ ! -d $@ ]; then cd $(DEV_HOME) && git clone git@github.com:$(GITHUB_USER)/emacs.d.git; fi
	cd $@ && make install

$(DEV_HOME): check-env
	if [ ! -d $@ ]; then mkdir $@; fi

dotfiles: check-env $(DEV_HOME)
	cd $(DEV_HOME) && git clone git@github.com:$(GITHUB_USER)/dotfiles.git
	cd $(DEV_HOME)/dotfiles && ./install

tmate: tmux tmate-install tmate-wrapper

tmate-install:
	brew tap nviennot/tmate
	brew install tmate
	brew install reattach-to-user-namespace

tmate-wrapper: check-env
	cd $(DEV_HOME) && git clone https://github.com/bobbyno/tmate-wrapper.git
	cd $(DEV_HOME)/tmate-wrapper && make install

tmux:
# tmux 1.8 for tmate compatibility
	brew install https://raw.githubusercontent.com/Homebrew/homebrew/c356bf77400b0d1ca83431330bf0750741fc24b1/Library/Formula/tmux.rb

fonts:
	cd /tmp && wget -O - http://downloads.sourceforge.net/project/dejavu/dejavu/2.34/dejavu-fonts-ttf-2.34.tar.bz2 | tar -xjf -
	mv /tmp/dejavu-fonts-ttf-2.34/ttf/* ~/Library/Fonts/

java:
	wget -P $$TMPDIR --no-check-certificate --no-cookies --header \
		"Cookie: oraclelicense=accept-securebackup-cookie" \
		"http://download.oracle.com/otn-pub/java/jdk/8u40-b25/jdk-8u40-macosx-x64.dmg"
	hdiutil mount $$TMPDIR/jdk-8u40-macosx-x64.dmg

java-libs:
	brew install maven leiningen

homebrew:
	ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew doctor
	brew install bash git tree wget unrar docker htop-osx
	cp /usr/local/Library/Contributions/brew_bash_completion.sh /usr/local/etc/bash_completion.d/

python: python-clean python-install python-pip-install

python-clean:
	brew uninstall --force python
	rm -rf /usr/local/lib/python2.7/site-packages
	rm -rf ~/Library/Python/2.7/lib/python/site-packages/*
	rm -f /usr/local/bin/activate.sh
	rm -f /usr/local/bin/virtualenv*
	sudo rm -rf /Library/Python/2.7/site-packages/*

python-install:
	brew install python

python-pip-install:
	pip install --upgrade pip setuptools
	pip install -r common-requirements.txt
	pip install -r emacs-requirements.txt

update-requirements:
	./update_requirements common-manifest common-requirements.txt
	./update_requirements emacs-manifest emacs-requirements.txt

install-latest-requirements: update-requirements python-pip-install

bootstrap: homebrew java java-libs fonts dotfiles python tmate emacs finish

.SILENT: finish
finish:
	echo "Now open a new shell and test!"
