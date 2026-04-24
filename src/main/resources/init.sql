DROP TABLE IF EXISTS Resources;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Groups;
DROP TABLE IF EXISTS Permissions;
DROP TABLE IF EXISTS UserGroups;
DROP TABLE IF EXISTS UserResourcePermissions;
DROP TABLE IF EXISTS GroupResourcePermissions;
DROP TABLE IF EXISTS AuthMethods;
DROP TABLE IF EXISTS Logs;

-- create core tables
CREATE TABLE Resources (
    resourceId INT PRIMARY KEY,
    name VARCHAR,
    creation DATE
);

CREATE TABLE Users (
    userId INT PRIMARY KEY,
    username VARCHAR NOT NULL UNIQUE, --DO we want taht to be Unique
    vorname VARCHAR,
    nachname VARCHAR,
    lastLogin TIMESTAMP
);

CREATE TABLE Groups (
    groupId INT PRIMARY KEY,
    name VARCHAR,
    creation DATE
);

CREATE TABLE Permissions (
    permId INT PRIMARY KEY,
    name VARCHAR -- what does this describe? ex. open/close
);

-- n-n tables
CREATE TABLE UserGroups (
    userId INT,
    groupId INT,
    PRIMARY KEY (userId, groupId),
    FOREIGN KEY (userId) REFERENCES Users(userId),
    FOREIGN KEY (groupId) REFERENCES Groups(groupId)
);

-- permission assignment
CREATE TABLE UserResourcePermissions (
    userId INT,
    resourceId INT,
    permId INT,
    PRIMARY KEY (userId, resourceId, permId)
    -- TODO constraints
);

CREATE TABLE GroupResourcePermissions (
    groupId INT,
    resourceId INT,
    permId INT,
    PRIMARY KEY (groupId, resourceId, permId)
    -- TODO constraints
);
--Trigger adds new logs when a user login is Detected.
CREATE TABLE Logs (
    time TIMESTAMP,
    logAction VARCHAR,
    userId INT,
    FOREIGN KEY (userId) REFERENCES Users(userId)
);

-- WIP "Authentication"
CREATE TABLE AuthMethods (
    AuthMethodId INT PRIMARY KEY,
    userId INT,
    type VARCHAR, -- "password", "api_token"
    super_secret_hash VARCHAR,
    creation DATE,
    expires DATE
);

-- sample data 
INSERT INTO Users (userId, username, vorname, nachname, lastLogin) VALUES
(0, 'gurki', 'Florian', 'Goerke', '2026-04-24'),
(1, 'amax', 'Anna', 'Max', '2026-04-01'),
(2, 'mweber', 'Max', 'Weber', '2026-04-02'),
(3, 'lschmidt', 'Laura', 'Schmidt', '2026-04-03'),
(4, 'tmueller', 'Tom', 'Müller', '2026-04-04'),
(5, 'smeier', 'Sophie', 'Meier', '2026-04-05'),
(6, 'jbecker', 'Jonas', 'Becker', '2026-04-06'),
(7, 'ehoffmann', 'Emma', 'Hoffmann', '2026-04-07'),
(8, 'lfischer', 'Leon', 'Fischer', '2026-04-08'),
(9, 'ngrant', 'Nina', 'Grant', '2026-04-09'),
(10, 'pbauer', 'Paul', 'Bauer', '2026-04-10'),
(11, 'hmeyer', 'Hannah', 'Meyer', '2026-04-11'),
(12, 'fgross', 'Felix', 'Groß', '2026-04-12'),
(13, 'klehmann', 'Klara', 'Lehmann', '2026-04-13'),
(14, 'dwagner', 'David', 'Wagner', '2026-04-14'),
(15, 'lkoch', 'Lena', 'Koch', '2026-04-15'),
(16, 'nrichter', 'Noah', 'Richter', '2026-04-16'),
(17, 'mmartin', 'Mia', 'Martin', '2026-04-17'),
(18, 'fschneider', 'Finn', 'Schneider', '2026-04-18'),
(19, 'jwolf', 'Julia', 'Wolf', '2026-04-19'),
(20, 'lgraf', 'Lukas', 'Graf', '2026-04-20'),
(21, 'avalentin', 'Amelie', 'Valentin', '2026-04-21'),
(22, 'obenner', 'Oskar', 'Benner', '2026-04-22'),
(23, 'mkrueger', 'Marie', 'Krüger', '2026-04-23'),
(24, 'eroth', 'Elias', 'Roth', '2026-04-24'),
(25, 'cklein', 'Clara', 'Klein', '2026-03-25'),
(26, 'nengel', 'Nico', 'Engel', '2026-03-26'),
(27, 'lsommer', 'Lea', 'Sommer', '2026-03-27'),
(28, 'ahuber', 'Anton', 'Huber', '2026-03-28'),
(29, 'mvoigt', 'Mila', 'Voigt', '2026-03-29'),
(30, 'jbrandt', 'Jan', 'Brandt', '2026-03-30');

INSERT INTO Groups VALUES (0, 'admin', '2026-04-01');

-- example permission, accessing a door?
INSERT INTO Permissions VALUES (0, 'doorAccess');

-- example resource, here its our class door
INSERT INTO Resources VALUES (0, 'door_p143', '');

-- give user 0 access to door_p143
INSERT INTO UserResourcePermissions VALUES (0, 0, 0);

-- get direct permissions of user 0 
SELECT P.name FROM UserResourcePermissions UP JOIN Permissions P ON UP.permId = P.permId WHERE UP.userId = 0;

-- get permissions of group 0
SELECT P.name FROM GroupResourcePermissions GP JOIN Permissions P ON GP.permId = P.permId WHERE GP.groupId = 0;

-- TODO view for ^ (Effective permissions per user)
-- TODO view for "user access summary" (which users can access which resources?) use case: dashboard
-- TODO view for permissions from a users view (can only see own perms)
-- TODO trigger for checking new grants (ex. user cant have direct AND group permission)

--Trigger--
CREATE TRIGGER trg_user_login
AFTER UPDATE ON Users
FOR EACH ROW
WHEN 
    OLD.lastLogin < NEW.lastLogin
BEGIN
    INSERT INTO Logs (time, logAction, userId)
    VALUES (
        CURRENT_TIMESTAMP,
        'USER_LOGIN',
        NEW.userId
    );
END;

UPDATE Users SET lastlogin='2026-4-24' WHERE userId=0;
SELECT * FROM Logs;


--Views--
CREATE VIEW EffectiveUserPermissions AS
SELECT 
    u.userId,
    r.resourceId,
    p.permId,
    p.name AS permission
FROM Users u
JOIN UserResourcePermissions urp 
    ON u.userId = urp.userId
JOIN Permissions p 
    ON urp.permId = p.permId
JOIN Resources r 
    ON urp.resourceId = r.resourceId

UNION

SELECT 
    u.userId,
    r.resourceId,
    p.permId,
    p.name AS permission
FROM Users u
JOIN UserGroups ug 
    ON u.userId = ug.userId
JOIN GroupResourcePermissions grp 
    ON ug.groupId = grp.groupId
JOIN Permissions p 
    ON grp.permId = p.permId
JOIN Resources r 
    ON grp.resourceId = r.resourceId;


CREATE VIEW UserWithGroups AS
SELECT 
    u.userId,
    u.username,
    g.groupId,
    g.name AS groupName
FROM Users u
JOIN UserGroups ug ON u.userId = ug.userId
JOIN Groups g ON ug.groupId = g.groupId;