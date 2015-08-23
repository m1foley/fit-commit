# Fit Commit

Validates your Git commit messages, based largely on Tim Pope's [authoritative guide](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

## Example

```
$ git commit
Adding a cool feature
foobar foobar foobar,
foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar

1: Error: Message must use present imperative tense.
2: Error: Second line must be blank.
3: Error: Lines should be <= 72 chars. (76)

Force commit? [y/n] ▊
```

## Installation

Install the gem:

    $ gem install fit-commit

Install the hook in your Git repo:

    $ fit-commit install

This creates a `.git/hooks/commit-msg` script which will automatically check your Git commit messages.

### RVM

If you are using rvm you need to install fit-commit into the `default` gemset, because it does not use the `current` environment:

    $ rvm default do gem install fit-commit

Alternatively you can configure fit-commit to use the `current` rvm gemset:

    $ git config fit-commit.ruby "rvm `rvm current` do ruby"

## Validations

* **Line Length**: Lines should be <= 72 chars. First line should be <= 50 chars. Second line must be blank.
* **Tense**: Message must use present imperative tense.
* **WIP**: Do not commit WIPs to master.
* **Frat House**: No frat house commit messages in master.

## Credits

Author: [Mike Foley](https://github.com/m1foley)

Inspiration taken from: [Tim Pope](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), [Jason Fox](https://gist.github.com/jasonrobertfox/8057124), [Addam Hardy](http://addamhardy.com/blog/2013/06/05/good-commit-messages-and-enforcing-them-with-git-hooks/), [pre-commit](https://github.com/jish/pre-commit)
