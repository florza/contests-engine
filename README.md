# Contests-Engine

## General
The *Contests-Engine* site provides a public REST-API to a tournament management back-end system that handles contests, participants, draws, matches and the like for almost any contest (football championships, tennis trophies, billard tournaments and so on).

The goal of *Contests-Engine* is to let developers of tournament management front-ends (websites, mobile apps, desktop apps, ...) concentrate on the presentation layer of their systems, e.g.
- Fast and simple data entry forms
- Easy definition of a manual draw by dragging around participants on the empty tableau
- Elegant renderings of large groups- or knock-out-tableaus with scrolling and zooming.

*Contests-Engine* in the background then handles tasks like
- Store, update and retrieve all data of the contests
- Randomly fill an incomplete draw or create an entire draw with due regard to special rules like seed lists
- Create all the matches and their dependencies according to the type of the contest (round robin, groups, elimination or double-elimination game, ...)
- Actualize everything whenever a new result is received, e.g. propagate the winner of an elimination game to the next round or group winners to the final group or elimination round
- Distribute points for wins, losses and eventually ties, calculate statistics and rankings

## First version (Minimal Viable Product)
The first version of *Contests-Engine*, which is almost finished, provide minimal functionality for
- Registration and login with username / password for contest managers
- Login for participants to a specific contest with tokens generated for read or write access to the entire contest or only a players own matches
- Creating and editing contests and participants with minimal data needed
- Doing the draw and generate all matches
- Edit the match results and actualize the contests state
- Contests type 'Groups' (round robin), no return matches and no sudden death or final groups for the group winners
- Contest type 'Knock-out' (sudden death, elimination game), no match for third place

## Ideas for future Enhancements
See [Issues](https://github.com/florza/contests-engine/issues), label `enhancement`.

## Tools used
*Contest-Engine* is written in Ruby on Rails.

Frontend applications can be developed with any tool that can make REST-API-calls. A first draft of such an application as a proof of concept was developed with Vue.js. Technical details of it can be found at https://github.com/florza/contests-example, a provisional version of the app can be be accessed (without any guarantees for availability or performance!) at https://contests-example.herokuapp.com.

## Basic API requests
This basic set of API-calls is implemented:

|Verb     |Resource                                 |Description|
|---      |---                                      |---|
|`POST`   |`/signup`                                |Registration of a new user
|`POST`   |`/signin`                                |Login
|`DELETE` |`/signin`                                |Logout
|`POST`   |`/refresh`                               |Refresh a timed out token^|
|`GET`    |`/api/v1/contests`                       |Read all contests of the user or the token's contest
|`GET`    |`/api/v1/contests/:id`                   |Read one contest
|`POST`   |`/api/v1/contests`                       |Create a new contest for the actual user
|`PATCH`  |`/api/v1/contests/:id`                   |Update a contest
|`DELETE` |`/api/v1/contests/:id`                   |Delete a contests
|`GET`    |`/api/v1/contests/:id/draw`              |Read an empty tableau structure for the actual number of participants
|`POST`   |`/api/v1/contests/:id/draw`              |Eventually complete, then create and save the draw for a contests
|`DELETE` |`/api/v1/contests/:id/draw`              |Delete the actual draw of a contest
|`GET`    |`/api/v1/contests/:id/participants`      |Read all participants of a contest
|`GET`    |`/api/v1/contests/:id/participants/:id`  |Read one participant
|`POST`   |`/api/v1/contests/:id/participants`      |Create one participant of the contest
|`PATCH`  |`/api/v1/contests/:id/participants/:id`  |Update a participant of the contest
|`DELETE` |`/api/v1/contests/:id/participants/:id`  |Delete a participant of the contest
|`GET`    |`/api/v1/contests/:id/matches/`          |Get all matches of the contest
|`GET`    |`/api/v1/contests/:id/matches/:id`       |Get one match of the contest
|`PATCH`  |`/api/v1/contests/:id/matches/:id`       |Update a match of the contests, usually the match result

A detailled description of these request can be found at [Postman](https://zangas.postman.co/collections/12018474-c1f1c04c-51a3-4584-82c8-1046d06c5579?version=latest&workspace=c3857627-8fcb-49b4-8468-f0d6f065d7ed).

An instance of the application and the API is provided at https://contests-example.herokuapp.com to send requests and receive responses with Postman or CURL. However, this installation is also used by the developers sometimes and no guarantee is given on the availability of the app or permanent storage of example data you entered. The app and the database may be overwritten or initialized at any time.

## JSON:API
For request and response formats, *Contests-Engine* implements the JSON:API specification of https://jsonapi.org. Therefore, the requests can also be modified with ordering, field selections, conditions, sideloads and other things by sending additional parameters according to this specification. For example:
```HTTP
GET /api/v1/contests/123?include=participants,matches
```
reads the data of an entire contest with all participants and matches in one request. This is the recommended way to read and refresh contest data after an update request, because you will always receive a consistent image of the contest. Especially an update of a match can lead to a lot of updates of other resources, e.g. succeeding matches, participants rankings or contest state, and if you just refreshed the updated match you would miss many of them!

## Contributions
Contributions to this application are very welcome. These may be:
- Comments to the issues and questions
- Propositions for additional features or better solutions
- Pull requests (but please be patient with me at the beginning - I do not have so much experience with this kind of collaboration, but I would be happy to gain it!)
- Development of a production-ready front-end application of your own, which would certainly result in many ideas to improve the back-end engine!

## Some recent developments
- Set read-only attributes `editable`, `result_1_vs_2`, `result_2_vs_1` in MatchResource, to free the client from this logic
- Replaced cookies and csrf token by the access token that is sent to the client in the login request and resent by the client in the authorization header.
- Included a static home page with some basic information ()
- Changed input/output to JSON:API-format (https://jsonapi.org) using the `Graphiti` gem (https://graphiti.dev)

## Next Steps
See https://github.com/florza/contests-example/issues.
