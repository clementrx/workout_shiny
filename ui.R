ui <- fluidPage(

  navbarPage(
    theme = shinytheme('cerulean'),

    "Suivi musculation",
    tabPanel("Input",

             sidebarPanel(width = 3,
                          fileInput('file1', 'Importer un fichier .xlsx',
                                    accept = c(".xlsx")
                          ),
                          column(12,
                                 'Ici on mettera des filtres'),
                          column(6,
                                 "Ou ici"),
                          column(6,
                                 'Ou la'),

                          br(),
                          br()
                          ),

             mainPanel(width = 9,
                       fluidRow(
                              summaryBox2("Exercices",
                                          textOutput('ex_box'),
                                         width = 3,
                                         icon = "fas fa-clipboard-list",
                                         style = "info"),
                              summaryBox2("Séries",
                                          textOutput('series_box'),
                                         width = 3,
                                         icon = "fas fa-th-list",
                                         style = "success"),
                              summaryBox2("Poids",
                                          textOutput('poids_box'),
                                         width = 4,
                                         icon = "fas fa-dumbbell",
                                         style = "danger")
                              ),
                       hr(),
                       fluidRow(column(12,
                         highchartOutput("time_content")
                       )),

                       hr(),
                       fluidRow(
                         reactableOutput("contents")),
                       hr(),
                       hr(),
                       h3('Estimation des max'),
                       fluidRow(
                                reactableOutput("table_max")),
                       ))


  )

)
