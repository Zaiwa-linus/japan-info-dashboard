<script>
    /** @type {string} title - カードのタイトル */
    export let title = '';

    /** @type {string} emoji - タイトルの前に表示する絵文字（オプション） */
    export let emoji = '';

    /** @type {number|string|null} value - 表示する数値 */
    export let value = null;

    /** @type {string} fmt - 数値フォーマット: 'num0' (整数カンマ区切り), 'num1' (小数1桁), 'num2' (小数2桁)。デフォルト 'num0' */
    export let fmt = 'num0';

    function formatValue(val) {
        if (val == null) return '-';
        const n = Number(val);
        if (fmt === 'num0') return Math.round(n).toLocaleString();
        if (fmt === 'num1') return n.toLocaleString(undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 });
        if (fmt === 'num2') return n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return String(val);
    }
</script>

<div class="card">
    <span class="stat-title">{#if emoji}<span class="stat-emoji">{emoji}</span>{/if}{title}</span>
    <span class="stat-value">{formatValue(value)}</span>
</div>

<style>
    .card {
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 12px;
        padding: 1.25rem 1.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
    }
    .stat-title {
        font-size: 0.75rem;
        color: #64748b;
        line-height: 1.2;
    }
    .stat-emoji {
        margin-right: 0.25rem;
    }
    .stat-value {
        font-size: 1.5rem;
        font-weight: 700;
        line-height: 1.2;
        padding-left: 0.75rem;
    }
</style>
