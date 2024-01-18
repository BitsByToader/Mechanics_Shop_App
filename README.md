![image](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/ea46578d-78a7-486d-8771-a8767a89c998)
# Mechanics_Shop_App
The repository contains all necessary code for an application which manages a mechanics shop. It supports operations for clients, managers and mechanics.

In short the current capabilities of the system are as follows: A client is able to place a service order along with a description and preffered drop-off date, which will be accepeted/denied by a manager. If confirmed, the manager will assign mechanics to the order which will be able to modify the bill of the order and add any other relevant (short) notes. Finally, the manager can close the order and bill the client, which will have to pay the bill in order to receive a pick-up date for the vehicle.

# Reductive overview of the system
![image](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/c7b50c3d-3c5a-4bfc-8fb3-488652d5d5b2)

The front-end is written in SwiftUI and supports iOS, iPadOS and macOS clients. The back-end is written in Swift, using the Vapor framework, and supports Linux and macOS targets. The databse is any ordinary, somewhat current MySQL/MariaDB version.

# Database design
![Database Design](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/eb76ccac-8210-41ca-97da-1a04607dd114)

# Screenshots
![Login screen](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/85539b09-a6ce-45d5-baf8-8c5fcffece57)

![Orders view](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/5ba4a26d-5fee-47d0-a5ad-142842e0ce7e)

![Order view](https://github.com/BitsByToader/Mechanics_Shop_App/assets/57571262/417e5e35-59e3-467f-ac4c-0616c941f84b)
