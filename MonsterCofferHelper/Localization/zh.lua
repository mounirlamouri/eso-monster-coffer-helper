ZO_CreateStringId("SI_MCH_TITLE", "Monster Coffer Helper")
ZO_CreateStringId("SI_MCH_PANEL_TITLE", "无畏者肩甲")

-- Numbers: the character between the whole and the decimal part
ZO_CreateStringId("SI_MCH_DECIMAL_SEPARATOR", ".")

-- Verdicts
ZO_CreateStringId("SI_MCH_VERDICT_MYSTERY", "建议购买神秘宝箱")
ZO_CreateStringId("SI_MCH_VERDICT_CURATED", "建议购买精选宝箱")
ZO_CreateStringId("SI_MCH_VERDICT_EITHER", "两者花费相同")
ZO_CreateStringId("SI_MCH_VERDICT_DONE", "收集完成 - 无需购买")

-- Panel body
ZO_CreateStringId("SI_MCH_COLLECTED", "已收集")
ZO_CreateStringId("SI_MCH_LINE_COLLECTED", "<<1>> / <<2>> 件肩甲，共 <<3>> 套（缺 <<4>> 件）")
ZO_CreateStringId("SI_MCH_MYSTERY", "神秘")
ZO_CreateStringId("SI_MCH_CURATED", "精选")
ZO_CreateStringId("SI_MCH_LINE_OFFER", "<<1>> 把钥匙，<<2>> 为新 -> 每件新肩甲 <<3>> 把钥匙")
ZO_CreateStringId("SI_MCH_SWITCH_HINT", "在缺少的肩甲降到 <<1>> 件之前，神秘宝箱更便宜（还差 <<2>> 件）。")
ZO_CreateStringId("SI_MCH_SWITCH_NOW", "已过平衡点：从现在起精选宝箱更便宜。")
ZO_CreateStringId("SI_MCH_FINISH", "完成此商人")
ZO_CreateStringId("SI_MCH_FINISH_LINE", "最优方式约 <<1>> 把钥匙（全神秘 <<2>> / 全精选 <<3>>）")
ZO_CreateStringId("SI_MCH_ALL_VENDORS", "所有商人")
ZO_CreateStringId("SI_MCH_ALL_LINE", "缺少的 <<2>> 件肩甲约需 <<1>> 把钥匙")
ZO_CreateStringId("SI_MCH_KEYS_HELD", "你持有 <<1>> 把无畏者钥匙")
ZO_CreateStringId("SI_MCH_KEYS_BUY", "你持有 <<1>> 把无畏者钥匙：以最优方式在此约可获得 <<2>> 件新肩甲")
ZO_CreateStringId("SI_MCH_KEYS_FINISH", "你持有 <<1>> 把无畏者钥匙：平均足以完成此商人")
ZO_CreateStringId("SI_MCH_INCOMPLETE_SETS", "仍缺肩甲的套装")
ZO_CreateStringId("SI_MCH_AND_MORE", "以及另外 <<1>> 套")
ZO_CreateStringId("SI_MCH_NO_DATA", "没有此商人的肩甲数据。")
ZO_CreateStringId("SI_MCH_PRICES_ASSUMED", "假定价格 - 访问商人以确认")

-- Chat
ZO_CreateStringId("SI_MCH_CHAT_PREFIX", "宝箱")
ZO_CreateStringId("SI_MCH_CHAT_LINE", "<<1>>：<<2>> - 每件新肩甲 <<3>> 把钥匙，精选为 <<4>>（已收集 <<5>>/<<6>>）")
ZO_CreateStringId("SI_MCH_CHAT_DONE", "<<1>>：所有肩甲均已收集。请保留你的钥匙。")

-- Tooltip
ZO_CreateStringId("SI_MCH_TT_CHANCE", "新肩甲：<<1>>")
ZO_CreateStringId("SI_MCH_TT_COST", "实际花费：每件新肩甲 <<1>> 把钥匙")
ZO_CreateStringId("SI_MCH_TT_BEST", "此处最佳选择")
ZO_CreateStringId("SI_MCH_TT_WORSE", "另一种宝箱每件新肩甲更便宜")
ZO_CreateStringId("SI_MCH_TT_SET_MISSING", "此宝箱的 <<2>> 件肩甲中仍缺 <<1>> 件")
ZO_CreateStringId("SI_MCH_TT_SET_DONE", "你已拥有此宝箱的全部肩甲 - 浪费钥匙")

