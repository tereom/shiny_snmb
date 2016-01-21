library(leaflet)
# Define UI for miles per gallon application
shinyUI(fluidPage(
  p(),
  #  title
  h2("Buscador de especies"),

  wellPanel(
    textInput("especies", label = "Nombre:", value = "vaca|taurus|caballo|equus"),
    helpText("Ingresa el nombre o nombres (común y/o científico) de los animales
      o plantas que deseas buscar, los nombres deben estar separados por el
      símbolo '|'. Ejemplo: vaca|taurus|caballo|equus"),
    actionButton("actualiza", "actualiza", icon("refresh"))

  ),
#   mainPanel(
#     p(),
#     leafletOutput("mapa_base", width = "800px", height = "500px"),
#     p(),
#     dataTableOutput("tbl"),
#     downloadButton('downloadCgl', 'Descargar tabla conglomerados')
#   )
  mainPanel(
    tabsetPanel(
      tabPanel("Mapa",
        leafletOutput("mapa_base", width = "800px", height = "500px"),
        p(),
        dataTableOutput("tbl"),
        p()
      ),
      tabPanel("Descargas",
        h3("Descarga de tablas en formato csv"),
        wellPanel(
#         p("El siguiente botón descarga la tabla de la pestaña Mapa en formato
#           csv."),
        h4("Tabla de presencia a nivel conglomerado"),
          p("Para descargar esta tabla es necesario haber ejecutado una búsqueda
            de especie(s), es la tabla análoga a la que aparece en la parte
            inferior de la pestaña Mapa."),
        downloadButton('downloadCgl', 'Presencia conglomerados'),
        h4("Tablas con rutas a archivos"),
        p("Las siguientes tablas se descargan por tipo de registro (especie
          invasora, huellas/excretas, trampa cámara)."),
        radioButtons("tab", "Tabla",
          list("Especies Invasoras" = "ei",
            "Huellas/Excretas " = "he",
            "Especimen/resto" = "er",
            "Cámara" = "camara")),
        radioButtons("sel_especies", "Especies",
          list("Especificadas en buscador" = "especies_noms",
            "Todas" = "especies_todas")
          ),
        downloadButton('downloadFiles', 'Rutas Archivos')
        ))
    )
  )
))
