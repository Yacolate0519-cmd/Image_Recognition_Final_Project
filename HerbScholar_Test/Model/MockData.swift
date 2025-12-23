import Foundation

let mockHerbs: [Herb] = [
    Herb(
        id: "1",
        name: "白朮片（Bai Zhu）",
        scientificName: "Atractylodes macrocephala",
        category: "補益藥",
        properties: "溫",
        taste: "甘、苦",
        meridians: ["脾", "胃"],
        functions: [
            "健脾益氣：用於脾氣虛弱所致的食少、倦怠乏力。",
            "燥濕利水：改善脾虛夾濕所致的腹脹、泄瀉、水腫。",
            "止汗安胎：用於脾虛自汗及妊娠胎動不安。"
        ],
        indications: [
            "脾胃虛弱，食慾不振，腹脹便溏",
            "脾虛泄瀉、痰飲、水腫",
            "表虛自汗",
            "妊娠胎動不安"
        ],
        dosage: "煎服，6–12 克。",
        precautions: [
            "陰虛內熱、津液不足者慎用",
            "實熱證者不宜使用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Baizhu_Slices_白朮.jpeg",
        description: "白朮為菊科植物白朮的乾燥根莖，臨床多切製成白朮片使用。其性溫味甘苦，善於健脾益氣、燥濕利水，是治療脾虛濕盛的重要藥材。"
    ),
    Herb(
        id: "2",
        name: "蒼朮（Cang Zhu）",
        scientificName: "Atractylodes lancea",
        category: "化濕藥",
        properties: "溫",
        taste: "辛、苦",
        meridians: ["脾", "胃"],
        functions: [
            "燥濕健脾：用於濕阻中焦所致的脘腹脹滿、食慾不振。",
            "祛風散寒：用於風寒濕痺與感受風寒濕邪。",
            "明目：用於夜盲症及視物昏花。"
        ],
        indications: [
            "濕阻中焦，脘腹脹滿，食少嘔吐",
            "風寒濕痺，肢體痠痛",
            "夜盲、小兒佝僂病"
        ],
        dosage: "煎服，3–9 克。",
        precautions: [
            "陰虛內熱、氣虛多汗者忌用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Atractylodes_Rhizome_蒼朮.jpeg",
        description: "蒼朮為菊科植物，藥性較白朮更燥，長於燥濕，而補氣健脾之力不及白朮。"
    ),
    Herb(
        id: "3",
        name: "木香（Mu Xiang）",
        scientificName: "Aucklandia lappa",
        category: "理氣藥",
        properties: "溫",
        taste: "辛、苦",
        meridians: ["脾", "胃", "大腸", "膽"],
        functions: [
            "行氣止痛：常用於脾胃氣滯、脘腹脹痛。",
            "健脾消食：改善食積不化與泄瀉後重。"
        ],
        indications: [
            "胸脘脹痛、瀉痢後重",
            "食積不消、不思飲食"
        ],
        dosage: "煎服，3–10 克；後下效果較佳。",
        precautions: [
            "陰虛津虧者慎用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Radix_Aucklandiae_木香.jpeg",
        description: "木香為理氣止痛的要藥，特別是針對中焦脾胃與下焦大腸的氣滯症狀效果顯著。"
    ),
    Herb(
        id: "4",
        name: "熟地黃（Shu Di Huang）",
        scientificName: "Rehmannia glutinosa",
        category: "補益藥",
        properties: "微溫",
        taste: "甘",
        meridians: ["肝", "腎"],
        functions: [
            "補血滋陰：改善面色萎黃、心悸、失眠。",
            "益精填髓：用於肝腎精血虧虛所致的腰膝痠軟、耳鳴。"
        ],
        indications: [
            "血虛萎黃、眩暈心悸",
            "腎虛精虧、月經不調",
            "消渴、耳鳴目昏"
        ],
        dosage: "煎服，9–30 克。",
        precautions: [
            "性滋膩，脾虛便溏、痰濕多者不宜多用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Prepared_Rehmannia_Root_地黃.jpeg",
        description: "地黃經由砂仁拌酒反覆蒸曬而成（九蒸九曬），由寒轉溫，補益力強且不傷胃。"
    ),
    Herb(
        id: "5",
        name: "山藥（Shan Yao）",
        scientificName: "Dioscorea polystachya",
        category: "補益藥",
        properties: "平",
        taste: "甘",
        meridians: ["脾", "肺", "腎"],
        functions: [
            "補脾養胃：改善脾虛食少與便溏。",
            "生津益肺：用於肺虛喘咳及消渴證。",
            "補腎澀精：改善腎虛帶下、遺精及尿頻。"
        ],
        indications: [
            "脾虛泄瀉、久痢",
            "肺虛喘咳、消渴",
            "腎虛遺精、婦女帶下"
        ],
        dosage: "煎服，15–30 克（大劑量可達 60 克）。",
        precautions: [
            "濕盛中滿或有實邪者忌用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dioscorea_polystachya_Turcz_山藥.jpeg",
        description: "山藥為平補脾肺腎三經的良藥，補而不滯，溫而不燥，亦可作為日常食療。"
    ),
    Herb(
        id: "6",
        name: "白芷（Bai Zhi）",
        scientificName: "Angelica dahurica",
        category: "解表藥",
        properties: "溫",
        taste: "辛",
        meridians: ["胃", "大腸", "肺"],
        functions: [
            "解表散寒：治療風寒感冒、頭痛鼻塞。",
            "通竅止痛：尤擅治療前額疼痛（陽明頭痛）與牙痛。",
            "消腫排膿：用於瘡瘍腫毒初起或膿成不潰。"
        ],
        indications: [
            "感冒頭痛、眉稜骨痛、鼻淵鼻塞",
            "牙痛、帶下、瘡瘍腫痛"
        ],
        dosage: "煎服，3–10 克。",
        precautions: [
            "陰虛血熱者忌用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dahurian_Angelica_白芷.jpeg",
        description: "白芷氣味芳香，能通竅止痛，是中醫治療面部疾病與鼻病的重要藥材。"
    ),
    Herb(
        id: "7",
        name: "陳皮（Chen Pi）",
        scientificName: "Citrus reticulata",
        category: "理氣藥",
        properties: "溫",
        taste: "辛、苦",
        meridians: ["脾", "肺"],
        functions: [
            "理氣健脾：改善脾胃氣滯所致的腹脹、嘔吐、便溏。",
            "燥濕化痰：主治痰濕咳嗽、胸膈滿悶。"
        ],
        indications: [
            "脘腹脹滿、不思飲食、嘔吐噯氣",
            "咳嗽痰多、胸悶不舒"
        ],
        dosage: "煎服，3–10 克。",
        precautions: [
            "舌赤少津、內有實熱者不宜過量"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Citri_Reticulatae_Pericarpium_陳皮.jpeg",
        description: "陳皮即橘皮，貯藏年份愈久藥效愈佳，故名。具有調氣、化痰、消食之功。"
    ),
    Herb(
        id: "8",
        name: "何首烏（He Shou Wu）",
        scientificName: "Fallopia multiflora",
        category: "補益藥",
        properties: "微溫",
        taste: "苦、甘、澀",
        meridians: ["肝", "腎"],
        functions: [
            "補肝腎、益精血：制首烏長於補益精血，烏鬚髮，強筋骨。",
            "解毒潤腸：生首烏偏於截瘧解毒、潤腸通便。"
        ],
        indications: [
            "精血虧虛、鬚髮早白、腰膝痠軟",
            "腸燥便秘（生用）、久瘧"
        ],
        dosage: "煎服，10–20 克。",
        precautions: [
            "脾虛便溏者慎用；注意肝毒性風險，不可長期超量服用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Fallopia_multiflora.jpeg",
        description: "何首烏在應用上分為生首烏與制首烏，功用截然不同，臨床補益多用制首烏。"
    ),
    Herb(
        id: "9",
        name: "紅耆（Hong Qi）",
        scientificName: "Hedysarum polybotrys",
        category: "補益藥",
        properties: "微溫",
        taste: "甘",
        meridians: ["脾", "肺"],
        functions: [
            "補氣升陽：用於中氣下陷、久瀉脫肛。",
            "固表止汗：用於表虛自汗。",
            "托毒生肌：用於瘡瘍久潰不斂。"
        ],
        indications: [
            "氣虛乏力、食少便溏、久瀉",
            "自汗、水腫、癰疽難潰"
        ],
        dosage: "煎服，9–30 克。",
        precautions: [
            "表實邪盛、氣滯濕阻、陰虛陽亢者禁用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Hedysarum_Root.jpeg",
        description: "紅耆在台灣與甘肅常用，其功效與黃耆相似，但部分文獻認為其補氣力較黃耆更為醇厚。"
    ),
    Herb(
        id: "10",
        name: "黃耆（Huang Qi）",
        scientificName: "Astragalus membranaceus",
        category: "補益藥",
        properties: "微溫",
        taste: "甘",
        meridians: ["脾", "肺"],
        functions: [
            "益氣固表：增強免疫力，預防感冒。",
            "利尿消腫：用於氣虛所致的水腫。",
            "升陽舉陷：治療子宮脫垂、胃下垂。"
        ],
        indications: [
            "氣虛體弱、倦怠乏力、表虛自汗",
            "氣虛浮腫、慢性潰瘍難癒"
        ],
        dosage: "煎服，9–30 克；大劑量可用至 60 克。",
        precautions: [
            "外感初起、內有實熱者不宜使用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Astragalus_membranaceus.jpeg",
        description: "黃耆被譽為「補氣諸藥之長」，是中醫臨床及食療中最常用的補氣藥物之一。"
    ),
    Herb(
        id: "11",
        name: "甘草（Gan Cao）",
        scientificName: "Glycyrrhiza uralensis",
        category: "補益藥",
        properties: "平",
        taste: "甘",
        meridians: ["心", "肺", "脾", "胃"],
        functions: [
            "補脾益氣：改善脾胃虛弱、倦怠乏力。",
            "潤肺止咳：用於咳嗽痰多、咽喉腫痛。",
            "緩急止痛：治療脘腹、四肢攣急疼痛。",
            "調和諸藥：緩解其他藥物的毒性或烈性。"
        ],
        indications: [
            "脾胃虛弱、心悸氣短、咳嗽咽痛",
            "腹痛攣急、藥食中毒"
        ],
        dosage: "煎服，2–10 克。",
        precautions: [
            "反大戟、甘遂、芫花、海藻；長期服用可能導致浮腫或血壓升高"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Licorice_甘草.jpg",
        description: "甘草在中醫處方中出現率最高，有「國老」之稱，既能補益，又能調和藥性。"
    ),
    Herb(
        id: "12",
        name: "川芎（Chuan Xiong）",
        scientificName: "Ligusticum chuanxiong",
        category: "活血化瘀藥",
        properties: "溫",
        taste: "辛",
        meridians: ["肝", "膽", "心包"],
        functions: [
            "活血行氣：用於月經不調、經閉痛經。",
            "祛風止痛：是治頭痛的要藥，對各種頭痛（寒熱虛實）均有效果。"
        ],
        indications: [
            "月經不調、痛經、產後瘀滯腹痛",
            "頭痛（風寒、風熱、偏頭痛）、肢體痺痛"
        ],
        dosage: "煎服，3–10 克。",
        precautions: [
            "陰虛火旺、月經過多者、孕婦慎用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Ligusticum_chuanxiong_Hort_川穹.jpeg",
        description: "川芎為「血中之氣藥」，能上行頭目、下行血海、外徹皮毛、旁通絡脈。"
    ),
    Herb(
        id: "13",
        name: "茯苓（Poria）",
        scientificName: "Poria cocos",
        category: "利水滲濕藥",
        properties: "平",
        taste: "甘、淡",
        meridians: ["心", "肺", "脾", "腎"],
        functions: [
            "利水滲濕：用於水腫、尿少。",
            "健脾寧心：改善脾虛食少、心悸失眠。"
        ],
        indications: [
            "水腫尿少、痰飲咳嗽",
            "脾虛食少、便溏泄瀉",
            "心神不安、失眠、驚悸"
        ],
        dosage: "煎服，10–15 克。",
        precautions: [
            "虛寒精滑者慎用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Poria_茯苓.jpeg",
        description: "茯苓寄生於松樹根上，藥性平和，利水而不傷正，是臨床極為常用的補脾利濕藥。"
    ),
    Herb(
        id: "14",
        name: "莪朮（E Zhu）",
        scientificName: "Curcuma zedoaria",
        category: "活血化瘀藥",
        properties: "溫",
        taste: "辛、苦",
        meridians: ["肝", "脾"],
        functions: [
            "破血行氣：消解強大的血瘀。用於經閉、腹部腫塊（癥瘕）。",
            "消積止痛：治療食積不化所致的脘腹脹痛。"
        ],
        indications: [
            "血瘀經閉、癥瘕痞塊",
            "食積脘腹脹痛"
        ],
        dosage: "煎服，3–9 克。",
        precautions: [
            "孕婦及月經過多者禁用"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Zedoary_Rhizome_莪朮.jpeg",
        description: "莪朮藥性猛烈，長於破氣散結，常用於治療嚴重的氣滯血瘀證。"
    ),
    Herb(
        id: "15",
        name: "牛奶榕（羊奶頭）",
        scientificName: "Ficus hirta",
        category: "補益/祛濕藥",
        properties: "平",
        taste: "甘、微澀",
        meridians: ["脾", "肺", "肝"],
        functions: [
            "健脾化濕：用於脾虛食少、消化不良。",
            "祛風除濕：改善風濕痺痛、筋骨不利。",
            "行氣活血：用於產後無乳、跌打損傷。"
        ],
        indications: [
            "脾虛食少、腹瀉、白帶過多",
            "風濕關節痛、咳嗽、產後乳少"
        ],
        dosage: "煎服，15–30 克（大劑量可用至 60 克）。",
        precautions: [
            "目前無特殊禁忌，但孕婦使用前請諮詢專業中醫師"
        ],
        imageUrl: "https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Taiwan_Ficus_牛奶榕.jpeg",
        description: "牛奶榕在台灣民間俗稱「羊奶頭」，被譽為台灣天仙果。因切開枝葉有白色乳汁且果實像羊乳頭而得名。"
    )
]

//Taiwan Ficus -> 牛奶榕（羊奶頭）
//Atractylodes Rhizome -> 蒼朮
//Radix Aucklandiae -> 木香
//Prepared Rehmannia Root -> 熟地黃
//Dioscorea polystachya Turcz -> 山藥
//Dahurian Angelica -> 白芷
//Citri Reticulatae Pericarpium -> 陳皮
//Fallopia multiflora -> 何首烏
//Baizhu Slices -> 白朮片
//Hedysarum Root -> 紅耆
//Astragalus membranaceus -> 黃耆
//Licorice -> 甘草
//Ligusticum chuanxiong Hort -> 川芎
//Poria -> 茯苓
//Zedoary Rhizome -> 莪朮

// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Atractylodes_Rhizome_蒼朮.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Astragalus_membranaceus.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Baizhu_Slices_白朮.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Citri_Reticulatae_Pericarpium_陳皮.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dahurian_Angelica_白芷.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Dioscorea_polystachya_Turcz_山藥.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Fallopia_multiflora.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Hedysarum_Root.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Licorice_甘草.jpg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Ligusticum_chuanxiong_Hort_川穹.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Poria_茯苓.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Prepared_Rehmannia_Root_地黃.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Radix_Aucklandiae_木香.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Taiwan_Ficus_牛奶榕.jpeg
// https://raw.githubusercontent.com/Yacolate0519-cmd/Traditional_Medicine_Project_Datasets/main/2/Zedoary_Rhizome_莪朮.jpeg
