# shiny_snmb
Aplicaciones shiny para explorar la base de datos del SNMB.

## Buscador de registros

Es una aplicación que explora los conglomerados del SNMB en busca de registros de un animal o planta en particular, 
adicionalmente permite descargar archivos csv con los registros de especies invasoras, huellas/excretas, especimenes/restos
o registros de la trampa cámara. Para la descarga de archivos se puede especificar el nombre común y/o científico del animal
o planta de interés o se pueden descargar todos los existentes.

La sección del mapa usa coordenadas tomadas de la maya *real* del SNMB, es fácil modificar para tomar las coordenadas ingresadas 
en campo, para lograr esto se modifica server.R y dejamos el parámetro `malla` en blanco.


