## Function to create percent cover of macroalgae, turf algae, CCA and other inverts

# Purpose:
# create csv files with percent cover by site at the species and group levels


## Tag: data analysis


# outputs created in this file --------------
# Domain estimates
# unwh_cover_strata
# percent_cover_site
# percent_cover_species
# cover_group_key
# Domain_check


# CallS:
# analysis ready data

# output gets called by:
# Analysis Rmarkdown, etc.
#

# NCRMP Caribbean Benthic analytics team: Groves, Viehman
# Last update: Mar 2020


##############################################################################################################################

#' Creates percent cover dataframe
#'
#'
#'
#'
#' @param region A string indicating the region
#' @return A dataframe
#' @importFrom magrittr "%>%"
#' @export
#'
#'


NCRMP_calculate_cover <- function(region){

  # Load analysis ready (AR) data
  # Florida

  if(region == "SEFCRI"){

      dat1 <- SEFCRI_2014_2stage_benthic_cover

      dat2 <- SEFCRI_2016_benthic_cover

      dat3 <- SEFCRI_2018_benthic_cover

      dat <- dplyr::bind_rows(dat1, dat2, dat3) %>%
        dplyr::mutate(ANALYSIS_STRATUM = paste(STRAT, "/ PROT =", PROT, sep = " "))

  }

  if(region == "FLK"){

    dat1 <- FLK_2014_2stage_benthic_cover %>%
      dplyr::mutate(YEAR = 2014)

    dat2 <- FLK_2016_benthic_cover

    dat3 <- FLK_2018_benthic_cover

    dat <- dplyr::bind_rows(dat1, dat2, dat3) %>%
      dplyr::mutate(ANALYSIS_STRATUM = paste(STRAT, "/ PROT =", PROT, sep = " "))

  }

  if(region == "Tortugas"){

    dat1 <- TortugasMarq_2014_benthic_cover

    dat2 <- TortugasMarq_2016_benthic_cover

    dat3 <- Tortugas_2018_benthic_cover

    dat <- dplyr::bind_rows(dat1, dat2, dat3) %>%
      dplyr::filter(SUB_REGION_NAME != "Marquesas",
                    SUB_REGION_NAME != "Marquesas-Tortugas Trans") %>%
      dplyr::mutate(ANALYSIS_STRATUM = paste(STRAT, "/ PROT =", PROT, sep = " "))

  }

  # GOM / Carib

  if(region == "STTSTJ"){


      dat1 <- USVI_2013_benthic_cover %>%
        dplyr::filter(REGION == "STTSTJ")

      dat2 <- USVI_2015_benthic_cover %>%
        dplyr::filter(REGION == "STTSTJ")

      dat3 <- USVI_2017_benthic_cover %>%
        dplyr::filter(REGION == "STTSTJ")

      dat4 <- USVI_2019_benthic_cover %>%
        dplyr::filter(REGION == "STTSTJ")

      dat <- dplyr::bind_rows(dat1, dat2, dat3, dat4) %>%
          dplyr::mutate(ANALYSIS_STRATUM = STRAT)

    }

  if(region == "STX"){


      dat2 <- USVI_2015_benthic_cover %>%
        dplyr::filter(REGION == "STX")

      dat3 <- USVI_2017_benthic_cover %>%
        dplyr::filter(REGION == "STX")

      dat4 <- USVI_2019_benthic_cover %>%
        dplyr::filter(REGION == "STX")

      dat <- dplyr::bind_rows(dat2, dat3, dat4) %>%
          dplyr::mutate(ANALYSIS_STRATUM = STRAT)

  }

  if(region == "PRICO"){

      dat1 <- PRICO_2014_benthic_cover

      dat2 <- PRICO_2016_benthic_cover %>%
        dplyr::mutate(YEAR = 2016)

      dat3 <- PRICO_2019_benthic_cover

      dat <- dplyr::bind_rows(dat1, dat2, dat3) %>%
          dplyr::mutate(ANALYSIS_STRATUM = STRAT)

  }

  if(region == "GOM"){

    if(year == 2013){

      dat <- FGBNMS_2013_benthic_cover %>%
        dplyr::mutate(ANALYSIS_STRATUM = "FGBNMS")

    }

    if(year == 2015) {

      dat <- FGBNMS_2015_benthic_cover %>%
        dplyr::mutate(ANALYSIS_STRATUM = "FGBNMS")

    }

    if(year == 2018) {

      dat <- FGBNMS_2018_benthic_cover  %>%
        dplyr::mutate(ANALYSIS_STRATUM = "FGBNMS")

    }
  }


  # Load species list

  # simplify species_name for MAC FLES and MAC CALC (as were not used in NCRMP) more detailed species collected in scream survey
  ncrmp_frrp_sppcodes2 <- ncrmp_frrp_sppcodes %>%
    dplyr::select(fl_ncrmp_code, species_name, cover_group) %>%
    # remove duplicate codes
    dplyr::distinct(fl_ncrmp_code, species_name, cover_group) %>%
    dplyr::mutate(species_name = as.character(species_name)) %>%
    dplyr::mutate(cover_group = as.character(cover_group)) %>%
    dplyr::mutate(cover_group = dplyr::case_when(species_name == "Ramicrusta spp" ~ "RAMICRUSTA SPP.",
                                                 species_name == "Peysonnellia" ~ "PEYSONNELLIA",
                                                 species_name == "Turf Algae Free of Sediment" ~ "TURF ALGAE",
                                                 species_name == "Turf Algae with Sediment" ~ "TURF ALGAE",
                                                 cover_group == "ALGAE" ~ "MACROALGAE",
                                                 TRUE ~ cover_group))


  cover_group_key <-  ncrmp_frrp_sppcodes2


  # Calculate percent cover of species by site

  if(region == "SEFCRI" ||
     region == "FLK" ||
     region == "Tortugas") {

    percent_cover_species <- dat %>%
      dplyr::mutate(Percent_Cvr = rowSums(.[28:30])) %>%
      dplyr::inner_join(.,ncrmp_frrp_sppcodes2,  by = c( "COVER_CAT_CD" = "fl_ncrmp_code")) %>%
      dplyr::select(-HARDBOTTOM_P, -SOFTBOTTOM_P, -RUBBLE_P) %>%
      dplyr::mutate(PROT = as.factor(PROT)) %>%
      dplyr::ungroup() %>%
      dplyr::group_by(REGION, YEAR, MONTH, DAY, SUB_REGION_NAME, ADMIN, PRIMARY_SAMPLE_UNIT, LAT_DEGREES, LON_DEGREES,
                      ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, COVER_CAT_CD, COVER_CAT_NAME, cover_group) %>%
      dplyr::summarise(Percent_Cvr_site = mean(Percent_Cvr),
                       MIN_DEPTH = mean(MIN_DEPTH),
                       MAX_DEPTH = mean(MAX_DEPTH)) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(Percent_Cvr = Percent_Cvr_site) %>%
      dplyr::select(REGION, YEAR, MONTH, DAY, SUB_REGION_NAME, ADMIN, PRIMARY_SAMPLE_UNIT, LAT_DEGREES, LON_DEGREES,
                    ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, MIN_DEPTH, MAX_DEPTH, COVER_CAT_CD, COVER_CAT_NAME, cover_group, Percent_Cvr)

  } else {

    percent_cover_species <- dat %>%
      dplyr::mutate(Percent_Cvr = rowSums(.[28:30])) %>%
      dplyr::inner_join(.,ncrmp_frrp_sppcodes2,  by = c( "COVER_CAT_CD" = "fl_ncrmp_code")) %>%
      dplyr::select(-HARDBOTTOM_P, -SOFTBOTTOM_P, -RUBBLE_P) %>%
      dplyr::mutate(PROT = as.factor(PROT)) %>%
      dplyr::select(REGION, YEAR, MONTH, DAY, SUB_REGION_NAME, ADMIN, PRIMARY_SAMPLE_UNIT, LAT_DEGREES, LON_DEGREES,
                    ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, MIN_DEPTH, MAX_DEPTH, COVER_CAT_CD, COVER_CAT_NAME, cover_group, Percent_Cvr)

  }

  # Calculate percent cover of major biological categories by site

  dat1 <-  dat %>%
    dplyr::mutate(Percent_Cvr = rowSums(.[28:30])) %>%
    dplyr::inner_join(.,ncrmp_frrp_sppcodes2,  by = c( "COVER_CAT_CD" = "fl_ncrmp_code")) %>%
    dplyr::select(-HARDBOTTOM_P, -SOFTBOTTOM_P, -RUBBLE_P) %>%
    dplyr::mutate(PROT = as.factor(PROT)) %>%
    dplyr::group_by(YEAR, REGION, SUB_REGION_NAME, PRIMARY_SAMPLE_UNIT, STATION_NR, LAT_DEGREES, LON_DEGREES,
                    MIN_DEPTH, MAX_DEPTH, ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, cover_group) %>%
    dplyr::summarise(Percent_Cvr = sum(Percent_Cvr)) %>%
    dplyr::ungroup()


  # Calculate percent cover at the STRATA level

  ### Reclassify all other categories to other or macroalgae

  dat2 <- dat1 %>%
    dplyr::mutate(cover_group = dplyr::case_when(cover_group == "SUBSTRATE" ~ "OTHER",
                                                 cover_group == "HYDROCORALS" ~ "OTHER",
                                                 cover_group == "OTHER INVERTEBRATES" ~ "OTHER",
                                                 cover_group == "CYANOBACTERIA" ~ "OTHER",
                                                 cover_group == "SEAGRASSES" ~ "OTHER",
                                                 cover_group == "PEYSONNELLIA" ~ "MACROALGAE",
                                                 cover_group == "OTHER" ~ "OTHER",
                                                 TRUE ~ cover_group))


  ### Account for SEFCRI/FLK 2014 & Tortugas 2018 2 transect data - take the transect means

  if(region == "SEFCRI" ||
     region == "FLK" ||
     region == "Tortugas") {

    dat2 <- dat2 %>%
      dplyr::group_by(YEAR, REGION, SUB_REGION_NAME, PRIMARY_SAMPLE_UNIT, LAT_DEGREES, LON_DEGREES,
                      ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, cover_group) %>%
      dplyr::summarise(Percent_Cvr = mean(Percent_Cvr),
                       MIN_DEPTH = mean(MIN_DEPTH),
                       MAX_DEPTH = mean(MAX_DEPTH)) %>%
      dplyr::ungroup()


  } else{

    dat2 <- dat2 %>%
      dplyr::group_by(YEAR, REGION, SUB_REGION_NAME, PRIMARY_SAMPLE_UNIT, LAT_DEGREES, LON_DEGREES,
                      MIN_DEPTH, MAX_DEPTH, ANALYSIS_STRATUM, STRAT, HABITAT_CD, PROT, cover_group) %>%
      dplyr::summarise(Percent_Cvr = sum(Percent_Cvr)) %>%
      dplyr::ungroup()
  }


  # Loop in cover groups that are missing from certain strat
  groupsOfInterest <- c("CCA", "HARD CORALS", "MACROALGAE", "OTHER", "SOFT CORALS", "SPONGES", "TURF ALGAE",
                        "RAMICRUSTA SPP.")

  # make unique sites df
  allsites <- unique(dat2[, c("YEAR", "REGION", "SUB_REGION_NAME", "PRIMARY_SAMPLE_UNIT","MIN_DEPTH","MAX_DEPTH",
                              "LAT_DEGREES", "LON_DEGREES", "ANALYSIS_STRATUM", "STRAT", "HABITAT_CD", "PROT")])

  # create empty dataframe with same column names as the demo data frame
  PA <-   dat2[FALSE, ]

  # use loop to add in missing cover groups within strata
  for (i in groupsOfInterest)
  {
    # select out rows where cover_group is within groupsOfInterest object
    presence <-   dat2[ dat2[, 'cover_group'] == i,]
    # merge and keep all sites. If no data, rows should be full of NAs
    pres_abs <- dplyr::full_join(allsites, presence)
    #add cover group name to NA rows
    pres_abs$cover_group <- i
    #add each new cover group to the previous one
    PA <- rbind(PA, pres_abs)
    PA <- dplyr::mutate(PA, Percent_Cvr = tidyr::replace_na(Percent_Cvr, 0))
  }

  dat2 <- PA %>%
    dplyr::mutate(n = dplyr::case_when(Percent_Cvr > 0 ~ 1, TRUE ~ 0)) %>%
    dplyr::ungroup()

  percent_cover_site <- dat2

  # site level totals are ~100% (may not be exact for 2 transect data where means are taken)
  cover_check_site <- percent_cover_site %>%
    dplyr::group_by(REGION, YEAR, PRIMARY_SAMPLE_UNIT, STRAT) %>%
    dplyr::summarise(Cover = sum(Percent_Cvr))

  # Add NTOT, # Cells sampled and calculate sampling weights in weighting function


  tmp  <- NCRMP_make_weighted_LPI_data(inputdata = dat2, region)


  # unpack list
  for(k in 1:length(tmp))assign(names(tmp)[k], tmp[[k]])


  # Check your Domain totals - they should equal about 100
  # If this number is not very close to 100, there is likely something wrong with your ntot. Any strata that was
  # not sampled that year needs to be removed from the ntot BEFORE ngrot is calculated. Slight variations from 100
  # could be due to using the most recent NTOT file for past years - this is OK.

  Domain_check <- Domain_est %>%
    dplyr::group_by(REGION, YEAR) %>%
    dplyr::summarise(Whole_pie = sum(avCvr))



  ################
  # Export
  ################

  # Create list to export
  output <- list(
    "percent_cover_species" = percent_cover_species,
    "percent_cover_site" = percent_cover_site,
    "cover_check_site" = cover_check_site,
    "cover_group_key" = cover_group_key,
    "cover_strata" = cover_strata,
    "Domain_est" = Domain_est,
    "Domain_check" = Domain_check
  )

  return(output)
}
