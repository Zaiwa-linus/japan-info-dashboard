<script>
    /** @type {string} title - カードのタイトル */
    export let title = '';

    /** @type {string} emoji - タイトルの前に表示する絵文字（オプション） */
    export let emoji = '';

    /** @type {number|string|null} value - 表示する数値 */
    export let value = null;

    /** @type {string} fmt - 数値フォーマット: 'num0' (整数カンマ区切り), 'num1' (小数1桁), 'num2' (小数2桁)。デフォルト 'num0' */
    export let fmt = 'num0';

    /** @type {number|string|null} comparison - 変動値（オプション） */
    export let comparison = null;

    /** @type {string} comparisonTitle - 変動値ラベル（オプション） */
    export let comparisonTitle = '';

    /** @type {string} link - 遷移先パス（オプション） */
    export let link = '';

    function formatValue(val) {
        if (val == null) return '-';
        const n = Number(val);
        if (fmt === 'num0') return Math.round(n).toLocaleString();
        if (fmt === 'num1') return n.toLocaleString(undefined, { minimumFractionDigits: 1, maximumFractionDigits: 1 });
        if (fmt === 'num2') return n.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        return String(val);
    }

    $: comparisonNum = comparison != null ? Number(comparison) : null;
    $: isPositive = comparisonNum != null && comparisonNum > 0;
    $: isNegative = comparisonNum != null && comparisonNum < 0;
</script>

{#if link}
<a href={link} class="card-link">
    <div class="card">
        <span class="stat-title">{#if emoji}<span class="stat-emoji">{emoji}</span>{/if}{title}</span>
        <span class="stat-value">{formatValue(value)}</span>
        {#if comparison != null}
            <span class="stat-comparison" class:positive={isPositive} class:negative={isNegative}>
                {#if comparisonTitle}<span class="comparison-label">{comparisonTitle}:</span>{/if}
                {isPositive ? '+' : ''}{formatValue(comparison)}
            </span>
        {/if}
    </div>
</a>
{:else}
<div class="card">
    <span class="stat-title">{#if emoji}<span class="stat-emoji">{emoji}</span>{/if}{title}</span>
    <span class="stat-value">{formatValue(value)}</span>
    {#if comparison != null}
        <span class="stat-comparison" class:positive={isPositive} class:negative={isNegative}>
            {#if comparisonTitle}<span class="comparison-label">{comparisonTitle}:</span>{/if}
            {isPositive ? '+' : ''}{formatValue(comparison)}
        </span>
    {/if}
</div>
{/if}

<style>
    .card-link {
        text-decoration: none;
        color: inherit;
        display: block;
    }
    .card {
        background: transparent;
        border: 1px solid #cbd5e1;
        border-radius: 12px;
        padding: 1.25rem 1.5rem;
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        transition: border-color 0.2s;
    }
    .card-link:hover .card,
    .card-link:focus .card {
        border-color: #3b82f6;
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
    .stat-comparison {
        font-size: 0.75rem;
        padding-left: 0.75rem;
        color: #64748b;
    }
    .comparison-label {
        margin-right: 0.25rem;
    }
    .stat-comparison.positive {
        color: #16a34a;
    }
    .stat-comparison.negative {
        color: #dc2626;
    }
</style>
