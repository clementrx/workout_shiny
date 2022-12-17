import_fichier <- function(path){

  df <- read_excel(paste(path, ".xlsx", sep=""), 1)

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
    na.omit() %>%
    rename(poids = `charge (kg)`) %>%
    mutate(date = as.Date(date),
           serie = as.integer(serie),
           reps = as.integer(reps),
           poids = as.numeric(poids))

  return(df)

}

# test <- import_fichier('/Users/clementrieux/Documents/workout_analysis/test')
