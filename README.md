# hubot-gitlab-connector

[![Build Status](https://travis-ci.org/oltruong/hubot-gitlab-connector.svg?branch=master)](https://travis-ci.org/oltruong/hubot-gitlab-connector)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/ba98acc265c64f819cd2403e32857a21)](https://www.codacy.com/app/oliv-truong/hubot-gitlab-connector?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=oltruong/hubot-gitlab-connector&amp;utm_campaign=Badge_Grade)

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
