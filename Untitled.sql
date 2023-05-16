SELECT 
    *
FROM
    ClassicModels.OrderDetails
WHERE
    quantityOrdered > 30 AND priceEach < 100
LIMIT 20;