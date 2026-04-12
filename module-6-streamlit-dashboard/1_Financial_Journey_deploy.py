import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go

from plotly.subplots import make_subplots

from pathlib import Path

# =========================================================
# ---------- Load data from CSV files
# =========================================================

DATA_DIR = Path(__file__).resolve().parent  # deploy/ folder

# Income Statement - annual
df_pl = pd.read_csv(DATA_DIR / "vw_pl_annual.csv")

df_pl = df_pl.rename(columns={
    "year": "Year",
    "revenue": "Revenue",
    "cogs": "COGS",
    "opex": "OPEX",
    "ebitda": "EBITDA",
    "net_income": "Net_Income",
    "Net Margin (%)": "Margin (%)"
})

# Cash Flow - annual
df_cf = pd.read_csv(DATA_DIR / "vw_cf_annual.csv")

df_cf = df_cf.rename(columns={
    "year": "Year",
    "revolving_credit": "Revolving_Credit",
    "cash_end": "Cash_End"
})

# ---------- Financial indicators from CSV
csv_path = DATA_DIR / "ifrs_financial_indicators_T.csv"

df_ind = pd.read_csv(csv_path)

if "Unnamed: 0" in df_ind.columns:
    df_ind = df_ind.drop(columns=["Unnamed: 0"])


df_ind = df_ind.rename(columns={
    "Year": "Year",
    "Net_Debt_EBITDA": "Net_Debt_EBITDA",
    "Interest_Coverage": "Interest_Coverage",
    "ROE (%)": "ROE_pct",
    "ROA (%)": "ROA_pct"
})

df_ind = df_ind[[
    "Year",
    "Net_Debt_EBITDA",
    "Interest_Coverage",
    "ROE_pct",
    "ROA_pct"
]].copy()

# ---------- Ensure numeric types
df_pl["Year"] = pd.to_numeric(df_pl["Year"], errors="coerce")
df_cf["Year"] = pd.to_numeric(df_cf["Year"], errors="coerce")
df_ind["Year"] = pd.to_numeric(df_ind["Year"], errors="coerce")

for col in ["Net_Debt_EBITDA", "Interest_Coverage", "ROE_pct", "ROA_pct"]:
    df_ind[col] = pd.to_numeric(df_ind[col], errors="coerce")

# Extract available years (used in filters)
years = sorted(df_pl["Year"].dropna().astype(int).unique().tolist())


# =========================================================
# ---------- FILTER HELPER ----------
# =========================================================
def filter_by_year(df, year_range):
    return df[
        (df["Year"] >= year_range[0]) &
        (df["Year"] <= year_range[1])
    ].copy()

# =========================================================
# ---------- CONFIG ----------
# =========================================================
st.set_page_config(
    page_title="Digital Finance Dashboard",
    layout="wide"
)

# =========================================================
# ---------- HELPERS ----------
# =========================================================
def format_millions(v):
    if pd.isna(v):
        return "-"
    return f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

def add_highlight(text):
    st.markdown(
        f"<div class='highlight-item'>{text}</div>",
        unsafe_allow_html=True,
    )
def format_percent(v):
    if v is None or pd.isna(v):
        return "-"
    return f"{v*100:.2f}%".replace(".", ",")

# =========================================================
# ---------- GLOBAL + LAYOUT STYLES ----------
# =========================================================
st.markdown("""
<style>

/* ---------- GLOBAL SETTINGS ---------- */
#MainMenu {visibility: hidden;}
footer {visibility: hidden;}
header {visibility: hidden;}

/* padding: TOP  RIGHT  BOTTOM  LEFT */
.block-container {
    padding: 0.35rem 0.8rem 0.5rem 0.8rem !important;
    max-width: 1280px !important;
    margin: 0 auto !important;
}

/* Remove extra spacing above header */
div[data-testid="stVerticalBlock"] > div:has(.header-title) {
    margin-bottom: 0 !important;
}
          
/* ---------- HEADER ---------- */
.header-shell {
    background: #1d2d44;
    height: 40px;
    padding: 0 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
}

.header-title {
    font-size: 18px;
    font-weight: 700;
    color: #e5e5e5;
    letter-spacing: 0.3px;
    line-height: 1.2;
    padding-top: 6px;
}

/* ---------- PANEL TITLES ---------- */
.panel-title {
    background: transparent;
    color: #2f2f2f;
    padding: 0;
    font-size: 15px;
    font-weight: 600;
    margin-bottom: 4px;
}

/* ---------- HIGHLIGHT SECTION ---------- */
.highlight-box {
    border-top: 3px solid #f5a000;
    padding-top: 10px;
    margin-top: 4px;
    background: rgba(255,255,255,0.6);
}

.highlight-bar {
    background: transparent;
    color: #2f2f2f;
    padding: 0 0 8px 0;
    font-size: 15px;
    font-weight: 700;
    border-radius: 0;
}

.highlight-item {
    position: relative;
    padding: 6px 0 6px 26px;
    font-size: 14px;
    color: #2f2f2f;
    line-height: 1.55;
    letter-spacing: 0.1px;
}

.highlight-item::before {
    content: "•";
    position: absolute;
    left: 4px;
    top: 0%;
    color: #f5a000;
    font-size: 20px;
    font-weight: 700;
}

/* ---------- NAV BUTTONS ---------- */
div.stButton > button[kind="secondary"] {
    background-color: #3e5c76;
    color: white;
    border-radius: 6px;
    border: none;
    font-weight: 600;
}

div.stButton > button[kind="secondary"]:hover {
    background-color: #2a4365;
    color: white;
}

/* Active page */
div.stButton > button[kind="primary"] {
    background-color: #f5a000;
    color: black;
    border-radius: 6px;
    border: none;
    font-weight: 700;
}

/* ---------- KPI CARDS ---------- */
.kpi-card {
    background-color: #354f52;
    border-radius: 8px;
    padding: 2px 4px;
}

.kpi-card2 {
    background-color: #52796f;   
    border-radius: 8px;
    padding: 2px 4px;
}

.kpi-title {
    font-size: 12px;
    color: white;
    text-align: center;
    margin-bottom: 1px;
}

.kpi-value {
    font-size: 19px;
    font-weight: 700;
    color: white;
    text-align: center;
}
            
/* ---------- CHART FRAME ---------- */
.chart-card-clean {
    background: #ffffff;
    border: 1px solid #eaeaea;
    border-radius: 8px;
    padding: 10px 10px 4px 10px;
    margin-bottom: 8px;
}

/* ---------- DATAFRAME ---------- */
div[data-testid="stDataFrame"] div[role="table"] {
    font-size: 13px;
}
            
div[data-testid="column"] {
    padding-left: 2px !important;
    padding-right: 2px !important;
}


</style>
""", unsafe_allow_html=True)

