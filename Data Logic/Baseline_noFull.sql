/* 
Experiment 1: Fully-specified model, includes all original model features including:
* Timestamp
* Station
* Material
* Vehicle identifier
* Vehicle fullness
*/
WITH LoadData AS
(
    SELECT
        CONVERT(DATETIME, CONVERT(CHAR(8), [Date], 112) + ' ' + CONVERT(CHAR(8), [Time], 108)) AS [TimeStamp],
        EntityName AS Station,
        CASE 
            WHEN EntityMaterialTypeCode IN (3, 4, 7, 8) THEN 'MSW'
            WHEN EntityMaterialTypeCode IN (1, 2) THEN 'Wood'
            WHEN EntityMaterialTypeCode IN (14, 15) THEN 'Yd'
            WHEN EntityMaterialTypeCode = 9 THEN 'ComOrg'
            ELSE 'ResOrg'
        END AS Material,
        CASE 
            WHEN TruckNumber <> '0' THEN TruckNumber
            -- Vehicles 23 - 27 descrs haven't made it to shdata sql view yet
            WHEN TruckNumber = '0' AND VehicleTypeCode = 23 THEN 'Pickup w/ 3 Axle Trlr'
            WHEN TruckNumber = '0' AND VehicleTypeCode = 24 THEN 'Car w 2 Axle Trlr'
            WHEN TruckNumber = '0' AND VehicleTypeCode = 25 THEN 'Van w Trlr'
            WHEN TruckNumber = '0' AND VehicleTypeCode = 26 THEN 'Box truck tipper'
            WHEN TruckNumber = '0' AND VehicleTypeCode = 27 THEN 'On site bin'
            -- But all others have
            ELSE VehicleType 
        END AS Vehicle,
        NetTonnage AS Tons
        
        FROM
        [SWIS].[dbo].[MetroWeighMasterTransactionDataView]
        
        WHERE
        TransactionTypeCode<>16 AND --excludes voided transactions
        DestinationTypeCode=20 AND --excludes any outbound transactions
        EntityMaterialTypeCode IN (1, 2, 3, 4, 7, 8, 6, 9, 14, 15) AND --all weight-based streams
        NetTonnage BETWEEN .01 AND 16 AND --eliminate zero-ton loads and miscoded outbound loads
        VehicleType NOT IN ('NULL', 'Not Specified', 'OUT DB W/TAGS') AND
        Date BETWEEN '2021-04-01' AND '2023-03-31' -- train/test on last 2 years
),
VehicleCapacity AS
(
    SELECT
        Station,
        Material,
        Vehicle,
        MAX(Tons) AS Capacity

    FROM 
    LoadData

    GROUP BY
    Station,
    Material,
    Vehicle
)
SELECT
    LoadData.TimeStamp,
    LoadData.Station,
    LoadData.Material,
    LoadData.Vehicle,
    LoadData.Tons

FROM
LoadData INNER JOIN VehicleCapacity ON
    LoadData.Station = VehicleCapacity.Station
    AND LoadData.Material = VehicleCapacity.Material
    AND LoadData.Vehicle = VehicleCapacity.Vehicle