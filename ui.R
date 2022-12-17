ui <- fluidPage(

  navbarPage(
    theme = shinytheme('cerulean'),

    "Suivi musculation (Beta)",
    tabPanel("Resumé",

             sidebarPanel(width = 3,
                          fileInput('file1', 'Importer un fichier .xlsx',
                                    accept = c(".xlsx")
                          ),

                          downloadLink("downloadData", "Télécharger le template"),
                          # column(12,
                          #        'Ici on mettera des filtres'),
                          # column(6,
                          #        "Ou ici"),
                          # column(6,
                          #        'Ou la'),

                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          dateRangeInput("daterange",
                                         "Période : " ,
                                         start = today()-90,
                                         end   = today(),
                                         # min = NULL,
                                         # max = NULL,
                                         format = "yyyy-mm-dd",
                                         # startview = "month",
                                         # weekstart = 0,
                                         language = "fr",
                                         separator = " à "),
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
                                         style = "warning")
                              ),
                       hr(),
                       fluidRow(column(12,
                         highchartOutput("time_content")
                       )),

                       hr(),
                       fluidRow(
                         reactableOutput("contents"))
                       )),

    tabPanel("Evolution",

             sidebarPanel(width = 3,
                          uiOutput('exercice_filter'),

                          br(),
                          br()
             ),

             mainPanel(width = 9,

                       # hr(),
                       fluidRow(column(12,
                                       highchartOutput("exercice_plot"))),
                       hr(),
                       fluidRow(reactableOutput("view_ex"))

             )),

    tabPanel("Estimation des max",

             # sidebarPanel(width = 3,
             #              # uiOutput('exercice_filter'),
             #
             #              br(),
             #              br()
             # ),

             mainPanel(width = '100%',

                       fluidRow(reactableOutput("table_max"))

             )),

    tabPanel("Calcul de max",

             sidebarPanel(width = 3,
                          numericInput('poids_inputs',
                                       'Poids (kg):',
                                       50,
                                       min = 1,
                                       max = 10000),
                          br(),
                          numericInput('reps_inputs',
                                       'Répétition(s):',
                                       10,
                                       min = 1,
                                       max = 20),
                          # uiOutput('exercice_filter'),

                          br(),
                          br()
             ),

             mainPanel(width = 9,

                       fluidRow(reactableOutput("value_max")),
                       fluidRow(highchartOutput("plot_opti"))

             ))


  )

)
