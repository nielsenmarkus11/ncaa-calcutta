bracket <- get_tournament_scores()
team_names <- scrape.teams('mens')

library(dplyr)
teams1 <- bracket %>%
  dplyr::mutate(match_id = row_number()) %>% 
  dplyr::filter(round == 1) %>% 
  dplyr::select(match_id, rank = team1_seed, region, team1_id) %>% 
  left_join(team_names, by = c('team1_id'='id')) %>%
  dplyr::select(match_id, rank, region, team=name) %>% 
  dplyr::mutate(rank = as.numeric(as.character(rank)),
                region = stringi::stri_trans_totitle(region))

teams2 <- bracket %>%
  dplyr::mutate(match_id = row_number()) %>% 
  dplyr::filter(round == 1) %>% 
  dplyr::select(match_id, rank = team2_seed, region, team2_id, team3_id) %>% 
  left_join(team_names, by = c('team2_id'='id')) %>%
  left_join(team_names, by = c('team3_id'='id')) %>%
  dplyr::mutate(rank = as.numeric(as.character(rank)),
                region = stringi::stri_trans_totitle(region),
                name = paste0(name.x,ifelse(is.na(name.y),"",paste0('/',name.y)))) %>%
  dplyr::select(match_id, rank, region, team=name)

# Find Opponent
t1opp <- teams2 %>% 
  dplyr::select(match_id, opponent = team)
teams1 <- teams1 %>% 
  left_join(t1opp, by='match_id')

t2opp <- teams1 %>% 
  dplyr::select(match_id, opponent = team)
teams2 <- teams2 %>% 
  left_join(t2opp, by='match_id')



teams <- bind_rows(teams1, teams2) %>% 
  arrange(region, rank)

teams$match_id <- NULL

start_auction(teams)

write.csv(teams,file="inst/extdata/ncaa-teams-2019.csv", row.names = FALSE)
