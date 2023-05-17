# Food Waste - Database Design and SQL

# Description: 

# Grocery stores and other food retailers often have left over food stock in their shelves that are 
# near expiration. Unfortunately, these stores are left to throw out these expired and near-expired 
# food leading to a large amount of food waste. This database is designed to tackle the problem of 
# food waste by allowing non-profit organizations (NPOs) like food banks to query information about 
# nearby food retailers. Using this designed database, they may query which food suppliers near them 
# have specific types of food and when it expires. So, they can offer to purchase the foods that will 
# be expiring soon at bulk discounts to eliminate waste. They can also keep track of what products in 
# their office stock are going to run out. Assuming these queries are performed in late September, i.e., 
# food with expiration date in October is close to expiration.

# Software: MySQL Workbench

# Queries:

# 1. Our NPO realizes that tomatoes are in high demand. He wants to check if his primary sources, Jusgo 
# or GW has at least 15lbs of tomatoes in one of the stores that have the expiration date of 29th of 
# November. Order by total tomato volume.

SELECT 
    foodSupplier.supplierName AS Name,
    SUM(supplierInv.quantity) AS AvailablePoundOfTomato
FROM
    supplierInv,
    foodSupplier
WHERE
    supplierInv.supplierID = foodSupplier.supplierID
        AND foodSupplier.supplierName REGEXP 'Jusgo|GW'
        AND supplierInv.expDate = '2022-11-29'
        AND (SELECT 
            SUM(supplierInv.quantity)
        FROM
            supplierInv,
            foodSupplier
        WHERE
            supplierInv.supplierid = foodSupplier.supplierID
                AND supplierInv.productName REGEXP 'Tomato|tomato'
                AND foodSupplier.supplierName REGEXP 'Jusgo|GW') > 15
GROUP BY foodSupplier.supplierName
ORDER BY AvailablePoundOfTomato DESC;

Output:
+ --------- + --------------------------- +
| Name      | AvailablePoundOfTomato      |
+ --------- + --------------------------- +
| Jusgo | 64                          |
| GW      | 28                          |
+ --------- + --------------------------- +

# 2. Our NPO FoodForEveryone wants to find all the addresses of Food Suppliers in the same city as their 
# Athens office. Order by supplier names.

SELECT 
    foodSupplier.supplierName,
    foodSupplier.streetAddress,
    city.cityName
FROM
    foodSupplier
        JOIN
    city ON city.cityID = foodSupplier.cityID
WHERE
    city.cityName REGEXP 'Athens'
ORDER BY foodSupplier.supplierName;

Output:
+ ----------------- + ------------------ + ------------- +
| supplierName      | streetAddress      | cityName      |
+ ----------------- + ------------------ + ------------- +
| Earth Fare        | 1689 S Lumpkin St  | Athens        |
| Kroger            | 191 Alps Rd        | Athens        |
| Hmart       | 171 International Dr | Athens        |
+ ----------------- + ------------------ + ------------- +

# 3. Our NPO wants to see how much milk in Publix in Atlanta, GA is expiring soon in October that they 
# may be able to purchase.

SELECT 
    supplierName,
    cityName,
    productName,
    SUM(quantity) AS totalAmount,
    expDate
FROM
    state
        JOIN
    city ON state.stateID = city.cityID
        JOIN
    foodSupplier ON city.cityID = foodSupplier.cityID
        JOIN
    supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    cityName = 'Atlanta'
        AND stateName = 'Georgia'
        AND productName = 'Milk'
        AND expDate >= '2022-10-01'
        AND expDate < '2022-10-31'
        AND supplierName REGEXP 'publix|Publix'
GROUP BY supplierName , cityName , productName , expDate;

Output:
+ ----------------- + ------------- + ---------------- + ---------------- + ------------ +
| supplierName      | cityName      | productName      | totalAmount      | expDate      |
+ ----------------- + ------------- + ---------------- + ---------------- + ------------ +
| Publix at Piedmont | Atlanta       | Milk             | 1                | 2022-10-15   |
| Publix at Piedmont | Atlanta       | Milk             | 2                | 2022-10-26   |
+ ----------------- + ------------- + ---------------- + ---------------- + ------------ +

