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
      rename(poids = `charge (kg)`) %>%
      mutate(date = as.Date(date),
             serie = as.integer(serie),
             reps = as.integer(reps),
             poids = as.numeric(poids))

    df

  })

  data_time <- reactive({

    data() %>%
      group_by(date) %>%
      summarise(exercices = n_distinct(exercice),
                series = sum(serie, na.rm = T),
                poids = sum(poids, na.rm = T)) %>%
      ungroup() %>%
      pivot_longer(!c(date, poids), names_to = 'gr', values_to = 'value')

  })

  output$time_content <- renderHighchart({
    highchart()%>%
      hc_xAxis(type = "datetime", labels = list(format = '{value:%m/%d}')) %>%
      hc_yAxis_multiples(list(title = list(text = "Exercices / Séries"),
                              labels=list(format = '{value}'),
                              showFirstLabel = TRUE,
                              showLastLabel=TRUE,
                              opposite = FALSE),
                         list(title = list(text = "Charges (Kg)"),
                              labels = list(format = "{value}"),showLastLabel = FALSE, opposite = TRUE)) %>%
      hc_plotOptions(column = list(stacking = "normal")) %>%
      hc_add_series(data_time(),type="column",hcaes(x=date,y=value, group = 'gr'),yAxis=0) %>%
      hc_add_series(data_time(),type="line",hcaes(x=date,y=poids), yAxis = 1, name = 'Charge',  color = 'orange')

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
      ungroup() %>%
      reactable(
        theme = clean(),
        pagination = FALSE,
        columns = list(
          min_poids = colDef(
            name = 'Poids mini',
            cell = data_bars(
              data = .,
              fill_color = c('#FFF2D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          mean_poids = colDef(
            name = 'Poids moyen',
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          max_poids = colDef(
            name = 'Poids max',
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          min_serie = colDef(
            name = 'Serie mini',
            cell = data_bars(
              data = .,
              fill_color = c('#FFF2D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          mean_serie = colDef(
            name = 'Serie moyen',
            cell = data_bars(
              data = .,
              fill_color = c('#FFF3D9','#FFE1A6','#FFCB66','#FFB627'),
              fill_gradient = TRUE,
              background = 'transparent',
              number_fmt = scales::comma_format(accuracy = 0.1)
            )),

          max_serie = colDef(
            name = 'Serie max',
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
      mutate('90%' = max*0.9,
             '80%' = max*0.8,
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

  output$exercice_filter <- renderPrint({
    res <- lapply(1:5, function(i) input[[paste0('a', i)]])
    str(setNames(res, paste0('a', 1:5)))
  })

  output$exercice_filter = renderUI({
    my_ex = unique(data()$exercice)
    selectInput('exercice_name', 'Exercice', my_ex)
  })

  output$exercice_plot <- renderHighchart({

  data_plot_ex <- data() %>%
    filter(exercice == input$exercice_name) %>%
    pivot_longer(!c(date, exercice, poids), names_to = 'gr', values_to = 'value')

  hc <- highchart()%>%
    hc_xAxis(type = "datetime", labels = list(format = '{value:%m/%d}')) %>%
    hc_yAxis_multiples(list(title = list(text = "Exercices / Séries"),
                            labels=list(format = '{value}'),
                            showFirstLabel = TRUE,
                            showLastLabel=TRUE,
                            opposite = FALSE),
                       list(title = list(text = "Charges (Kg)"),
                            labels = list(format = "{value}"),showLastLabel = FALSE, opposite = TRUE)) %>%
    # hc_plotOptions(column = list(stacking = "normal")) %>%
    hc_add_series(data_plot_ex,type="column",hcaes(x=date,y=value, group = 'gr'),yAxis=0) %>%
    hc_add_series(data_plot_ex,type="line",hcaes(x=date,y=poids), yAxis = 1, name = 'Charge')

  hc


  })

  output$view_ex <- renderReactable({

    data_plot_ex <- data() %>%
      filter(exercice == input$exercice_name) %>%
      mutate(max = round(poids / (1.0279 - (0.0278*reps)),1)) %>%
      arrange(date) %>%
      mutate(evol = round((max - lag(max))/max,2),
             evol = ifelse(is.na(evol), 0, evol))

    reactable(data_plot_ex, columns = list(
      evol = colDef(
        style = function(value) {
          if (value > 0) {
            color <- "#008000"
          } else if (value < 0) {
            color <- "#e00000"
          } else {
            color <- "#777"
          }
          list(color = color, fontWeight = "bold")
        }
      )
    ))

  })


}

