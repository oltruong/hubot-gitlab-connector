# hubot-gitlab-connector

[![Build Status](https://travis-ci.org/oltruong/hubot-gitlab-connector.svg?branch=master)](https://travis-ci.org/oltruong/hubot-gitlab-connector)

A hubot script that communicates with Gitlab

See [`src/gitlab-connector.coffee`](src/gitlab-connector.coffee) for full documentation.

## Installation

In hubot project repo, run:

`yarn install hubot-gitlab-connector --save`

Then add **hubot-gitlab-connector** to your `external-scripts.json`:

```json
[
  "hubot-gitlab-connector"
]
```

## Sample Interaction

```
user1>> hubot gitlab version
hubot>> @user1 gitlab version is 8.13.0-pre, revision 4e963fe
```

For all features, type

```
hubot gitlab help
```

## NPM Module

https://www.npmjs.com/package/hubot-gitlab-connector
