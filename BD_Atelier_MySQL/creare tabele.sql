create database atelier;

create table orders(
    id binary(16) primary key,
    customer binary(16) not null, -- FK to Users
    state enum('waiting', 'confirmed', 'denied', 'inprogress', 'rfp', 'pickedup') not null,
    dropOffDate datetime not null,
    startDate datetime,
    finishDate datetime,
    clientDescription text,
    mechanicNotes text,
    manager binary(16) -- FK to Users
);

create table users(
    id binary(16) primary key,
    name varchar(40) not null,
    type enum('mechanic', 'manager', 'client') not null,
    username varchar(20) unique not null,
    password varchar(256) not null-- argon2 hash
);

create table mechanics(
    id binary(16) primary key,
    user binary(16) not null, -- FK to Users
    ordersFullfilled numeric(5),
    hireDate date not null,
    manager binary(16) not null -- FK to Users,
    CHECK(ordersFullfilled > 0)
);

create table bills(
    id binary(16) primary key,
    orderid binary(16) unique not null, -- FK to Orders
    billed boolean,
    payed boolean
);

create table billitems(
    id binary(16) primary key,
    bill binary(16) not null, -- FK to Bills
    name varchar(20) not null,
    price double(53) not null,
    quantity numeric(5) not null,
    labourHours numeric(5) not null,
    labourPricePerHour double(53) not null,
    CHECK(quantity > 0),
    CHECK(labourPricePerHour > 0)
);

create table orders_mechanics(
    orderid binary(16) not null, -- FK to Orders
    mechanic binary(16) not null, -- FK to Mechanics
    primary key(orderid, mechanic)
);