# 4. NPO wants to find products that have the maximum amount among all foods and at least 10 units in
# inventory at all suppliers in GA state, So, NPO can know where to easily order large amounts of 
# certain foods.

SELECT 
    supplierName,
    streetAddress,
    stateName,
    productName,
    MAX(supplierInv.quantity) AS Total
FROM
    state
        JOIN
    city ON state.stateID = city.cityID
        JOIN
    foodSupplier ON city.cityID = foodSupplier.cityID
        JOIN
    supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    stateName REGEXP 'Georgia'
GROUP BY supplierName , streetAddress , stateName , productName
HAVING MAX(supplierInv.quantity) > 10
ORDER BY MAX(supplierInv.quantity) DESC;

Output:
+ ----------------- + ------------------ + -------------- + ---------------- + ---------- +
| supplierName      | streetAddress      | stateName      | productName      | Total      |
+ ----------------- + ------------------ + -------------- + ---------------- + ---------- +
| Publix at Piedmont | 595 Piedmont Ave NE | Georgia        | Eggs             | 27         |
| Sprouts Farmers Market | 1845 Piedmont Ave NE Ste 500 | Georgia        | Eggs             | 27         |
| Sprouts Farmers Market | 1845 Piedmont Ave NE Ste 500 | Georgia        | Honey            | 21         |
| Sprouts Farmers Market | 1845 Piedmont Ave NE Ste 500 | Georgia        | Cookies          | 21         |
| Publix at Piedmont | 595 Piedmont Ave NE | Georgia        | Tomatoes         | 13         |
+ ----------------- + ------------------ + -------------- + ---------------- + ---------- +

# 5. Our NPO hears that across their locations, eggs are not selling very well at the local food 
# suppliers. They are interested in buying eggs. However, they only want to purchase eggs that 
# are expiring soon (October). So, they want to find which food suppliers have near-expired eggs 
# and their exact expiration dates.

SELECT 
    supplierInv.productName AS Product,
    supplierInv.expDate,
    supplierInv.quantity,
    supplierInv.unitOfMeasurement,
    foodSupplier.supplierName AS Supplier,
    foodSupplier.streetAddress,
    foodSupplier.cityID,
    foodSupplier.stateID
FROM
    supplierInv
        JOIN
    foodSupplier ON supplierInv.supplierID = foodSupplier.supplierID
WHERE
    productName REGEXP 'eggs|Eggs'
        AND expDate < '2022-11-01';

Output:
+ ------------ + ------------ + ------------- + ---------------------- + ------------- + ------------------ + ----------- + ------------ +
| Product  	| expDate  	| quantity  	| unitOfMeasurement  	| Supplier  	| streetAddress  	| cityID  	| stateID  	|
+ ------------ + ------------ + ------------- + ---------------------- + ------------- + ------------------ + ----------- + ------------ +
| Eggs     	| 2022-10-30   | 27        	| Oz                 	| Publix at Piedmont | 595 Piedmont Ave NE | 1       	| 1        	|
| Eggs     	| 2022-10-24   | 27        	| Oz                 	| Kroger    	| 191 Alps Rd    	| 2       	| 1        	|
+ ------------ + ------------ + ------------- + ---------------------- + ------------- + ------------------ + ----------- + ------------ +

# 6. A NPO in GA wants to run a sandwich donation at the end of September. So, they want to know
# how many pounds of tomatoes that are expiring in the October or later they can buy. Since the 
# amount of sandwiches they can provide depends on the amount tomatoes they can buy. Assuming each 
# pound of tomatoes can make ten sandwiches. 

SELECT 
    productName,
    SUM(supplierInv.quantity) AS Total,
    unitOfMeasurement AS Unit,
    (10 * (SUM(supplierInv.quantity))) AS Sandwich
