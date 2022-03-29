# frozen_string_literal: true

module BCDice
  module GameSystem
    class ShuumatsuKikou < Base
      # ゲームシステムの識別子
      ID = 'ShuumatsuKikou'

      # ゲームシステム名
      NAME = '終末紀行ＲＰＧ'

      # ゲームシステム名の読みがな
      SORT_KEY = 'しゆうまつきこう'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~HELP
        ■判定
        xB6>=5
        x: 能力値
        （汎用コマンドそのままです）

        ■各種表
        資源の減少チェック: ResourceLose, RLose
        獲得資源決定: ResourceGain, RGain

        □ランダムエリア決定表
        都市／荒野決定: RandomArea, RArea
        荒野エリア決定: RandomWaste, RWaste
        都市エリア決定: RandomUrban, RUrban

        □ランダム障害シーン決定表
        シーン決定: RandomObs, RObs
        技術系Ａ: RandomObsTechA, ROTA
        技術系Ｂ: RandamObsTechB, ROTB
        生存系Ａ: RandomObsSurviveA, ROSA
        生存系Ｂ: RandomObsSurviveB, ROSB
        戦闘系Ａ: RandomObsCombatA, ROCA
        戦闘系Ｂ: RandomObsCombatB, ROCB

        □ランダム旅情シーン決定表
        シーン決定: RandomEmo, REmo
        日常系Ａ: RandomEmoDailyA, REDA
        日常系Ｂ: RandomEmoDailyB, REDB
        日常系Ｃ: RandomEmoDailyC, REDC
        追憶系Ａ: RandomEmoReminiscenceA, RERA
        追憶系Ｂ: RandomEmoReminiscenceB, RERB
        追憶系Ｃ: RandomEmoReminiscenceC, RERC

        □ランダム難所シーン決定表
        荒野系: RandomDangerousWaste, RDW
        都市系: RandomDangerousUrban, RDU
      HELP

      def eval_game_system_specific_command(command)
        roll_tables(ALIAS[command] || command, TABLES)
      end

      # ５要素のテーブル.
      # 1D6 を [1..2, 3, 4, 5, 6] の５通りに割り振る.
      class FiveItemsTable < DiceTable::RangeTable
        def initialize(name, item1, item2, item3, item4, item5)
          super(
            name,
            "1D6",
            [
              [1..2, item1],
              [3, item2],
              [4, item3],
              [5, item4],
              [6, item5],
            ]
          )
        end
      end

      TABLES = {
        "ResourceLose" => DiceTable::Table.new(
          "資源の減少チェック",
          "1D6",
          [
            "〈食料〉",
            "〈健康〉",
            "〈電力〉",
            "〈パーツ〉",
            "〈ヴィークル〉",
            "［資源の減少チェック］をもう１回行なう。その際、減少する資源は１ではなく２となる。",
          ]
        ),
        "ResourceGain" => DiceTable::Table.new(
          "獲得資源決定",
          "1D6",
          [
            "〈食料〉",
            "〈健康〉",
            "〈電力〉",
            "〈パーツ〉",
            "〈ヴィークル〉",
            "任意、好きな資源を手に入れる。",
          ]
        ),
        "RandomArea" => DiceTable::RangeTable.new(
          "都市／荒野決定",
          "1D6",
          [
            [1..3, "荒野エリア決定表へ（ → RWaste ）"],
            [4..6, "都市エリア決定表へ（ → RUrban ）"],
          ]
        ),
        "RandomWaste" => FiveItemsTable.new(
          "荒野エリア決定",
          "平原――地平線の果てまで続く、茫漠とした荒野。それを貫くように走るハイウェイの痕跡。その沿道に廃墟が点在している。",
          "砂漠――砂漠がどこまでも広がっている。大海に浮かぶ島のように、倒壊した高層ビルが顔を出している。熱と渇きが旅人を苛む。",
          "汚染地帯――土も、水も、空気さえも、汚染物質で満たされた区域。ここでは呼吸すらも死を招く。あまり長居したい土地ではない。",
          "雪原――視界一面を覆う雪の大地。ただそこにいるだけで、身体の熱が奪われていく。生命の活動を許さないモノトーンの世界だ。",
          "山岳――旅人の前にそびえる巨大な山塊。山越えは落石や崩落の危険性など、通過するだけでリスクが高い。だが他に道はない。"
        ),
        "RandomUrban" => FiveItemsTable.new(
          "都市エリア決定",
          "無人都市――かつて栄華を誇ったメトロポリス。だが今、旅人のほかに動いているものはいない。無数のビル群が墓標のようにそびえる。",
          "要塞都市――巨大な城壁と、朽ち果てた無人防衛兵器群によって守られた要塞都市。この都市が守ろうとした住人はもういない。",
          "地下都市――放棄された広大な地下シェルター。光の届かない暗黒の地下空間。ある時期の人類は、地下に生活拠点を移していたようだ。",
          "密林都市――この都市の廃墟は、繁茂したミュータント植物の密林に覆われている。そこには異形の生態系が成立している。",
          "水没都市――水没した都市。かつての人類の遺構群が、上昇した海面下に沈んでいる。都市の新たな主は、ミュータント魚群だ。"
        ),
        "RandomObs" => DiceTable::Table.new(
          "障害シーン決定",
          "1D6",
          [
            "技術系Ａ（ → ROTA ）",
            "技術系Ｂ（ → ROTB ）",
            "生存系Ａ（ → ROSA ）",
            "生存系Ｂ（ → ROSB ）",
            "戦闘系Ａ（ → ROCA ）",
            "戦闘系Ｂ（ → ROCB ）",
          ]
        ),
        "RandomObsTechA" => FiveItemsTable.new(
          "ランダム障害シーン／技術系Ａ",
          "電子ロック――電子ロックが生きている倉庫を発見。ロックを開けて中の資源を回収する。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］１回。",
          "発電機の再生――停止した風力発電機（風車）を発見。発電効率は低いが、復旧させればロボットのバッテリーを充電できる。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈電力〉－１。",
          "オーバーホール――ヴィークルが不調だ。一度しっかり分解整備（オーバーホール）しなければ。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈ヴィークル〉－１。",
          "リフォーム――居心地の良さそうな住居跡を発見。ちょっとリフォームすれば、快適な休息を取れる。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈健康〉－１。",
          "ロボット工場――ロボット工場跡を発見。残された部品をうまく加工すれば、劣化したパーツを交換できる。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈パーツ〉－１。"
        ),
        "RandomObsTechB" => FiveItemsTable.new(
          "ランダム障害シーン／技術系Ｂ",
          "悪路走破――ヴィークルで悪路を走る。スピードを落とさず走り抜ければ、時間的消耗を抑えることができる。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］を１回行なう。",
          "食料生産プラント――食料生産プラント跡を発見。うまく復旧すれば、最後に残った材料で食料を生産できる。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈食料〉－１。",
          "パーツ交換――ロボットのパーツが劣化、破損する。予備パーツはあるが、自力では交換が難しい。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈パーツ〉－１。",
          "バッテリー回収――ドローンの残骸を発見。うまく解体すれば、バッテリーを回収できそうだ。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈電力〉－１。",
          "ロボットの行商人――ロボットの行商人と出会う。彼は旅人たち(「数十年ぶりの客」らしい)に取り引きを持ちかけてくる。行商人の提示する品物の質を見極めろ。【技術】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０ならボッタくられ、［資源の減少チェック］を１回行なう。"
        ),
        "RandomObsSurviveA" => FiveItemsTable.new(
          "ランダム障害シーン／生存系Ａ",
          "迷い路――入り組んだ地域を進む。方向感覚を失えば、さらなる消耗を強いられる。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら道に迷い、［資源の減少チェック］を１回行なう。",
          "危険地帯――ガスや汚染物質に満ちた危険地帯を通過する。ロボットはともかく、人間は長居できない。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら人間は負傷し〈健康〉－１。",
          "カビ――ロボットにミュータントのカビが生える。このカビは特定の貴金属を好む。すぐに除去しなければ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈パーツ〉－１。",
          "水不足――水不足が深刻化し始める。一刻も早く水源を探して、補充しなければ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈食料〉－１。",
          "崩壊寸前――崩れかかった遺跡から、資源を回収する。時間をかければ崩落に巻き込まれる。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］を１回行なう。"
        ),
        "RandomObsSurviveB" => FiveItemsTable.new(
          "ランダム障害シーン／生存系Ｂ",
          "隠れんぼ――狂暴なミュータントの群を発見。隠れてやりすごせ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］を１回行なう。",
          "ソーラーパネル掃除――ソーラーパネルを繁茂したミュータント植物が覆っている。植物を刈り取ってパネルを復旧し、電力を得よう。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈電力〉－１。",
          "スタック――泥や砂地にハマって、ヴィークルがスタックする。力づくで引きずり出せ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈ヴィークル〉－１。",
          "体調不良――汚染物質を吸引したか、毒に当たったか、体調が急変する。うまく療養(看病)せよ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈健康〉－１。",
          "保存食の加工――食料の確保。小型の可食ミュータントを捕獲した。うまく保存用に加工せよ。【生存】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈食料〉－１。"
        ),
        "RandomObsCombatA" => FiveItemsTable.new(
          "ランダム障害シーン／戦闘系Ａ",
          "大群との遭遇――狂暴なミュータントの群の襲撃を受ける。激しい戦闘で消耗戦となる。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］を１回行なう。",
          "地獄の毒々ミュータント――猛毒を持つ狂暴なミュータントが襲ってくる。うまく毒を避けて倒さなければ。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈健康〉－１。",
          "暴走ドローン――暴走ドローンを発見。ロボットと共通のパーツを使っているようだ。うまく破壊すればパーツを回収できる。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈パーツ〉－１。",
          "生体発電機――発電器官を有するミュータントに遭遇。発電器官を潰さずにしとめれば、電池代わりになるかもしれない。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈電力〉－１。",
          "高速戦闘――ヴィークル型の高速ドローンが襲ってくる。ヴィークルを破壊して部品を奪うつもりのようだ。返り討ちにして逆に部品を奪え。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈ヴィークル〉を1失う。"
        ),
        "RandomObsCombatB" => FiveItemsTable.new(
          "ランダム障害シーン／戦闘系Ｂ",
          "瓦礫撤去――巨大な瓦礫が進路を塞いでいる。破壊して通らなければ、遠回りを強いられ消耗する。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら［資源の減少チェック］を１回行なう。",
          "溶解ミュータント――金属や樹脂を溶かすミュータントに遭遇。執拗にロボットを狙ってくる。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈パーツ〉－１。",
          "電気食らい――電気を食う蟲型ドローンが寄ってくる。ロボットの体内にある電池は、彼らの食糧だ。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈電力〉－１。",
          "殺人機械――暴走ドローンが襲ってくる。対人殺傷用らしく、人間だけを執拗に狙ってくる。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈健康〉－１。",
          "ごちそうミュータント――大型の可食ミュータントに遭遇。貴重な食糧だ、可食部位を傷つけずに倒そう。【戦闘】の協力判定を行なう。成功数３以上なら［リワード］を１得る。成功数０なら〈食料〉－１。"
        ),
        "RandomEmo" => DiceTable::Table.new(
          "旅情シーン決定",
          "1D6",
          [
            "日常系Ａ（ → REDA ）",
            "日常系Ｂ（ → REDB ）",
            "日常系Ｃ（ → REDC ）",
            "追憶系Ａ（ → RERA ）",
            "追憶系Ｂ（ → RERB ）",
            "追憶系Ｃ（ → RERC ）",
          ]
        ),
        "RandomEmoDailyA" => FiveItemsTable.new(
          "ランダム旅情シーン／日常系Ａ",
          "野営――ふたりぼっちの夜がくる。熱を失わないよう、火を焚き、寄り添う。",
          "暇つぶし――悪天候などにより、停滞を余儀なくされる。暇だ。とにかく暇だ。",
          "遊ぶ――遊ぶ。かくれんぼでも、しりとりでも、雪合戦でも、なんでもいい。まったく無意味だが、それがいい。",
          "訓練――いつ、どんな危険が襲ってくるか解らない。武器の扱いを訓練しよう。",
          "移動――ヴィークルに揺られて移動する。淡々と、黄昏の景色がゆっくりと流れていく。"
        ),
        "RandomEmoDailyB" => FiveItemsTable.new(
          "ランダム旅情シーン／日常系Ｂ",
          "食事――人間は、ものを食べなければ生きていけない。どうせいつかは死ぬのに、不便なことだ。",
          "観察――もうひとりの旅人を観察する。今まで知らなかった一面が見られるかもしれない。知らない方がよかったかもしれない。",
          "整備――ヴィークルを整備する。こいつも大事な旅の仲間だ。だが、いつかは部品や燃料が尽き、動かなくなるだろう。",
          "星空――星空を見上げる。世界は激変したが、星の光はほとんど変わらない。ちょっと北極星がズレたぐらいだ。",
          "水浴び――水場を発見。水浴びして汚れを落とす。ついでに洗濯も済ませてしまおう。どうせまた汚れるけど。"
        ),
        "RandomEmoDailyC" => FiveItemsTable.new(
          "ランダム旅情シーン／日常系Ｃ",
          "記録――日記でも、写真、スケッチ、なんでもいい。今この瞬間を、形にして残しておきたい。",
          "酒――なんと生きている酒蔵を発見。飲もうぜ、今宵、銀河を杯にして。ロボットが酔えるかは知らん。",
          "歌う――なぜかメロディーが口をついて出る。郷愁を覚える。かつて好きだった歌なのかもしれない。",
          "悪夢――悪夢にうなされ目が覚める。だが目覚めたこの世界が、悪夢よりマシであると言えるだろうか？",
          "ケンカ――ささいなことが原因で仲たがいする。セッション中に仲直りしておけ。理由は「大事なもの」を壊してしまった、などがよいだろう、"
        ),
        "RandomEmoReminiscenceA" => FiveItemsTable.new(
          "ランダム旅情シーン／追憶系Ａ",
          "住居――住居跡を訪れる。ミイラ化した人間の死体を発見する。だいぶ前に死んだものだ。この死体はどう生き、どう死んだのだろう？",
          "届かなかった手紙――郵便ポストを発見する。配達されなかった手紙が残されている。恋文、借金の督促など、往時の人類の日常を垣間見る。",
          "ゆうえんち――娯楽施設跡（遊園地、テーマパーク）を訪れる。システムが生きており、稼働している遊具がある。少し遊んで行こう。きっと旅人は最後の客だ。",
          "終末ショッピング――商業施設跡（ショッピングモールなど）を訪れる。半壊した接客ロボットが現れ、何もない店内を案内する。その後「彼」は機能を停止する。",
          "天国なんてあるのかな――宗教施設跡（墓所や教会など）を訪れる。旅人が死んだら、誰が弔うのか？　天国はあるのか？　ロボットもそこに行けるのか？"
        ),
        "RandomEmoReminiscenceB" => FiveItemsTable.new(
          "ランダム旅情シーン／追憶系Ｂ",
          "人の遺したもの――文化施設跡（博物館、図書館、美術館）を訪れる。人類が築いた文化の残滓を垣間見る。",
          "残骸――旅人のロボットとよく似た、別のロボットの残骸を発見する。このロボットは何のために動き、ここで力尽きたのだろう。",
          "飛ばない鳥――飛行場跡を訪れる。無数の航空機が擱座している。この人工の鳥たちが、ふたたび空を舞うことはないだろう。",
          "湯けむり終末紀行――温泉レジャー施設跡を訪れる。施設は半壊しているが、なんと未だに温泉が湧き続けている。世界が終わっても、温泉は心地よい。",
          "終末学校――学校の跡を訪れる。机とイスが散乱している。人間の子供たちは、ここでさまざまなことを学んだのだろう。"
        ),
        "RandomEmoReminiscenceC" => FiveItemsTable.new(
          "ランダム旅情シーン／追憶系Ｃ",
          "兵どもが夢の跡――戦場跡を通過する。動かなくなった兵器があちこちに散らばっている。彼らは何と、何のために戦ったのだろう？",
          "地下鉄――廃墟の地下鉄。旅人が車両に乗ると、自動制御で勝手に走り出す。次の駅に到着すると、最後まで残っていた電力が尽きる。終電だったらしい。",
          "謎のプラント――巨大なプラント跡を訪れる。爆発でもあったらしく、中心部が半壊している。あちこちにある表示は「ぬーくりあ」「でんじゃー」と読める。",
          "メリークリスマス――廃墟が、電飾や植物を模した模型で飾り立てられている。赤い服を着て袋を持ち、動物のひくソリに乗った老人の人形が置かれている。",
          "せめてよい夢を――完全に停止した冷凍睡眠施設を発見。眠ったまま干からびた人々がいる。旅人もこうなっていたかもしれない。その方が幸せだったかも。"
        ),
        "RandomDangerousWaste" => DiceTable::Table.new(
          "ランダム難所シーン／荒野系",
          "1D6",
          [
            "渡河（ p27 ）",
            "ワイルドレース（ p27 ）",
            "冬来たる（ p27 ）",
            "果てなき熱砂（ p28 ）",
            "鋼鉄の嵐（ p28 ）",
            "殺戮兵器、起動（ p28 ）",
          ]
        ),
        "RandomDangerousUrban" => DiceTable::Table.new(
          "ランダム難所シーン／都市系",
          "1D6",
          [
            "亀裂を超える（ p29 ）",
            "プラント復旧（ p29 ）",
            "地下迷宮（ p29 ）",
            "塔を登る（ p29 ）",
            "自動防衛システム（ p30 ）",
            "地底よりの恐怖（ p30 ）",
          ]
        ),
      }.transform_keys(&:upcase).freeze

      ALIAS = {
        "RLose" => "ResourceLose",
        "RGain" => "ResourceGain",
        "RArea" => "RandomArea",
        "RWaste" => "RandomWaste",
        "RUrban" => "RandomUrban",
        "RObs" => "RandomObs",
        "ROTA" => "RandomObsTechA",
        "ROTB" => "RandomObsTechB",
        "ROSA" => "RandomObsSurviveA",
        "ROSB" => "RandomObsSurviveB",
        "ROCA" => "RandomObsCombatA",
        "ROCB" => "RandomObsCombatB",
        "REmo" => "RandomEmo",
        "REDA" => "RandomEmoDailyA",
        "REDB" => "RandomEmoDailyB",
        "REDC" => "RandomEmoDailyC",
        "RERA" => "RandomEmoReminiscenceA",
        "RERB" => "RandomEmoReminiscenceB",
        "RERC" => "RandomEmoReminiscenceC",
        "RDW" => "RandomDangerousWaste",
        "RDU" => "RandomDangerousUrban",
      }.transform_keys(&:upcase).transform_values(&:upcase).freeze

      register_prefix(TABLES.keys, ALIAS.keys)
    end
  end
end