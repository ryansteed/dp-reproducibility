REPLICATION PACKAGE FOR "Down the River: Glyphosate Use in Agriculture and Birth Outcomes of Surrounding Populations"

AUTHORS: Mateus Dias, Rudi Rocha, and Rodrigo R. Soares


____________________________________________________________________________________________________________________________________________________________________________________________________________________________________
DATA CITATIONS AND DATA AVAILABILITY STATEMENT

All the data used - with one exception - is open and accessible online. Since we use many different sources, we indicate
how to access each source. The only exception is data from the National Producer Union for Plant Defense (SINDIVEG) regarding 
herbicide sales, used in our paper for some robustness checks. We obtained these data by email from the then Data Manager,
Ivan Amancio Sampaio, contacted at ivan@sindiveg.org.br.

In what follows, we cite each information source and indicate how to access them. A dataset list is also provided separately 
as an xlsx file.

*Bustos, P., Caprettini, B., Ponticelli, J. Agricultural Productivity and Structural Transformation. Evidence from Brazil.
American Economic Review, 106 (6), 2016, 1320-1365. Data available online at https://www.aeaweb.org/articles?id=10.1257/aer.20131061

*da Silva, A., Alvares, C., and Watanabe, C. (2011). Natural Potential for Erosion for Brazilian Territory.
In Godone, D., editor, Soil Erosion Studies, chapter 1, pages 3–24. InTech. [Available at https://www.intechopen.com/chapters/23108]

*INSTITUTO DE PESQUISA ECONÔMICA APLICADA – Ipeadata. Dados regionais. Available at http://www.ipeadata.gov.br. Accessed in December 6th 2022.

*IBGE – INSTITUTO BRASILEIRO DE GEOGRAFIA E ESTATÍSTICA . Censo Brasileiro de 2000. Rio de Janeiro: IBGE, 2002.

*IBGE – INSTITUTO BRASILEIRO DE GEOGRAFIA E ESTATÍSTICA . Produção agrícola municipal : culturas temporárias e permanentes. 
Rio de Janeiro: IBGE. Accessed in December 6th 2022. Available at https://www.ibge.gov.br/estatisticas/economicas/agricultura-e-pecuaria/9117-producao-agricola-municipal-culturas-temporarias-e-permanentes.html?=&t=destaques

*Brasil, Ministério da Saúde. Database of Sistema Único de Saúde-DATASUS. Available at http://www.datasus.gov.br. 
Accessed in December 6th 2022.

*Agência Nacional de Águas (Brasil) - ANA. Inventário das estações fluviométricas. 2 ed. - Brasília: ANA; SGH, 2009.

*Agência Nacional de Águas (Brasil) - ANA. Dados Abertos da Agência Nacional de Águas e Saneamento Básico. Available at
https://dadosabertos.ana.gov.br/. Accessed in December 6th 2022.

*MapBiomas Project - LAND COVER AND TRANSITIONS BY MUNICIPALITY (COLLECTION 3). Available at  https://mapbiomas.org/en/statistics.
Accessed in October 19th 2018.

*Willmott & Matsuura University of Delaware's Global (Land) Precipitation and Temperature database. Available at https://climatedataguide.ucar.edu/climate-data/global-land-precipitation-and-temperature-willmott-matsuura-university-delaware

*IBAMA - Instituto Brasileiro do Meio Ambiente e dos Recursos. Dados Abertos (Open Data). Available at https://dadosabertos.ibama.gov.br/.

_________________

DATA LIST
__________________

DATA FILE (Data\Originais)                                    SOURCE                                NOTES                PROVIDED
Files in 'Bustos et al' folder                          Bustos et al (2016)                                                Yes

Files in 'Captação ANA' folder                 Brazilian National Waters Agency (ANA)                                      Yes

Files in 'Ipeadata originais censo 2000'      Brazilian Census Bureau (IBGE), accessed                                     Yes
      folder                                             through IPEADATA

Files in 'PNE' folder                                 da Silva et al (2011)                                                Yes

Files in 'Shapefiles' folder                                   ANA                                                         Yes

amcs_br.dta                                                 IPEADATA                                                       Yes

amcs_subbasins.dta                                        IPEADATA & ANA	                Merge using data             Yes
                                                                                            from the two sources

area_mun_Ibge_2010.dta &                             Brazilian Census Bureau (IBGE)                                        Yes
area_mun_Ibge_2010_adjusted.dta

area_temp_1996_2010.xlsx                             Brazilian Census Bureau (IBGE)                                        Yes

climate_ufmundv.dta                          Global (land) precipitation and temperature:                                  Yes
                                              Willmott & Matsuura, University of Delaware

controles.dta                                            Bustos et al (2016)	              Share of Agricultural          Yes
                                                                                                  GDP Data

corn_area_1996_2010.xlsx                                       IBGE                                                        Yes

gdp_mun.dta                                                    IBGE                                                        Yes

glyphosate_herb_per_state_2009.dta	                           IBAMA                                                       Yes

herb_tons_ai_culture.dta                      Sindicato Nacional da Indústria de 	      Data obtained by email 	         Yes
                                                Produtos para Defesa Vegetal (SINDIVEG)   from the union, not 
                                                                                          available in their website; 
                                                                                          only used in robustness checks.

herb_tons_ai_uf.dta                                          SINDIVEG	                  Data obtained by email           Yes
                                                                                          from the union, not 
                                                                                          available in their website; 
                                                                                          only used in robustness checks.

hospital_beds.dta                                     Ministry of Health's DataSUS                                         Yes

immunization_coverage.dta                             Ministry of Health's DataSUS                                         Yes

intersections.csv                                              ANA & IBGE	           AMCs & basins intersections       Yes
                                                                                         from shapefiles, calculations 
                                                                                         done using QGIS 2.12 & 
                                                                                         EPSG29195 projection.

Mapbiomas_v3.xlsx                                         MapBiomas Project                                                Yes

pbf.dta                                                       IPEADATA                                                     Yes

pop_br_91to12.dta                                               IBGE                                                       Yes

pop_per_age.dta                                                 IBGE                                                       Yes

pop0to1.dta                                                     IBGE                                                       Yes

POPBRFEM_1049_9610.dta                                          IBGE                                                       Yes

potential_maize_amc.dta                                     GAEZ Database                                                  Yes

potential_soy_amc.dta                                       GAEZ Database                                                  Yes

psf.dta                                                        DataSUS                                                     Yes

soy_area_1996_2010.xlsx                                         IBGE                                                       Yes

water_quality_1.dta &                                            ANA                                                       Yes
water_quality_2.dta &
water_quality_3.dta

SIM_micro.dta                                                  DataSUS	              Open microdata not provided due      No
                                                                                      to size; we provide the cleaned 
                                                                                      data.

SINASC_micro                                                  DataSUS	              Open microdata not provided due      No
                                                                                      to size; we provide the cleaned 
                                                                                      data.

Censo00_'state'_pes_comp.dta                                    IBGE	              Open microdata not provided due      No
                                                                                      to size; we provide the cleaned 
                                                                                      data.

Censo10_'state'_pes_comp.dta                                    IBGE	              Open microdata not provided due      No
                                                                                      to size; we provide the cleaned 
                                                                                      data.

____________________________________________________________________________________________________________________________________________________________________________________________________________________________________


___________________________

Computational Requirements
___________________________

Hardware Specifications: 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz   1.69 GHz processor with 16.0 GB RAM

All codes were run on Stata 14 MP (version is important due to memory requirements).
Necessary Stata Packages: outreg2, ivreg2, xtivreg2

Runtime:
   1. Data cleaning: ~22h (excluding the Census and DATASUS microdata cleaning procedures, since we provide these data after cleaning procedure)
   2. Results: ~9min


_______________

Description
_______________

We provide the raw data we used, the codes to clean them and generate the final datasets, and the codes that
generate the figures and tables of the paper. We used Stata 14 MP for the analysis; the codes may not run on 
versions other than MP due to memory requirements. (Some of our datasets are quite large!)

The Codes folder has two subfolders. The first is "build_agro_codes", with all the codes needed to construct
our datasets from the raw data, which can be found on Data/Originais. To run these codes, it is only necessary to run
build_master.do adjusting the paths in this do-file.

Given the size of the datasets, we are not providing the 2000 & 2010 Census microdata nor the Ministry of Health's DataSUS
microdata. They are publicly available on the Brazilian Census Bureau's website and on the DataSUS website. We provide
the cleaned datasets, which can be found on Data\Workfiles. Thus, to run our data cleaning and data construction codes,
it is necessary to comment the lines that call these do-files in the build master do-file. 

[If desired, the format for the microdata is (i) in the case of the DataSUS data, it is necessary to have one file for 
mortality microdata called SIM_micro.dta and one file for birth microdata called SINASC_micro.dta and specify the (unique) 
path of these two datasets in the master do-file; and (ii) in the case of the Census, we need the dtas per state as
generated by the Data Zoom package available at http://www.econ.puc-rio.br/datazoom/english/index.html. It is also needed
to specify the path of the data in the main build do-file.]

The second subfolder within "Codes" is called "results", which contains all the codes to generate the tables and figures
of the paper. It is only necessary to run results_master.do adjusting the paths within the do-file.

Below, we describe in more detail what can be found in (i) Data, (ii) Codes/build, and (iii) Codes/results and what has to
be adjusted to run the do-files.

_______

Data
_______

The data folder contains two subfolders. One is 'Originais', with the raw data we use,
and another called 'Workfiles', which contains the final datasets.

Importantly, we do not include here the 2000 Census microdata nor the mortality and birth
microdata from the Ministry of Health's DataSUS due to their sizes. They are, however,
publicly available and are easily downloaded from these public entities' websites.

WORKFILES:
- data_final.dta: main dataset used for all but the spillover results.
- data_spillovers_censo.dta: dataset for the spillover results.

RAW DATA ('ORIGINAIS' FOLDER):
-> Folders
  - Bustos et al: Data from Bustos et al that we use for spillover results
  - Captação ANA: Data from ANA (National Waters Agency) regarding water sources for every municipality
  - Ipeadata originais censo 2000: Aggregated data from the 2000 Census (obtained through IPEADATA's website)
  - PNE: Soil characteristics data
  - Shapefiles: Shapefiles used in the analysis

-> xlsx & dta
  - amcs_br.dta: crosswalk between municipalities and minimum comparable areas (AMCs)
  - amcs_subbasins.dta: relationship between AMCs and level 4 ottobasins; typically AMCs cover more than one of these basins and we assign for each AMC the ottobasins that covers the largest share of the AMC's area.
  - area_mun_Ibge_2010.dta & area_mun_Ibge_2010_adjusted.dta: Municipalities' areas according to the Brazilian Census Bureau. The only difference in the adjusted file
  is that it includes a 6-digit ID variable derived from the already present 7-digit ID to make merging easier. The last digit of the 7-digit ID is
  irrelevant to identify municipalities, so we obtain the 6-digit ID simply by dropping the last digit.
  - area_temp_1996_2010.xlsx: Data on the planted area of all temporary crops by municipality.
  - climate_ufmundv.dta: rainfall data.
  - controles.dta: Share of agriculture participation in GDP per municipality (from Bustos et al.)
  - corn_area_1996_2010.xlsx: Data on corn planted area by municipality.
  - gdp_mun.dta: Municipal GDP data.
  - glyphosate_herb_per_state_2009.dta: 2009 glyphosate sales per state.
  - herb_tons_ai_culture.dta: Total herbicide sales associated with soy.
  - herb_tons_ai_uf.dta: Total herbicide sales associated with soy per state.
  - hospital_beds.dta: Data on hospital beds.
  - immunization_coverage.dta: Vaccination coverage data per municipality.
  - intersections.csv: Dataset with the intersections between AMCs and level 4 ottobasins and their respective areas. Areas were calculated
  using QGIS 2.12 and the epsg29195 projection (with the projection on the new system of coordinates done on the fly). 
  - Mapbiomas_v3.xlsx: Data from the MapBiomas project (version 3) regarding land use per municipality.
  - pbf.dta: Data on the existence or not of the Bolsa Familia program (main conditional cash transfer program).
  - pop_br_91to12.dta: Data on population per municipality.
  - pop_per_age.dta: Data on population per municipality and per age.
  - pop0to1.dta: Data on population between 0 and 1 years old per municipality.
  - POPBRFEM_1049_9610.dta: Data on women population (10-49 years old) per municipality.
  - potential_maize_amc.dta: Data on potential yield for maize/corn per AMC.
  - potential_soy_amc.dta: Data on soy potential yield per AMC.
  - psf.dta: Data on the existence of the Family Health program per municipality.
  - soy_area_1996_2010.xlsx: Data on soy planted area per municipality.
  - water_quality_1.dta, water_quality_2.dta, water_quality_3.dta: Data on water quality per municipality, each with a different rule for
  assignment of testing centers to municipalities according to the paper's main text.


______________________

Codes/build_agro_codes
______________________

The master do-file within this folder generates the final dataset of the paper used to generate all the
results. It also generates an auxiliary dataset used to generate the spillover results.

Before running the do-file, some paths have to be adjusted in build_master.do:

1. pathfiles_data: substitute this path for the path of the data folder.
   ** The final and intermediate datasets are saved in a folder called Workfiles
      within this path.

2. pathfiles_do: substitute the path in the file for the path where the do files
                 used for cleaning the data and constructing the datasets are
		     located.

3. pathfiles_censusdata: substitute this path for the path of the Census microdata (the DTAs).

-- Obs: We ignore some locations that were created and extinguished before 1996
   or after 2010. We also ignore one small municipality called Pinto Bandeira, 
   which only existed for two years as a separate municipality and does not affect
   our analysis.

The master do-file uses several do-files to clean data from different sources,
which are then combined into the final dataset. The auxiliary do-files we use
are described below:

- build_panel.do: this basic file constructs the basic panel structure for every
intermediate dataset. It is used by all the other auxiliary do-files below.

The auxiliary do-files below generate intermediate datasets. All of them are
generated using the same panel structure from build_panel.do to make the
merging process easier.

- data_census.do, data_censo2000.do: These do-files clean the 2000 & 2010 Census
microdata. The datasets generated are data_census.dta & data_censo2000.dta, respectively.
   * Source: IBGE (Brazilian Census Bureau)
   * Generate data_census.dta & 

- data_glyph_pot_subbasins.do: Generates the dataset data_glyph_pot_subbasins.dta, with
data regarding potentials & glyphosate (in municipality, upstream, and downstream).
   * Sources: IBGE, GAEZ Database, IBAMA (Brazilian Environmental Agency), & ANA (Brazilian National Waters Agency)
   * Generates data_glyph_pot_subbasins.dta

- data_potential_distance.do & data_glyph_distance.do: Generate glyphosate and potential
data per distance.
   * Same sources as previous do-file. 
   * Needs data_glyph_pot_subbasins.dta & we have to define which glyphosate measure we are using inside the do file.
   * Generate data_potential_distance.dta & data_glyph_distance.dta

- data_water_quality.do: Creates dataset with water quality measures.
   * Source: National Waters Agency (ANA).
   * Generates data_water_quality.dta

- data_soil_coverage_mapbiomas_v3.do: Generates dataset with land use data.
   * Source: Mapbiomas, v3
   * Generates data_soil_coverage_mapbiomas_v3.dta

- data_rain_subbasins.do: Generates dataset with information about rain (heterogeneity results).
   * Source: Willmott & Matsuura University of Delaware's Global (Land) Precipitation and Temperature database.
   * Generates data_rain_subbasins.dta

- data_soil_subbasins.do: Generates dataset with information about soil characteristics (heterogeneity results).
   * Source: da Silva, A., Alvares, C., and Watanabe, C. (2011). Natural Potential for Erosion for Brazilian Territory.
             In Godone, D., editor, Soil Erosion Studies, chapter 1, pages 3–24. InTech.
   * Generates data_soil_subbasins.dta

- data_watersources.do: Generates dataset with information about the source of water
in each municipality (heterogeneity results).
   * Source: National Waters Agency (ANA).
   * Generates data_watersources.dta

- SIM_build_all.do: Mortality data.
   * Source: DataSUS (Ministry of Health)
   * Generates SIM_year.dta

- SINASC_build.do: Birth outcomes data.
   * Source: DataSUS (Ministry of Health) 
   * Generates SINASC_year.dta

- SIM_build_bymonth.do: Mortality data per month (exposure results).
   * Source: DataSUS (Ministry of Health)
   * Generates SIM_yearmonth.dta

- SINASC_build_bymonth.do: Births per month (exposure results).
   * Source: DataSUS (Ministry of Health) 
   * Generates SINASC_yearmonth_onlybirths.dta

- data_spillovers_censo.do: Generate Census spillovers data -> This is used as
a separate dataset and is not merged with the rest.
   * Source: IBGE
   * Generates


Finally, data_merge.do merges all the data generated above (except for spillovers),
creates data_final.dta, and erases the (intermediate) datasets that were created before.
   * When merging the data, we also include some data that we already have in dta format 
   and did not need to clean prior to the merging. These data contain information on total 
   population per municipality, population per age in each municipality, women (10-49 years old) 
   population per municipality, and 0-1 year old population in each municipality (from IBGE). 
   We also merge in the same way the data about vaccination coverage, presence of Family Health 
   Program, and hospital beds (all three from the Ministry of Health's DataSUS), data about the main
   cash transfer program, Bolsa Familia, Municipal GDP, and Municipal Farming GDP (from IBGE).

_____________

Codes/results
_____________

The master do-file, results_master.do, generates all the tables and figures with results and 
descriptives for the paper (except maps and Table E.8, which describes the glyphosate 
application season). Before running the do-file, some paths have to be adjusted in 
results_master.do:

1. pathdataorig: substitute this path for the path where the original data is located.
2. pathdata: substitute the path in the file for the path where the final datasets are
             located.
3. pathresults: choose the path where you want the tables (in .xls files) and figures
                o be saved.
4. path_tables: substitute the path here for the path where the tables' do-files
                are located.
5. path_figures: substitute the path here for the path where the figures' do-files
                are located.


With the exception of the descriptives and the spillover results, all tables and 
figures require some final adjustments and global definitions done through _preamble.do.
The results generated by each do-file are:

Main text:
1. table1_descriptive_stats: descriptive statistics
2. table2_main_results: OLS, reduced form, and IV results on infant mortality rates
3. table3_first_stage: first stage for the IV
4. table4_other_outcomes: reduced form and IV results for birth outcomes other than IMR
5. table5_trends_birth_rate: results on IMR and birth rates controlling for birth rate
                             & socioeconomic trends
6. table6_placebo_downstream: placebo results using potential downstream instead of upstream
7. table7_heterogeneity: heterogeneous effects on IMR by rainfall, soil characteristics, and
                         water source
8. table8_exposure: results on IMR for high exposure months vs low exposure months
9. table9_land_use: results on land use

Appendix:
10. tableC1_sum_up_down: results on IMR controlling for sum of potential upstream and downstream
11. tableC2_sum_up_down_other: results for other birth outcomes with the same specification as the previous one
12. tableE1_glyph_alt_measures: results on IMR with full set of controls for alternative glyphosate measures
13. tableE2_IMR_wo_area_upstream: results on IMR excluding municipalities w/o area upstream
14. tableE3_placebo_downstream: placebo results for other outcomes using potential downstream
15. tableE4_interaction_area: results on IMR with effect heterogeneity by area upstream
16. tableE5_distance: results on IMR by distance
17. tableE6_spillovers: spillover results based on Bustos et al. (2016) - separate dataset
18. tableE7_corn: first stage using corn planted area and corn potential
19. tableE9_water_quality: results on water quality measures and on IMR using the same restricted sample

Figures:
20. fig1_soy_glyph_br: descriptive figures showing soy productivity growth and glyphosate usage in Brazil
21. fig3_event_study_IMR: event-study for main IMR results
22. figD2_event_study_other_outcomes: event-studies for all other birth outcomes
23. figD3_event_study_exposure: event-studies for IMR on high exposure vs low exposure months