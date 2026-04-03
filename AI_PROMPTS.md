# 修仙纪 AI 素材生成指南

本文档提供所有需要 AI 生成的素材的详细提示词，可用于 DALL-E、Midjourney、通义万相、Stable Diffusion 等工具。

---

## 一、丹药图标（5个，64x64 PNG）

所有丹药图标风格要求：
- 圆形/胶囊形丹药，古代丹药风格
- 玉石/瓷器容器感
- 干净背景，游戏资产感
- 统一视觉风格，带元素对应颜色光效

### 1.1 回血丹 (health_pill.png)
**颜色**：红色主调
**提示词**：
```
A round red pill elixir icon, ancient Chinese medicine style, glowing red aura,
jade container with red gem inlay, floating on clean dark background,
64x64 pixel art style, high contrast, RPG game asset, subtle shine
```

### 1.2 攻击丹 (attack_buff.png)
**颜色**：蓝色主调
**提示词**：
```
A round blue pill elixir icon, ancient Chinese medicine style, crackling blue lightning aura,
jade container with blue crystal, floating on clean dark background,
64x64 pixel art style, high contrast, RPG game asset, energy effect
```

### 1.3 防御丹 (defense_buff.png)
**颜色**：绿色主调
**提示词**：
```
A round green pill elixir icon, ancient Chinese medicine style, swirling green wind aura,
jade container with green jade inlay, floating on clean dark background,
64x64 pixel art style, high contrast, RPG game asset, protective shield shimmer
```

### 1.4 瞬移丹 (teleport_pill.png)
**颜色**：紫色主调
**提示词**：
```
A round purple pill elixir icon, ancient Chinese medicine style, swirling purple mist and space distortion,
jade container with purple amethyst, floating on clean dark background,
64x64 pixel art style, high contrast, RPG game asset, teleportation effect
```

### 1.5 解谜丹 (puzzle_unlock.png)
**颜色**：金色主调
**提示词**：
```
A round golden pill elixir icon, ancient Chinese medicine style, glowing golden light rays,
jade container with gold ornaments, floating on clean dark background,
64x64 pixel art style, high contrast, RPG game asset, mystical unlock aura
```

---

## 二、角色精灵 Spritesheet

### 2.1 玩家角色 spritesheet 规格
- **尺寸**：每帧 32x48 像素
- **布局**：水平排列的 spritesheet
- **动作**：待机(1帧) → 跑步(4帧) → 跳跃(2帧) → 掉落(2帧) → 冲刺(2帧) → 飞行(2帧)
- **风格**：东方修仙风格人形角色，宽袖道袍

### 2.2 玩家待机帧 (idle.png)
**提示词**：
```
2D game sprite, Chinese cultivator character, standing idle pose, flowing white daoist robes,
long black hair, serene expression, front view, clean pixel art style,
32x48 pixels, transparent background, RPG character sprite
```

### 2.3 玩家跑步 spritesheet (run.png)
**提示词**：
```
2D game sprite sheet, Chinese cultivator character, running animation sequence (4 frames),
flowing white daoist robes with motion blur, dynamic running pose,
side view, clean pixel art style, horizontal strip, 128x48 total size,
transparent background, RPG character sprite
```

### 2.4 玩家跳跃帧 (jump.png)
**提示词**：
```
2D game sprite, Chinese cultivator character, jumping pose, robes flowing upward,
both arms slightly raised, ascending motion, side view, clean pixel art style,
32x48 pixels, transparent background, RPG character sprite
```

### 2.5 玩家掉落帧 (fall.png)
**提示词**：
```
2D game sprite, Chinese cultivator character, falling pose, robes floating upward,
slight panic expression, descending motion, side view, clean pixel art style,
32x48 pixels, transparent background, RPG character sprite
```

### 2.6 玩家冲刺帧 (dash.png)
**提示词**：
```
2D game sprite, Chinese cultivator character, dashing forward with speed lines,
white blur trail effect behind, leaning forward pose, side view,
clean pixel art style, 48x32 pixels, transparent background, RPG character sprite
```

