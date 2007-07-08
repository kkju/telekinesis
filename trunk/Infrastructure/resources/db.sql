CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created TIMESTAMP,
    uid VARCHAR(255),
    name VARCHAR(255)
);

CREATE TABLE ips (
    userid INT NOT NULL,
    ip VARCHAR(18),
    FOREIGN KEY (userid) REFERENCES users.id
);

CREATE TABLE ports (
    userid INT NOT NULL,
    port VARCHAR(6),
    service VARCHAR(64),
    FOREIGN KEY (userid) REFERENCES users.id
);