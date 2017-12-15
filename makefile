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
	brew install pkg-config gnutls
	brew install emacs --with-cocoa --with-ctags --with-gnutls
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
	brew install tmate
	brew install reattach-to-user-namespace

tmate-wrapper: check-env
	cd $(DEV_HOME) && git clone https://github.com/bobbyno/tmate-wrapper.git
	cd $(DEV_HOME)/tmate-wrapper && make install

tmux:
	brew install tmux

fonts:
	cd /tmp && wget -O - http://downloads.sourceforge.net/project/dejavu/dejavu/2.34/dejavu-fonts-ttf-2.34.tar.bz2 | tar -xjf -
	mv /tmp/dejavu-fonts-ttf-2.34/ttf/* ~/Library/Fonts/

java-9:
	wget -P $$TMPDIR --no-check-certificate --no-cookies --header \
		"Cookie: oraclelicense=accept-securebackup-cookie" \
		"http://download.oracle.com/otn-pub/java/jdk/9.0.1+11/jdk-9.0.1_osx-x64_bin.dmg"
	hdiutil mount $$TMPDIR/jdk-9.0.1_osx-x64_bin.dmg
	open "/Volumes/JDK 9.0.1/JDK 9.0.1.pkg"

java-formula:
	brew install maven leiningen

homebrew: homebrew-install homebrew-formula

homebrew-install:
	ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew doctor
	# TODO: Find out what brew did with completion
	# cp /usr/local/Library/Contributions/brew_bash_completion.sh /usr/local/etc/bash_completion.d/

homebrew-formula:
	brew install aspell bash cloc coreutils curl gawk git hilite htop-osx igraph jq parallel pstree rlwrap tree unrar wget

python: python-clean python-install python-pip-install

python-clean:
	brew uninstall --force python python3
	rm -rf /usr/local/lib/python*
	rm -rf ~/Library/Python/*
	rm -f /usr/local/bin/activate.sh
	rm -f /usr/local/bin/virtualenv*
	sudo rm -rf /Library/Python/*

python-install:
	brew install python3
	cd /usr/local/bin && \
	ln -sf pip3 pip && \
	ln -sf python3 python

python-pip-install:
	pip install --upgrade pip setuptools wheel
	pip install -r common-requirements.txt
	pip install -r emacs-requirements.txt
	pip install -r stats-requirements.txt

python-pip-install-latest: python-update-requirements python-pip-install

python-update-requirements:
	./update_requirements common
	./update_requirements emacs
	./update_requirements stats

ruby-version := 2.4.2
ruby: ruby-install

ruby-update: ruby-gem-update ruby-install-default-gems

ruby-install:
	brew install rbenv ruby-build
	rbenv install $(ruby-version)
	rbenv global $(ruby-version)
	echo "gem: --no-document" > ~/.gemrc
	@echo "Now source ~/.bashrc to run 'rbenv init' in this shell before continuing with 'make ruby-update'"

ruby-gem-update:
	gem install rubygems-update
	update_rubygems
	gem update --system

ruby-install-default-gems:
	gem install bundler

intellij-idea:

	brew cask install intellij-idea
vim:
	brew install vim

bootstrap: homebrew java-9 java-formula fonts dotfiles python ruby tmate emacs intellij-idea vim finish


.SILENT: finish
finish:
	echo "Now open a new shell and test!"
