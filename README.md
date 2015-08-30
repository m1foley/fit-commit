# Fit Commit

A Git hook to validate your commit messages, based largely on Tim Pope's [authoritative guide](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

## Example

```
$ git commit
Adding a cool feature
foobar foobar foobar,
foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar

1: Error: Message must use imperative present tense.
2: Error: Second line must be blank.
3: Error: Lines should be <= 72 chars. (76)

Force commit? [y/n] ▊
```

## Prerequisites

* Ruby >= 1.9

## Installation

Install the gem:

    $ gem install fit-commit

Install the hook in your Git repo:

    $ fit-commit install

This creates a `.git/hooks/commit-msg` script which will automatically check your Git commit messages.

## Validations

* **Line Length**: All lines must be <= 72 chars (URLs excluded). First line should be <= 50 chars. Second line must be blank.
* **Tense**: Message must use imperative present tense: "Fix bug" and not "Fixed bug" or "Fixes bug."
* **Summary Period**: Do not end your summary with a period.
* **WIP**: Do not commit WIPs to master.
* **Frat House**: No frat house commit messages in master.


## FAQ

### Can Fit Commit run in all my repos without having to install it each time?
First set your global Git template directory:

```
$ git config --global init.templatedir '~/.git_template'
```

Now you can copy the hooks you want installed in new repos by default:

```
# From a repo where Fit Commit is already installed
$ cp .git/hooks/commit-msg ~/.git_templates/hooks/commit-msg
```

To copy your default hooks into existing repos:

```
$ git init
```

### Fit Commit is too opinionated for me. What can I do?
Fit Commit aims to be useful to everyone. If you can suggest an improvement to make it useful to more people, please open a GitHub Issue or Pull Request.


## Credits

Author: [Mike Foley](https://github.com/m1foley)

Inspiration taken from: [Tim Pope](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), [Jason Fox](https://gist.github.com/jasonrobertfox/8057124), [Addam Hardy](http://addamhardy.com/blog/2013/06/05/good-commit-messages-and-enforcing-them-with-git-hooks/), [pre-commit](https://github.com/jish/pre-commit)
