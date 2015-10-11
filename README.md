# Fit Commit

A Git hook to validate your commit messages based on [community standards](#who-decided-these-rules).

## Example

```
$ git commit
Adding a cool feature
foobar foobar foobar,
foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar

1: Error: Message must use imperative present tense.
2: Error: Second line must be blank.
3: Error: Lines should be <= 72 chars. (76)

Force commit? [y/n/e] ▊
```

## Prerequisites

* Ruby >= 1.9 (OS X users already have this installed)

## Installation

Install the gem:

    $ gem install fit-commit

Install the hook in your Git repo:

    $ fit-commit install

This creates a `.git/hooks/commit-msg` script which will automatically check your Git commit messages.

## Validations

* **Line Length**: All lines must be <= 72 chars (URLs excluded). First line should be <= 50 chars. Second line must be blank.
* **Tense**: Message must use imperative present tense: "Fix bug" and not "Fixed bug" or "Fixes bug."
* **Subject Period**: Do not end your subject line with a period.
* **Capitalize Subject**: Begin all subject lines with a capital letter.
* **WIP**: Do not commit WIPs to shared branches.
* **Frat House**: No frat house commit messages in shared branches.

## Configuration

Settings are read from these files in increasing precedence: `/etc/fit_commit.yml`, `$HOME/.fit_commit.yml`, `config/fit_commit.yml`, `./.fit_commit.yml`.

These are the default settings that can be overridden:

```yaml
---
Validators/LineLength:
  Enabled: true
  MaxLineLength: 72
  SubjectWarnLength: 50
  AllowLongUrls: true
Validators/Tense:
  Enabled: true
Validators/SubjectPeriod:
  Enabled: true
Validators/CapitalizeSubject:
  Enabled: true
Validators/Wip:
  Enabled:
    - master
Validators/Frathouse:
  Enabled:
    - master
```

The `Enabled` property accepts multiple formats:

```yaml
# true/false to enable/disable the validation (branch agnostic)
Validators/Foo:
  Enabled: false
# Array of String/Regex matching each branch for which it's enabled
Validators/Bar:
  Enabled:
    - master
    - !ruby/regexp /\Afoo.+bar/
```

## Adding Custom Validators

Create your custom validator as a `FitCommit::Validators::Base` subclass:

```ruby
module FitCommit
  module Validators
    class MyCustomValidator < Base
      def validate_line(lineno, text)
        if text =~ /sneak peak/i
          add_error(lineno, "I think you mean 'sneak peek'.")
        end
      end
    end
  end
end
```

`Require` the file and enable the validator in your config:

```yaml
FitCommit:
  Require:
    - somedir/my_custom_validator.rb
Validators/MyCustomValidator:
  Enabled: true
```

You can also publish your validator as a gem, and require it that way:

```yaml
FitCommit:
  Require:
    - my-custom-validator-gem
Validators/MyCustomValidator:
  Enabled: true
```

If others might find your validator useful, submit it as a Pull Request. If it's not useful for everyone, it can be disabled by default.

## FAQ

### Can Fit Commit run in all my repos without having to install it each time?
First set your global Git template directory:

```
$ git config --global init.templatedir '~/.git_template'
$ mkdir -p ~/.git_template/hooks
```

Now you can copy the hooks you want installed in new repos by default:

```
# From a repo where Fit Commit is already installed
$ cp .git/hooks/commit-msg ~/.git_template/hooks/commit-msg
```

To copy your default hooks into existing repos:

```
$ git init
```

### Who decided these rules?
Fit Commit aims to enforce *community standards*. The two influential guides are:

- [Tim Pope's blog](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- [The official Git documentation](http://git.kernel.org/cgit/git/git.git/tree/Documentation/SubmittingPatches?id=HEAD)

The Git community has largely (but not completely) coalesced around these standards. [Chris Beams](http://chris.beams.io/posts/git-commit/) and the [Pro Git book](https://git-scm.com/book) also provide good summaries on why we have them.

### How can I improve Fit Commit?
Fit Commit aims to be useful to everyone. If you can suggest an improvement to make it useful to more people, please open a GitHub Issue or Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more info.


## Credits

Author: [Mike Foley](https://github.com/m1foley)

Inspiration taken from: [Tim Pope](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), [Jason Fox](https://gist.github.com/jasonrobertfox/8057124), [Addam Hardy](http://addamhardy.com/blog/2013/06/05/good-commit-messages-and-enforcing-them-with-git-hooks/), [pre-commit](https://github.com/jish/pre-commit)

Similar projects: [gitlint](https://github.com/jorisroovers/gitlint) (written in Python)
