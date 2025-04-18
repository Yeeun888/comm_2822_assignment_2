------------------------------
-- ORACLE DATABASE CREATION --
------------------------------

// User ERD //

CREATE TABLE Users (
    user_id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    profile_picture_url VARCHAR(255),
    register_time TIMESTAMP
);

CREATE TABLE UserSong (
    user_id VARCHAR(36),
    song_id VARCHAR(36),
    timestamp TIMESTAMP,
    PRIMARY KEY (user_id, song_id, timestamp),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id)
);

CREATE TABLE UserPlaylist (
    playlist_id VARCHAR(36),
    user_id VARCHAR(36),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    PRIMARY KEY (playlist_id, user_id)
);

-- Test comment for change ---

-------------------------
-- MOCK DATA INSERTION --
-------------------------

------------------------
-- ANALYTICAL QUERIES --
------------------------