FROM
    state
        JOIN
    city ON state.stateID = city.cityID
        JOIN
    foodSupplier ON city.cityID = foodSupplier.cityID
        JOIN
    supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    stateName REGEXP 'Georgia'
        AND productName REGEXP 'Tomato|tomato'
        AND expDate >= '2022-10-01'
GROUP BY productName , unitOfMeasurement;

Output:
+ ---------------- + ---------- + --------- + ------------- +
| productName      | Total      | Unit      | Sandwich      |
+ ---------------- + ---------- + --------- + ------------- +
| Tomatoes         | 18         | Lbs       | 180           |
+ ---------------- + ---------- + --------- + ------------- +

# 7. Our NPO wants to know which suppliers supplied food for all their offices and what they have
# in inventory currently with expiration date later than 09/20/2022 ordered by supplier names, 
# product names, expiration date. So, it may be faster and easier to order certain items for all 
# offices later from these suppliers.

SELECT 
    supplierName,
    productName,
    expDate,
    SUM(quantity) AS quantity
FROM
    foodSupplier
        JOIN
    supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            office
        WHERE
            NOT EXISTS( SELECT 
                    *
                FROM
                    officeStock
                WHERE
                    officeStock.supplierID = foodSupplier.supplierID
                        AND officeStock.officeID = office.officeID))
        AND supplierInv.expDate > '2022-09-20'
GROUP BY supplierName , productName , expDate
ORDER BY supplierName , productName , expDate;

Output:
+ ----------------- + ---------------- + ------------ + ------------- +
| supplierName      | productName      | expDate      | quantity      |
+ ----------------- + ---------------- + ------------ + ------------- +
| Kroger            | Bananas          | 2022-09-25   | 2             |
| Kroger            | Eggs             | 2022-09-24   | 27            |
| Kroger            | Rice             | 2022-11-01   | 5             |
| Kroger            | Rice             | 2022-11-11   | 2             |
| Kroger            | Tomatoes         | 2022-11-29   | 1             |
| Publix at Piedmont | Apples           | 2022-10-01   | 3             |
| Publix at Piedmont | Apples           | 2022-10-05   | 2             |
| Publix at Piedmont | Bread            | 2022-10-15   | 1             |
| Publix at Piedmont | Eggs             | 2022-09-30   | 27            |
| Publix at Piedmont | Eggs             | 2022-11-01   | 27            |
| Publix at Piedmont | Milk             | 2022-10-15   | 1             |
| Publix at Piedmont | Milk             | 2022-10-26   | 2             |
| Publix at Piedmont | Tomatoes         | 2022-11-29   | 13            |
+ ----------------- + ---------------- + ------------ + ------------- +

# 8. Our NPO office at Atlanta, GA wants to find the name and address of the supplier that has
# the largest amount of milk in their inventory among all suppliers at the same city for an 
# upcoming large purchase of milk.

SELECT 
    supplierName,
    streetAddress,
    cityName,
    stateName,
    productName,
    SUM(quantity) AS totalAmount,
    unitOfMeasurement
FROM
    state
        JOIN
    city ON state.stateID = city.cityID
        JOIN
    foodSupplier ON city.cityID = foodSupplier.cityID
        JOIN
    supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    cityName = 'Atlanta'
        AND stateName = 'Georgia'
        AND productName = 'Milk'
GROUP BY supplierName , streetAddress , cityName , stateName , productName , unitOfMeasurement
HAVING totalAmount = (SELECT 
        SUM(quantity)
    FROM
        state
            JOIN
        city ON state.stateID = city.cityID
            JOIN
        foodSupplier ON city.cityID = foodSupplier.cityID
            JOIN
        supplierInv ON foodSupplier.supplierID = supplierInv.supplierID
    WHERE
        cityName = 'Atlanta'
            AND stateName = 'Georgia'
            AND productName = 'Milk'
    GROUP BY supplierName
    ORDER BY SUM(quantity) DESC
LIMIT 1);

