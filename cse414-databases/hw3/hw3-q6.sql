/*
Q6: 4 rows, 3 seconds

Alaska Airlines Inc.
SkyWest Airlines Inc.
United Air Lines Inc.
Virgin America
 */

SELECT DISTINCT c.name AS carrier
FROM (SELECT f.carrier_id
  FROM Flights AS f
  WHERE f.origin_city = 'Seattle WA'
  AND f.dest_city = 'San Francisco CA') AS cid JOIN Carriers AS c ON cid.carrier_id = c.cid