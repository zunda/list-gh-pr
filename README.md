# list-gh-pr
Lists recent open pull requests from others

## Installation
Generate an unscoped toekn at https://github.com/settings/tokens and store it in `~/.netrc`:

```
machine api.github.com
  login (github-login)
  password (generated-token)
```

Install dependent gems

```sh
$ bundle install --path=vendor/bundle
```

## Usage
```sh
$ bundle exec ruby list-gh-pr.rb
```