# =========================================================
# ---------- HEADER + NAV ----------
# =========================================================
if "page" not in st.session_state:
    st.session_state.page = "Financial Journey"

col_title, col_nav = st.columns([3.1, 2], gap="medium")

# ---------- TITLE ----------
with col_title:
    st.markdown("""
    <div class="header-shell">
        <div class="header-title">Digital Finance, Forecasting &amp; Analytics Platform</div>
    </div>
    """, unsafe_allow_html=True)

# ---------- NAV ----------
with col_nav:
    nav1, nav2, nav3 = st.columns(3)

    with nav1:
        if st.button(
            "Financial Journey",
            use_container_width=True,
            key="nav1",
            type="primary" if st.session_state.page == "Financial Journey" else "secondary"
        ):
            st.session_state.page = "Financial Journey"
            st.rerun()

    with nav2:
        if st.button(
            "Sales",
            use_container_width=True,
            key="nav2",
            type="primary" if st.session_state.page == "Sales" else "secondary"
        ):
            st.session_state.page = "Sales"
            st.rerun()

    with nav3:
        if st.button(
            "Forecasting",
            use_container_width=True,
            key="nav3",
            type="primary" if st.session_state.page == "Forecasting" else "secondary"
        ):
            st.session_state.page = "Forecasting"
            st.rerun()

page = st.session_state.page

# =========================================================
# TAB 1 - FINANCIAL JOURNEY
# =========================================================
if page == "Financial Journey":

    REGIME_RANGES = {
        "Full Period": (2010, 2024),
        "Crisis 2018-2019": (2018, 2019),
        "Recovery": (2020, 2024),
    }

    REGIME_OPTIONS = ["Full Period", "Crisis 2018-2019", "Recovery", "Year Range"]

    def normalize_year_range(value):
        if isinstance(value, tuple) and len(value) == 2:
            return (int(value[0]), int(value[1]))
        if isinstance(value, list) and len(value) == 2:
            return (int(value[0]), int(value[1]))
        if isinstance(value, (int, float)):
            v = int(value)
            return (v, v)
        return (2010, 2024)

    # ---------- Session state ----------
    if "regime" not in st.session_state:
        st.session_state.regime = "Year Range"

    if "year_range" not in st.session_state:
        st.session_state.year_range = (2010, 2024)

# /* ------------------------------ LINE 1  ------------------------------ */
    top_left, top_right = st.columns([1.35, 0.9], gap="small")

# /* ---------- LINE 1 - RIGHT / FIlTERS---------- */
    with top_right:
        filter_right, filter_left = st.columns([1.0, 1.6], gap="small")

        # ---------- Dropdown ----------
        with filter_right:
            selected_regime = st.selectbox(
                "Economic Regime",
                REGIME_OPTIONS,
                index=REGIME_OPTIONS.index(st.session_state.regime)
            )

            if selected_regime != st.session_state.regime:
                st.session_state.regime = selected_regime

                if selected_regime in REGIME_RANGES:
                    st.session_state.year_range = REGIME_RANGES[selected_regime]

                st.rerun()

        # ---------- Slider ----------
        with filter_left:
            current_range = normalize_year_range(st.session_state.year_range)
            is_custom_range = (st.session_state.regime == "Year Range")

            selected_range = st.select_slider(
                "Year Range",
                options=years,
                value=current_range,
                disabled=not is_custom_range
            )

            selected_range = normalize_year_range(selected_range)

            if is_custom_range and selected_range != st.session_state.year_range:
                st.session_state.year_range = selected_range

                matched_regime = "Year Range"
                for regime_name, regime_range in REGIME_RANGES.items():
                    if regime_range == selected_range:
                        matched_regime = regime_name
                        break

                st.session_state.regime = matched_regime
                st.rerun()

    # ---------- Final values used in filtering ----------
    year_range = normalize_year_range(st.session_state.year_range)
    regime = st.session_state.regime

    filtered_pl = filter_by_year(df_pl, year_range)
    filtered_cf = filter_by_year(df_cf, year_range)
    filtered_ind = filter_by_year(df_ind, year_range)