-- Purchase confirmation
ZO_CreateStringId("SI_MCH_GUARD_TITLE", "不是最佳选择")
ZO_CreateStringId("SI_MCH_GUARD_MYSTERY_WORSE", "此处目前精选宝箱更便宜：每件新肩甲 <<1>> 把钥匙，而神秘宝箱为 <<2>> 把。")
ZO_CreateStringId("SI_MCH_GUARD_CURATED_WORSE", "此处目前神秘宝箱更便宜：每件新肩甲 <<1>> 把钥匙，而此精选宝箱为 <<2>> 把。")
ZO_CreateStringId("SI_MCH_GUARD_DUPLICATE", "你已拥有此宝箱能给出的全部肩甲，只会得到重复物品。")
ZO_CreateStringId("SI_MCH_GUARD_BULK_MYSTERY", "平均而言，<<2>> 个神秘宝箱就能让你到达精选宝箱更便宜的临界点。一次购买 <<1>> 个很可能会超过这个点。")
ZO_CreateStringId("SI_MCH_GUARD_BULK_CURATED", "此宝箱中你只缺 <<2>> 件肩甲，所以购买 <<1>> 个至少会得到 <<3>> 件重复物品。")
ZO_CreateStringId("SI_MCH_GUARD_BUY", "仍然购买")

-- Settings
ZO_CreateStringId("SI_MCH_SET_DISPLAY", "显示")
ZO_CreateStringId("SI_MCH_SET_PANEL", "在商人处显示面板")
ZO_CreateStringId("SI_MCH_SET_PANEL_TT", "与无畏者军需官交谈时弹出推荐窗口。")
ZO_CreateStringId("SI_MCH_SET_CHAT", "在聊天中显示推荐")
ZO_CreateStringId("SI_MCH_SET_CHAT_TT", "商人商店打开时在聊天中写一行结论。")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS", "在宝箱提示中添加信息")
ZO_CreateStringId("SI_MCH_SET_TOOLTIPS_TT", "在商人商店的宝箱上显示你的几率和实际钥匙花费。")
ZO_CreateStringId("SI_MCH_SET_CONFIRM", "确认非最佳的购买")
ZO_CreateStringId("SI_MCH_SET_CONFIRM_TT", "在购买较贵的宝箱、只能给出你已拥有肩甲的宝箱，或一次购买超过划算数量的宝箱之前进行询问。")
ZO_CreateStringId("SI_MCH_SET_LOCK", "锁定面板位置")
ZO_CreateStringId("SI_MCH_SET_RESET_POS", "重置面板位置")
ZO_CreateStringId("SI_MCH_SET_MAXSETS", "面板中列出的套装数")
ZO_CreateStringId("SI_MCH_SET_MAXSETS_TT", "列出多少个未完成的套装，其余的合并为数量。")

ZO_CreateStringId("SI_MCH_SET_PRICES", "价格")
ZO_CreateStringId("SI_MCH_SET_LEARN", "使用从商人读取的价格")
ZO_CreateStringId("SI_MCH_SET_LEARN_TT", "从商店窗口读取实际钥匙价格并记住。关闭后始终使用下方数值。")
ZO_CreateStringId("SI_MCH_SET_MCOST", "神秘宝箱价格（钥匙）")
ZO_CreateStringId("SI_MCH_SET_CCOST", "精选宝箱价格（钥匙）")
ZO_CreateStringId("SI_MCH_SET_COST_TT", "在插件看到商人商店之前使用的备用值。")

ZO_CreateStringId("SI_MCH_SET_POOL", "商人库存")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL", "使用从商人读取的库存")
ZO_CreateStringId("SI_MCH_SET_LEARNPOOL_TT", "将商店窗口中看到的套装加入 LibSets 自带的列表，这样比 LibSets 数据更新的套装也会被计入。")
ZO_CreateStringId("SI_MCH_SET_FORGET", "忘记从商人读取的所有内容")

ZO_CreateStringId("SI_BINDING_NAME_MCH_TOGGLE", "切换 Coffer Helper")
