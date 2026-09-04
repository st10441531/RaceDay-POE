RaceDay
RaceDay is a full-stack, web-based event management system built for the South African road running, walking, and cycling community. It replaces the paper-based registration, spreadsheets, and disconnected communication channels that many community events still rely on, giving Event Organisers a single platform to create and manage events, categories, and results, while Participants can browse upcoming events, enter events, track their personal performance history, and prepare for race day using live weather and route information.
This repository contains Part 1 – System Planning and Database of the PROG6212 Portfolio of Evidence: the entity-relationship design, API endpoint plan, and SQL database script that were completed before any application code was written.
User Roles
RaceDay supports two roles, both represented in a single `Users` table and distinguished by a `Role` column:
Organiser – creates and manages events, defines categories and routes for each event, views and manages participant enrolments, and captures race results.
Participant – browses upcoming events, enrols in event categories, views live weather and route information ahead of race day, and tracks their own performance history across past events.
Repository Structure
```
RaceDay-POE/
├── docs/
│   ├── raceday_erd.png          # Entity Relationship Diagram (Section A)
│   ├── api-endpoint-plan.md     # API endpoint specification table (Section B)
│   └── raceday_database.sql     # Full SQL Server schema + seed data (Section C)
├── .github/
│   └── workflows/
│       └── validate-structure.yml   # CI check that /docs contains all required files
└── README.md
```
Part 1 Deliverables
Entity Relationship Diagram — six entities (Users, Events, EventRoutes, Categories, Enrolments, Results) with primary keys, foreign keys, and cardinality for every relationship.
API Endpoint Plan — every planned endpoint for Authentication, User Profile, Events, Categories, Event Enrolments, and Results, with HTTP method, route, description, role required, request body, and expected response.
SQL Database Script — creates the full schema in SQL Server Management Studio (SSMS) with all constraints, and seeds it with two Organisers, two Participants, three Events, categories per event, and sample enrolments.
CI/CD
A GitHub Actions workflow (`.github/workflows/validate-structure.yml`) runs on every push and pull request to `main`, validating that the `/docs` folder exists and contains the ERD, endpoint plan, and SQL script, and that a README is present at the repository root.
Successful build screenshot:
> _Insert a screenshot of a green/passing GitHub Actions run here once the workflow has run successfully on your repository._
Video Walkthrough
YouTube (unlisted): Insert your unlisted YouTube link here.
The video walks through the planning documents, the ERD design decisions, the endpoint plan choices, and runs the SQL script live in SSMS.