### 2.7 玩家飞行帧 (fly.png)
**提示词**：
```
2D game sprite, Chinese cultivator character, hovering in mid-air cross-legged,
subtle floating particles, serene expression, slight glow underneath,
clean pixel art style, 32x48 pixels, transparent background, RPG character sprite
```

---

## 三、境界图标（10个，128x128 PNG）

每个境界一个独特图标，风格统一但复杂度递增。

### 境界列表
1. 炼气 (Lianqi)
2. 筑基 (Zhuji)
3. 金丹 (Jindan)
4. 元婴 (Yuanying)
5. 化神 (Huashen)
6. 炼虚 (Lianxu)
7. 合体 (Heti)
8. 大乘 (Dacheng)
9. 渡劫 (Dujie)
10. 飞升 (Feisheng)

### 境界图标提示词模板
```
2D game icon, [境界名] realm symbol, Chinese cultivation theme,
floating golden [元素] core/medallion, ancient Chinese mystical style,
glowing with spiritual energy, on dark background,
128x128 pixels, clean pixel art style, RPG game asset, detailed
```

### 替换建议
| 境界 | 核心元素 | 颜色 |
|------|----------|------|
| 炼气 | 小气旋 | 浅蓝 |
| 筑基 | 固体丹 | 白 |
| 金丹 | 金色丹 | 金 |
| 元婴 | 小人婴 | 彩色 |
| 化神 | 羽翼 | 虹彩 |
| 炼虚 | 虚空门 | 紫黑 |
| 合体 | 阴阳鱼 | 黑白 |
| 大乘 | 巨佛法相 | 金紫 |
| 渡劫 | 雷云 | 银电 |
| 飞升 | 飞升光环 | 金白 |

---

## 四、Boss 精灵（6个，spritesheet）

每个 Boss 需要：攻击(3帧) + 待机(2帧) + 受击(2帧) + 特殊(3帧)

### 4.1 Boss1 山岳守护者 (Mountain Guardian)
**提示词**：
```
2D boss sprite sheet, Mountain Guardian - giant stone golem boss,
massive rock body with glowing blue crystal eyes, ancient mountain spirit,
angry expression, attack animation frames, stone crumbling effects,
horizontal spritesheet, clean pixel art, dark fantasy RPG style, detailed
```

### 4.2 Boss2 骨魔 (Bone Demon)
**提示词**：
```
2D boss sprite sheet, Bone Demon - skeletal demon lord,
skeleton with flowing black robes, glowing red eyes, skeletal hands with claws,
floating bones around, attack animation frames, dark aura,
horizontal spritesheet, clean pixel art, dark fantasy RPG style, detailed
```

### 4.3 Boss3 火麒麟 (Fire Qilin)
**提示词**：
```
2D boss sprite sheet, Fire Qilin - mythical fire beast,
deer-like body covered in flames, lion mane, hooves of fire,
golden scales, breathing fire attack animation, majestic pose,
horizontal spritesheet, clean pixel art, Chinese mythology RPG style, detailed
```

### 4.4 Boss4 雷鹏 (Thunder Roc)
**提示词**：
```
2D boss sprite sheet, Thunder Roc - giant thunder bird,
massive wings with lightning bolts, golden feathers, electric sparks,
flying attack animation with thunderclap, wings spread pose,
horizontal spritesheet, clean pixel art, Chinese mythology RPG style, detailed
```

### 4.5 Boss5 古剑灵 (Ancient Sword Spirit)
**提示词**：
```
2D boss sprite sheet, Ancient Sword Spirit - giant floating spirit sword,
enormous ancient Chinese broadsword with ghostly blue flame blade,
sentient sword with carved face, slash attack animation frames,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG style, detailed
```

### 4.6 Boss6 飞升试炼 (Ascension Trial)
**提示词**：
```
2D boss sprite sheet, Ascension Trial - manifestation of heavenly tribulation,
giant glowing humanoid made of golden lightning and cosmic energy,
multiple arms forming seals, all 9 realms energy swirling around,
special attack with realm symbols appearing, horizontal spritesheet,
clean pixel art, Chinese cultivation RPG style, epic detailed
```

