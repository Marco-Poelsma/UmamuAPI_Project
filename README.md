[El vídeo explicativo del proyecto se puede encontrar en Youtube](https://youtu.be/2n87f7D0D7I)

[Link al JSON de la API de sparks](https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json)

[Link al JSON de la API de umamusume](https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json)


# UmamuAPI

UmamuAPI es una aplicación iOS diseñada para ayudar a los jugadores de Uma Musume: Pretty Derby a gestionar de forma eficiente la ascendencia y los sparks de sus personajes.

## Contexto

En Uma Musume: Pretty Derby, una parte clave del entrenamiento consiste en seleccionar correctamente la ascendencia (madres y abuelas) de una uma musume, ya que estas pueden transmitir habilidades y mejoras a través de los llamados sparks.

Los sparks pueden ser de cuatro tipos:

- Atributo (`stat`): mejora estadísticas como speed, stamina, power, guts o wit.

- Aptitud (`aptitude`): mejora el rendimiento según tipo de pista, distancia o estilo.

- Habilidad única (`unique_skill`): proporciona descuentos y desbloquea habilidades especiales.

- Habilidad (`skill`): ofrece descuentos adicionales y pequeñas mejoras de atributos.

>[!NOTE]
>Cada personaje debe contar, como mínimo, con un spark de atributo y un spark de aptitud.
>La inspiración se basa en dos generaciones anteriores (madres y abuelas). Una uma musume puede ser su propia abuela, pero no su propia madre.

## Objetivo de la Aplicación

UmamuAPI simplifica la gestión de ascendencia y sparks, facilitando la selección óptima de personajes para maximizar el rendimiento en cada partida.

Está dirigida a jugadores que desean optimizar sus estrategias sin tener que gestionar manualmente toda la información.

## Funcionalidades Principales

- Crear, editar, eliminar y visualizar uma musume

- Añadir sparks desde una lista predefinida

- Marcar personajes como favoritos

- Buscador por nombre o ID (PK)

- Filtro que muestra solo umamusume con 3 estrellas en un spark de tipo `stat` o `aptitude`

- Persistencia de favoritos incluso tras reiniciar la aplicación

- Validaciones para evitar datos incompletos (mínimo dos personajes y sparks obligatorios)

## Orden de Visualización

Las uma musume se muestran en una lista ordenada por el siguiente criterio jerárquico:

- Favoritos

- Nombre

- ID (PK)

## Estructura del Proyecto
En el desarrollo del proyecto, se ha usado la arquitectura MVVM para mantener un código limpio y legible. La estructura de carpetas del archivo es la siguiente:
```
├── UmamuAPI Project/
│   ├── Assets.xcassets/
│   │   ├── AccentColor.colorset/
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset/
│   │   │   ├── Contents.json
│   │   │   ├── favicon-120x120-1.png
│   │   │   ├── favicon-120x120.png
│   │   │   ├── favicon-152x152.png
│   │   │   ├── favicon-167x167.png
│   │   │   ├── favicon-180x180.png
│   │   │   ├── favicon-20x20.png
│   │   │   ├── favicon-29x29.png
│   │   │   ├── favicon-40x40-1.png
│   │   │   ├── favicon-40x40-2.png
│   │   │   ├── favicon-40x40.png
│   │   │   ├── favicon-58x58-1.png
│   │   │   ├── favicon-58x58.png
│   │   │   ├── favicon-60x60.png
│   │   │   ├── favicon-76x76.png
│   │   │   ├── favicon-80x80-1.png
│   │   │   ├── favicon-80x80.png
│   │   │   └── favicon-87x87.png
│   │   └── Contents.json
│   ├── Model/
│   │   ├── Color.swift
│   │   ├── GitHubService.swift
│   │   ├── Spark.swift
│   │   ├── SparkResponse.swift
│   │   ├── SparkResponse.swift.swift
│   │   ├── Umamusume.swift
│   │   ├── UmamusumeFormMode.swift
│   │   └── UmamusumeResponse.swift
│   ├── Preview Content/
│   │   └── Preview Assets.xcassets/
│   │       └── Contents.json
│   ├── View/
│   │   ├── BackgroundGreyView.swift
│   │   ├── CornerRadius.swift
│   │   ├── ListContainer.swift
│   │   ├── RoundedCorner.swift
│   │   ├── ScrollableListContainer.swift
│   │   ├── SparkListView.swift
│   │   ├── SparkPickerSheet.swift
│   │   ├── SparkRankingsView.swift
│   │   ├── StyledRowView.swift
│   │   ├── SwipeRow.swift
│   │   ├── test.swift
│   │   ├── TopRankingView.swift
│   │   ├── UmamusumeFormSheet.swift
│   │   ├── UmamusumeListView.swift
│   │   └── UmamusumePickerSheet.swift
│   ├── ViewModel/
│   │   ├── APIConnection.swift
│   │   ├── APIError.swift
│   │   ├── APIService.swift
│   │   ├── Array+Identifiable.swift
│   │   ├── DataCache.swift
│   │   ├── FavouritesStore.swift
│   │   ├── SparkPickerViewModel.swift
│   │   ├── SparkViewModel.swift
│   │   ├── StarButton.swift
│   │   ├── SyncManager.swift
│   │   ├── UmamusumeFormViewModel.swift
│   │   ├── UmamusumePickerViewModel.swift
│   │   └── UmamusumeViewModel.swift
│   ├── .gitignore
│   ├── ContentView.swift
│   ├── Info.plist
│   └── UmamuAPI_ProjectApp.swift
└── UmamuAPI Project.xcodeproj/
    ├── project.xcworkspace/
    │   ├── xcshareddata/
    │   │   └── IDEWorkspaceChecks.plist
    │   └── contents.xcworkspacedata
    ├── xcuserdata/
    │   └── alumne.xcuserdatad/
    │       └── xcschemes/
    │           └── xcschememanagement.plist
    └── project.pbxproj
```

## Instrucciones de uso

A continuación se describen los pasos principales para utilizar UmamuAPI correctamente.

### Favoritos y persistencia

Desde la lista principal puedes marcar cualquier uma musume como favorita.

Las favoritas se priorizan automáticamente en el orden de visualización.

Los favoritos se mantienen guardados incluso si:

- Se reinicia la aplicación.

- Se reinicia el emulador de Xcode.

La aplicación es compatible con modo claro y modo oscuro.

### Crear una Umamusume

Accede a la vista de creación (sheet superpuesta).

Introduce un nombre.

Selecciona los sparks necesarios.

Requisitos obligatorios para guardar:

Mínimo:

- 1 spark de tipo stat

- 1 spark de tipo aptitude

Máximo:

- 1 spark de tipo stat

- 1 spark de tipo aptitude

Los demás sparks son opcionales.

Cada spark debe tener entre 1 y 3 estrellas.

No se permite 0 estrellas.

El botón Save permanecerá deshabilitado hasta que se cumplan todos los requisitos mínimos.

### Selección de Sparks

Existe una barra de búsqueda para encontrar sparks rápidamente.

Se puede modificar el número de estrellas antes de guardar.

Los cambios pueden editarse posteriormente desde la vista de edición.

### Inspiraciones

Es obligatorio seleccionar exactamente 2 inspiraciones.

No se puede guardar si:

- Hay menos de 2 inspiraciones.

- Se intenta seleccionar más de 2.

La interfaz muestra avisos cuando no se cumplen los requisitos.

Se pueden seleccionar y deseleccionar antes de guardar.

### Editar una Umamusume

Desde la vista de edición se puede:

- Modificar el nombre.

- Cambiar sparks y número de estrellas.

- Cambiar inspiraciones.

- Eliminar la uma musume.

La vista de edición reutiliza el mismo diseño que la vista de creación.

### Eliminar una Umamusume

Existen dos métodos:

- Deslizar completamente hacia la izquierda.

- Deslizar parcialmente y pulsar el botón Delete.

### Rankings

Los rankings están disponibles para sparks de tipo:

- Stat

- Aptitude

Se muestran las uma musume con 3 estrellas en el spark seleccionado.

Se mantiene el sistema de búsqueda dentro del ranking.

Si no hay resultados, se muestra un placeholder informativo.

### Búsqueda

Disponible en todas las vistas principales.

Permite buscar por:

- Nombre

- ID (PK)

La búsqueda funciona por coincidencia parcial de texto.

### Compatibilidad

- Compatible con modo vertical y horizontal.

- Soporte completo para modo claro y oscuro.

- Persistencia de datos tras reinicios.

