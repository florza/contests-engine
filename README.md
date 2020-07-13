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

To see which parts of the application already work, look at the collection "Test iTurnier2Tier" in our Postman workspace. There you see examples of working requests, e.g.:
- POST /signup (registration of a new user)
- POST /signin (login)
- DELETE /signin (logout)
- POST /refresh
- GET /api/v1/contests
- POST /api/v1/contests
- PUT /api/v1/contests/<id>
- DELETE /api/v1/contests/<id>

Untested parts:
- GET /api/v1/contests/<id>/participants
- POST /api/v1/contests/<id>/participants
- PUT /api/v1/contests/<id>/participants/<id>

Still completely missing:
- POST /api/v1/contests/<id>/draw
- everything with matches
- Additional contesttypes: several groups, KO, pyramids, ...