---

## 五、召唤兽精灵（9种，spritesheet）

每种召唤兽需要：待机(2帧) + 跟随(4帧) + 技能(3帧)

### 5.1 剑灵 (Sword Spirit)
**提示词**：
```
2D summon sprite sheet, Sword Spirit - small ethereal sword companion,
tiny humanoid made of condensed sword energy, silver-blue glow,
floating pose, following animation, sword slash attack,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, cute but fierce
```

### 5.2 灵草 (Spirit Grass)
**提示词**：
```
2D summon sprite sheet, Spirit Grass - sentient spiritual plant,
cute green sprout with tiny face, leaves waving, healing aura,
floating above ground, following animation, healing sparkles effect,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, adorable
```

### 5.3 冰凤 (Ice Phoenix)
**提示词**：
```
2D summon sprite sheet, Ice Phoenix - elegant ice bird,
crystalline ice feathers, frost trail, cold mist surrounding,
flying following animation, ice shard attack with freeze effect,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, majestic
```

### 5.4 火鸦 (Fire Crow)
**提示词**：
```
2D summon sprite sheet, Fire Crow - flame wreathed crow,
black feathers with fire edges, flames trailing, smoke wisps,
flying following animation, fire peck attack with burn effect,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, aggressive
```

### 5.5 石魔 (Stone Golem)
**提示词**：
```
2D summon sprite sheet, Stone Golem - earth elemental companion,
chunky stone body with glowing core, moss and vines,
heavy stomping following animation, ground pound attack with taunt effect,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, sturdy
```

### 5.6 影魔 (Shadow Demon)
**提示词**：
```
2D summon sprite sheet, Shadow Demon - shadow assassin spirit,
wavy dark purple ghost body, glowing yellow eyes, smoke effects,
phasing following animation, shadow strike attack with mark effect,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, sneaky
```

### 5.7 太阳神 (Sun God)
**提示词**：
```
2D summon sprite sheet, Sun God - radiant solar spirit,
golden humanoid made of sunlight,，光芒四射, warm glow,
floating following animation, healing light attack with radiance buff,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, divine
```

### 5.8 阴阳兽 (Yin Yang Beast)
**提示词**：
```
2D summon sprite sheet, Yin Yang Beast - balanced dual nature creature,
half black half white wolf/dragon hybrid, swirling yin-yang symbol,
phased following animation, balanced strike with freeze and heal,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, mystical
```

### 5.9 仙兽 (Immortal Beast)
**提示词**：
```
2D summon sprite sheet, Immortal Beast - ultimate cultivation beast,
majestic multi-colored celestial creature, all elements combined,
glowing aura of five elements, epic following animation,
multi-element breath attack with freeze/burn/shadow/taunt/heal all at once,
horizontal spritesheet, clean pixel art, Chinese cultivation RPG, legendary
```

---

## 六、关卡背景图（10张）

每张背景需要：16:9 宽屏比例，适合 1280x720 显示

### 背景风格统一要求
```
Ancient Chinese cultivation world, misty mountain landscape,
traditional ink wash painting meets pixel art,
floating islands in background, parallax scrolling layers,
mystical atmosphere, fantasy 2D platformer style
```

### 各关背景提示词

| 关卡 | 境界名 | 场景元素 | 主色调 |
|------|--------|----------|--------|
| Level 1 | 炼气 | 青山绿水、简单竹林 | 翠绿 |
| Level 2 | 筑基 | 古老山洞、矿石 | 褐灰 |
| Level 3 | 金丹 | 金色宫殿、丹炉 | 金红 |
| Level 4 | 元婴 | 云海之上、仙鹤 | 白蓝 |
| Level 5 | 化神 | 樱花树下、古寺 | 粉白 |
| Level 6 | 炼虚 | 星空虚空、陨石 | 深紫 |
| Level 7 | 合体 | 阴阳太极殿 | 黑白 |
| Level 8 | 大乘 | 佛光普照、金莲 | 金紫 |
| Level 9 | 渡劫 | 雷云风暴、天劫 | 银电 |
| Level 10 | 飞升 | 天宫之门、飞升光环 | 金白 |

