/* ============================================================
   RaceDay Database Schema
   PROG6212 POE - Part 1
   Run in SQL Server Management Studio (SSMS) on a clean instance
   ============================================================ */

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* Drop tables in dependency order if they already exist, so the
   script can be re-run cleanly */
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.EventRoutes', 'U') IS NOT NULL DROP TABLE dbo.EventRoutes;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* ============================================================
   TABLE: Users
   Holds both Organisers and Participants, distinguished by Role.
   ============================================================ */
CREATE TABLE dbo.Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(100)   NOT NULL,
    Email           NVARCHAR(150)   NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255)   NOT NULL,
    Role            NVARCHAR(20)    NOT NULL
                        CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

/* ============================================================
   TABLE: Events
   Created and owned by an Organiser.
   ============================================================ */
CREATE TABLE dbo.Events (
    EventID         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID     INT             NOT NULL,
    Name            NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(1000)  NULL,
    EventDate       DATE            NOT NULL,
    Location        NVARCHAR(150)   NOT NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Scheduled'
                        CONSTRAINT CK_Events_Status CHECK (Status IN ('Scheduled', 'Cancelled', 'Completed')),
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID)
        REFERENCES dbo.Users(UserID)
);
GO

/* ============================================================
   TABLE: EventRoutes
   Route / GPX / elevation information used for race-day prep.
   ============================================================ */
CREATE TABLE dbo.EventRoutes (
    RouteID         INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT             NOT NULL,
    RouteName       NVARCHAR(100)   NOT NULL,
    DistanceKm      DECIMAL(6,2)    NOT NULL,
    ElevationGainM  DECIMAL(7,2)    NOT NULL DEFAULT 0,
    RouteMapUrl     NVARCHAR(500)   NULL,
    CONSTRAINT FK_EventRoutes_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID)
);
GO

/* ============================================================
   TABLE: Categories
   Distance / fee categories offered within an event.
   ============================================================ */
CREATE TABLE dbo.Categories (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT             NOT NULL,
    Name            NVARCHAR(100)   NOT NULL,
    DistanceKm      DECIMAL(6,2)    NOT NULL,
    MaxParticipants INT             NOT NULL DEFAULT 100,
    EntryFee        DECIMAL(8,2)    NOT NULL DEFAULT 0,
    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID)
);
GO

/* ============================================================
   TABLE: Enrolments
   A Participant entering a Category.
   ============================================================ */
CREATE TABLE dbo.Enrolments (
    EnrolmentID     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID   INT             NOT NULL,
    CategoryID      INT             NOT NULL,
    BibNumber       NVARCHAR(20)    NOT NULL UNIQUE,
    EnrolmentDate   DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Confirmed'
                        CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantID, CategoryID)
);
GO

/* ============================================================
   TABLE: Results
   One result per Enrolment (1:1).
   ============================================================ */
CREATE TABLE dbo.Results (
    ResultID        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID     INT             NOT NULL UNIQUE,
    FinishTime      TIME            NULL,
    Position        INT             NULL,
    RaceStatus      NVARCHAR(20)    NOT NULL DEFAULT 'Finished'
                        CONSTRAINT CK_Results_Status CHECK (RaceStatus IN ('Finished', 'DNF', 'DQ')),
    RecordedAt      DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID)
        REFERENCES dbo.Enrolments(EnrolmentID)
);
GO

/* ============================================================
   SEED DATA
   ============================================================ */

-- Organisers
INSERT INTO dbo.Users (Name, Email, PasswordHash, Role) VALUES
('Thandiwe Mokoena', 'thandiwe.mokoena@raceday.co.za', 'HASHED_PW_1', 'Organiser'),
('Pieter van Wyk',    'pieter.vanwyk@raceday.co.za',    'HASHED_PW_2', 'Organiser');

-- Participants
INSERT INTO dbo.Users (Name, Email, PasswordHash, Role) VALUES
('Lindiwe Dube',   'lindiwe.dube@example.com',   'HASHED_PW_3', 'Participant'),
('Johan Botha',    'johan.botha@example.com',    'HASHED_PW_4', 'Participant');

-- Events (owned by the two organisers)
INSERT INTO dbo.Events (OrganiserID, Name, Description, EventDate, Location, Status) VALUES
(1, 'Pretoria Park Run Challenge', 'A community 5km/10km park run through Pretoria''s green belts.', '2026-10-10', 'Pretoria, Gauteng', 'Scheduled'),
(1, 'Cape Peninsula Cycle Tour',   'A scenic road cycling tour around the Cape Peninsula.',          '2026-11-15', 'Cape Town, Western Cape', 'Scheduled'),
(2, 'Durban Coastal Marathon',     'A full and half marathon along Durban''s beachfront.',           '2026-12-05', 'Durban, KwaZulu-Natal', 'Scheduled');

-- Routes (at least one per event)
INSERT INTO dbo.EventRoutes (EventID, RouteName, DistanceKm, ElevationGainM, RouteMapUrl) VALUES
(1, 'Park Loop Route',       10.0, 85.0,  'https://maps.raceday.co.za/routes/pretoria-park-10k'),
(2, 'Peninsula Coastal Route', 109.0, 1450.0, 'https://maps.raceday.co.za/routes/cape-peninsula-109k'),
(3, 'Beachfront Marathon Route', 42.2, 60.0, 'https://maps.raceday.co.za/routes/durban-marathon-42k');

-- Categories (at least one per event)
INSERT INTO dbo.Categories (EventID, Name, DistanceKm, MaxParticipants, EntryFee) VALUES
(1, '5km Fun Run',    5.0,  300, 100.00),
(1, '10km Challenge', 10.0, 200, 150.00),
(2, 'Full Tour (109km)', 109.0, 500, 450.00),
(3, 'Half Marathon',  21.1, 1000, 250.00),
(3, 'Full Marathon',  42.2, 800,  350.00);

-- Enrolments (sample participants entering categories)
INSERT INTO dbo.Enrolments (ParticipantID, CategoryID, BibNumber, Status) VALUES
(3, 2, 'BIB-1001', 'Confirmed'),  -- Lindiwe -> Pretoria 10km Challenge
(4, 3, 'BIB-1002', 'Confirmed'),  -- Johan -> Cape Peninsula Full Tour
(3, 4, 'BIB-1003', 'Confirmed');  -- Lindiwe -> Durban Half Marathon

-- Sample results for a completed enrolment
INSERT INTO dbo.Results (EnrolmentID, FinishTime, Position, RaceStatus) VALUES
(1, '00:48:32', 12, 'Finished');
GO
