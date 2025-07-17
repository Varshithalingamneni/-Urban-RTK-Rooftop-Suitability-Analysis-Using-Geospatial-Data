# Determining Rooftop Candidates for Hosting GPS Error Correction RTK Sites

As GPS technology becomes increasingly central to navigation, mapping, and autonomous systems, the demand for higher precision is growing and, in some cases, it can be a matter of life and death. Although standard GPS provides location accuracy within meters, this level of precision falls short for applications that demand pinpoint accuracy. To bridge this gap, several GPS error correction techniques are employed, such as Post-Processing, Differential GPS (DGPS), and Real-Time Kinematics (RTK). These methods require strategic enhancements to consistently achieve centimeter-level accuracy. This project focuses on improving the accuracy of the RTK method, which provides real-time correction signals to mobile receivers. The effectiveness of RTK systems depends on the placement of its base stations on rooftops with minimal signal obstruction and maximum sky visibility. To meet this requirement, in this project we evaluated the horizon profile of each building in an area using spatial data such as building footprints, elevation, and height. Additionally, for each building, we generated 360° horizon graphs to capture blocking angles, allowing us to visually and quantitatively assess potential interference. We also conducted geospatial analysis of 2,834 buildings in the GMU campus area to determine ideal rooftop candidates. Each rooftop was assessed against a strict interference threshold to ensure unobstructed sky visibility. The analysis incorporated atmospheric dome modeling to account for landscape curvature and elevation differences. As a result, we identified 49 optimal rooftops for RTK base station installation. These findings led to the development of a visibility ranking system that determines high-potential rooftop installation sites.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Dependencies](#dependencies)
3. [Data Preparation](#data-preparation)
4. [Methodology](#methodology)
5. [Results](#results)
6. [Usage Instructions](#usage-instructions)
7. [Team Members](#team-members)

---

## Project Overview

(See above for full project description)

## Dependencies

* **Hardware:** Minimum 4 GB RAM, Dual‑core Intel Core i5 or better
* **Software:**

  * [QGIS](https://qgis.org/download/)
  * [PostgreSQL](https://www.postgresql.org/download/)
  * [PGAdmin](https://www.pgadmin.org/) or [DBeaver](https://dbeaver.io/download/)
  * [OSGeo4W (Windows)](https://trac.osgeo.org/osgeo4w/)

## Data Preparation

1. **Import Building Footprints** into PostGIS using OSGeo4W:

   ```bash
   ogr2ogr -f "PostgreSQL" \
     PG:"host=<host> dbname=<db> user=postgres password=<pw>" \
     "<path/to/json>" -nln test_bldgs -a_srs EPSG:4326 -overwrite
   ```
2. **Compute Horizon Profiles**: Generate 360° radial lines (up to 30 km) per rooftop.
3. **Intersect & Measure**: Find intersections between horizon rays and taller buildings.

## Methodology

1. **Horizontal Profiling:**

   * Sample each rooftop’s skyline at 1° azimuth increments.
   * Compute blocking angles where adjacent buildings protrude above the horizon.
2. **Atmospheric Dome Modeling:**

   * Approximate the open-sky dome with 1° elevation slices.
   * Map blocked azimuth–elevation cells to dome facets to estimate sky obstruction.
3. **Candidate Scoring:**

   * Filter rooftops with no blocking angles above 10°.
   * Incorporate building elevation (absolute height) into selection.
   * Rank by unobstructed sky area and height suitability.

## Results

* **Total Buildings Analyzed:** 2,834
* **RTK‑Suitable Rooftops Identified:** 49
* **Deliverables:**

  * `eligible_candidates` table (PostGIS)
  * CSV exports and interactive 3D visualization scripts
  * Sky visibility ranking report

## Usage Instructions

1. Clone this repository:

   ```bash
   git clone https://github.com/<your-org>/rtk-rooftop-selection.git
   cd rtk-rooftop-selection
   ```
2. Load data into PostGIS.
3. Run SQL scripts in `Code` folder via PGAdmin or psql.
4. Generate plots and export CSVs using provided R scripts.
5. Visualize results in QGIS or via the interactive dashboards.
6. Visualize the 3D view of the angle based on individual buildings.

## Team Members

* Sabari Mukundth Jayaram
* Vyoma Harshitha Podapati
* Kirubel Tadesse
* Satya Sai Varun Chidagam
* Sai Sree Varshitha Lingamneni
* Sai Pranav Beesetti


