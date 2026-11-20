ZO_CreateStringId("SI_MCH_TITLE", "Monster Coffer Helper")
ZO_CreateStringId("SI_MCH_PANEL_TITLE", "Hombreras de los Intrépidos")

-- Numbers: the character between the whole and the decimal part
ZO_CreateStringId("SI_MCH_DECIMAL_SEPARATOR", ",")

-- Verdicts
ZO_CreateStringId("SI_MCH_VERDICT_MYSTERY", "Compra cofres MISTERIOSOS")
ZO_CreateStringId("SI_MCH_VERDICT_CURATED", "Compra cofres SELECCIONADOS")
ZO_CreateStringId("SI_MCH_VERDICT_EITHER", "Los dos cuestan lo mismo")
ZO_CreateStringId("SI_MCH_VERDICT_DONE", "Colección completa - no compres nada")

-- Panel body
ZO_CreateStringId("SI_MCH_COLLECTED", "Colección")
ZO_CreateStringId("SI_MCH_LINE_COLLECTED", "<<1>> / <<2>> <<2[hombrera/hombreras]>> de <<3>> <<3[conjunto/conjuntos]>> (sin conseguir: <<4>>)")
ZO_CreateStringId("SI_MCH_MYSTERY", "Misterioso")
ZO_CreateStringId("SI_MCH_CURATED", "Seleccionado")
ZO_CreateStringId("SI_MCH_LINE_OFFER", "<<1>> <<1[llave/llaves]>>, <<2>> de que sea nueva -> <<3>> <<4[llave/llaves]>> por hombrera nueva")
ZO_CreateStringId("SI_MCH_SWITCH_HINT", "El cofre misterioso sigue siendo más barato hasta que <<1[falte/falten]>> <<1>> <<1[hombrera/hombreras]>> (<<2[queda/quedan]>> <<2>>).")
ZO_CreateStringId("SI_MCH_SWITCH_NOW", "Ya has pasado el punto de equilibrio: a partir de ahora el cofre seleccionado es más barato.")
ZO_CreateStringId("SI_MCH_FINISH", "Completar este vendedor")
ZO_CreateStringId("SI_MCH_FINISH_LINE", "~<<1>> <<4[llave/llaves]>> eligiendo bien (todo misterioso <<2>> / todo seleccionado <<3>>)")
ZO_CreateStringId("SI_MCH_ALL_VENDORS", "Todos los vendedores")
ZO_CreateStringId("SI_MCH_ALL_LINE", "~<<1>> <<3[llave/llaves]>> por <<2>> <<2[hombrera que falta/hombreras que faltan]>>")
ZO_CreateStringId("SI_MCH_KEYS_HELD", "Tienes <<1>> <<1[llave/llaves]>> de los Intrépidos")
ZO_CreateStringId("SI_MCH_KEYS_BUY", "Tienes <<1>> <<1[llave/llaves]>> de los Intrépidos: aproximadamente <<2>> <<2[hombrera nueva/hombreras nuevas]>> aquí eligiendo bien")
ZO_CreateStringId("SI_MCH_KEYS_FINISH", "Tienes <<1>> <<1[llave/llaves]>> de los Intrépidos: de media, <<1[suficiente/suficientes]>> para completar este vendedor")
ZO_CreateStringId("SI_MCH_INCOMPLETE_SETS", "Conjuntos a los que aún les faltan hombreras")
ZO_CreateStringId("SI_MCH_AND_MORE", "y <<1>> más")
ZO_CreateStringId("SI_MCH_NO_DATA", "No hay datos de hombreras para este vendedor.")
ZO_CreateStringId("SI_MCH_PRICES_ASSUMED", "precios supuestos - visita al vendedor para confirmarlos")

-- Chat
ZO_CreateStringId("SI_MCH_CHAT_PREFIX", "Cofre")
ZO_CreateStringId("SI_MCH_CHAT_LINE", "<<1>>: <<2>> - <<3>> <<7[llave/llaves]>> por hombrera nueva frente a <<4>> con el seleccionado (<<5>>/<<6>> conseguidas)")
ZO_CreateStringId("SI_MCH_CHAT_DONE", "<<1>>: tienes todas las hombreras. Guarda tus llaves.")

-- Tooltip
ZO_CreateStringId("SI_MCH_TT_CHANCE", "Probabilidad de hombrera nueva: <<1>>")
ZO_CreateStringId("SI_MCH_TT_COST", "Coste real: <<1>> <<2[llave/llaves]>> por hombrera nueva")
ZO_CreateStringId("SI_MCH_TT_BEST", "La mejor compra aquí")
ZO_CreateStringId("SI_MCH_TT_WORSE", "El otro cofre sale más barato por hombrera nueva")
ZO_CreateStringId("SI_MCH_TT_SET_MISSING", "Aún te <<1[falta/faltan]>> <<1>> de las <<2>> hombreras de este cofre")
ZO_CreateStringId("SI_MCH_TT_SET_DONE", "Ya tienes todas las hombreras de este cofre - llaves desperdiciadas")

