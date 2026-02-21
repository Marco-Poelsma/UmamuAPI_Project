[El vídeo explicativo del proyecto se puede encontrar en Youtube](https://youtu.be/n_ej3iBJVik)

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


