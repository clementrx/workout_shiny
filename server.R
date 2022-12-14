server = function(input, output){


  df_export <- import_fichier(here('test.xlsx'))

  df_template <- df_export %>%
    mutate(date = as.character(date)) %>%
    rename(`charge (kg)` = 'poids')

  wb <- createWorkbook()
  addWorksheet(wb, sheetName = "sheet1")
  writeData(wb, sheet = 1, x = df_template, startCol = 1, startRow = 1)

  data <- reactive({
    inFile <- input$file1

    if(is.null(inFile)){

      # return(NULL)

      df_export <- df_export %>%
        filter(date >= input$daterange[1],
               date <= input$daterange[2])

      return(df_export)
    }


    df <- import_fichier(inFile$datapath)
    df <- df %>%
      filter(date >= input$daterange[1],
             date <= input$daterange[2])

    # df <- read_excel(paste(inFile$datapath, ".xlsx", sep=""), 1)


  })


  output$downloadData <- downloadHandler(
    filename = function() {
      paste("template.xlsx")
    },
    content = function(file) {
      # write.csv(df_export, file, row.names = FALSE)
      saveWorkbook(wb, file = file, overwrite = TRUE)
      # write.xlsx(df_export, file, row.names = FALSE)
    }
  )

  output$ex_box <- renderText({
    paste0(length(unique(data()$exercice)))
  })

  output$series_box <- renderText({
    paste0(sum(data()$serie))
  })

  output$poids_box <- renderText({
    paste0(sum(data()$poids), ' Kg')
  })

  data_time <- reactive({

    data() %>%
      mutate(poids_total = serie*reps*poids) %>%
      group_by(date) %>%
      summarise(exercices = n_distinct(exercice, na.rm = T),
                series = sum(serie, na.rm = T),
                repetitions = sum(serie*reps, na.rm = T),
                poids = sum(poids_total, na.rm = T)) %>%
      ungroup() %>%
      pivot_longer(!c(date, poids), names_to = 'gr', values_to = 'value')

  })

  output$ex_box <- renderText({
    paste0(length(unique(data()$exercice)))
  })

  output$series_box <- renderText({
    paste0(sum(data()$serie))
  })

  output$poids_box <- renderText({
    paste0(sum(data()$poids*data()$serie*data()$reps), ' Kg')
  })

  output$time_content <- renderHighchart({
    highchart()%>%
      hc_xAxis(type = "datetime", labels = list(format = '{value:%m/%d}')) %>%
      hc_yAxis_multiples(list(title = list(text = "Exercices / S??ries"),
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
      ),
      defaultPageSize = 30
    )

  })


  output$exercice_filter = renderUI({
    my_ex = unique(data()$exercice)
    selectInput('exercice_name', 'Exercice', my_ex)
  })

  output$exercice_plot <- renderHighchart({

  data_plot_ex <- data() %>%
    filter(exercice == input$exercice_name) %>%
    mutate(poids_total = serie*reps*poids) %>%
    group_by(date) %>%
    summarise(exercices = n_distinct(exercice, na.rm = T),
              serie_tot = sum(serie, na.rm = T),
              reps_tot = sum(serie*reps, na.rm = T),
              poids = sum(poids_total, na.rm = T)) %>%
    ungroup() %>%
    pivot_longer(!c(date, poids), names_to = 'gr', values_to = 'value')

  hc <- highchart()%>%
    hc_xAxis(type = "datetime", labels = list(format = '{value:%m/%d}')) %>%
    hc_yAxis_multiples(list(title = list(text = "Exercices / S??ries"),
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
      mutate(poids_total = serie*reps*poids) %>%
      group_by(date) %>%
      mutate(serie_tot = sum(serie, na.rm = T),
             reps_tot = sum(serie*reps, na.rm = T),
             poids_total = sum(poids_total, na.rm = T),
             max = round(poids / (1.0279 - (0.0278*reps)),1)) %>%
      top_n(1, max) %>%
      ungroup() %>%
      arrange(date) %>%
      mutate(evol = round((max - lag(max))/max,2),
             evol = ifelse(is.na(evol), 0, evol)) %>%
      select(-c(exercice)) %>%
      arrange(desc(date))

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
        },
        format = colFormat(percent = TRUE)
      )
    ),
    defaultPageSize = 10)

  })

  output$value_max <- renderReactable({

    max <- round(input$poids_inputs  / (1.0279 - (0.0278*input$reps_inputs)),1)

    df_max <- data.frame(max,
                         max*0.9,
                         max*0.8,
                         max*0.7,
                         max*0.6,
                         max*0.5,
                         max*0.4,
                         max*0.3
    )
    colnames(df_max) <- c('100%',
                          '90%',
                          '80%',
                          '70%',
                          '60%',
                          '50%',
                          '40%',
                          '30%')

    reactable(
      df_max,
      theme = clean(centered = TRUE)
    )

    })

  output$plot_opti <- renderHighchart({

    max <- round(input$poids_inputs  / (1.0279 - (0.0278*input$reps_inputs)),1)

    poids_opti <- c()
    reps <- c()

    for( i in (1:20)){
      reps <- c(reps, i)
      compute_poids <- round(max*(1.0279 - (0.0278*i)), 2)
      poids_opti <- c(poids_opti, compute_poids)
    }

    df_opti <- data.frame(reps, poids_opti)

    hc <- highchart()%>%
      hc_xAxis(title = list(text = 'Nombre de r??p??titions')) %>%
      hc_yAxis(title = list(text = 'Charge (kg)')) %>%
      hc_add_series(df_opti,type="column",hcaes(x=reps,y=poids_opti),yAxis=0, name = 'Charge optimum')

    hc

  })

}

