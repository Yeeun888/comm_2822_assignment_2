--------------------------
-- OLD DATABASE CLEANUP --
--------------------------

-- Current SQL Version (https://stackoverflow.com/questions/65857333/query-to-get-oracle-db-version)
SELECT
    version
FROM
    product_component_version
WHERE
    product LIKE 'Oracle Database%';

-- DANGEROUS CODE BELOW. DROPS ALL TABLES 
-- DO NOT RUN WITH ASSIGNMENT CODE

-- BEGIN
--   FOR c IN (SELECT table_name 
--            FROM user_tables) LOOP
--      EXECUTE IMMEDIATE 'DROP TABLE ' || c.table_name || ' CASCADE CONSTRAINTS';
--   END LOOP;
-- END;

------------------------------
-- ORACLE DATABASE CREATION --
------------------------------

-- Creation order starts from attributes with no dependents to those it's dependents
-- based of team ERD in presentation appendix

-- All with logins users, rightholders, merchants
CREATE TABLE Users (
    user_id             VARCHAR2(36),
    username            VARCHAR2(256) NOT NULL UNIQUE,
    email               VARCHAR2(256) NOT NULL UNIQUE,
    password_hash       VARCHAR2(256) NOT NULL,
    first_name          VARCHAR2(256) NOT NULL,
    last_name           VARCHAR2(256) NOT NULL,
    profile_picture_url VARCHAR2(256),
    created_at          TIMESTAMP DEFAULT current_timestamp NOT NULL,
    last_login          TIMESTAMP,
    
    CONSTRAINT last_login_check CHECK (last_login >= created_at),
    PRIMARY KEY (user_id)
);

CREATE TABLE rightholders (
    rightholder_id     VARCHAR2(36),
    rightholder_signin VARCHAR(256) NOT NULL UNIQUE,
    password_hash      VARCHAR(256) NOT NULL,
    rightholder_name   VARCHAR2(256) NOT NULL,
    contact_name       VARCHAR2(256) NOT NULL,
    business_email     VARCHAR2(256) NOT NULL,
    billing_address    VARCHAR2(256),
    tax_id_number      NUMBER,
    
    PRIMARY KEY ( rightholder_id )
);

CREATE TABLE merchants (
    merchant_id     VARCHAR2(36),
    merchant_signin VARCHAR2(256) NOT NULL UNIQUE,
    password_hash   VARCHAR2(256) NOT NULL,
    business_name   VARCHAR2(256) NOT NULL,
    contact_name    VARCHAR2(256),
    business_email  VARCHAR2(256) NOT NULL,
    billing_address VARCHAR2(256),
    
    PRIMARY KEY ( merchant_id )
);

-------------------------------- ADS SYSTEM ------------------------------------
CREATE TABLE Ads (
    ad_id               VARCHAR2(36),
    merchant_id         VARCHAR2(36) NOT NULL,
    redirect_link       VARCHAR2(256) NOT NULL,
    ad_type             VARCHAR2(10) NOT NULL,
    content_url         VARCHAR2(256) NOT NULL,
    CONSTRAINT merchant_ads_fk FOREIGN KEY (merchant_id) REFERENCES Merchants (merchant_id),
    
    PRIMARY KEY ( ad_id )
);

CREATE TABLE Campaign (
    campaign_id VARCHAR2(36),
    user_id     VARCHAR2(36) NOT NULL,
    start_date  TIMESTAMP NOT NULL,
    end_date    TIMESTAMP NOT NULL,
    CONSTRAINT campaign_user_fk FOREIGN KEY ( user_id ) REFERENCES USERS ( user_id ),
    
    PRIMARY KEY ( campaign_id )
);

-- Composite entity for ads and campaign
CREATE TABLE CurrentAds (
    ad_id               VARCHAR2(36),
    campaign_id         VARCHAR2(36),
    
    CONSTRAINT ad_fk FOREIGN KEY (ad_id) REFERENCES Ads (ad_id),
    CONSTRAINT campaign_fk FOREIGN KEY (campaign_id) REFERENCES Campaign (campaign_id),
    
    PRIMARY KEY (ad_id, campaign_id)
);

CREATE TABLE Category (
    ad_category_id  VARCHAR2(36),
    description     VARCHAR2(256),
    
    PRIMARY KEY (ad_category_id)
);

CREATE TABLE AdCategory (
    ad_id           VARCHAR2(36),
    ad_category_id  VARCHAR2(36),
    
    CONSTRAINT adcategory_category_fk FOREIGN KEY (ad_category_id) 
        REFERENCES Category (ad_category_id),
    CONSTRAINT ac_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES Ads (ad_id),

    PRIMARY KEY ( ad_id, ad_category_id )
);

CREATE TABLE Location (
    local_ad_group_id VARCHAR2(36),
    description        VARCHAR2(256),
    timezone           VARCHAR2(256),
    
    PRIMARY KEY ( local_ad_group_id )
);

CREATE TABLE AdLocation (
    ad_id             VARCHAR2(36),
    local_ad_group_id VARCHAR2(36),
    timezone          VARCHAR2(256),
    
    CONSTRAINT adlocation_location_fk FOREIGN KEY (local_ad_group_id) 
        REFERENCES Location (local_ad_group_id),
    CONSTRAINT al_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES ads (ad_id),

        
    PRIMARY KEY (ad_id, local_ad_group_id)
);

CREATE TABLE AdStats (
    ad_stat_id           VARCHAR2(36),
    merchant_id          VARCHAR2(36) NOT NULL,
    ad_id                VARCHAR2(36) NOT NULL,
    start_time           TIMESTAMP NOT NULL,
    end_time             TIMESTAMP NOT NULL,
    impressions          NUMBER DEFAULT 0 NOT NULL,
    clicks               NUMBER DEFAULT 0 NOT NULL,
    cost_per_click       NUMBER DEFAULT 1 NOT NULL,
    cost_per_impression  NUMBER(10,5) DEFAULT '0.005' NOT NULL,
    
    CONSTRAINT adstats_merchant_fk FOREIGN KEY (merchant_id) 
        REFERENCES Merchants (merchant_id),
    CONSTRAINT adstats_ad_id_fk FOREIGN KEY (ad_id) 
        REFERENCES Ads (ad_id),
        
    PRIMARY KEY ( ad_stat_id )
);

------------------------------ MERCHANT SYSTEM ---------------------------------
CREATE TABLE MerchantInvoice (
    merchant_payment_id  NUMBER,
    ad_stat_id           VARCHAR2(36),
    payment_date         TIMESTAMP,
    payment_account      NUMBER,
    status               VARCHAR2(20) CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED')),

    CONSTRAINT merchantinvoice_adstat_fk FOREIGN KEY (ad_stat_id)
        REFERENCES AdStats (ad_stat_id),
        
    PRIMARY KEY ( merchant_payment_id )
);

CREATE TABLE MerchantPayments (
    merchant_id          VARCHAR2(36),
    merchant_payment_id  NUMBER,

    CONSTRAINT merchantpayments_merchant_fk FOREIGN KEY (merchant_id)
        REFERENCES Merchants (merchant_id),
    CONSTRAINT merchantpayment_merchant_payment_fk FOREIGN KEY (merchant_payment_id)
        REFERENCES MerchantInvoice (merchant_payment_id),

    PRIMARY KEY (merchant_id, merchant_payment_id)
);

-------------------------------- USER SYSTEM -----------------------------------
CREATE TABLE UserPlaylist (
    playlist_id          VARCHAR2(36),
    user_id              VARCHAR2(36) NOT NULL,
    playlist_name        VARCHAR2(256) NOT NULL,
    playlist_description VARCHAR2(256),
    image_url            VARCHAR2(256) NOT NULL,
    created_at           TIMESTAMP,
    CONSTRAINT user_playlist_fk FOREIGN KEY (user_id) REFERENCES USERS (user_id),
    
    PRIMARY KEY ( playlist_id )
);

-------------------------------- SONG SYSTEM -----------------------------------
CREATE TABLE Genre (
    genre_id          VARCHAR2(36),
    genre_name        VARCHAR2(256) NOT NULL UNIQUE,
    genre_description VARCHAR2(256) NOT NULL,
    
    PRIMARY KEY ( genre_id )
);

CREATE TABLE Artists (
    artist_id   VARCHAR2(36),
    artist_name VARCHAR2(256) NOT NULL,
    picture_url VARCHAR2(256) NOT NULL,
    biography   VARCHAR2(256) NOT NULL,
    created_at  TIMESTAMP DEFAULT current_timestamp NOT NULL,
    updated_at  TIMESTAMP,
    
    PRIMARY KEY ( artist_id )
);

CREATE TABLE Albums (
    album_id           VARCHAR2(36) PRIMARY KEY,
    artist_id          VARCHAR2(36),
    genre_id           VARCHAR2(36),
    album_name         VARCHAR2(256) NOT NULL,
    album_duration     NUMBER CONSTRAINT duration_check CHECK (album_duration > 0),
    
    CONSTRAINT albums_artist_fk FOREIGN KEY (artist_id)
        REFERENCES Artists (artist_id),
    CONSTRAINT albums_genre_fk FOREIGN KEY (genre_id)
        REFERENCES Genre (genre_id)
);

CREATE TABLE ArtistCollaboration (
    artist_id          VARCHAR2(36),
    album_id           VARCHAR2(36),
        
    CONSTRAINT ac_artist_fk FOREIGN KEY (artist_id)
        REFERENCES Artists (artist_id),
    CONSTRAINT ac_album_fk FOREIGN KEY (album_id)
        REFERENCES Albums (album_id),
        
    PRIMARY KEY (artist_id, album_id)
);

CREATE TABLE Songs (
    song_id            VARCHAR2(36),
    genre_id           VARCHAR2(256),
    album_id           VARCHAR2(36),
    right_holder_id    VARCHAR2(36),
    song_title         VARCHAR2(256) NOT NULL,
    song_duration      NUMBER CONSTRAINT song_duration_check CHECK (song_duration > 0),
    release_date       VARCHAR2(36),
    
    CONSTRAINT songs_genre_fk FOREIGN KEY (genre_id)
        REFERENCES Genre (genre_id),
    CONSTRAINT songs_album_fk FOREIGN KEY (album_id)
        REFERENCES Albums (album_id),
    CONSTRAINT songs_rightholder_fk FOREIGN KEY (right_holder_id)
        REFERENCES RightHolders (rightholder_id),
        
    PRIMARY KEY ( song_id )
);

CREATE TABLE SongCollaborations (
    song_id            VARCHAR2(36),
    artists_id         VARCHAR2(36),
        
    CONSTRAINT sc_song_fk FOREIGN KEY (song_id)
        REFERENCES Songs (song_id),
    CONSTRAINT sc_artist_fk FOREIGN KEY (artists_id)
        REFERENCES Artists (artist_id),
        
    PRIMARY KEY (song_id, artists_id)
);

---------------------------- RIGHTHOLDERS SYSTEM -------------------------------
CREATE TABLE SongStats (
    songstat_id     VARCHAR2(36),
    rightholder_id  VARCHAR2(36),
    song_id         VARCHAR2(256),
    cost_per_play   NUMBER(10,5) NOT NULL,
    likes           NUMBER DEFAULT 0 CONSTRAINT likes_check CHECK (likes > 0),
    shares          NUMBER DEFAULT 0 NOT NULL,
    start_date      TIMESTAMP,
    end_date        TIMESTAMP,

    CONSTRAINT songstats_rightholder_fk FOREIGN KEY (rightholder_id)
        REFERENCES Rightholders (rightholder_id),
    CONSTRAINT songstat_song_id_fk FOREIGN KEY (song_id) 
        REFERENCES Songs (song_id),

    PRIMARY KEY (songstat_id)
);

CREATE TABLE RightholderInvoice (
    rightholder_payment_id VARCHAR2(36),
    songstat_id            VARCHAR2(36),
    payment_date           TIMESTAMP NOT NULL,
    payment_account        NUMBER NOT NULL,
    status                 VARCHAR2(20),

    CONSTRAINT rightholderinvoice_songstat_fk FOREIGN KEY (songstat_id)
        REFERENCES SongStats (songstat_id),

    CONSTRAINT rightholderinvoice_status_ck CHECK (status IN ('PENDING', 'PAID', 'FAILED')),
    
    PRIMARY KEY ( rightholder_payment_id )
);

CREATE TABLE RightholderPayment (
    rightholder_id         VARCHAR2(36),
    rightholder_payment_id VARCHAR2(256),

    CONSTRAINT rightholderpayment_rightholder_fk FOREIGN KEY (rightholder_id)
        REFERENCES Rightholders (rightholder_id),
    CONSTRAINT rightholderpayment_rightholder_payment_fk FOREIGN KEY (rightholder_payment_id)
        REFERENCES RightholderInvoice (rightholder_payment_id),

    PRIMARY KEY (rightholder_id, rightholder_payment_id)
);


------------------------- CROSS SYSTEM DEPENDENTS ------------------------------
CREATE TABLE PlaylistSongs (
    playlist_id VARCHAR2(36),
    song_id VARCHAR2(36),
    
    CONSTRAINT ps_playlist_id_fk FOREIGN KEY (playlist_id) 
        REFERENCES UserPlaylist (playlist_id),
    CONSTRAINT ps_song_id_fk FOREIGN KEY (song_id)
        REFERENCES Songs (song_id),
        
    PRIMARY KEY ( playlist_id, song_id )
);

-------------------------
-- MOCK DATA INSERTION --
-------------------------

------------------------
-- ANALYTICAL QUERIES --
------------------------