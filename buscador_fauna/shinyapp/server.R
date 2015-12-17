library(shiny)
library(plyr)
library(dplyr)
library(tidyr)
library(shiny)
library(rgdal)
library(DT)
library(DBI)
library(leaflet)

load("/Volumes/ARCHIVOS_C/Mac_Pro/SNMB/datos/malla.Rdata")

# Filtramos los conglomerados en la base para hacer el mapa de conglomerados
# muestreados en leaflet, tiene que ser aquí para que no sea reactiva y sólo se
# calcule una vez
PASS_SNMB = Sys.getenv("PASS_SNMB")
base_input_aux <- src_postgres(dbname = "snmb", host = "dbms", user = "snmb", 
  password = PASS_SNMB)
conglomerado_ids <- tbl(base_input_aux, "conglomerado_muestra") %>%
  collect() %>%
  mutate(id = as.numeric(nombre)) %>%
  `$`("id")
RPostgreSQL::dbDisconnect(base_input_aux$con)  

malla <- malla %>% 
  filter(cgl %in% conglomerado_ids) %>% 
  select(cgl_id = cgl, lng = lon, lat)

source("/Volumes/ARCHIVOS_C/Mac_Pro/SNMB/queryfactory_R_snmb/species.R", 
  local = TRUE)
source("/Volumes/ARCHIVOS_C/Mac_Pro/SNMB/queryfactory_R_snmb/querySpecies.R", 
  local = TRUE)

shinyServer(function(input, output){
  # datos reactivos
  animal_mult <- eventReactive(input$actualiza, {  
    speciesFinder(input$especies, malla)
  })
  # mapa base con los conglomerados en azúl
  output$mapa_base <- renderLeaflet({
    leaflet() %>% 
      addTiles(options =  providerTileOptions(opacity = 0.75)) %>%
      fitBounds(lng1 = -117.82, lat1 = 32.64, lng2 = -84.91, lat2 = 13.39) %>%
      addCircleMarkers(data = malla,
        lng =~lng, lat=~lat, 
        popup=~paste("cgl:", cgl_id), 
        stroke = FALSE,
        fillOpacity = 0.4, 
        radius = 2,
        color = ~"navy",
        group = "base")
  })
  
  # graficar puntos sobre el mapa base que indican los conglomerados donde se 
  # detectó la especie(s) buscada(s), se indican con puntos rojos
  observeEvent(input$actualiza, {
    animales <- animal_mult()[[2]]
    
    leafletProxy("mapa_base", data = animales) %>% 
      # clearCircleMarkers() %>%
      clearGroup(group = "obs") %>%
      clearGroup(group = "highlights") %>%
      addCircleMarkers(
        lng =~lng, lat=~lat, 
        popup=~paste("cgl:", cgl_id), 
        stroke = FALSE,
        fillOpacity = 0.8, 
        radius = 4,
        color = ~"red",
        group = "obs")
  })
  
  # agregar marcador en mapa que indica los renglones de la tabla seleccionados 
  # con el mouse
  observeEvent(input$tbl_rows_selected, {
    animales <- animal_mult()[[2]]
    
    animales_sub <- animales[as.numeric(input$tbl_rows_selected), drop = FALSE]
    
    leafletProxy("mapa_base", data = animales_sub) %>% 
      clearGroup(group = "highlights") %>%
      addCircleMarkers(
        lng =~lng, lat=~lat, 
        popup =~paste("cgl:", cgl_id), 
        #stroke = FALSE,
        #fillOpacity = 1, 
        radius = 8,
        weight = 2,
        #color = ~"red",
        group = "highlights")
  })
  
  # tabla con información de las especies buscadas, la tabla es a nivel 
  # conglomerado
  output$tbl <- DT::renderDataTable({
    tab <- animal_mult()[[1]] 
  }, 
    options = list(
      lengthMenu = c(5, 10, 15, 20, -1), 
      pageLength = 15, 
      columnDefs = list(
        list(className = 'dt-center', targets = c(5, 6, 7, 8, 9, 10)))
    )
  )
  
  # descarga de la tabla a nivel conglomerado
  output$downloadCgl <- downloadHandler(
    filename = "tab_cgls.csv",
    content = function(file) {
      write.csv(animal_mult()[[1]], file)
    }
  )
  
  # construcción de tablas a nivel archivo
  dataFiles <- reactive({  
    queryTabs <- switch(input$tab,
      ei = queryInvaders,
      he = queryFootprints,
      er = querySpecimens,
      camara = queryInvaders,
      queryInvaders)
    noms <- ifelse(input$sel_especies == "especies_noms", input$especies, "all")
    queryTabs(noms = noms)
  })
  
  # descarga de la tabla a nivel archivo
  output$downloadFiles <- downloadHandler(
    filename = "tab_archivos.csv",
    content = function(file) {
      write.csv(dataFiles(), file)
    }
  )
  
})