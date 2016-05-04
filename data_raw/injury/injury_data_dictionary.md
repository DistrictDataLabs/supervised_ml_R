Dataset is a sample of tow-away crashes for vehicles less than 10 years old in the United States. This is a curated sample of data, designed to accompany an introductory workshop on supervised machine learning methods. Each observation is a single occupant in a crash. There may be multiple observations for a given crash, depending on the number of vehicles involved and the number of occupants in the vehicles.

## Data Source
(http://www.nhtsa.giov/Data/National+Automotive+Sampling+System+(NASS)/NASS+Crashworthiness+Data+System)

Data are compiled from the National Automotive Sampling System / Crashworthiness Data System (NASS/CDS). NASS/CDS data are collected by the National Highway Traffic Safety Administration. The data represent a probability sample of crashes in the United States involving passenger cars, light trucks, vans, and utility vehicles. Approximately 5,000 accidents are sampled per year, stratified by primary sampling unit (PSU). There are 27 PSUs across the country. Each PSU has an assigned crash investigation team. These crash investigators obtain data by investigating the crash site, studying the vehicles involved, interviewing crash victims, by reviewing medical records. Personal information about individuals involved in the crashes are not included in any public NASS file.

The data selected for this study include NASS/CDS years 2000 - 2014. Several observations are removed due to data misingess. Data have been re-sampled to be representative of crashes in the U.S. as collected data are biased towards more severe accidents.

## Maximum Abbreviated Injury Scale (MAIS)

(Source: Baker SP, O'Neill B, Haddon W, Long WB, "The Injury Severity Score: a method for describing patients with multiple injuries and evaluating emergency care,", Journal of Trauma, Vol. 14, No. 5, 1997, pp. 187-196.)

The Abbreviated Injury Scale (AIS) is a coding system created by the Association for the Advancement of Automotive Medicine. It is used to classify and describe  the severity of injuries, representing the threat to life associated with an injury, not a comprehensive assesement of injury severity. The AIS scale is listed in the table below. 

| AIS-Code | Injury Level | AIS % Prob. of Death |
|----------|--------------|----------------------|
| 1        | Minor        | 0                    |
| 2        | Moderate     | 1 - 2                |
| 3        | Serious      | 8 - 10               |
| 4        | Severe       | 5 - 50               |
| 5        | Critical     | 5 - 50               |
| 6        | Maximum      | 100                  |
| 9        | Not specified| N/A                  |


In an automobile accident, occupants may have several injuries. Therefore, the maximum AIS (MAIS) is recorded as the injury severity for an occupant in our data. For example, if an occupant has a superficial laceration of the thigh (AIS level 1) and a fractured sternum (AIS level 2), the MAIS is 2. Additionally, the MAIS  variable in the NASS/CDS data is coded as "7" where AIS would be "9". A common proxy for severe injuries in the literature is "MAIS 3+", a binary indicator for whether an occupant's MAIS injury is in the range 3 - 6. 

## Variables
* id - a unique ID for each observation. This is generated for the class and does
       not correspond to any NASS/CDS characteristic
* mais - maximum Abbreviated Injury Scale Level, severity of injury. mais >= 3 is severe
* mais3pl - binary indicator for severe injury. mais >= 3 is considered severe.
* crash_mode - crash mode. Frontal, Rear, far side (FS), near side (NS), roll, unknown
               FS and NS depend on occupant seating. For example, a crash to the passenger
               side is considered FS for occupants on the drivers side and NS for occupants 
               on the passenger side.
* delta_v - measure of severity of a traffic collision, defined as the change
            in velocity between pre-collision and post-collision trajectories of 
            a vehicle.
* max_ext_crush - maximum exterior crush for the first impact area in inches
* intrusion_depth - maximum depth of intrusion near a given occupant defined by occno
* age - age of the occupant
* height - height of the occupant
* weight - weight of the occupant
* bmi - body mass index of the occupant. A scaled ratio of weight to height.
* seatrack - track position of the occupant's seat.
* multi - flag for multiple vehicle collison. 0 - No, 1 - Yes
* pri_dir_force - Principal direction of force in the accident
* damage_width - width of damage
* damage_direction - offset of damage from the center lines of the vehicle
* curbwgt_kg - weight of the vehicle in kilograms