SHELL := /usr/bin/env bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
emacsd = $(DEV_HOME)/emacs.d
oldemacs = /tmp/emacs

.SILENT: check-env

list:
	###########################################################################################################
	# You may choose to put the following in your bashrc or equivalent for tab-completion:										#
	# 	complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' ?akefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make 		#
	###########################################################################################################
	@grep '^[^#[:space:]].*:' Makefile

help:
	@echo make bootstrap

bootstrap: homebrew java-9 java-formula fonts dotfiles python python-pip-install-latest ruby tmate emacs intellij-idea vim docker-desktop sublime atom chrome postgresql postman finish

check-env:
	[ ! -z "$(GITHUB_USER)" ] || { echo "You need to export GITHUB_USER" ; exit 1 ; }
	[ ! -z "$(DEV_HOME)" ]    || { echo "You need to export DEV_HOME"    ; exit 1 ; }

$(oldemacs):
	if [ ! -d $(oldemacs) ]; then mkdir $(oldemacs); fi

$(emacsd): check-env $(DEV_HOME)
	if [ ! -d $@ ]; then cd $(DEV_HOME) && git clone git@github.com:$(GITHUB_USER)/emacs.d.git; fi
	cd $@ && make install

$(DEV_HOME): check-env
	if [ ! -d $@ ]; then mkdir $@; fi

homebrew: homebrew-install homebrew-formula homebrew-remote-productivity

homebrew-install:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo 'eval "$(opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
	eval "$(/opt/homebrew/bin/brew shellenv)"
	# ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew doctor
	sudo chown -R $(whoami) $(brew --prefix)/*
	# TODO: Find out what brew did with completion
	# cp /usr/local/Library/Contributions/brew_bash_completion.sh /usr/local/etc/bash_completion.d/


homebrew-formula:
	brew install aspell bash cloc coreutils curl gawk git hilite htop-osx igraph jq pstree rlwrap tree wget gzip

homebrew-remote-productivity:
	brew zoom miro slack 1password

java-17-x64:
	wget -P $$TMPDIR --no-check-certificate --no-cookies --header \
		"Cookie: oraclelicense=accept-securebackup-cookie" \
		"https://download.oracle.com/java/17/latest/jdk-17_macos-x64_bin.tar.gz"
	tar xvzf $$TMPDIR/jdk-17_macos-x64_bin.tar.gz

java-formula:
	brew install maven

fonts:
	cd /tmp && wget -O - http://downloads.sourceforge.net/project/dejavu/dejavu/2.34/dejavu-fonts-ttf-2.34.tar.bz2 | tar -xjf -
	mv /tmp/dejavu-fonts-ttf-2.34/ttf/* ~/Library/Fonts/

dotfiles: check-env $(DEV_HOME)
	cd $(DEV_HOME) && git clone git@github.com:$(GITHUB_USER)/dotfiles.git
	cd $(DEV_HOME)/dotfiles && ./install

python: python-clean python-install python-pip-install

python-clean:
	brew uninstall --ignore-dependencies python python3
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
	pip install -r devops-requirements.txt

python-pip-install-latest: python-update-requirements python-pip-install

python-update-requirements:
	./update_requirements common
	./update_requirements emacs
	./update_requirements stats
	./update_requirements devops


ruby-version := 3.1.0
ruby: ruby-install ruby-update

ruby-install:
	brew install rbenv ruby-build
	rbenv install $(ruby-version)
	rbenv global $(ruby-version)
	ruby -v
	echo "gem: --no-document" > ~/.gemrc
	@echo "Now source ~/.bashrc to run 'rbenv init' in this shell before continuing with 'make ruby-update'"

ruby-update: ruby-install-default-gems ruby-gem-update

ruby-install-default-gems:
	gem install bundler

ruby-gem-update:
	gem update --system

tmate: tmux tmate-install tmate-wrapper

tmux:
	brew install tmux

tmate-install:
	brew install tmate
	brew install reattach-to-user-namespace

tmate-wrapper: check-env
	cd $(DEV_HOME) && git clone https://github.com/bobbyno/tmate-wrapper.git
	cd $(DEV_HOME)/tmate-wrapper && make install

emacs: clean-old-emacs $(emacsd)
	brew install pkg-config gnutls
	brew install emacs --with-cocoa --with-ctags --with-gnutls
	brew linkapps emacs
	@echo MANUAL STEP:
	@echo "Now you need to update the list of packages in emacs."
	@echo "Run emacs, then run M-x list-packages."
	@echo "Close emacs, then open it again. When it loads this time, it will be able to install the packages."

clean-old-emacs: $(oldemacs)
	-sudo mv /usr/bin/emacs $(oldemacs)
	-sudo mv /usr/share/emacs $(oldemacs)/share-emacs
	-sudo mv /usr/bin/emacs-undumped $(oldemacs)
	if [ -d /Applications/Emacs.app ]; then mv /Applications/Emacs.app $(oldemacs); fi

intellij-idea:
	brew install --cask intellij-idea

vim:
	brew install vim

docker-desktop:
	brew install --cask  docker
	docker --version

sublime:
	brew install --cask sublime-merge

slack:
	brew install --cask slack

zoom:
	brew install --cask zoom

1Password:
	brew install --cask 1password

atom:
	brew install --cask atom

chrome:
	brew install --cask google-chrome

postgresql:
	brew install postgresql

postman:
	brew install --cask postman

.SILENT: finish
finish:
	echo "Now open a new shell and test!"