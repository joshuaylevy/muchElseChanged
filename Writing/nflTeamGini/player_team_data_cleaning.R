#DATA CLEANING

library(tidyverse)
library(reldist)
setwd("~/Personal/Much Else Changed/Writing/nflTeamGini")

## DROPPING ALL YEARS PRIOR TO 2020
full_csv <- read.csv("mismatch_export.csv") %>%
  filter(year <= 2020) %>%
  mutate(cash_paid = as.numeric(as.character(cash_paid))) %>%
  distinct()

#Recode Houston Oilers as Titans, Redskins as Washington, and drop blanks
full_csv$team <- as.factor(recode(full_csv$team, Oilers = "Titans", Redskins = "Washington"))
full_csv <- full_csv %>%
  filter(team != "")

# TEAM RECORD DATA
team_record <- read.csv('teamRecord.csv') %>%
  select(team, w, l, t, pct_total, pf, pa, year) %>%
  mutate(points_ratio = pf/pa)

# Adding superbowl data (1 is a superbowl win, 2 is a superbowl loss, NA is failure to arrive at the sb)
superbowls <- data.frame(year = c(1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020,
                                  1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020),
                        team = c("49ers", "Giants", "Washington", "Cowboys", "Cowboys", "49ers", "Cowboys", "Packers", "Broncos", "Broncos", "Rams", "Ravens", "Patriots", "Buccaneers", "Patriots", "Steelers", "Colts", "Giants", "Steelers", "Saints", "Packers", "Giants", "Ravens", "Seahawks", "Patriots", "Broncos", "Patriots", "Eagles", "Patriots", "Chiefs", "Buccaneers",
                                 "Bills", "Bills", "Bills", "Bills", "Chargers", "Steelers", "Patriots", "Packers", "Falcons", "Titans", "Giants", "Rams", "Raiders", "Panthers", "Eagles", "Seahawks", "Bears", "Patriots", "Cardinals", "Colts", "Steelers", "Patriots", "49ers", "Broncos", "Seahawks", "Panthers", "Falcons", "Patriots", "Rams", "49ers", "Chiefs" ),
                        wins = c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
                                 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2))


# FIGURE TYPE A: Probably going to have to drop prio to (2005?) because of data quality
gini_success <- full_csv %>%
  group_by(team, year) %>%
  summarise(gCoeff = gini(cash_paid),
            mean_cash = mean(cash_paid),
            median_cash = median(cash_paid),
            top_cash = max(cash_paid),
            bot_cash = min(cash_paid),
            players_recorded = n()) %>%
  ungroup() %>%
  inner_join(team_record, by = c("team", "year")) %>%
  left_join(superbowls, by = c("team", "year")) %>%
  rename("sb_wins_runups" = wins) %>%
  distinct()


write.csv(gini_success, file='TYPE_A_gini_success.csv', row.names=FALSE)



#FIGURE TYPE B:Probably going to have to drop years prior to (2005?) because of data quality
gini_over_time <- full_csv %>%
  group_by(team, year) %>%
  summarise(gCoeff = gini(cash_paid),
            mean_cash = mean(cash_paid),
            median_cash = median(cash_paid),
            top_cash = max(cash_paid),
            bot_cash = min(cash_paid),
            players_recorded = n())

write.csv(gini_over_time, file='TYPE_B_gini_over_time.csv', row.names=FALSE)




#FIGURE TYPE C: Histogram data (with team-year-level resolution)
cash_histograms <- full_csv %>%
  select(year, team, cash_paid, name, position)

write.csv(cash_histograms, file='TYPE_C_cash_histograms.csv', row.names=FALSE)


#FIGURE TYPE D: 
cash_lorenz_gini <- full_csv %>%
  select(year, team, cash_paid, name, position) %>%
  inner_join(gini_over_time, by = c("team", "year"))

write.csv(cash_lorenz_gini, file='TYPE_D_cash_lorenz_diagram.csv', row.names=FALSE)
  
 