# ------------------------------ Measures ------------------------------
    if filtered_pl.empty:
        avg_revenue = 0
        avg_ebitda = 0
        avg_net_income = 0

        revenue_cagr = None
        total_ebitda = 0
        total_net_income = 0

    else:
        avg_revenue = filtered_pl["Revenue"].mean()
        avg_ebitda = filtered_pl["EBITDA"].mean()
        avg_net_income = filtered_pl["Net_Income"].mean()

        df_sorted = filtered_pl.sort_values("Year")
        first_year = df_sorted["Year"].iloc[0]
        last_year = df_sorted["Year"].iloc[-1]
        first_revenue = df_sorted["Revenue"].iloc[0]
        last_revenue = df_sorted["Revenue"].iloc[-1]
        first_ebitda = df_sorted["EBITDA"].iloc[0]
        last_ebitda = df_sorted["EBITDA"].iloc[-1]
        first_net_income = df_sorted["Net_Income"].iloc[0]
        last_net_income = df_sorted["Net_Income"].iloc[-1]
        n_years = last_year - first_year

        # CAGR Revenue
        if n_years > 0 and first_revenue > 0:
            revenue_cagr = (last_revenue / first_revenue) ** (1 / n_years) - 1
        else:
            revenue_cagr = None

        # Margins
        if not filtered_pl.empty:

            ebitda_margin_avg = (filtered_pl["EBITDA"] / filtered_pl["Revenue"]).mean()
            net_margin_avg = (filtered_pl["Net_Income"] / filtered_pl["Revenue"]).mean()

        else:
            ebitda_margin_avg = None
            net_margin_avg = None

    
    # ---------- Filter Empty ----------

    if filtered_pl.empty:
        st.warning("No data available for the selected filters.")

    else:

    # ---------- LINE 1 - RIGHT / KPI CARDS ----------
        
        with top_right:
            
            kpi1, kpi2, kpi3 = st.columns(3, gap="small")

            with kpi1:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Avg Revenue</div>
                        <div class="kpi-value">{format_millions(avg_revenue)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi2:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Avg EBITDA</div>
                        <div class="kpi-value">{format_millions(avg_ebitda)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi3:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Avg Net Income</div>
                        <div class="kpi-value">{format_millions(avg_net_income)}</div>
                    </div>
                """, unsafe_allow_html=True)
            st.markdown("<div style='height:0px;'></div>", unsafe_allow_html=True)

           # KPI Second Line
            kpi4, kpi5, kpi6 = st.columns(3, gap="small")

            with kpi4:
                st.markdown(f"""
                    <div class="kpi-card2">
                        <div class="kpi-title">Revenue CAGR</div>
                        <div class="kpi-value">{format_percent(revenue_cagr)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi5:
                st.markdown(f"""
                    <div class="kpi-card2">
                        <div class="kpi-title">Avg EBITDA Margin</div>
                        <div class="kpi-value">{format_percent(ebitda_margin_avg)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi6:
                st.markdown(f"""
                    <div class="kpi-card2">
                        <div class="kpi-title">Avg Net Margin</div>
                        <div class="kpi-value">{format_percent(net_margin_avg)}</div>
                    </div>
                """, unsafe_allow_html=True)    

# /* ---------- LINE 1 - CHART / LEFT ---------- */
        with top_left:
            with st.container(border=True):

                fig_top = go.Figure()
                fig_top.update_layout(
                    title=dict(
                        text="Revenue, EBITDA & Net Income (in Millions)",
                        x=0,  
                        xanchor="left",
                        font=dict(size=14)
                    ),
                    height=180,
                    margin=dict(l=10, r=10, t=40, b=00),  
                    legend=dict(orientation="h", y=1.1, x=0),
                    plot_bgcolor="white",
                    paper_bgcolor="white",
                    hovermode="x unified"
                )

                fig_top.add_trace(go.Scatter(
                    x=filtered_pl["Year"],
                    y=filtered_pl["Revenue"],
                    mode="lines+markers",
                    name="Revenue",
                    line=dict(width=3),
                    marker=dict(size=6)
                ))

                fig_top.add_trace(go.Scatter(
                    x=filtered_pl["Year"],
                    y=filtered_pl["EBITDA"],
                    mode="lines+markers",
                    name="EBITDA",
                    line=dict(width=3),
                    marker=dict(size=6)
                ))

                fig_top.add_trace(go.Scatter(
                    x=filtered_pl["Year"],
                    y=filtered_pl["Net_Income"],
                    mode="lines+markers",
                    name="Net Income",
                    line=dict(width=3, color="#437A2C"),
                    marker=dict(size=6)
                ))

                for xline in [2018, 2020]:
                    if filtered_pl["Year"].min() <= xline <= filtered_pl["Year"].max():
                        fig_top.add_vline(
                            x=xline,
                            line_dash="dash",
                            line_color="gray",
                            opacity=0.7
                        )

                fig_top.update_yaxes(gridcolor="#eaeaea")
                fig_top.update_xaxes(showgrid=False)

                st.plotly_chart(fig_top, use_container_width=True)

# /* ------------------------------ LINE 2  ------------------------------ */
        
        left, right = st.columns([1.0, 1.0], gap="small")

# /* ---------- LINE 2 - LEFT / CHART---------- */
        with left:
            chart_box = st.container(border=True)
            
            with chart_box:
                if filtered_ind.empty:
                    st.info("No indicator data available for the selected filters.")
                else:
                    fig_mid = make_subplots(specs=[[{"secondary_y": True}]])

                    # Returns (left axis)
                    fig_mid.add_trace(
                        go.Bar(
                            x=filtered_ind["Year"],
                            y=filtered_ind["ROA_pct"],
                            name="ROA",
                            marker=dict(color="#3a7ca5")   
                        ),
                        secondary_y=False
                    )

                    fig_mid.add_trace(
                        go.Bar(
                            x=filtered_ind["Year"],
                            y=filtered_ind["ROE_pct"],
                            name="ROE",
                            marker=dict(color="#3e5c76")
                        ),
                        secondary_y=False
                    )

                    # Leverage & coverage (right axis)
                    fig_mid.add_trace(
                        go.Scatter(
                            x=filtered_ind["Year"],
                            y=filtered_ind["Net_Debt_EBITDA"],
                            mode="lines+markers",
                            name="Net Debt / EBITDA",
                            line=dict(color="#D62728", width=3),  
                            marker=dict(color="#D62728", size=6)
                        ),
                        secondary_y=True
                    )

                    fig_mid.add_trace(
                        go.Scatter(
                            x=filtered_ind["Year"],
                            y=filtered_ind["Interest_Coverage"],
                            mode="lines+markers",
                            name="Interest Coverage",
                            line=dict(color="#6a994e", width=3),  
                            marker=dict(color="#6a994e", size=6)
                        ),
                        secondary_y=True
                    )

                    fig_mid.update_layout(
                        title=dict(text="Capital Efficiency & Shareholder Return", x=0, xanchor="left", font=dict(size=14, color="#2f2f2f")),
                        height=170,
                        margin=dict(l=10, r=10, t=45, b=0),
                        legend=dict(
                            orientation="h",
                            y=1.15,
                            x=0
                        ),
                        barmode="group",
                        plot_bgcolor="white",
                        paper_bgcolor="white",
                        hovermode="x unified",
                        xaxis_title=None,
                        yaxis_title=None
                    )

                    fig_mid.update_yaxes(
                        title_text="Return (%)",
                        gridcolor="#eaeaea",
                        secondary_y=False
                    )

                    fig_mid.update_yaxes(
                        title_text="Leverage / Coverage (x)",
                        showgrid=False,
                        secondary_y=True
                    )

                    fig_mid.update_xaxes(showgrid=False)

                    st.plotly_chart(fig_mid, use_container_width=True)

# /* ---------- LINE 2 - RIGHT CHART ---------- */
        with right:
            chart_box = st.container(border=True)
            
            with chart_box:
                fig_bottom = go.Figure()

                fig_bottom.add_trace(go.Scatter(
                    x=filtered_cf["Year"],
                    y=filtered_cf["Cash_End"],
                    mode="lines",
                    fill="tozeroy",
                    name="Cash End",
                    line=dict(color="#4C78A8", width=2),
                    fillcolor="rgba(76,120,168,0.20)"
                ))

                fig_bottom.add_trace(go.Scatter(
                    x=filtered_cf["Year"],
                    y=filtered_cf["Revolving_Credit"],
                    mode="lines",
                    fill="tozeroy",
                    name="Revolving Credit",
                    line=dict(color="#D62728", width=2),
                    fillcolor="rgba(214,39,40,0.25)"
                ))

                fig_bottom.update_layout(
                    title=dict(
                        text="Cash End & Revolving Credit Line (in Millions)",
                        x=0,
                        xanchor="left",
                        font=dict(size=14, color="#2f2f2f")
                    ),
                    height=170,
                    margin=dict(l=10, r=10, t=45, b=0),
                    legend=dict(orientation="h", y=1.15, x=0),
                    plot_bgcolor="white",
                    paper_bgcolor="white",
                    xaxis_title=None,
                    yaxis_title=None,
                    hovermode="x unified"
                )

                fig_bottom.update_yaxes(gridcolor="#eaeaea")
                fig_bottom.update_xaxes(showgrid=False)

                st.plotly_chart(fig_bottom, use_container_width=True)

# /* ------------------------------ LINE 3 ------------------------------ */
        left3, right3 = st.columns([1.0, 1.0], gap="small") 

# /* ---------- LINE 3 - RIGHT / HIGHLIGHTS ---------- */
        with right3:           
            st.markdown('<div class="highlight-bar">Executive Highlights</div>', unsafe_allow_html=True)
            st.markdown('<div class="highlight-box">', unsafe_allow_html=True)

            add_highlight("<b>Revenue</b> more than doubled (+102%) between 2010 and 2024 (CAGR ~5%$ p.a.).")
            add_highlight("<b>EBITDA margin</b> margin contracted to 7%$ in 2019 before recovering to 26%$ in 2024.")
            add_highlight("<b>Net Debt/EBITDA</b> peaked (6.7x) during the crisis and normalized to 0.9x by 2024")

            st.markdown('</div>', unsafe_allow_html=True)

# /* ---------- LINE 3 - LEFT / TABLE ---------- */
        
        with left3:

            st.markdown( "<div style='font-size:13px; color:#6b7280; margin-bottom:4px;'>Income Statement</div>", unsafe_allow_html=True)

            table_df = filtered_pl[
                ["Year", "Revenue", "COGS", "OPEX", "EBITDA", "Net_Income", "Margin (%)"]
            ].copy()

            table_df = table_df.rename(columns={"Net_Income": "Net Income"})

            for col in ["Revenue", "COGS", "OPEX", "EBITDA", "Net Income"]:
                table_df[col] = table_df[col].map(format_millions)

            table_df["Margin (%)"] = table_df["Margin (%)"].map(
                lambda x: str(round(x, 2)).replace(".", ",") if pd.notna(x) else "-"  )
                  
            st.dataframe(table_df, use_container_width=True, height=140, hide_index=True)
            

# =========================================================
# TAB 2 - SALES
# =========================================================
elif page == "Sales":

    # =========================================================
    # ---------- Load Sales Data
    # =========================================================

    df_sales_raw = pd.read_csv(DATA_DIR / "fact_sales_agg.csv")
    # fact_sales.amount is stored in thousands → convert to actual units
    df_sales_raw["revenue"] = df_sales_raw["revenue"] * 1000

    df_pv_raw = pd.read_csv(DATA_DIR / "fact_price_volume_agg.csv")

    df_sales_raw["year"] = pd.to_numeric(df_sales_raw["year"], errors="coerce")
    df_pv_raw["year"]    = pd.to_numeric(df_pv_raw["year"],    errors="coerce")

    channels_list    = sorted(df_sales_raw["channelname"].dropna().unique().tolist())
    products_list    = sorted(df_sales_raw["productname"].dropna().unique().tolist())
    sales_years_list = sorted(df_sales_raw["year"].dropna().astype(int).unique().tolist())

    # =========================================================
    # ---------- SESSION STATE
    # =========================================================

    if "sales_year_range" not in st.session_state:
        st.session_state.sales_year_range = (min(sales_years_list), max(sales_years_list))
    if "sales_channel" not in st.session_state:
        st.session_state.sales_channel = "All"
    if "sales_product" not in st.session_state:
        st.session_state.sales_product = "All"

    # =========================================================
    # ---------- HELPERS
    # =========================================================

    def format_smart(v):
        if v is None or pd.isna(v):
            return "-"
        abs_v = abs(v)
        if abs_v >= 1e6:
            return f"{v/1e6:,.2f}M".replace(",", "X").replace(".", ",").replace("X", ".")
        elif abs_v >= 1e3:
            return f"{v/1e3:,.2f}K".replace(",", "X").replace(".", ",").replace("X", ".")
        return f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

    def fmt_wf(v):
        abs_v = abs(v)
        if abs_v >= 1e6:
            return f"{v/1e6:.2f}M"
        elif abs_v >= 1e3:
            return f"{v/1e3:.1f}K"
        return f"{v:.0f}"

    # =========================================================
    # ---------- FILTER + KPI ROW
    # =========================================================

    sales_top_left, sales_top_right = st.columns([1.5, 1.0], gap="small")

    with sales_top_left:
        sl_col, reset_col, ch_col, pr_col = st.columns([2.0, 0.5, 1.0, 1.0], gap="small")

        with sl_col:
            sales_range = st.select_slider(
                "Year Range",
                options=sales_years_list,
                value=(int(st.session_state.sales_year_range[0]), int(st.session_state.sales_year_range[1])),
                key="sales_yr_slider"
            )
            st.session_state.sales_year_range = (int(sales_range[0]), int(sales_range[1]))

        with reset_col:
            st.markdown("<div style='height:27px'></div>", unsafe_allow_html=True)
            if st.button("Reset", key="sales_reset", use_container_width=True):
                st.session_state.sales_year_range = (min(sales_years_list), max(sales_years_list))
                st.session_state.sales_channel    = "All"
                st.session_state.sales_product    = "All"
                st.rerun()

        with ch_col:
            channel_opts = ["All"] + channels_list
            idx_ch = channel_opts.index(st.session_state.sales_channel) if st.session_state.sales_channel in channel_opts else 0
            sel_channel = st.selectbox("Channel", channel_opts, index=idx_ch, key="sales_ch_sel")
            st.session_state.sales_channel = sel_channel

        with pr_col:
            product_opts = ["All"] + products_list
            idx_pr = product_opts.index(st.session_state.sales_product) if st.session_state.sales_product in product_opts else 0
            sel_product = st.selectbox("Products", product_opts, index=idx_pr, key="sales_pr_sel")
            st.session_state.sales_product = sel_product

    # =========================================================
    # ---------- FILTER DATA
    # =========================================================

    yr_min, yr_max = st.session_state.sales_year_range

    df_filt = df_sales_raw[
        (df_sales_raw["year"] >= yr_min) &
        (df_sales_raw["year"] <= yr_max)
    ].copy()

    if st.session_state.sales_channel != "All":
        df_filt = df_filt[df_filt["channelname"] == st.session_state.sales_channel]

    if st.session_state.sales_product != "All":
        df_filt = df_filt[df_filt["productname"] == st.session_state.sales_product]

    df_pv_filt = df_pv_raw[
        (df_pv_raw["year"] >= yr_min) &
        (df_pv_raw["year"] <= yr_max)
    ].copy()

    if df_filt.empty:
        st.warning("No data available for the selected filters.")

    else:

        # ---------- KPI calculations ----------
        df_yearly = df_filt.groupby("year")["revenue"].sum().reset_index().sort_values("year")
        total_revenue   = df_yearly["revenue"].sum()
        first_rev       = df_yearly["revenue"].iloc[0]
        last_rev        = df_yearly["revenue"].iloc[-1]
        total_growth_pct = (last_rev / first_rev - 1) if first_rev > 0 else None
        total_units     = df_pv_filt["total_units"].sum() if not df_pv_filt.empty else None

        # ---------- KPI cards ----------
        with sales_top_right:
            kpi_s1, kpi_s2, kpi_s3 = st.columns(3, gap="small")

            with kpi_s1:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Total Revenue</div>
                        <div class="kpi-value">{format_smart(total_revenue)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi_s2:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Total Growth</div>
                        <div class="kpi-value">{format_percent(total_growth_pct)}</div>
                    </div>
                """, unsafe_allow_html=True)

            with kpi_s3:
                st.markdown(f"""
                    <div class="kpi-card">
                        <div class="kpi-title">Total Units</div>
                        <div class="kpi-value">{format_smart(total_units)}</div>
                    </div>
                """, unsafe_allow_html=True)

        st.markdown("<div style='height:6px'></div>", unsafe_allow_html=True)

        # =========================================================
        # ---------- CHART ROW 1  (Waterfall | Channel Mix | Product Mix)
        # =========================================================

        c1, c2, c3 = st.columns([1.0, 1.0, 1.0], gap="small")

        # --- Waterfall: Revenue Growth Drivers ---
        with c1:
            with st.container(border=True):
                df_pv_s = df_pv_filt.sort_values("year")

                if not df_pv_s.empty and len(df_pv_s) >= 2:
                    pv_first = df_pv_s.iloc[0]
                    pv_last  = df_pv_s.iloc[-1]

                    units_start  = pv_first["total_units"]
                    units_end    = pv_last["total_units"]
                    price_start  = pv_first["avg_price"]
                    price_end    = pv_last["avg_price"]

                    vol_effect   = (units_end - units_start) * price_start
                    price_effect = (price_end - price_start) * units_end

                    fig_wf = go.Figure(go.Waterfall(
                        orientation="v",
                        measure=["absolute", "relative", "relative", "total"],
                        x=["Revenue Start", "Volume Effect", "Price Effect", "Revenue End"],
                        y=[first_rev, vol_effect, price_effect, last_rev],
                        text=[fmt_wf(first_rev), fmt_wf(vol_effect), fmt_wf(price_effect), fmt_wf(last_rev)],
                        textposition="outside",
                        connector={"line": {"color": "#cccccc"}},
                        increasing={"marker": {"color": "#888888"}},
                        decreasing={"marker": {"color": "#D62728"}},
                        totals={"marker": {"color": "#1d3557"}}
                    ))

                    fig_wf.update_layout(
                        title=dict(
                            text="Revenue Growth Drivers (Price vs Volume)",
                            x=0, xanchor="left", font=dict(size=13)
                        ),
                        height=210,
                        margin=dict(l=10, r=10, t=40, b=10),
                        plot_bgcolor="white",
                        paper_bgcolor="white",
                        showlegend=False,
                        yaxis=dict(gridcolor="#eaeaea"),
                        xaxis=dict(showgrid=False)
                    )
                    st.plotly_chart(fig_wf, use_container_width=True)
                else:
                    st.info("Insufficient data for waterfall chart.")

        with c2:
            with st.container(border=True):
                df_ch = df_filt.groupby(["year", "channelname"])["revenue"].sum().reset_index()

                CHANNEL_COLORS = ["#1d2d44", "#888888", "#457b9d", "#f5a000", "#437A2C"]
                fig_ch = go.Figure()

                for i, ch in enumerate(sorted(df_ch["channelname"].unique())):
                    df_sub = df_ch[df_ch["channelname"] == ch]
                    fig_ch.add_trace(go.Bar(
                        x=df_sub["year"],
                        y=df_sub["revenue"],
                        name=ch,
                        marker_color=CHANNEL_COLORS[i % len(CHANNEL_COLORS)]
                    ))

                fig_ch.update_layout(
                    title=dict(text="Channel Mix (in Millions)", x=0, xanchor="left", font=dict(size=13)),
                    barmode="stack",
                    height=210,
                    margin=dict(l=10, r=10, t=40, b=10),
                    plot_bgcolor="white",
                    paper_bgcolor="white",
                    legend=dict(orientation="h", y=1.15, x=0, font=dict(size=10)),
                    hovermode="x unified",
                    yaxis=dict(gridcolor="#eaeaea"),
                    xaxis=dict(showgrid=False)
                )
                st.plotly_chart(fig_ch, use_container_width=True)

        # --- Product Mix ---
        with c3:
            with st.container(border=True):
                df_pr = df_filt.groupby(["year", "productname"])["revenue"].sum().reset_index()

                PRODUCT_COLORS = ["#283618", "#888888", "#588157", "#437A2C", "#f5a000"]
                fig_pr = go.Figure()

                for i, prd in enumerate(sorted(df_pr["productname"].unique())):
                    df_sub = df_pr[df_pr["productname"] == prd]
                    fig_pr.add_trace(go.Bar(
                        x=df_sub["year"],
                        y=df_sub["revenue"],
                        name=prd,
                        marker_color=PRODUCT_COLORS[i % len(PRODUCT_COLORS)]
                    ))

                fig_pr.update_layout(
                    title=dict(text="Product Mix (in Millions)", x=0, xanchor="left", font=dict(size=13)),
                    barmode="stack",
                    height=210,
                    margin=dict(l=10, r=10, t=40, b=10),
                    plot_bgcolor="white",
                    paper_bgcolor="white",
                    legend=dict(orientation="h", y=1.15, x=0, font=dict(size=10)),
                    hovermode="x unified",
                    yaxis=dict(gridcolor="#eaeaea"),
                    xaxis=dict(showgrid=False)
                )
                st.plotly_chart(fig_pr, use_container_width=True)

        # =========================================================
        # ---------- CHART ROW 2  (Index Line | Executive Highlights)
        # =========================================================

        row2_left, row2_right = st.columns([1.1, 0.9], gap="small")

        with row2_left:
            with st.container(border=True):
                df_rev_yr = df_filt.groupby("year")["revenue"].sum().reset_index().sort_values("year")
                df_idx = df_rev_yr.merge(df_pv_filt.sort_values("year"), on="year", how="outer").sort_values("year")

                if not df_idx.empty and len(df_idx) > 1:
                    base_rev   = df_idx["revenue"].iloc[0]
                    base_units = df_idx["total_units"].iloc[0]
                    base_price = df_idx["avg_price"].iloc[0]

                    df_idx["rev_idx"]   = (df_idx["revenue"]     / base_rev   * 100) if base_rev   else None
                    df_idx["units_idx"] = (df_idx["total_units"] / base_units * 100) if base_units else None
                    df_idx["price_idx"] = (df_idx["avg_price"]   / base_price * 100) if base_price else None

                    fig_idx = go.Figure()
                    fig_idx.add_trace(go.Scatter(
                        x=df_idx["year"], y=df_idx["rev_idx"],
                        mode="lines", name="Revenue Index",
                        line=dict(color="#437A2C", width=2.5)
                    ))
                    fig_idx.add_trace(go.Scatter(
                        x=df_idx["year"], y=df_idx["units_idx"],
                        mode="lines", name="Units Index",
                        line=dict(color="#1d2d44", width=2.5)
                    ))
                    fig_idx.add_trace(go.Scatter(
                        x=df_idx["year"], y=df_idx["price_idx"],
                        mode="lines", name="Price Index",
                        line=dict(color="#f5a000", width=2.5)
                    ))

                    if yr_min <= 2021 <= yr_max:
                        fig_idx.add_vline(x=2021, line_dash="dash", line_color="gray", opacity=0.6)

                    fig_idx.update_layout(
                        title=dict(
                            text="Revenue Index, Units Index and Price Index by Year",
                            x=0, xanchor="left", font=dict(size=13)
                        ),
                        height=190,
                        margin=dict(l=10, r=10, t=45, b=0),
                        legend=dict(orientation="h", y=1.15, x=0, font=dict(size=10)),
                        plot_bgcolor="white",
                        paper_bgcolor="white",
                        hovermode="x unified",
                        yaxis=dict(gridcolor="#eaeaea"),
                        xaxis=dict(showgrid=False)
                    )
                    st.plotly_chart(fig_idx, use_container_width=True)
                else:
                    st.info("Insufficient data for index chart.")

        with row2_right:
            st.markdown('<div class="highlight-bar">Executive Highlights</div>', unsafe_allow_html=True)
            st.markdown('<div class="highlight-box">', unsafe_allow_html=True)

            add_highlight("<b>2010&ndash;2017:</b> Expansion phase with strong <b>volume-led growth</b>.")
            add_highlight("<b>2018&ndash;2019:</b> Temporary slowdown during the operational stress period.")
            add_highlight("<b>2021&ndash;2023:</b> Growth became primarily <b>price-driven</b>, reflecting <b>global instability</b>.")
            add_highlight("<b>Revenue = Price &times; Units &times; Channel Factor.</b>")
            add_highlight("<b>Average Price Premium:</b> Direct: Base Price | Online +5% | Retail +15%")

            st.markdown('</div>', unsafe_allow_html=True)

# =========================================================
# TAB 3 - FORECASTING
# =========================================================
elif page == "Forecasting":

    # =========================================================
    # ---------- Load Forecasting Data
    # =========================================================

    df_act = pd.read_csv(DATA_DIR / "vw_pl_monthly.csv")
    df_act = df_act[df_act["year"].astype(int).isin([2023, 2024])].copy()
    df_act = df_act.rename(columns={
        "EBITDA (%)":     "ebitda_pct",
        "Net Margin (%)": "net_margin_pct"
    })
    df_act = df_act[["year", "month", "revenue", "ebitda", "ebitda_pct", "net_income", "net_margin_pct"]].copy()

    df_fcast = pd.read_csv(DATA_DIR / "vw_pl_monthly_forecast.csv")
    df_fcast["ebitda_pct"]      = df_fcast["ebitda"]     / df_fcast["revenue"].replace(0, pd.NA) * 100
    df_fcast["net_margin_pct"]  = df_fcast["net_income"] / df_fcast["revenue"].replace(0, pd.NA) * 100

    # Scenario CSV
    df_sc = pd.read_csv(DATA_DIR / "final_23_forecast.csv")
    df_sc["year"]  = df_sc["Date"].astype(str).str[:4].astype(int)
    df_sc["month"] = df_sc["Date"].astype(str).str[4:].astype(int)

    # Ensure numeric types
    for _df in [df_act, df_fcast]:
        for _col in ["year", "month", "revenue", "ebitda", "ebitda_pct", "net_income", "net_margin_pct"]:
            if _col in _df.columns:
                _df[_col] = pd.to_numeric(_df[_col], errors="coerce")

    # Readable period label  e.g. "Jan/23"
    import calendar as _cal

    def make_label(row):
        return f"{_cal.month_abbr[int(row['month'])]}/{str(int(row['year']))[2:]}"

    for _df in [df_act, df_fcast, df_sc]:
        _df["period_label"] = _df.apply(make_label, axis=1)
        _df["period_sort"]  = _df["year"] * 100 + _df["month"]

    fc_years_list = sorted(df_act["year"].dropna().astype(int).unique().tolist())

    # =========================================================
    # ---------- SESSION STATE
    # =========================================================

    if "fc_year" not in st.session_state:
        st.session_state.fc_year = "All"

    # =========================================================
    # ---------- HELPERS
    # =========================================================

    def fmt_fc(v):
        if v is None or pd.isna(v):
            return "-"
        abs_v = abs(v)
        if abs_v >= 1e6:
            return f"{v/1e6:,.2f}M".replace(",", "X").replace(".", ",").replace("X", ".")
        elif abs_v >= 1e3:
            return f"{v/1e3:,.2f}K".replace(",", "X").replace(".", ",").replace("X", ".")
        return f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

    def delta_color(v):
        if v is None or pd.isna(v):
            return "#6b7280"
        if -3 <= v <= 3:
            return "#6b7280"
        return "#D62728" 

    # =========================================================
    # ---------- MAIN LAYOUT: Scenario Chart (left) | Filter + KPIs (right)
    # =========================================================

    fc_top_left, fc_top_right = st.columns([1.35, 0.9], gap="small")

    # Filter renders first in the right column to set session state
    with fc_top_right:
        yr_opts = ["All"] + [str(y) for y in fc_years_list]
        sel_yr = st.selectbox(
            "Year",
            yr_opts,
            index=yr_opts.index(str(st.session_state.fc_year)) if str(st.session_state.fc_year) in yr_opts else 0,
            key="fc_yr_sel"
        )
        st.session_state.fc_year = sel_yr

    # =========================================================
    # ---------- FILTER DATA
    # =========================================================

    if st.session_state.fc_year == "All":
        df_act_f   = df_act.copy()
        df_fcast_f = df_fcast.copy()
        df_sc_f    = df_sc.copy()
    else:
        _yr = int(st.session_state.fc_year)
        df_act_f   = df_act[df_act["year"]     == _yr].copy()
        df_fcast_f = df_fcast[df_fcast["year"] == _yr].copy()
        df_sc_f    = df_sc[df_sc["year"]        == _yr].copy()

    for _df in [df_act_f, df_fcast_f, df_sc_f]:
        _df.sort_values("period_sort", inplace=True)

    if df_act_f.empty:
        st.warning("No data available for the selected filter.")

    else:

        # ---------- KPI Calculations ----------
        act_rev   = df_act_f["revenue"].sum()
        act_ebi   = df_act_f["ebitda"].sum()
        act_ni    = df_act_f["net_income"].sum()

        fcast_rev = df_fcast_f["revenue"].sum()    if not df_fcast_f.empty else None
        fcast_ebi = df_fcast_f["ebitda"].sum()     if not df_fcast_f.empty else None
        fcast_ni  = df_fcast_f["net_income"].sum() if not df_fcast_f.empty else None

        diff_rev = act_rev - fcast_rev if fcast_rev is not None else None
        diff_ebi = act_ebi - fcast_ebi if fcast_ebi is not None else None
        diff_ni  = act_ni  - fcast_ni  if fcast_ni  is not None else None

        diff_rev_pct = (diff_rev / fcast_rev * 100) if fcast_rev else None
        diff_ebi_pct = (diff_ebi / fcast_ebi * 100) if fcast_ebi else None
        diff_ni_pct  = (diff_ni  / fcast_ni  * 100) if fcast_ni  else None

        # ---------- KPI Cards (right column, below filter) ----------
        with fc_top_right:
            st.markdown("<div style='height:4px'></div>", unsafe_allow_html=True)

            kf1, kf2, kf3 = st.columns(3, gap="small")
            with kf1:
                st.markdown(f"""<div class="kpi-card"><div class="kpi-title">Revenue Actual</div><div class="kpi-value">{fmt_fc(act_rev)}</div></div>""", unsafe_allow_html=True)
            with kf2:
                st.markdown(f"""<div class="kpi-card"><div class="kpi-title">EBITDA Actual</div><div class="kpi-value">{fmt_fc(act_ebi)}</div></div>""", unsafe_allow_html=True)
            with kf3:
                st.markdown(f"""<div class="kpi-card"><div class="kpi-title">Net Income Actual</div><div class="kpi-value">{fmt_fc(act_ni)}</div></div>""", unsafe_allow_html=True)

            st.markdown("<div style='height:4px'></div>", unsafe_allow_html=True)

            kf4, kf5, kf6 = st.columns(3, gap="small")
            with kf4:
                st.markdown(f"""<div class="kpi-card2"><div class="kpi-title">Revenue Forecast</div><div class="kpi-value">{fmt_fc(fcast_rev)}</div></div>""", unsafe_allow_html=True)
            with kf5:
                st.markdown(f"""<div class="kpi-card2"><div class="kpi-title">EBITDA Forecast</div><div class="kpi-value">{fmt_fc(fcast_ebi)}</div></div>""", unsafe_allow_html=True)
            with kf6:
                st.markdown(f"""<div class="kpi-card2"><div class="kpi-title">Net Income Forecast</div><div class="kpi-value">{fmt_fc(fcast_ni)}</div></div>""", unsafe_allow_html=True)

            st.markdown("<div style='height:4px'></div>", unsafe_allow_html=True)

            kf7, kf8, kf9 = st.columns(3, gap="small")

            def kpi_diff_card(title, val_pct, val_abs):
                color = delta_color(val_pct)
                sign  = "+" if (val_pct is not None and val_pct >= 0) else ""
                pct_str = f"{sign}{val_pct:.1f}%" if val_pct is not None else "-"
                abs_str = fmt_fc(val_abs) if val_abs is not None else ""
                return f"""<div style="background:#dee2e6; border-left:4px solid {color}; border-radius:6px; padding:3px 6px;">
                    <div class="kpi-title" style="color:#4b5563;">{title}</div>
                    <div class="kpi-value" style="color:{color}; font-size:17px;">{pct_str}</div>
                </div>"""

            with kf7:
                st.markdown(kpi_diff_card("Revenue Variance", diff_rev_pct, diff_rev), unsafe_allow_html=True)
            with kf8:
                st.markdown(kpi_diff_card("EBITDA Variance", diff_ebi_pct, diff_ebi), unsafe_allow_html=True)
            with kf9:
                st.markdown(kpi_diff_card("Net Income Variance", diff_ni_pct, diff_ni), unsafe_allow_html=True)

        # ---------- Scenario Analysis Chart (left column) ----------
        with fc_top_left:
            with st.container(border=True):
                if not df_sc_f.empty:
                    x_lbl = df_sc_f["period_label"].tolist()

                    fig_sc = go.Figure()
                    fig_sc.add_trace(go.Scatter(
                        x=x_lbl, y=df_sc_f["Optimistic_Case_P70"],
                        mode="lines", name="Optimistic P70",
                        line=dict(color="rgba(58,124,165,0.5)", width=1), fill=None
                    ))
                    fig_sc.add_trace(go.Scatter(
                        x=x_lbl, y=df_sc_f["Stress_Case_P10"],
                        mode="lines", name="Stress P10",
                        line=dict(color="rgba(214,39,40,0.5)", width=1),
                        fill="tonexty", fillcolor="rgba(180,200,220,0.15)"
                    ))
                    fig_sc.add_trace(go.Scatter(
                        x=x_lbl, y=df_sc_f["Pessimistic_Case_P30"],
                        mode="lines", name="Pessimistic P30",
                        line=dict(color="#f5a000", width=1.5, dash="dot")
                    ))
                    fig_sc.add_trace(go.Scatter(
                        x=x_lbl, y=df_sc_f["Final_Forecast"],
                        mode="lines", name="Final Forecast",
                        line=dict(color="#3e5c76", width=2, dash="dash")
                    ))
                    fig_sc.add_trace(go.Scatter(
                        x=x_lbl, y=df_sc_f["Revenue"],
                        mode="lines+markers", name="Actual Revenue",
                        line=dict(color="#437A2C", width=2.5), marker=dict(size=5)
                    ))

                    fig_sc.update_layout(
                        title=dict(text="Profitability & Scenario Analysis", x=0, xanchor="left", font=dict(size=13)),
                        height=270,
                        margin=dict(l=10, r=10, t=40, b=0),
                        plot_bgcolor="white", paper_bgcolor="white",
                        legend=dict(orientation="h", y=1.08, x=0, font=dict(size=10)),
                        hovermode="x unified",
                        yaxis=dict(gridcolor="#eaeaea"),
                        xaxis=dict(showgrid=False, tickangle=-45, tickfont=dict(size=10))
                    )
                    st.plotly_chart(fig_sc, use_container_width=True)
                else:
                    st.info("No scenario data for the selected filter.")

        st.markdown("<div style='height:6px'></div>", unsafe_allow_html=True)

        # =========================================================
        # ---------- CHART ROW 2  (Margin Evolution | Executive Highlights)
        # =========================================================

        ch2_l, ch2_r = st.columns([1.0, 1.0], gap="small")

        with ch2_l:
            with st.container(border=True):
                if not df_act_f.empty and not df_fcast_f.empty:
                    df_mg = df_act_f[["period_label", "period_sort", "ebitda_pct", "net_margin_pct"]].merge(
                        df_fcast_f[["period_sort", "ebitda_pct", "net_margin_pct"]].rename(
                            columns={"ebitda_pct": "ebitda_pct_f", "net_margin_pct": "nm_pct_f"}
                        ),
                        on="period_sort", how="inner"
                    ).sort_values("period_sort")

                    fig_mg = go.Figure()
                    fig_mg.add_trace(go.Scatter(
                        x=df_mg["period_label"], y=df_mg["ebitda_pct"],
                        mode="lines+markers", name="EBITDA% Actual",
                        line=dict(color="#3e5c76", width=2.5), marker=dict(size=5)
                    ))
                    fig_mg.add_trace(go.Scatter(
                        x=df_mg["period_label"], y=df_mg["ebitda_pct_f"],
                        mode="lines", name="EBITDA% Forecast",
                        line=dict(color="#3e5c76", width=1.5, dash="dash")
                    ))
                    fig_mg.add_trace(go.Scatter(
                        x=df_mg["period_label"], y=df_mg["net_margin_pct"],
                        mode="lines+markers", name="Net Margin% Actual",
                        line=dict(color="#437A2C", width=2.5), marker=dict(size=5)
                    ))
                    fig_mg.add_trace(go.Scatter(
                        x=df_mg["period_label"], y=df_mg["nm_pct_f"],
                        mode="lines", name="Net Margin% Forecast",
                        line=dict(color="#437A2C", width=1.5, dash="dash")
                    ))

                    fig_mg.update_layout(
                        title=dict(text="EBITDA% & Net Margin% — Actual vs Forecast", x=0, xanchor="left", font=dict(size=13)),
                        height=210,
                        margin=dict(l=10, r=10, t=40, b=0),
                        plot_bgcolor="white", paper_bgcolor="white",
                        legend=dict(orientation="h", y=1.18, x=0, font=dict(size=10)),
                        hovermode="x unified",
                        yaxis=dict(gridcolor="#eaeaea", ticksuffix="%", range=[-10, 50]),
                        xaxis=dict(showgrid=False, tickangle=-45, tickfont=dict(size=10))
                    )
                    st.plotly_chart(fig_mg, use_container_width=True)
                else:
                    st.info("Insufficient data for margin chart.")

        with ch2_r:
            st.markdown('<div class="highlight-bar">Executive Highlights</div>', unsafe_allow_html=True)
            st.markdown('<div class="highlight-box">', unsafe_allow_html=True)

            add_highlight("<b>SARIMA model (1,1,1)(1,1,1,12)</b> captures structural trend and seasonality in the revenue series, providing a statistically driven projection baseline.")
            add_highlight("<b>2023:</b> Statistical projection slightly overestimated performance, with <b>Revenue -2.3%, EBITDA -13% and Net Income -17% vs forecast.<b/>")
            add_highlight("<b>2024:</b> Forecast accuracy improved significantly, with <b>Revenue almost fully aligned with projections (-0.28%) and profitability metrics in line with plan<b/>.")
            add_highlight("<b>The forecast represents a purely statistical projection.<b/>")
            st.markdown('</div>', unsafe_allow_html=True)
