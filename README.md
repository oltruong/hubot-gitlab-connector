# hubot-gitlab-connector

[![Build Status](https://travis-ci.org/oltruong/hubot-gitlab-connector.svg?branch=master)](https://travis-ci.org/oltruong/hubot-gitlab-connector)
[![Coverage Status](https://coveralls.io/repos/github/oltruong/hubot-gitlab-connector/badge.svg)](https://coveralls.io/github/oltruong/hubot-gitlab-connector)
[![npm (scoped)](https://img.shields.io/npm/v/hubot-gitlab-connector.svg)](https://www.npmjs.com/package/hubot-gitlab-connector)

A hubot script that communicates with Gitlab

See [`src/gitlab-connector.coffee`](src/gitlab-connector.coffee) for full documentation.

## Features
- Show all projects
- Search projects by name
- Display branches of a given project
- Trigger a pipeline
- Show or accept merge requests
- Display version

## Installation

In hubot project repo, run:

`yarn install hubot-gitlab-connector --save`

Then add **hubot-gitlab-connector** to your `external-scripts.json`:

```json
[
  "hubot-gitlab-connector"
]
```

Set 2 environment variables
```
HUBOT_GITLAB_URL: url of gitlab server
HUBOT_GITLAB_TOKEN: access token
```
See https://docs.gitlab.com/ce/user/profile/personal_access_tokens.html for access tokens

## Sample Interaction

```
user1>> hubot gitlab version
hubot>> @user1 gitlab version is 8.13.0-pre, revision 4e963fe
```

For all features, type

```
hubot gitlab help
```

## Contributing

Granted, the script does not do much for now. If you have any request, please create an issue, or better, propose a pull request. 
:)

## NPM Module

https://www.npmjs.com/package/hubot-gitlab-connector
