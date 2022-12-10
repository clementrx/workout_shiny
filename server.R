server = function(input, output){

  data <- reactive({
    # inFile <- input$file1
    #
    # if(is.null(inFile))
    #   return(NULL)
    # file.rename(inFile$datapath,
    #             paste(inFile$datapath, ".xlsx", sep=""))
    # read_excel(paste(inFile$datapath, ".xlsx", sep=""), 1)

    df <- read_excel(paste("test.xlsx", sep=""), 1)
    df <- df %>%
      rename(poids = `charge (kg)`)

  })

  output$contents <- renderReactable({
    tb <- data() %>%
      group_by(exercice) %>%
      summarise(min_poids = min(poids, na.rm = T),
                mean_poids = mean(poids, na.rm = T),
                max_poids = max(poids, na.rm = T),
                min_serie = min(serie, na.rm = T),
                mean_serie = mean(serie, na.rm = T),
                max_serie = max(serie, na.rm = T)) %>%
      reactable(
        theme = clean(),
        pagination = FALSE,
        columns = list(
          min_poids = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF2D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          mean_poids = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          max_poids = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          min_serie = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF2D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          mean_serie = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          max_serie = colDef(
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            ))


          )
      )

    tb

  })

  output$evol <- renderPlot({
    ggplot(data(),
           aes(x = date,
               y = poids,
               color = exercice)) +
      geom_point() +
      geom_line()
  })

  output$ex_box <- renderText({
    paste0(length(unique(data()$exercice)))
  })

    output$series_box <- renderText({
      paste0(sum(data()$serie))
  })

  output$poids_box <- renderText({
      paste0(sum(data()$poids), ' Kg')
  })


  output$table_max <- renderReactable({

    averages <- data() %>%
      group_by(exercice, reps) %>%
      summarise(max = max(poids, na.rm = T)) %>%
      ungroup() %>%
      mutate(max_estimated = round(max / (1.0279 - (0.0278*reps)),1)) %>%
      group_by(exercice) %>%
      summarise(max = max(max_estimated, na.rm = T)) %>%
      ungroup() %>%
      mutate('80%' = max*0.8,
             '70%' = max*0.7,
             '60%' = max*0.6,
             '50%' = max*0.5,
             '40%' = max*0.4,
             '30%' = max*0.3,
      )

    reactable(
      averages,
      theme = clean(centered = TRUE),
      columns = list(
        exercice = colDef(
          maxWidth = 200,
          style = color_scales(
            data = data,
            colors = viridis::mako(5)),
          format = colFormat(digits = 1)),
        max = colDef(maxWidth = 50)
      )
    )

  })


}

