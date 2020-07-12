# Backend for iTurnier II

First draft for a new generation of iTurnier.org
- backend tier written in Ruby on Rails
- frontend with any tool, first draft will be with Vue.js
- main goal is to make it much easier for a contest manager to define und manage a contests
- no more user registration and login necessary for the player or teams: the contest manager just sends them a link with an access token to view a contest and to enter the results of their own matches

The first version will only provide minimal functionality for
- registration and login
- contests with 1 group only, each participant playing 1 match against each other
- tokens generated for read or write access to the entire contest, not only a players own matches

The code contains a folder *iturnier-front* with a preliminary version of a Vue-frontend. This code was written with a simplified version of the backend and is **not adapted** to the actual version of the backend.

More or less working parts of the application:
- POST /signup (registration of a new user)
- POST /signin (login)
- GET /api/v1/contests
- POST /api/v1/contests

Untested parts:
- DELETE /signin (logout)
- POST /refresh
- PUT /api/v1/contests/<id>
- GET /api/v1/contests/<id>/participants
- POST /api/v1/contests/<id>/participants
- PUT /api/v1/contests/<id>/participants/<id>

Still completely missing:
- POST /api/v1/contests/<id>/auslosung
- everything with matches
- several groups, KO, pyramids, ...
