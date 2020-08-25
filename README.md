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
- contests with 1 ore more groups, each participant playing 1 match against each other of the same group, without sudden death or final groups for the group winners
- tokens generated for read or write access to the entire contest, not only a players own matches

## Status
The basic set of API-calls is implemented
- POST /signup (registration of a new user)
- POST /signin (login)
- DELETE /signin (logout)
- POST /refresh
- GET /api/v1/contests
- GET /api/v1/contests/<id>
- POST /api/v1/contests
- PATCH /api/v1/contests/<id>
- DELETE /api/v1/contests/<id>
- POST /api/v1/contest<id>/draw
- PATCH /api/v1/contest<id>/touch
- GET /api/v1/contests/<id>/participants
- GET /api/v1/contests/<id>/participants/<id>
- POST /api/v1/contests/<id>/participants
- PATCH /api/v1/contests/<id>/participants/<id>
- DELETE /api/v1/contests/<id>/participants/<id>
- GET /api/v1/contests/<id>/matches/
- GET /api/v1/contests/<id>/matches/<id>
- PATCH /api/v1/contests/<id>/matches/<id>

## Recent Steps
- First steps to KO draw:
  - Random draw of all empty positions, i.e. of all positions, if the user has not drawn any positions manually. Such a draw also returns the correct BYE positions.
  - Adapted KO validation to incomplete draws.
  - Delete KO draw, i.e. params in contest and participants and all matches. No test yet if some matches have already been played.
- Compute and save participants rank within the group (with possibly equal values) to take the ordering responsibility away from the frontend
- Added contest 'Demoturnier Gruppen' with 7 (famous) participants to fixtures in order to have a test contest with 2 groups
- Restructured match.result with 2 arrays (score_p1, score_p2) instead of array of arrays (score)
- Restructured contest.result_params
- Login with token not with a param field in the link but in a second signin form. The request is handled similar to a user login, i.e. it gives back a csrf-token as session id.
Also returned is now some additional data, i.e. the type of signin (user/token) and the user record of the logged in user or some info to the used token (read/write, contest/participant, id).
- User: rename email to username
- Settings for "tie allowed" (contest) and walk_over (match) with adapted validation of results and additional tests
- Settings for lucky_loser in match (will only be used later in KO)
- Field contesttype_params renamed to ctype_params
- Separated result params in a new field, moved 'points' object from ctype_params to result_params
- Field userdata in all tables

## Next Steps
- Delete draw
- Create draw (Post? Patch?) with first defining the structure of the tableau
  - with seed list: complete draw, overwrites previous:
    1. Seed #1 to the top
    2. Seed #2 to the bottom
    3. Seeds #3 and #4 randomly to middle positions
    4. And so on for #5 - #8, #9 - 16, ... (to maximal number of seeds or number of groups - never more than 1 seed per group)
    5. Place eventually remaining participants randomly
  - without seed list: eventually with partial draw as input, randomly drawing the remaining participants


- Error processing and messages, see also:
    - https://blog.rebased.pl/2016/11/07/api-error-handling.htmlj
    - jsonapi.org !!
    - https://medium.com/@swilgosz/handling-exceptions-in-rails-api-applications-b276efa7e796
- User: allow update

## Still completely missing
- Additional ctypes: KO, groups or KO after groups, pyramids, double-KO...
