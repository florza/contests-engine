# Backend for iTurnier II

First draft for a new generation of iTurnier.org
- backend tier written in Ruby on Rails
- frontend with any tool, first draft will probably be with Vue.js
- main goal is to make it much easier for a contest manager to define und manage a contests
- no more user registration and login necessary for the player or teams: the contest manager just sends them a link with an access token to view a contest and to enter the results of their own matches

The first version will only provide minimal functionality for
- registration and login
- creating and editing contests and participants
- doing the draw and generate all matches
- edit the match results and actualize the contests state
- contests with 1 group only, each participant playing 1 match against each other
- tokens generated for read or write access to the entire contest, not only a players own matches

To see which parts of the application already exist, look at the controller_tests. There you see the controllers and actions that are implemented. The following list should show the same information, but may be less accurately updated:
- POST /signup (registration of a new user)
- POST /signin (login)
- DELETE /signin (logout)
- POST /refresh
- GET /api/v1/contests
- GET /api/v1/contests/<id>
- POST /api/v1/contests
- PUT /api/v1/contests/<id>
- DELETE /api/v1/contests/<id>
- POST /api/v1/contest<id>/draw
- GET /api/v1/contests/<id>/participants
- GET /api/v1/contests/<id>/participants/<id>
- POST /api/v1/contests/<id>/participants
- PUT /api/v1/contests/<id>/participants/<id>
- DELETE /api/v1/contests/<id>/participants/<id>
- GET /api/v1/contests/<id>/matches/
- GET /api/v1/contests/<id>/matches/<id>
- PUT /api/v1/contests/<id>/matches/<id>

Next steps:
- try deployment to Heroku
- adapt draft of Vue frontend to the actual models, activate bootstrap
- manage update of Groups result by computing the ranking

Still completely missing:
- Additional contesttypes: several groups, KO, pyramids, ...
