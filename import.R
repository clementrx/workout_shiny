import_fichier <- function(path){

  df <- read_excel(path, 1)

  if(is.character(df$serie) == T){
    df$serie<- as.numeric(df$serie)
  }

  if(is.character(df$reps) == T){
    df$reps<- as.numeric(df$reps)
  }

  if(is.character(df$`charge (kg)`) == T){
    df$`charge (kg)` <- as.numeric(df$`charge (kg)`)
  }

  df <- df %>%
    rename(poids = `charge (kg)`) %>%
    mutate(poids = ifelse(is.na(poids),
                          1,
                          poids)) %>%
    na.omit() %>%
    mutate(date = as.Date(date),
           serie = as.integer(serie),
           reps = as.integer(reps),
           poids = as.numeric(poids))

  return(df)

}





# test <- import_fichier('/Users/clementrieux/Documents/workout_analysis/test')
