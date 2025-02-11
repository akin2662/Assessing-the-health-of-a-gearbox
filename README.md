# Assessing-the-health-of-a-gearbox
**Note:** This project was done as a requirement for the course ENME691- Industrial AI at University of Maryland,College Park and was done in collaboration with Murilo Nicoluzzi (murinico@umd.edu). The data for this project was provided by the Industrial AI Center (iaiCenter) at University of Maryland, College Park. Contact: contact@iaicenter.com

## Project Description:
This project develops a vibration-based health monitoring system to detect eccentric gear faults in industrial gearboxes operating under multiple conditions (45 Hz light/heavy load, 50 Hz light load). The system uses accelerometer data and machine learning models to predict faults, aiming to prevent unplanned downtime in power plants.

**Key Components:**
* **Data:** 1-second vibration samples at 66.67 kHz from 2 accelerometers and a tachometer
* **Fault Signature:** Eccentricity in Gear 3 (48 teeth) on idler shaft
* **Features:** RMS, kurtosis, and peak-to-peak values from time-domain signals
* **Models:** Self-Organizing Maps (SOM), SVM, k-NN, and Hotelling’s T²

Here is the complete report of the project | [Report](https://github.com/user-attachments/files/18746579/Group.2.-.Industrial.AI.Final.Report.pdf)

## Libraries and Dependencies
* MATLAB R2024b
* Statistics and Machine Learning Toolbox
* SOM Toolbox
* Signal Processing Toolbox
