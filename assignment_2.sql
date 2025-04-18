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

// Artists and Song system ERD //

CREATE TABLE Genres (
    genre_id VARCHAR(36) PRIMARY KEY,
    genre_name VARCHAR(100),
    genre_description TEXT
);

CREATE TABLE Artists (
    artist_id VARCHAR(36) PRIMARY KEY,
    full_name VARCHAR(255),
    stage_name VARCHAR(255),
    label_id VARCHAR(36),
    instagram_url VARCHAR(255),
    tiktok_url VARCHAR(255),
    contact_email VARCHAR(255)
);

CREATE TABLE Albums (
    album_id VARCHAR(36) PRIMARY KEY,
    album_name VARCHAR(255),
    artist_id VARCHAR(36),
    release_year INT,
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

CREATE TABLE Songs (
    song_id VARCHAR(36) PRIMARY KEY,
    song_title VARCHAR(255),
    length_seconds INT,
    genre_id VARCHAR(36),
    album_id VARCHAR(36),
    artist_id VARCHAR(36),
    release_date DATE,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id),
    FOREIGN KEY (album_id) REFERENCES Albums(album_id),
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

CREATE TABLE SongCollaborations (
    song_id VARCHAR(36),
    artist_id VARCHAR(36),
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES Songs(song_id),
    FOREIGN KEY (artist_id) REFERENCES Artists(artist_id)
);

-- Test comment for change ---

-------------------------
-- MOCK DATA INSERTION --
-------------------------

------------------------
-- ANALYTICAL QUERIES --
------------------------
