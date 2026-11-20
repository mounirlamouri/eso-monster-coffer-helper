ZO_CreateStringId("SI_MCH_TITLE", "Monster Coffer Helper")
ZO_CreateStringId("SI_MCH_PANEL_TITLE", "Наплечники Неустрашимых")

-- Numbers: the character between the whole and the decimal part
ZO_CreateStringId("SI_MCH_DECIMAL_SEPARATOR", ",")

-- Verdicts
ZO_CreateStringId("SI_MCH_VERDICT_MYSTERY", "Покупайте ТАИНСТВЕННЫЕ сундуки")
ZO_CreateStringId("SI_MCH_VERDICT_CURATED", "Покупайте ИЗБРАННЫЕ сундуки")
ZO_CreateStringId("SI_MCH_VERDICT_EITHER", "Оба варианта стоят одинаково")
ZO_CreateStringId("SI_MCH_VERDICT_DONE", "Коллекция собрана - ничего не покупайте")

-- Panel body
ZO_CreateStringId("SI_MCH_COLLECTED", "Собрано")
ZO_CreateStringId("SI_MCH_LINE_COLLECTED", "наплечники: <<1>> / <<2>>, комплекты: <<3>> (не хватает: <<4>>)")
ZO_CreateStringId("SI_MCH_MYSTERY", "Таинственный")
ZO_CreateStringId("SI_MCH_CURATED", "Избранный")
ZO_CreateStringId("SI_MCH_LINE_OFFER", "цена: <<1>>, шанс нового: <<2>> -> ключей за новый наплечник: <<3>>")
ZO_CreateStringId("SI_MCH_SWITCH_HINT", "Таинственный сундук выгоднее, пока недостающих наплечников больше <<1>> (ещё: <<2>>).")
ZO_CreateStringId("SI_MCH_SWITCH_NOW", "Точка равновесия пройдена: дальше выгоднее избранный сундук.")
ZO_CreateStringId("SI_MCH_FINISH", "Завершить этого торговца")
ZO_CreateStringId("SI_MCH_FINISH_LINE", "ключей при лучшем выборе: ~<<1>> (только таинственные: <<2>> / только избранные: <<3>>)")
ZO_CreateStringId("SI_MCH_ALL_VENDORS", "Все торговцы")
ZO_CreateStringId("SI_MCH_ALL_LINE", "недостающих наплечников: <<2>>, ключей: ~<<1>>")
ZO_CreateStringId("SI_MCH_KEYS_HELD", "Ключей Неустрашимых: <<1>>")
ZO_CreateStringId("SI_MCH_KEYS_BUY", "Ключей Неустрашимых: <<1>> (новых наплечников здесь при лучшем выборе: ~<<2>>)")
ZO_CreateStringId("SI_MCH_KEYS_FINISH", "Ключей Неустрашимых: <<1>> (в среднем хватит, чтобы завершить этого торговца)")
ZO_CreateStringId("SI_MCH_INCOMPLETE_SETS", "Ещё не хватает наплечников из")
ZO_CreateStringId("SI_MCH_AND_MORE", "и ещё <<1>>")
ZO_CreateStringId("SI_MCH_NO_DATA", "Нет данных о наплечниках этого торговца.")
ZO_CreateStringId("SI_MCH_PRICES_ASSUMED", "предполагаемые цены - посетите торговца, чтобы проверить")

-- Chat
ZO_CreateStringId("SI_MCH_CHAT_PREFIX", "Сундук")
ZO_CreateStringId("SI_MCH_CHAT_LINE", "<<1>>: <<2>> - ключей за новый наплечник: <<3>> против <<4>> у избранного (собрано: <<5>>/<<6>>)")
ZO_CreateStringId("SI_MCH_CHAT_DONE", "<<1>>: все наплечники собраны. Сберегите ключи.")

-- Tooltip
ZO_CreateStringId("SI_MCH_TT_CHANCE", "Новый наплечник: <<1>>")
ZO_CreateStringId("SI_MCH_TT_COST", "Реальная цена в ключах за новый наплечник: <<1>>")
ZO_CreateStringId("SI_MCH_TT_BEST", "Лучшая покупка здесь")
ZO_CreateStringId("SI_MCH_TT_WORSE", "Другой сундук дешевле за новый наплечник")
ZO_CreateStringId("SI_MCH_TT_SET_MISSING", "Не хватает наплечников из этого сундука: <<1>> из <<2>>")
ZO_CreateStringId("SI_MCH_TT_SET_DONE", "У вас уже есть все наплечники из этого сундука - ключи будут потрачены зря")

