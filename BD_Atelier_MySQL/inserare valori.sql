-- Tabel users
insert into
    users (id, name, type, username, password)
values
    (UUID_TO_BIN(UUID()), "Joe Doe", 'manager', 'JDoe', '$argon2i$v=19$m=256,t=32,p=2$d2plOGJ1ejV1aDAwMDAwMA$5iSXeu7dsSsZa7GZxwPpYWKeUiaWkZH7myJV4RlSP9M'); -- argon2 hash pentru '1234'

insert into
    users (id, name, type, username, password)
values
    (UUID_TO_BIN(UUID()), "John Smith", 'mechanic', 'JSmith', '$argon2i$v=19$m=256,t=32,p=2$d2plOGJ1ejV1aDAwMDAwMA$5iSXeu7dsSsZa7GZxwPpYWKeUiaWkZH7myJV4RlSP9M');

insert into
    users (id, name, type, username, password)
values
    (UUID_TO_BIN(UUID()), "Tim Apple", 'mechanic', 'TApple', '$argon2i$v=19$m=256,t=32,p=2$d2plOGJ1ejV1aDAwMDAwMA$5iSXeu7dsSsZa7GZxwPpYWKeUiaWkZH7myJV4RlSP9M');

insert into
    users (id, name, type, username, password)
values
    (UUID_TO_BIN(UUID()), "Bob Builder", 'client', 'BBuilder', '$argon2i$v=19$m=256,t=32,p=2$d2plOGJ1ejV1aDAwMDAwMA$5iSXeu7dsSsZa7GZxwPpYWKeUiaWkZH7myJV4RlSP9M');

insert into
    users (id, name, type, username, password)
values
    (UUID_TO_BIN(UUID()), "Tudor Ifrim", 'client', 'tudor', '$argon2i$v=19$m=256,t=32,p=2$d2plOGJ1ejV1aDAwMDAwMA$5iSXeu7dsSsZa7GZxwPpYWKeUiaWkZH7myJV4RlSP9M');
--


-- NOTA: Din cauza deciziei (mai putin inspirate din acest punct de vedere) de a folosi UUID-uri
-- in loc de id-uri int clasice cu auto increment, nu prea pot sa creez inserari reale ca nu ar coincide
-- cu generarea automata random a UUID-urilor.
-- Astfel, am lasat aici doar niste template-uri pentru inserarea valorilor in baza de date...


-- Tabel mecanici
insert into
    mechanics(id, user, ordersFullfilled, hireDate, manager)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), 4, DATE('2023-06-23'), UUID_TO_BIN(...));

insert into
    mechanics(id, user, ordersFullfilled, hireDate, manager)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), 19, DATE('2010-03-19'), UUID_TO_BIN(...));
--



-- Tabel orders
insert into
    orders(id, customer, state, dropOffDate, startDate, clientDescription, manager)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), 'waiting', CURRENT_DATE(), CURRENT_DATE(), 'It no work:(', UUID_TO_BIN(...));

insert into
    orders(id, customer, state, dropOffDate, startDate, clientDescription, manager)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), 'inprogress', CURRENT_DATE(), CURRENT_DATE(), 'Brok xD', ...);
--



-- Tabel orders_mechanics
insert into
    orders_mechanics(orderid, mechanic)
values
    (UUID_TO_BIN(...), UUID_TO_BIN(...));

insert into
    orders_mechanics(orderid, mechanic)
values
    (UUID_TO_BIN(...), UUID_TO_BIN(...));
--


-- Tabel bills
insert into
    bills(id, orderid, billed, payed)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), 0, 0);
--



-- Tabel billitems
insert into
    billitems(id, bill, name, price, quantity, labourHours, labourPricePerHour)
values
    (UUID_TO_BIN(UUID()), UUID_TO_BIN(...), '', 1.0, 1, 1, 1.0);
--