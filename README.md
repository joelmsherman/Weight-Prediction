# Predicting Weights of Transfer Station Loads without Scales
![image](https://github.com/joelmsherman/Weight-Prediction/blob/b80fc6400cdb6717cb35838323e2e37caa3557cd/Images/ReadmeTitle.png)

A consolidated summary presentation is available [here](https://www.beautiful.ai/player/-NXNAsMpTJbK0JcUkRhR)

## Background
ABC Waste Inc's revenues depend largely on the ability to apply an accurate weight (in tons) to established specific tonnage fees and and government taxes.  To do this, ABC uses certified vehicle scales (to within +/- .01 tons, or 20lbs) to record weights.  

In addition to weight, ABC's scalehouses collect additional information about each load, including information about the vehicle (truck number, type), customer, station, and its timestamp (date and time of arrival).  Since mid-2012, ABC's database contains well over 4 million records.

## Objective
The objective of this analysis is to train, validate, test and deploy a machine learning (ML) model that will predict load weight in the event of a temporary scale outage or malfunction, based on readily observable features of the load.  The end product must be accessible to scalehouse staff on battery-powered devices, be easy to use, and performant.  

## Methods
The analysis is conducted in the following steps.

### Exploratory Data Analysis
Over 4 million records were extracted from ABC's point-of-sale system between June 1, 2012 and January 31, 2023, for analysis of feature distributions, and the variation of those distributions with respect to load weight.  Short descriptions of each feature are as follows:

* **Timestamp:** Date and time of the load's arrival, which contain features such as year, month, day of week and hour of the day of arrival.
* **Station:** Facility to which the load is arriving.
* **Material:** Dominant material stream (MSW, residential or commercial organics, wood or yard debris) arriving in the load.
* **Vehicle:**  Information about the arriving vehicle, including it's type or truck number (if known).
* **Fullness** The fullness of a vehicle arriving at facility f with Material m, relative to it's historical max for s and m over the data duration.

An exploratory analysis of the data is available [here](https://app.hex.tech/54be54bd-cccc-4888-804c-cdb2c24bc75d/hex/dd01deda-2a53-4694-933f-63119b539ca5/draft/logic).

### Machine Learning
A baseline and 4 alternative regression models were trained and tested.  The goal was to find a most parsimonious, best-fitting model that accurately predicted weights.  Parsimony will be important when the model is deployed into the field, as they will allow staff to make minimal observations and generate predictions very quickly.  

## Results
The experiment results showed that the model without date, time and truck number features generalized the best and had the lowest error.  Parsimony won the day. The final feature set of the model:

* *Station:* Facility to which the load is arriving.
* *Material:* Dominant material stream (MSW, residential or commercial organics, wood or yard debris) arriving in the load.
* *Vehicle:*  Arriving vehicle type.
* *Fullness* Fullness of a vehicle, expressed as a percentage between 0 and 1.

Over the two year period April 2021 through March 2023, the MAE of the 277K holdout loads was about .03 tons.  On a total tonnage basis, the model predicted 382,200 tons, in comparison to the 382,000 actual tons in the sample. An analysis of the ML experiments, including pre-processing steps, test harness and experiment results are available [here](https://app.hex.tech/54be54bd-cccc-4888-804c-cdb2c24bc75d/hex/3f5c7f28-f15d-459a-8999-b1f779103515/draft/logic).

 

