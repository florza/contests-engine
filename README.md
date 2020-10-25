# Backend for iTurnier II

First draft for a new generation of iTurnier.org
- This backend tier is written in Ruby on Rails
- Frontend could be made with any tool, a first draft as a proof of concept is made with Vue.js

The main goal is to make it much easier for a contest manager to define und manage a contest, e.g.
- No user registration and login necessary for the player or teams: the contest manager just sends them a link with an access token to view a contest and to enter the results of their own matches
- Minimal data needed for participants, only name and shortname

The first version of the backen will only provide minimal functionality for
- registration and login
- creating and editing contests and participants
- doing the draw and generate all matches
- edit the match results and actualize the contests state
- contests with 1 ore more groups (round robin), no return matches, without sudden death or final groups for the group winners
- knockout (sudden death, elimination game), no match for third place
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
- DELETE /api/v1/contests/<id>-
- GET /api/v1/contests/<id>/draw (empty tableau structure)
- POST /api/v1/contests/<id>/draw (save and amend draw)
- DELETE /api/v1/contests/<id>/draw
- GET /api/v1/contests/<id>/participants
- GET /api/v1/contests/<id>/participants/<id>
- POST /api/v1/contests/<id>/participants
- PATCH /api/v1/contests/<id>/participants/<id>
- DELETE /api/v1/contests/<id>/participants/<id>
- GET /api/v1/contests/<id>/matches/
- GET /api/v1/contests/<id>/matches/<id>
- PATCH /api/v1/contests/<id>/matches/<id>

## Recent Steps
- Replaced cookies and csrf token by the access token that is sent to the client in the login request and resent by the client in the authorization header.
- Changed some config details to the heroku standards for rails 6, included a static home page with some basic information.
- Branch graphity: implement DrawResource to render JSONAPI for Draw data without a corresponding active record model, install and try Graphiti Vandal (seems not to be very useful, e.g. because no login or header handling)
- Branch graphity: change input/output to JSONAPI-format (jsonapi.org), using the Graphiti gems (www.graphiti.dev)
- Improve test coverage
- Compute rank in KO
- Refactored update_participant_stats to DrawManager to handle both, Groups and KO
- Set winner of KO-match as participant_1/2 of next match
- Allowed non-standard BYE positions in KO
- Added test coverage reports (simplecov)
- Defined tests for DrawManagerKO and DrawManagerGroups
- Implemented GET draw, to get an empty tableau structure (BYE positions in KO, optimal group sizes and distribution for a given number of group)
- Refactored DrawManager classes:
  - Same instance variable names in all subclasses, and post params, to make it easier to define generally usable methods
  - Move code to parent class and reused it
  - Moved get_ko_schedule to schedule class, used same output structure for KO and groups
- Some general adaptions to style guide (is_a?, unless, size)
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
- Use graphiti namespace to centrally define the /api/v1 prefix, delete module / namespace definitions used so far in controllers and in routes.rb
- Replace public_columns by resource definitions
- Create draw with seed list (complete draw, overwrites previous):
    1. Seed #1 to the top
    2. Seed #2 to the bottom
    3. Seeds #3 and #4 randomly to middle positions
    4. And so on for #5 - #8, #9 - 16, ... (to maximal number of seeds or number of groups - never more than 1 seed per group)
    5. Place eventually remaining participants randomly
- Prevent some updates:
    - Participant add/delete or ctype update only after delete draw
    - No match update (or no winner update?) after following match has been played (with editable field or as a computed field in resource?)
    - No draw with played matches
- Error processing and messages, see also:
    - https://blog.rebased.pl/2016/11/07/api-error-handling.htmlj
    - jsonapi.org !!
    - https://medium.com/@swilgosz/handling-exceptions-in-rails-api-applications-b276efa7e796
- User: allow update

## Adaptions to Ruby style guide
- [ ] participant_1_id: participant1_id
- [x] one line lambda: ->(...) { ... } or -> { ... }
- [x] evtl.case instead of elsif?
- [x] is_instance_of?: is_a?
- [ ] multiline 'if b/  a = c/else/  a = d/end':
  multiline indented
  a = if b
        c
      else
        a
      end
- [ ] if (a = b(...)) is ok only with parenthesis
- [x] never 'and' / 'or', also "... && return", not "x and return"!
- [ ] chaining with '.' on first line (next line would also be ok, but be consistent!)
- [ ] split long string literals with \ at end of line
- [x] if !x: unless x, especially as modifier
- [ ] method lenght: usually <= 5, max 10 lines
- [x] no '::' in class method calls, use '.' ('..' for constants is ok)
- [ ] optional param (b = 5): use keyword param (b: 5)
- [ ] param default (b=5): (b = 5)
- [ ] Prefer modules to classes with only class methods (Result?!)
- [ ] avoid get_/set_ for attribute accessors and mutators
- [ ] array[0]/[-1]: array.first/.last
- [ ] use (and provide) fetch() and similars instead of []
- [x] count: size !!!
- [ ] map(...).flatten: flat_map(...)
- [ ] x.reverse.each: x.reverse_each

## Still completely missing
- Additional ctypes: KO, groups or KO after groups, pyramids, double-KO...
