# FreeDom — аудит исходного CSS главной страницы (17.11.2026)

## Объект и доказательства
- Страница: `/` (главная).
- Preview: https://freed-6dekucaox-sergeyogorodnik19-3325s-projects.vercel.app/
- Deployment: `dpl_F3z9YMDZBpmdPmjX34sf5FxkYKLR`.
- Commit: `cb930a2a5f8165f599d5b0f49c70cefd356039fd`.
- HTML fetch: HTTP 200.
- Источник анализа: HTML/CSS, полученные с точного Preview.
- Объём документа: 121,296 символов HTML; 33 inline style blocks.
- Режим проверки: source-only. Браузерный рендеринг и screenshots не выполнялись. Поэтому это аудит деклараций CSS, а не утверждение о фактических пиксельных размерах на экране.

## 1. Подтверждённые технологические параметры
- Основные шрифты подключаются из Google Fonts: Cormorant Garamond (400/500/600) и Manrope (400/500/600); есть системные serif/sans-serif fallbacks.
- Базовый цвет текста body в исходном CSS: `#302a24`.
- Базовый цвет заголовка центрального круга в начальном правиле: `#30271f`.
- Основная композиция использует CSS viewport units, `min()`, `clamp()`, абсолютное позиционирование и круговую орбиту.
- Основной breakpoint начального блока: `max-width:760px`; встречаются дополнительные media rules.
- Движение частично учитывает `prefers-reduced-motion: reduce`.

## 2. Обнаруженные декларации размеров
Важно: ниже перечислены значения, найденные в разных CSS-правилах страницы. Это НЕ итоговые computed styles. В документе присутствует длинная цепочка поздних переопределений, поэтому финальное значение нужно получить в браузере через computed styles и скриншот.

| Элемент | Обнаруженные декларации | Комментарий |
|---|---|---|
| Orbit | `min(94vw,820px)`, далее `124vw`, далее `92vw` | Несколько конкурирующих правил размера |
| Центральный круг | `224×224px`, позднее `148×148px`; в mobile-правилах встречается `154×154px` | Требуется computed style на обоих viewport |
| Portal circles | исходно `132×132px`, mobile `94×94px`, позднее mobile `76×76px` | Конфликт размеров mobile |
| Логотип | исходный размер текста 25px, затем 21px, clamp(21px,2vw,27px), затем 20px | Требуется выбрать единое правило |
| Portal label | встречаются 7px, 8.5px, 10px и 11px | Неустойчивая типографическая шкала |
| Hint | встречаются 8px, 9px, 10px | Нужна единая шкала и проверка читаемости |

В коде встречаются разные позиции логотипа: центрирование сверху, затем левое выравнивание с clamp-отступом, затем фиксированные 18px. Это не доказывает дефект в рендере, но делает поддержку и точное описание текущего макета сложнее.

## 3. Системная находка — каскад CSS
33 inline style blocks и повторяющиеся переопределения ключевых селекторов указывают на накопившийся patch-based CSS. Среди повторяющихся групп: `.core`, `.core h1`, `.portal`, `.portal b`, `.orbit`, `.brand-top`, `.hint`, `.direction-showcase`.

Риски:
1. Дизайнеру трудно определить, какое правило является источником истины.
2. Новое локальное исправление может быть перекрыто более поздним правилом.
3. Mobile размеры могут отличаться от ожидаемых по ранним CSS правилам.
4. Нельзя надёжно подготовить окончательную pixel-spec, опираясь только на первые декларации.
5. Дальнейшее накопление style patches повышает риск регрессий.

Это технический долг CSS, но не основание для немедленного большого рефакторинга.

## 4. Решение директора
1. Не добавлять ещё один набор CSS overrides на главную до установления текущих computed styles.
2. Получить реальные screenshots главной на 390×844 и 1440×900 (дополнительно 768×1024).
3. В браузере снять computed styles для `.brand-top`, `.orbit`, `.core`, `.portal`, `.portal b`, `.hint`, `.direction-showcase` в закрытом и открытом состоянии.
4. Сопоставить computed styles со скриншотами и утвердить единую спецификацию.
5. После этого подготовить отдельную задачу по консолидации CSS — только если она безопасна, узка и может быть проверена визуально.
6. Не менять текущую визуальную композицию до согласования с владельцем.

## 5. Черновая база для будущей спецификации
- Typeface families: Cormorant Garamond / Manrope.
- Body text declaration: `#302a24`.
- Core title initial declaration: `#30271f`.
- Main mobile breakpoint declaration: 760px.
- Orbit/core/portal sizes: NOT FINAL — конфликтующие декларации.
- Final palette tokens: NOT MEASURED.
- Final spacing scale: NOT MEASURED.
- Actual contrast ratios: NOT MEASURED.
- Visual result at 390×844 / 768×1024 / 1440×900: NOT OBSERVED.

## 6. Acceptance criteria for designer's next task
- Provide screenshots from the exact deployment and SHA.
- Record computed values, not only source declarations.
- Distinguish measured values from proposed redesign values.
- Describe open/closed orbit states separately.
- Include text wrap, contrast, hit-target and safe-area behavior.
- Do not mark visual audit PASS until browser evidence exists.
