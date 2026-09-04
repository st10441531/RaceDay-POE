# RaceDay – API Endpoint Plan

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| **Authentication** | | | | | |
| POST | /api/auth/register | Creates a new user account as either an Organiser or a Participant. | None (public) | `{ name, email, password, role }` | 201 Created – user object (no password) \| 409 Conflict – email already in use |
| POST | /api/auth/login | Authenticates a user and returns a JWT for subsequent requests. | None (public) | `{ email, password }` | 200 OK – `{ token, userId, role }` \| 401 Unauthorized – invalid credentials |
| **User Profile** | | | | | |
| GET | /api/users/me | Returns the profile of the currently logged-in user. | Any (logged in) | None | 200 OK – user profile object |
| PUT | /api/users/me | Updates the logged-in user's own profile details. | Any (logged in) | `{ name, email }` | 200 OK – updated profile \| 400 Bad Request – invalid data |
| GET | /api/users/me/performance | Returns the logged-in participant's personal performance history (past results across events). | Participant | None | 200 OK – array of past results \| 404 Not Found – no history yet |
| **Events** | | | | | |
| GET | /api/events | Lists all upcoming events, with optional filters (date, location, type). | None (public) | None | 200 OK – array of events |
| GET | /api/events/{id} | Returns full details for a single event, including its routes. | None (public) | None | 200 OK – event object \| 404 Not Found |
| POST | /api/events | Creates a new event, owned by the logged-in organiser. | Organiser | `{ name, description, eventDate, location }` | 201 Created – event object |
| PUT | /api/events/{id} | Updates an event owned by the logged-in organiser. | Organiser | `{ name, description, eventDate, location, status }` | 200 OK – updated event \| 403 Forbidden – not the owner \| 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event owned by the logged-in organiser. | Organiser | None | 204 No Content \| 403 Forbidden \| 404 Not Found |
| GET | /api/events/{id}/route | Returns route/GPX/elevation information for an event, used for race-day prep. | None (public) | None | 200 OK – array of route objects \| 404 Not Found |
| POST | /api/events/{id}/route | Adds a route to an event. | Organiser | `{ routeName, distanceKm, elevationGainM, routeMapUrl }` | 201 Created – route object |
| **Categories** | | | | | |
| GET | /api/events/{id}/categories | Lists all categories (e.g. 5km, 10km) available for an event. | None (public) | None | 200 OK – array of categories |
| POST | /api/events/{id}/categories | Adds a new category to an event. | Organiser | `{ name, distanceKm, maxParticipants, entryFee }` | 201 Created – category object |
| PUT | /api/categories/{id} | Updates a category's details. | Organiser | `{ name, distanceKm, maxParticipants, entryFee }` | 200 OK – updated category \| 404 Not Found |
| DELETE | /api/categories/{id} | Removes a category from an event. | Organiser | None | 204 No Content \| 404 Not Found |
| **Event Enrolments** | | | | | |
| POST | /api/categories/{id}/enrol | Enrols the logged-in participant into a category, generating a bib number. | Participant | None | 201 Created – enrolment with bib number \| 409 Conflict – already enrolled or category full |
| GET | /api/users/me/enrolments | Lists all of the logged-in participant's current and past enrolments. | Participant | None | 200 OK – array of enrolments |
| GET | /api/categories/{id}/enrolments | Lists all participants enrolled in a category (for the organiser managing that event). | Organiser | None | 200 OK – array of enrolments \| 403 Forbidden – not the event owner |
| DELETE | /api/enrolments/{id} | Cancels the logged-in participant's own enrolment. | Participant | None | 204 No Content \| 403 Forbidden – not the owner \| 404 Not Found |
| **Results** | | | | | |
| POST | /api/enrolments/{id}/results | Captures a finish time/position for a participant's enrolment. | Organiser | `{ finishTime, position, raceStatus }` | 201 Created – result object \| 404 Not Found – enrolment does not exist |
| GET | /api/events/{id}/results | Returns the full public results list for an event. | None (public) | None | 200 OK – array of results |
| GET | /api/users/me/results | Returns the logged-in participant's own results across all events (personal performance history). | Participant | None | 200 OK – array of results |