-- Purchase confirmation
ZO_CreateStringId("SI_MCH_GUARD_TITLE", "Не лучшая покупка")
ZO_CreateStringId("SI_MCH_GUARD_MYSTERY_WORSE", "Сейчас здесь дешевле избранные сундуки. Ключей за новый наплечник: <<1>> против <<2>> у таинственного сундука.")
ZO_CreateStringId("SI_MCH_GUARD_CURATED_WORSE", "Сейчас здесь дешевле таинственные сундуки. Ключей за новый наплечник: <<1>> против <<2>> у этого избранного сундука.")
ZO_CreateStringId("SI_MCH_GUARD_DUPLICATE", "У вас уже есть все наплечники, которые может дать этот сундук, поэтому из него выпадет только дубликат.")
ZO_CreateStringId("SI_MCH_GUARD_BULK_MYSTERY", "В среднем до точки, где избранные сундуки становятся дешевле, нужно таинственных сундуков: <<2>>. Покупка сразу <<1>> шт., скорее всего, выйдет за эту точку.")
ZO_CreateStringId("SI_MCH_GUARD_BULK_CURATED", "В этом сундуке вам не хватает наплечников: <<2>>, поэтому покупка <<1>> шт. даст как минимум дубликатов: <<3>>.")
ZO_CreateStringId("SI_MCH_GUARD_BUY", "Всё равно купить")

-- Settings
ZO_CreateStringId("SI_MCH_SET_DISPLAY", "Отображение")
ZO_CreateStringId("SI_MCH_SET_PANEL", "Показывать панель у торговца")
ZO_CreateStringId("SI_MCH_SET_PANEL_TT", "Открывает окно с рекомендацией, когда вы говорите с интендантом Неустрашимых.")
ZO_CreateStringId("SI_MCH_SET_CHAT", "Писать рекомендацию в чат")
ZO_CreateStringId("SI_MCH_SET_CHAT_TT", "Пишет в чат вердикт в одну строку, когда открывается магазин торговца.")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS", "Добавлять строки в подсказки сундуков")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS_TT", "Показывает ваши шансы и реальную цену в ключах на сундуках в магазине торговца.")
ZO_CreateStringId("SI_MCH_SET_CONFIRM", "Подтверждать невыгодные покупки")
ZO_CreateStringId("SI_MCH_SET_CONFIRM_TT", "Спрашивает перед покупкой более дорогого сундука, сундука, который может дать только уже имеющийся наплечник, или большего числа сундуков за раз, чем стоит покупать.")
ZO_CreateStringId("SI_MCH_SET_LOCK", "Закрепить панель")
ZO_CreateStringId("SI_MCH_SET_RESET_POS", "Сбросить положение панели")
ZO_CreateStringId("SI_MCH_SET_MAXSETS", "Комплектов в панели")
ZO_CreateStringId("SI_MCH_SET_MAXSETS_TT", "Сколько незавершённых комплектов назвать, прежде чем свести остальные к числу.")

ZO_CreateStringId("SI_MCH_SET_PRICES", "Цены")
ZO_CreateStringId("SI_MCH_SET_LEARN", "Использовать цены торговца")
ZO_CreateStringId("SI_MCH_SET_LEARN_TT", "Считывает реальную цену в ключах из окна магазина и запоминает её. Выключите, чтобы всегда использовать значения ниже.")
ZO_CreateStringId("SI_MCH_SET_MCOST", "Цена таинственного сундука (ключи)")
ZO_CreateStringId("SI_MCH_SET_CCOST", "Цена избранного сундука (ключи)")
ZO_CreateStringId("SI_MCH_SET_COST_TT", "Используется, пока аддон не увидел магазин торговца.")

ZO_CreateStringId("SI_MCH_SET_POOL", "Ассортимент торговца")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL", "Использовать ассортимент торговца")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL_TT", "Добавляет комплекты из окна магазина к списку LibSets, чтобы учитывались и комплекты новее данных LibSets.")
ZO_CreateStringId("SI_MCH_SET_FORGET", "Забыть всё, что считано у торговцев")

ZO_CreateStringId("SI_BINDING_NAME_MCH_TOGGLE", "Показать/скрыть Coffer Helper")
