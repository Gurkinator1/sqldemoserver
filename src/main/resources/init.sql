-- create core tables
CREATE TABLE Resources (
    resourceId INT PRIMARY KEY,
    name VARCHAR,
    creation DATE
);

CREATE TABLE Users (
    userId INT PRIMARY KEY
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


-- TODO query "all permissions for a user" using UNION on both UserResourcePermissions and GroupResourcePermissions
SELECT P.name FROM UserResourcePermissions UP JOIN Permissions P ON UP.permId = P.permId WHERE UP.userId = 0;

--....
UNION
SELECT FROM GroupResourcePermissions;

-- TODO view for ^ (Effective permissions per user)
-- TODO view for "user access summary" (which users can access which resources?) use case: dashboard
-- TODO view for permissions from a users view (can only see own perms)
-- TODO trigger for checking new grants (ex. user cant have direct AND group permission)

-- TODO sample data


-- WIP "Authentication"
CREATE TABLE AuthMethods (
    AuthMethodId INT PRIMARY KEY,
    userId INT,
    type VARCHAR, -- "password", "api_token"
    super_secret_hash VARCHAR,
    creation DATE,
    expires DATE,
);

-- TODO java API for authentication