-- Purchase confirmation
ZO_CreateStringId("SI_MCH_GUARD_TITLE", "No es la mejor compra")
ZO_CreateStringId("SI_MCH_GUARD_MYSTERY_WORSE", "Ahora mismo los cofres seleccionados son más baratos aquí: <<1>> <<3[llave/llaves]>> por hombrera nueva, frente a <<2>> con un cofre misterioso.")
ZO_CreateStringId("SI_MCH_GUARD_CURATED_WORSE", "Ahora mismo los cofres misteriosos son más baratos aquí: <<1>> <<3[llave/llaves]>> por hombrera nueva, frente a <<2>> con este cofre seleccionado.")
ZO_CreateStringId("SI_MCH_GUARD_DUPLICATE", "Ya tienes todas las hombreras que puede dar este cofre, así que solo puede darte un duplicado.")
ZO_CreateStringId("SI_MCH_GUARD_BULK_MYSTERY", "De media, <<2>> <<2[cofre misterioso te lleva/cofres misteriosos te llevan]>> al punto en que los cofres seleccionados pasan a ser más baratos. Comprar <<1>> de una vez probablemente lo superaría.")
ZO_CreateStringId("SI_MCH_GUARD_BULK_CURATED", "A este cofre solo le <<2[queda/quedan]>> <<2>> <<2[hombrera/hombreras]>> que te <<2[falta/faltan]>>, así que comprar <<1>> te daría al menos <<3>> <<3[duplicado/duplicados]>>.")
ZO_CreateStringId("SI_MCH_GUARD_BUY", "Comprar de todos modos")

-- Settings
ZO_CreateStringId("SI_MCH_SET_DISPLAY", "Visualización")
ZO_CreateStringId("SI_MCH_SET_PANEL", "Mostrar la ventana en el vendedor")
ZO_CreateStringId("SI_MCH_SET_PANEL_TT", "Abre la ventana de recomendación cuando hablas con un intendente de los Intrépidos.")
ZO_CreateStringId("SI_MCH_SET_CHAT", "Escribir la recomendación en el chat")
ZO_CreateStringId("SI_MCH_SET_CHAT_TT", "Escribe un veredicto de una línea en el chat al abrirse la tienda del vendedor.")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS", "Añadir líneas a la información de los cofres")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS_TT", "Muestra tus probabilidades y el coste real en llaves en los cofres de la tienda del vendedor.")
ZO_CreateStringId("SI_MCH_SET_CONFIRM", "Confirmar las compras que no son la mejor opción")
ZO_CreateStringId("SI_MCH_SET_CONFIRM_TT", "Pregunta antes de comprar el cofre más caro, un cofre que solo puede dar una hombrera que ya tienes, o más cofres de una vez de los que vale la pena comprar.")
ZO_CreateStringId("SI_MCH_SET_LOCK", "Bloquear la posición de la ventana")
ZO_CreateStringId("SI_MCH_SET_RESET_POS", "Restablecer la posición de la ventana")
ZO_CreateStringId("SI_MCH_SET_MAXSETS", "Conjuntos listados en la ventana")
ZO_CreateStringId("SI_MCH_SET_MAXSETS_TT", "Cuántos conjuntos incompletos se nombran antes de resumir el resto con un número.")

ZO_CreateStringId("SI_MCH_SET_PRICES", "Precios")
ZO_CreateStringId("SI_MCH_SET_LEARN", "Usar los precios leídos del vendedor")
ZO_CreateStringId("SI_MCH_SET_LEARN_TT", "Lee el coste real en llaves de la ventana de la tienda y lo recuerda. Desactívalo para usar siempre los valores de abajo.")
ZO_CreateStringId("SI_MCH_SET_MCOST", "Coste del cofre misterioso (llaves)")
ZO_CreateStringId("SI_MCH_SET_CCOST", "Coste del cofre seleccionado (llaves)")
ZO_CreateStringId("SI_MCH_SET_COST_TT", "Valor que se usa hasta que el addon haya visto la tienda del vendedor.")

ZO_CreateStringId("SI_MCH_SET_POOL", "Existencias del vendedor")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL", "Usar las existencias leídas del vendedor")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL_TT", "Añade los conjuntos vistos en la tienda a la lista que incluye LibSets, para que cuente también un conjunto más reciente que sus datos.")
ZO_CreateStringId("SI_MCH_SET_FORGET", "Olvidar todo lo leído de los vendedores")

ZO_CreateStringId("SI_BINDING_NAME_MCH_TOGGLE", "Mostrar/ocultar Monster Coffer Helper")
