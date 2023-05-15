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
            WHEN VehicleTypeCode = 23 THEN 'Pickup w/ 3 Axle Trlr'
            WHEN VehicleTypeCode = 24 THEN 'Car w 2 Axle Trlr'
            WHEN VehicleTypeCode = 25 THEN 'Van w Trlr'
            WHEN VehicleTypeCode = 26 THEN 'Box truck tipper'
            WHEN VehicleTypeCode = 27 THEN 'On site bin'
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
        Date IN ('2023-04-08', '2023-04-13', '2023-04-23', '2023-05-04', '2023-04-17')
),
VehicleCapacity AS -- include same time span as that of training/test data
(
    SELECT
        EntityName AS Station,
        CASE 
            WHEN EntityMaterialTypeCode IN (3, 4, 7, 8) THEN 'MSW'
            WHEN EntityMaterialTypeCode IN (1, 2) THEN 'Wood'
            WHEN EntityMaterialTypeCode IN (14, 15) THEN 'Yd'
            WHEN EntityMaterialTypeCode = 9 THEN 'ComOrg'
            ELSE 'ResOrg'
        END AS Material,
        CASE 
            WHEN VehicleTypeCode = 23 THEN 'Pickup w/ 3 Axle Trlr'
            WHEN VehicleTypeCode = 24 THEN 'Car w 2 Axle Trlr'
            WHEN VehicleTypeCode = 25 THEN 'Van w Trlr'
            WHEN VehicleTypeCode = 26 THEN 'Box truck tipper'
            WHEN VehicleTypeCode = 27 THEN 'On site bin'
            ELSE VehicleType 
        END AS Vehicle,
        MAX(NetTonnage) AS Capacity

    FROM 
    [SWIS].[dbo].[MetroWeighMasterTransactionDataView]

    WHERE
    TransactionTypeCode<>16 AND --excludes voided transactions
    DestinationTypeCode=20 AND --excludes any outbound transactions
    EntityMaterialTypeCode IN (1, 2, 3, 4, 7, 8, 6, 9, 14, 15) AND --all weight-based streams
    NetTonnage BETWEEN .01 AND 16 AND --eliminate zero-ton loads and miscoded outbound loads
    VehicleType NOT IN ('NULL', 'Not Specified', 'OUT DB W/TAGS') AND
    Date BETWEEN '2021-04-01' AND '2023-03-31' -- train/test on last 2 years

    GROUP BY
    EntityName,
    CASE 
        WHEN EntityMaterialTypeCode IN (3, 4, 7, 8) THEN 'MSW'
        WHEN EntityMaterialTypeCode IN (1, 2) THEN 'Wood'
        WHEN EntityMaterialTypeCode IN (14, 15) THEN 'Yd'
        WHEN EntityMaterialTypeCode = 9 THEN 'ComOrg'
        ELSE 'ResOrg'
    END,
    CASE 
        WHEN VehicleTypeCode = 23 THEN 'Pickup w/ 3 Axle Trlr'
        WHEN VehicleTypeCode = 24 THEN 'Car w 2 Axle Trlr'
        WHEN VehicleTypeCode = 25 THEN 'Van w Trlr'
        WHEN VehicleTypeCode = 26 THEN 'Box truck tipper'
        WHEN VehicleTypeCode = 27 THEN 'On site bin'
        ELSE VehicleType 
    END
),
Combined AS
(
SELECT
    LoadData.Station,
    LoadData.Material,
    LoadData.Vehicle,
    ROUND(LoadData.Tons/VehicleCapacity.Capacity,2) AS Fullness,
    LoadData.Tons

FROM
LoadData INNER JOIN VehicleCapacity ON
    LoadData.Station = VehicleCapacity.Station
    AND LoadData.Material = VehicleCapacity.Material
    AND LoadData.Vehicle = VehicleCapacity.Vehicle
)

SELECT * FROM Combined