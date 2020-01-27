/*
Q7: 4 rows, 5 seconds
Alaska Airlines Inc.
SkyWest Airlines Inc.
United Air Lines Inc.
Virgin America
 */

SELECT DISTINCT c.name AS carrier
FROM Flights AS f JOIN Carriers AS c ON f.carrier_id = c.cid
WHERE f.origin_city = 'Seattle WA'
AND f.dest_city = 'San Francisco CA'
ORDER BY carrier