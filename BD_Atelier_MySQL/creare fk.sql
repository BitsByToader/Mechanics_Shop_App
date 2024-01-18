-- Tabel orders
alter table
    orders
add constraint
    FK_OrderCustomer
foreign key (customer) references users(id);

alter table
    orders
add constraint
    FK_OrderManager
foreign key (manager) references users(id);
--



-- Tabel mechanics
alter table
    mechanics
add constraint
    FK_MechanicUser
foreign key (user) references users(id);

alter table
    mechanics
add constraint
    FK_MechanicManager
foreign key (manager) references users(id);
--



-- Tabel bills
alter table
    bills
add constraint 
    FK_BillOrder
foreign key (orderid) references orders(id);
--



-- Tabel billitems
alter table
    billitems
add constraint
    FK_BillItemBill
foreign key (bill) references bills(id);
--



-- Tabel orders_mechanics
alter table
    orders_mechanics
add constraint
    FK_order_mechanic
foreign key (orderid) references orders(id);

alter table
    orders_mechanics
add constraint
    FK_mechanic_order
foreign key (mechanic) references mechanics(id);
--