Output:
+ ----------------- + ------------------ + ------------- + -------------- + ---------------- + ---------------- + ---------------------- +
| supplierName      | streetAddress      | cityName      | stateName      | productName      | totalAmount      | unitOfMeasurement      |
+ ----------------- + ------------------ + ------------- + -------------- + ---------------- + ---------------- + ---------------------- +
| Publix at Piedmont | 595 Piedmont Ave NE | Atlanta       | Georgia        | Milk             | 30                | Gallons                |
+ ----------------- + ------------------ + ------------- + -------------- + ---------------- + ---------------- + ---------------------- +

# 9. Execute: Our NPO office at 1111 S Figueroa St, Los Angeles wants to know what products 
# are not available in the office stock, but available in local supplying stores, their 
# expiration dates, quantities, supplier names, and street addresses, ordered by product names
# and expiration dates. So, the NPO office can purchase new products and increase the diversity
# of their food stock. 

SELECT 
    productName, expDate, quantity, supplierName, streetAddress
FROM
    supplierInv
        JOIN
    foodSupplier ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    cityID = (SELECT 
            cityID
        FROM
            city
        WHERE
            cityName = 'Los Angeles')
        AND NOT EXISTS( SELECT 
            *
        FROM
            officeStock
        WHERE
            supplierInv.productName = officeStock.productName
                AND officeStock.officeID = (SELECT 
                    officeID
                FROM
                    office
                WHERE
                    address = '1111 S Figueroa St')
                AND cityID = (SELECT 
                    cityID
                FROM
                    city
                WHERE
                    cityName = 'Los Angeles'))
ORDER BY productName , expDate;

Output:
+ ---------------- + ------------ + ------------- + ----------------- + ------------------ +
| productName      | expDate      | quantity      | supplierName      | streetAddress      |
+ ---------------- + ------------ + ------------- + ----------------- + ------------------ +
| Almond Milk      | 2022-10-20   | 10            | Ralphs            | 11922 S Vermont Ave |
| Black Beans      | 2022-10-02   | 10            | Ralphs            | 11922 S Vermont Ave |
| Yogurt           | 2022-10-10   | 14            | Ralphs            | 11922 S Vermont Ave |
+ ---------------- + ------------ + ------------- + ----------------- + ------------------ +

# 10. Our NPO in Atlanta, GA was offered a purchasing discount by Publix, so they want to know
# whether Publix stores in Atlanta, GA have high-demand foods: eggs, bread or apple in stock, 
# if so, what are their quantities and expiration dates? Order by product names and expiration dates.

SELECT 
    productName,
    expDate,
    quantity,
    unitOfMeasurement,
    supplierName
FROM
    supplierInv
        JOIN
    foodSupplier ON foodSupplier.supplierID = supplierInv.supplierID
WHERE
    productName IN ('Apples' , 'Bread', 'Eggs')
        AND supplierName REGEXP 'Publix|publix'
        AND foodSupplier.cityID = (SELECT 
            city.cityID
        FROM
            city
        WHERE
            cityName = 'Atlanta'
                AND stateID = (SELECT 
                    state.stateID
                FROM
                    state
                WHERE
                    stateName = 'Georgia'))
ORDER BY productName , expDate;

Output:
+ ---------------- + ------------ + ------------- + ---------------------- + ----------------- +
| productName      | expDate      | quantity      | unitOfMeasurement      | supplierName      |
+ ---------------- + ------------ + ------------- + ---------------------- + ----------------- +
| Apples           | 2022-10-01   | 3             | Lbs                    | Publix at Piedmont |
| Apples           | 2022-10-05   | 2             | Lbs                    | Publix at Piedmont |
| Bread            | 2022-10-15   | 1             | Lbs                    | Publix at Piedmont |
| Eggs             | 2022-09-30   | 27            | Oz                     | Publix at Piedmont |
| Eggs             | 2022-11-01   | 27            | Oz                     | Publix at Piedmont |
+ ---------------- + ------------ + ------------- + ---------------------- + ----------------- +
