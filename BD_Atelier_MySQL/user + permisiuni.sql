CREATE USER 'atelier'@'%' IDENTIFIED BY 'atelier';
GRANT ALL PRIVILEGES ON atelier.* TO 'atelier'@'%';
FLUSH PRIVILEGES;