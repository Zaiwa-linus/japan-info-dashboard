<script>
    /**
     * TileMap の派生コンポーネント。
     * 値が正なら青系、負なら赤系でタイルの枠線を着色する。
     * 0 を中心とした発散カラースケールを使用。
     */

    /** @type {any[]} data - area_code, area_name, value を含むクエリ結果 */
    export let data = [];

    /** @type {string} selected - ハイライトする都道府県名 */
    export let selected = '';

    /** @type {string} fmt - 数値フォーマット: 'num0' (整数) or 'num1' (小数1桁)。デフォルト 'num1' */
    export let fmt = 'num1';

    /** @type {string} areaCodeCol - area_code カラム名 */
    export let areaCodeCol = 'area_code';

    /** @type {string} areaNameCol - area_name カラム名 */
    export let areaNameCol = 'area_name';

    /** @type {string} valueCol - value カラム名 */
    export let valueCol = 'value';

    // グリッド配置定義 (area_code -> [row, col])
    const POSITIONS = {
        '01000': [1, 12],
        '02000': [3, 12], '03000': [4, 12], '04000': [5, 12], '05000': [4, 11],
        '06000': [5, 11], '07000': [6, 12], '08000': [7, 13], '09000': [7, 12],
        '10000': [7, 11], '11000': [8, 12], '12000': [8, 13], '13000': [9, 12],
        '14000': [10, 12], '15000': [6, 10], '16000': [6, 9],  '17000': [6, 8],
        '18000': [6, 7],  '19000': [8, 11], '20000': [7, 10], '21000': [7, 9],
        '22000': [9, 11], '23000': [8, 10], '24000': [8, 9],  '25000': [7, 8],
        '26000': [7, 7],  '27000': [8, 7],  '28000': [7, 6],  '29000': [8, 8],
        '30000': [9, 8],  '31000': [6, 5],  '32000': [6, 4],  '33000': [7, 5],
        '34000': [7, 4],  '35000': [6, 3],  '36000': [9, 6],  '37000': [9, 5],
        '38000': [9, 4],  '39000': [10, 5], '40000': [7, 3],  '41000': [7, 2],
        '42000': [7, 1],  '43000': [8, 2],  '44000': [8, 3],  '45000': [9, 3],
        '46000': [9, 2],  '47000': [9, 1],
    };

    function shortName(name) {
        if (!name) return '';
        if (name === '北海道') return '北海道';
        const last = name.slice(-1);
        if (['都', '府', '県'].includes(last)) return name.slice(0, -1);
        return name;
    }

    function formatValue(val) {
        if (val == null) return '-';
        const n = Number(val);
        if (fmt === 'num0') {
            const abs = Math.abs(n);
            if (abs >= 1_000_000) return (n / 1_000_000).toFixed(1) + 'M';
            if (abs >= 10_000) return Math.round(n / 1_000) + 'K';
            if (abs >= 1_000) return (n / 1_000).toFixed(1) + 'K';
            return Math.round(n).toLocaleString();
        }
        return n.toFixed(1);
    }

    $: dataMap = new Map(data.map(d => [d[areaCodeCol], d]));

    // 正負それぞれの最大値を別々に求める
    $: values = data.filter(d => d[valueCol] != null).map(d => Number(d[valueCol]));
    $: posMax = values.length > 0 ? Math.max(0, ...values.filter(v => v > 0)) : 0;
    $: negMax = values.length > 0 ? Math.max(0, ...values.filter(v => v < 0).map(v => Math.abs(v))) : 0;

    function divergingColor(val) {
        if (val == null) return '#e2e8f0';
        const n = Number(val);
        if (n > 0 && posMax > 0) {
            const intensity = Math.min(n / posMax, 1);
            const r = Math.round(255 - intensity * (255 - 59));
            const g = Math.round(255 - intensity * (255 - 130));
            const b = Math.round(255 - intensity * (255 - 246));
            return `rgb(${r}, ${g}, ${b})`;
        } else if (n < 0 && negMax > 0) {
            const intensity = Math.min(Math.abs(n) / negMax, 1);
            const r = Math.round(255 - intensity * (255 - 239));
            const g = Math.round(255 - intensity * (255 - 68));
            const b = Math.round(255 - intensity * (255 - 68));
            return `rgb(${r}, ${g}, ${b})`;
        }
        return '#e2e8f0';
    }

    $: tiles = Object.entries(POSITIONS).map(([code, [row, col]]) => {
        const d = dataMap.get(code);
        return {
            code,
            row,
            col,
            name: d ? shortName(d[areaNameCol]) : code,
            fullName: d?.[areaNameCol] ?? '',
            value: d?.[valueCol] ?? null,
            isSelected: d?.[areaNameCol] === selected,
        };
    });
</script>

<div class="diverging-tile-map">
    {#each tiles as tile}
        <div
            class="tile{tile.isSelected ? ' tile-selected' : ''}"
            style="grid-row: {tile.row}; grid-column: {tile.col}; border-color: {divergingColor(tile.value)}; border-width: {tile.isSelected ? '2.5px' : '1.5px'};"
        >
            <span class="tile-name">{tile.name}</span>
            <span class="tile-value">{formatValue(tile.value)}</span>
            <div class="tooltip">{tile.fullName}: {tile.value != null ? Math.round(Number(tile.value)).toLocaleString() : '-'}</div>
        </div>
    {/each}
</div>

<style>
    .diverging-tile-map {
        display: grid;
        grid-template-columns: repeat(13, minmax(40px, 52px));
        gap: 3px;
        justify-content: center;
        margin: 1rem auto;
    }
    .tile {
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        padding: 4px 6px;
        display: flex;
        flex-direction: column;
        align-items: center;
        min-height: 44px;
        position: relative;
        cursor: pointer;
    }
    .tile:hover {
        z-index: 10;
    }
    .tooltip {
        display: none;
        position: absolute;
        bottom: calc(100% + 6px);
        left: 50%;
        transform: translateX(-50%);
        background: #1e293b;
        color: #fff;
        font-size: 0.7rem;
        padding: 4px 8px;
        border-radius: 4px;
        white-space: nowrap;
        pointer-events: none;
        box-shadow: 0 2px 6px rgba(0,0,0,0.2);
    }
    .tile:hover .tooltip {
        display: block;
    }
    .tile-selected {
        box-shadow: 0 0 0 1.5px #1e40af;
    }
    .tile-name {
        font-size: 0.55rem;
        opacity: 0.7;
        align-self: flex-start;
        line-height: 1;
    }
    .tile-value {
        font-size: 0.75rem;
        font-weight: 600;
        margin-top: auto;
        margin-bottom: auto;
    }
</style>
