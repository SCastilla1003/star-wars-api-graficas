/// Catálogo único de las 63 gráficas de la galería: 31 básicas y 32
/// avanzadas. El mismo catálogo se replica en las 4 librerías
/// (fl_chart, graphic, community_charts_flutter, drafter), de modo que
/// 63 × 4 = 252 gráficas en total.
///
/// Cada entrada tiene un id estable (para elegir el builder de cada
/// librería), un nombre visible y una descripción corta.
enum ChartLevel { basica, avanzada }

class ChartSpec {
  final String id;
  final String name;
  final String description;
  final ChartLevel level;

  const ChartSpec({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
  });
}

/// Las 63 entradas del catálogo.
const List<ChartSpec> kChartCatalog = [
  // -------------------------------------------------------------------------
  // Básicas (31)
  // -------------------------------------------------------------------------
  ChartSpec(
    id: 'line_simple',
    name: 'Líneas simples',
    description:
        'Línea única que sigue un métrico (diámetro) a lo largo de los planetas ordenados.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'line_multi',
    name: 'Líneas múltiples',
    description:
        'Varias series comparadas en los mismos ejes: población, agua y rotación por planeta.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'line_markers',
    name: 'Línea con marcadores',
    description: 'Puntos visibles en cada valor para leer cada planeta de forma individual.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'line_dashed',
    name: 'Línea discontinua',
    description: 'Trazo punteado para series de referencia o valores estimados.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'line_smooth',
    name: 'Curva suave',
    description: 'Interpolación suave entre puntos para una lectura visual más orgánica.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'line_gradient',
    name: 'Línea con degradado',
    description: 'Línea con relleno degradado bajo la curva, acentuando el pico.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'step_line',
    name: 'Step line',
    description: 'Escalones horizontales: cambia de valor de forma abrupta entre categorías.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_vertical',
    name: 'Barras verticales',
    description: 'Comparación clásica del diámetro de los planetas más grandes.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_horizontal',
    name: 'Barras horizontales',
    description: 'Barras horizontales para nombres largos: población ordenada de mayor a menor.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_grouped',
    name: 'Barras agrupadas',
    description: 'Dos series lado a lado por bioma: diámetro y agua superficial.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_stacked',
    name: 'Barras apiladas',
    description: 'Segmentos apilados por bioma: cuántos planetas de cada clima hay por grupo.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_stacked_100',
    name: 'Barras 100% apiladas',
    description: 'Proporciones normalizadas: cómo se reparte cada terreno dentro de un clima.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_diverging',
    name: 'Barras divergentes',
    description: 'Valores positivos y negativos según estén por encima o por debajo del promedio.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'combo_bar_line',
    name: 'Columna + línea',
    description: 'Barras de un métrico con una línea de tendencia superpuesta.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'area_simple',
    name: 'Área simple',
    description: 'Línea con relleno bajo la curva, resaltando la magnitud acumulada.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'area_stacked',
    name: 'Área apilada',
    description: 'Áreas apiladas por categoría mostrando la suma visual de varias series.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'area_gradient',
    name: 'Área con degradado',
    description: 'Relleno con opacidad decreciente hacia el eje inferior.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'step_area',
    name: 'Step area',
    description: 'Área con escalones: la superficie cambia de nivel de forma abrupta.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'pie_basic',
    name: 'Tarta',
    description: 'Proporción de cada clima sobre el total de planetas de SWAPI.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'pie_percent',
    name: 'Tarta con porcentajes',
    description: 'Porciones con etiqueta de porcentaje para lectura directa de la proporción.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'donut_basic',
    name: 'Dona',
    description: 'Tarta con hueco central que libera espacio para el total.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'donut_kpi',
    name: 'Dona con KPI central',
    description: 'Dona con el dato principal destacado en el centro (planetas totales).',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'scatter_basic',
    name: 'Dispersión',
    description: 'Relación entre dos variables: diámetro frente a población.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'scatter_bubble',
    name: 'Dispersión con burbujas',
    description: 'Tercera variable codificada como tamaño: agua superficial como radio.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'radar_basic',
    name: 'Radar',
    description: 'Perfil multivariable del planeta frente al promedio de SWAPI.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'radar_circle',
    name: 'Radar con rejilla circular',
    description: 'Misma comparación multivariable con anillos redondeados en vez de polígonos.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'polar_area',
    name: 'Área polar',
    description: 'Barras radiales: el valor se codifica en la longitud de cada sector.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'spark_line',
    name: 'Sparkline línea',
    description: 'Mini gráfico de línea compacto para mostrar la tendencia sin ejes.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'spark_area',
    name: 'Sparkline área',
    description: 'Mini gráfico de área compacto con relleno bajo la curva.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'spark_bar',
    name: 'Sparkline barras',
    description: 'Mini gráfico de columnas compacto para comparar valores de un vistazo.',
    level: ChartLevel.basica,
  ),
  ChartSpec(
    id: 'bar_stacked_total',
    name: 'Barras apiladas + total',
    description: 'Barras apiladas con la línea del total encima para ver la suma.',
    level: ChartLevel.basica,
  ),
  // -------------------------------------------------------------------------
  // Avanzadas (32)
  // -------------------------------------------------------------------------
  ChartSpec(
    id: 'candlestick',
    name: 'Velas japonesas',
    description:
        'Apertura, cierre, máximo y mínimo del diámetro de cada bioma (cuartiles).',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'ohlc',
    name: 'OHLC',
    description: 'Barras de máximo-mínimo con marcas de apertura y cierre por bioma.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'histogram',
    name: 'Histograma',
    description:
        'Distribución de frecuencias: en qué rango caen los diámetros de los planetas.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'box_plot',
    name: 'Box plot',
    description:
        'Caja y bigotes de un métrico por bioma: mediana, cuartiles y dispersión.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'waterfall',
    name: 'Waterfall',
    description: 'Aportes acumulados: cómo cada terreno contribuye al total de planetas.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'funnel',
    name: 'Funnel',
    description: 'Embudo de reducción acumulada de los climas más frecuentes a los raros.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'pyramid',
    name: 'Pirámide',
    description: 'Barras en espejo: comparación bilateral de dos métricos por categoría.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'treemap',
    name: 'Treemap',
    description:
        'Rectángulos anidados: terrenos y sus climas, el área es proporcional al conteo.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'sunburst',
    name: 'Sunburst',
    description: 'Anillos jerárquicos: clima en el interior, terreno en el anillo exterior.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'sankey',
    name: 'Sankey',
    description: 'Flujos entre climas y terrenos, el grosor es el número de planetas.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'gantt',
    name: 'Gantt',
    description: 'Barras de duración: periodo orbital de cada planeta como tarea temporal.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'heatmap_matrix',
    name: 'Heatmap matriz',
    description:
        'Matriz clima × terreno con intensidad de color según cuántos planetas hay.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'heatmap_calendar',
    name: 'Heatmap calendario',
    description: 'Cuadrícula tipo calendario con la intensidad de un métrico por planeta.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'range_area',
    name: 'Rango área',
    description: 'Banda continua entre el mínimo y el máximo de un métrico por bioma.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'range_column',
    name: 'Columnas de rango',
    description: 'Cada columna va del mínimo al máximo, sin base en cero.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'line_band',
    name: 'Línea con banda de confianza',
    description: 'Línea central con una banda de dispersión (± desviación) alrededor.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'stream_graph',
    name: 'Stream graph',
    description: 'Áreas onduladas centradas que fluyen, ideales para series apiladas.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'radial_bar',
    name: 'Radial bar',
    description:
        'Barras curvas alrededor de un círculo, proporcional al valor de cada categoría.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'gauge',
    name: 'Gauge',
    description: 'Medidor de aguja que sitúa un valor actual dentro de un rango total.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'bullet',
    name: 'Bullet',
    description: 'Barra de métrico contra un objetivo con rangos de referencia de fondo.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'scatter_regression',
    name: 'Dispersión con regresión',
    description: 'Nube de puntos con la recta de tendencia calculada por mínimos cuadrados.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'correlation_matrix',
    name: 'Matriz de correlación',
    description:
        'Mapa de calor de las correlaciones de Pearson entre los campos numéricos.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'line_log',
    name: 'Línea logarítmica',
    description: 'Eje logarítmico para abarcar poblaciones que difieren en órdenes de magnitud.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'bar_error',
    name: 'Barras con error',
    description: 'Media con barras de error (± desviación estándar) por bioma.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'bubble_log',
    name: 'Burbujas proporcionales',
    description: 'El área (no el radio) de cada burbuja es proporcional al valor, en escala log.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'pie_exploded',
    name: 'Tarta explosiva',
    description: 'Una porción separada del resto para destacar la categoría principal.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'donut_multi_ring',
    name: 'Dona multi-anillo',
    description: 'Varios anillos concéntricos comparando dos desgloses distintos.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'strip_plot',
    name: 'Strip plot',
    description: 'Puntos dispersos dentro de cada categoría para ver la distribución cruda.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'radar_multi',
    name: 'Radar multiserie',
    description: 'Tres planetas superpuestos en el mismo radar para comparar perfiles.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'dumbbell',
    name: 'Dumbbell',
    description: 'Dos puntos unidos por una línea: mínimo y máximo de cada bioma.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'line_annotations',
    name: 'Línea con anotaciones',
    description: 'Línea con marcas destacadas sobre los valores máximo y mínimo.',
    level: ChartLevel.avanzada,
  ),
  ChartSpec(
    id: 'waterfall_percent',
    name: 'Waterfall porcentual',
    description: 'Cascada normalizada al 100% para ver la contribución relativa.',
    level: ChartLevel.avanzada,
  ),
];

/// Filtra el catálogo por nivel.
List<ChartSpec> chartsForLevel(ChartLevel level) =>
    kChartCatalog.where((c) => c.level == level).toList();

/// Total de gráficas de la galería: 63 catálogo × 4 librerías.
const int kTotalGalleries = 4;
const int kChartsPerLibrary = 63;
const int kTotalCharts = kChartsPerLibrary * kTotalGalleries; // 252