### 背景提示词模板
```
Ancient Chinese cultivation world background, [境界名] realm stage,
[场景元素描述], [主色调] color scheme dominant,
misty mountains with floating islands, parallax background layers,
traditional Chinese fantasy landscape, 2D side-scrolling platformer,
16:9 aspect ratio, atmospheric depth, detailed
```

---

## 七、UI 元素

### 7.1 血条背景 (health_bar_bg.png)
**尺寸**：200x24 像素
**提示词**：
```
RPG game health bar background frame, ancient Chinese ornate frame design,
dark bronze/gold trim, subtle carved patterns,
empty inner area for health fill, clean pixel art style,
200x24 pixels, transparent center
```

### 7.2 血条填充 (health_bar_fill.png)
**尺寸**：196x16 像素
**提示词**：
```
RPG game health bar fill, gradient red to dark red,
subtle inner glow, clean pixel art style,
196x16 pixels, no frame
```

### 7.3 丹药 Hotbar 格子背景
**尺寸**：48x48 像素
**提示词**：
```
RPG game inventory slot, ancient Chinese wooden frame style,
dark wood grain border, subtle golden trim corners,
empty center for item, clean pixel art style,
48x48 pixels, transparent center
```

---

## 八、地面/平台瓦片

### 8.1 可平铺地面
**尺寸**：64x32 像素（单个瓦片）
**提示词**：
```
2D game tileable ground platform, ancient Chinese stone path,
weathered gray-blue flagstones, moss between stones,
subtle texture detail, seamless horizontal tile,
64x32 pixels, game asset, platformer style
```

### 8.2 草地地面
**尺寸**：64x32 像素
**提示词**：
```
2D game tileable grass platform, lush green grass on dirt base,
small flowers scattered, soft edges, seamless horizontal tile,
64x32 pixels, game asset, platformer style
```

---

## 九、攻击特效

### 9.1 金属性攻击特效
**提示词**：
```
2D game attack effect sprite sheet, metal element slash,
silver-white sword energy wave, sharp cutting particles,
3-frame animation sequence, horizontal strip,
clean pixel art, Chinese cultivation RPG, impactful
```

### 9.2 火属性攻击特效
**提示词**：
```
2D game attack effect sprite sheet, fire element blast,
flame explosion with ember particles, orange to red gradient,
3-frame animation sequence, horizontal strip,
clean pixel art, Chinese cultivation RPG, explosive
```

### 9.3 水属性攻击特效
**提示词**：
```
2D game attack effect sprite sheet, water element attack,
blue water wave/ice shards, crystalline frozen effect,
3-frame animation sequence, horizontal strip,
clean pixel art, Chinese cultivation RPG, flowing
```

### 9.4 木属性攻击特效
**提示词**：
```
2D game attack effect sprite sheet, wood element attack,
green vine whip with leaf particles, nature energy swirl,
3-frame animation sequence, horizontal strip,
clean pixel art, Chinese cultivation RPG, organic
```

### 9.5 土属性攻击特效
**提示词**：
```
2D game attack effect sprite sheet, earth element attack,
rock crumble and ground pound, brown stone debris,
3-frame animation sequence, horizontal strip,
clean pixel art, Chinese cultivation RPG, heavy impact
```

---

## 十、通用设置建议

### DALL-E 设置
- 尺寸：1024x1024（然后缩放到目标尺寸）
- 风格：Vivid / Natural
- 格式：PNG

### Midjourney 设置
- 版本：--v 6
- 宽高比：--ar 1:1（图标）或 --ar 16:9（背景）
- 风格：--style raw
- 质量：--q 2

### Stable Diffusion 设置
- 采样步数：30-40
- CFG Scale：7-9
- 尺寸：512x512 或 768x768
- 负面提示词：blurry, low quality, watermark, text, UI elements

### 缩放建议
AI 生成的图片建议先用 1024x1024 或 16:9 大图，然后用图像编辑工具（如 Photoshop、GIMP）缩放到目标像素尺寸，保持像素艺术风格。
