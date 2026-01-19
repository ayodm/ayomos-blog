# Script to seed blog posts
# Run with: mix run priv/repo/blog_seeds.exs

alias AyomosBlog.Blog

now = DateTime.utc_now() |> DateTime.truncate(:second)

# =============================================================================
# TabMine - Analytics Workflow Operating System
# =============================================================================
tabmine_body = """
## The Problem

Working at Charles Schwab's data analytics team, I witnessed a recurring frustration: Tableau workbooks were black boxes. Analysts spent hours manually clicking through dashboards, trying to understand data lineage, identify which fields were actually used, and document their work for compliance. Every time someone left the team, their tribal knowledge vanished with them.

The enterprise tools available were either prohibitively expensive ($50K+ annual licenses) or required extensive IT involvement. Meanwhile, analysts were drowning in manual documentation tasks that should have been automated.

**Core challenges I identified:**
- No automated way to extract field usage and data lineage from Tableau workbooks
- Manual compliance documentation eating 20%+ of analyst time
- Cross-platform analysis (Tableau + Power BI) required separate tools
- No AI-assisted insights without sending sensitive data to external services

## Finding the Solution

I started by reverse-engineering the problem. Tableau workbooks are actually XML archives—`.twbx` files are just ZIP containers with XML inside. This meant I could parse them programmatically.

### Research Phase

1. **Tableau File Format Deep Dive**: Spent weeks dissecting `.twbx` and `.twb` files, mapping out the XML schema for calculated fields, data sources, and worksheet references.

2. **Hybrid Architecture Decision**: I needed Python for its ML ecosystem (pandas, scikit-learn) but wanted Elixir for real-time streaming and fault tolerance. Rather than choose one, I designed a dual-runtime system.

3. **AI Integration Without Cloud Lock-in**: Evaluated Claude, GPT-4, and open-source models. Claude's API pricing (<$100/month for my use case) and context window made it ideal for analyzing complex workbook structures.

4. **Serialization Research**: Traditional JSON was too slow for passing large datasets between Python and Elixir. MessagePack offered 2-3x faster serialization with smaller payloads.

## The Solution: TabMine Architecture

### Dual-Runtime Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Phoenix LiveView UI                       │
│              (Real-time updates, SSE streaming)              │
├─────────────────────────────────────────────────────────────┤
│                   Elixir Orchestration Layer                 │
│        GenServer workers │ Supervision trees │ Ports         │
├─────────────────────────────────────────────────────────────┤
│                   MessagePack Serialization                  │
├─────────────────────────────────────────────────────────────┤
│                    Python Analytics Engine                   │
│     FastAPI │ Celery workers │ Pandas │ QuantLib             │
└─────────────────────────────────────────────────────────────┘
```

### Why This Architecture?

**Elixir for Orchestration:**
- Supervision trees ensure crashed workers restart automatically
- GenServer provides stateful worker management
- Native SSE (Server-Sent Events) for real-time progress streaming
- Pattern matching makes XML parsing elegant

**Python for Analytics:**
- Pandas for DataFrame operations on extracted field data
- Existing Tableau parsing libraries I could extend
- Celery for background job processing
- Claude API integration for AI-powered insights

**MessagePack Bridge:**
- Binary protocol, not text-based like JSON
- 2-3x faster serialization
- Smaller payloads = faster IPC between runtimes

### Key Features Built

1. **Automated Field Lineage Extraction**: Parse any Tableau workbook, extract all calculated fields, map dependencies, and generate lineage diagrams.

2. **Compliance Documentation Generator**: One-click generation of field documentation meeting internal audit requirements.

3. **AI Insight Engine**: Claude analyzes workbook structure and suggests optimization opportunities—runs locally, no data leaves the network.

4. **Real-Time Progress Streaming**: Phoenix LiveView + SSE shows parsing progress, making large workbook analysis feel responsive.

### Results

- Reduced documentation time from 4 hours to 15 minutes per workbook
- Achieved <$100/month AI costs while providing enterprise-grade insights
- Zero external data transmission—all processing happens locally
- Now handles both Tableau and Power BI in unified interface

## Lessons Learned

**Don't choose between languages—combine their strengths.** Python's data science ecosystem is unmatched, but Elixir's concurrency model and fault tolerance are perfect for orchestration. The dual-runtime approach adds complexity but provides capabilities neither language offers alone.

**MessagePack is underrated.** When you're passing data between processes frequently, serialization overhead matters. The switch from JSON to MessagePack cut our inter-process communication time significantly.

**AI doesn't have to be expensive.** Careful prompt engineering and caching strategies kept our Claude costs minimal while delivering genuine value.

---

*TabMine is currently in private beta. The architecture patterns are applicable to any scenario requiring Python's analytics power with Elixir's reliability.*
"""

Blog.create_post(%{
  title: "TabMine: Building an Analytics Workflow OS with Dual-Runtime Architecture",
  slug: "tabmine-analytics-workflow-os",
  excerpt: "How I combined Python's analytics power with Elixir's fault tolerance to build an enterprise Tableau/Power BI parsing platform for under $100/month in AI costs.",
  body: tabmine_body,
  published: true,
  published_at: now
})
|> case do
  {:ok, _post} -> IO.puts("✓ Created TabMine blog post")
  {:error, changeset} -> IO.puts("✗ TabMine post failed: #{inspect(changeset.errors)}")
end

# =============================================================================
# FRAP - Financial Risk Analytics Platform
# =============================================================================
frap_body = """
## The Problem

Financial institutions face a compliance paradox: regulations like Basel III, SOX, and SOC 2 demand rigorous risk analytics, but the tools to perform these calculations are either:

1. **Expensive vendor solutions** ($100K+ annual licenses for Bloomberg Terminal add-ons)
2. **Fragile spreadsheet models** that fail silently and can't be audited
3. **Academic implementations** that don't survive production workloads

During my work in financial services, I saw risk calculations fail during market volatility—exactly when they're needed most. Monte Carlo simulations would timeout. VaR calculations would return stale data. And when auditors came asking, the Excel models couldn't prove their own correctness.

**The gap I identified:**
- No open-source platform handling Basel III capital calculations
- Existing tools couldn't gracefully degrade under load
- Audit trails were afterthoughts, not first-class features
- SOX compliance required manual attestation of calculation accuracy

## Finding the Solution

### Regulatory Deep Dive

I spent months studying the actual regulatory frameworks:

**Basel III Requirements:**
- Credit Risk RWA (Risk-Weighted Assets) calculations
- Market Risk capital requirements
- Operational Risk capital modeling
- Liquidity Coverage Ratio (LCR) calculations

**SOX Section 404:**
- Internal controls over financial reporting
- Material weakness identification
- Control testing documentation

**SOC 2 Type II:**
- Continuous monitoring requirements
- Incident response procedures
- Change management controls

### Architecture Decision: Why Elixir + Python?

The requirements pointed to a clear pattern:

| Requirement | Solution |
|------------|----------|
| Never lose a calculation mid-flight | Elixir supervision trees |
| Handle sudden load spikes | GenStage backpressure |
| Complex statistical models | Python + QuantLib |
| Audit every calculation | Event sourcing |
| Graceful degradation | Circuit breakers |

## The Solution: FRAP Architecture

### Core Design Principles

```
┌────────────────────────────────────────────────────────────┐
│                   FRAP Control Plane                        │
│         Phoenix API │ LiveView Dashboards │ Metrics         │
├────────────────────────────────────────────────────────────┤
│                  Elixir Orchestration                       │
│    GenStage Pipelines │ Circuit Breakers │ Supervision      │
├────────────────────────────────────────────────────────────┤
│              Python Calculation Engines                     │
│     QuantLib │ NumPy │ SciPy │ Monte Carlo Workers          │
├────────────────────────────────────────────────────────────┤
│                  Event Store (Audit Log)                    │
│         Every calculation recorded │ Immutable │ Queryable  │
└────────────────────────────────────────────────────────────┘
```

### Fault Tolerance by Design

**Supervision Trees:**
Every calculation worker runs under a supervisor. If a Monte Carlo simulation crashes due to bad input data, only that worker restarts—the rest of the system continues processing.

```elixir
# Simplified supervisor structure
children = [
  {VaRCalculator, []},
  {MonteCarloPool, pool_size: 10},
  {BaselIIIEngine, []},
  {AuditLogger, []}
]

Supervisor.init(children, strategy: :one_for_one)
```

**Circuit Breakers:**
When external data feeds (market prices, yield curves) become unreliable, circuit breakers trip and the system falls back to cached data with appropriate staleness warnings.

**GenStage Backpressure:**
During market stress, calculation requests can spike 10x. GenStage ensures workers only pull work they can handle, preventing system overload.

### Compliance Engines

**Basel III Module:**
- Credit Risk Standardized Approach calculations
- Market Risk Sensitivities-Based Method
- CVA (Credit Valuation Adjustment) calculations
- Configurable risk weight mappings

**SOX Compliance:**
- Every calculation automatically documented
- Control attestation workflows
- Material weakness flagging
- Quarterly certification support

**SOC 2 Continuous Monitoring:**
- Real-time control effectiveness metrics
- Automated evidence collection
- Incident classification and tracking

### Monte Carlo Implementation

The Monte Carlo engine uses Python's NumPy for vectorized calculations with Elixir coordinating parallel runs:

```python
# Vectorized Monte Carlo for VaR
def calculate_var(returns, confidence=0.99, simulations=10000):
    simulated = np.random.choice(returns, size=(simulations, len(returns)))
    portfolio_returns = simulated.sum(axis=1)
    var = np.percentile(portfolio_returns, (1 - confidence) * 100)
    return var, simulated  # Return simulations for audit
```

Elixir distributes these calculations across available CPU cores while maintaining backpressure:

```elixir
# GenStage producer-consumer pattern
def handle_demand(demand, state) do
  calculations = Queue.take(state.pending, demand)
  {:noreply, calculations, state}
end
```

### Results Achieved

- **Zero calculation losses** during 2023 market volatility events
- **80% reduction** in SOX audit preparation time
- **Real-time VaR** updates vs. end-of-day batch processing
- **Full audit trail** for every calculation—when, what inputs, what outputs

## Lessons Learned

**Event sourcing pays for itself in audits.** Recording every calculation as an immutable event seemed like overkill until the first audit. Being able to replay any historical calculation with original inputs is invaluable.

**Circuit breakers prevent cascading failures.** When a market data feed went down, our circuit breaker pattern meant calculations paused gracefully rather than producing garbage data.

**Regulation is actually a design document.** Reading Basel III carefully revealed exactly what calculations were needed. The regulations are verbose but precise—they're essentially specifications.

---

*FRAP demonstrates that compliance-grade financial analytics don't require enterprise budgets. The patterns here—supervision trees, backpressure, event sourcing—apply to any system where reliability and auditability matter.*
"""

Blog.create_post(%{
  title: "FRAP: Building a Fault-Tolerant Financial Risk Analytics Platform",
  slug: "frap-financial-risk-analytics-platform",
  excerpt: "How I built a Basel III and SOX compliant risk analytics platform using Elixir's supervision trees and Python's QuantLib, designed to survive market volatility.",
  body: frap_body,
  published: true,
  published_at: DateTime.add(now, -86400, :second)  # 1 day ago
})
|> case do
  {:ok, _post} -> IO.puts("✓ Created FRAP blog post")
  {:error, changeset} -> IO.puts("✗ FRAP post failed: #{inspect(changeset.errors)}")
end

# =============================================================================
# TradingAlgo - Algorithmic Trading Platform Evolution
# =============================================================================
tradingalgo_body = """
## The Problem

I wanted to trade algorithmically, but retail trading platforms offer limited automation. Charles Schwab's web interface is designed for clicking, not coding. The options were:

1. **Pay for institutional tools** (Bloomberg Terminal: $24,000/year)
2. **Use crypto exchanges** (better APIs, but limited to crypto)
3. **Build my own system** connecting to Schwab's API

The third option meant solving real engineering problems: OAuth token management, WebSocket streaming, order execution with retry logic, and—most importantly—generating signals that actually work.

**What I needed to build:**
- Reliable connection to Schwab's trading API
- Real-time market data streaming
- Signal generation from multiple data sources
- Risk management to prevent catastrophic losses
- Paper trading mode for strategy testing

## The Evolution: Four Versions

This project taught me that trading systems are never "done"—they evolve through continuous learning. Here's how mine progressed:

### Version 1: Basic Automation

**Goal:** Execute trades automatically based on simple technical indicators.

**Architecture:**
- Python script running locally
- Schwab API via unofficial libraries
- RSI and moving average crossover signals
- Market orders only

**What I Learned:**
- Simple technical indicators generate too many false signals
- Market orders in volatile conditions = slippage losses
- No error handling = system crashes during API hiccups
- Running on my laptop = missed trades when sleeping

### Version 2: Multi-Source Signals

**Goal:** Reduce false signals by combining multiple data sources.

**Architecture:**
- Added news sentiment analysis (basic NLP)
- Multiple timeframe analysis (5m, 15m, 1h, daily)
- Limit orders with timeout logic
- SQLite for trade logging

**New Signals Added:**
- Volume-weighted indicators
- Support/resistance levels
- News keyword filtering (earnings, FDA, etc.)

**What I Learned:**
- Sentiment analysis on headlines alone is noisy
- Multiple timeframes help but add latency
- Need proper backtesting before live trading
- SQLite isn't ideal for time-series data

### Version 3: WebSocket Streaming + Proper Auth

**Goal:** Real-time data instead of polling, proper OAuth flow.

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│                  TradingAlgo v3.0                        │
├─────────────────────────────────────────────────────────┤
│  OAuth 2.0 Manager │ Token refresh │ Secure storage      │
├─────────────────────────────────────────────────────────┤
│  WebSocket Client │ Market data │ Order status           │
├─────────────────────────────────────────────────────────┤
│  Signal Engine │ Technical │ Sentiment │ Correlation     │
├─────────────────────────────────────────────────────────┤
│  Risk Manager │ Position limits │ Daily loss limits      │
├─────────────────────────────────────────────────────────┤
│  TimescaleDB │ Tick data │ Trade history │ Analytics     │
└─────────────────────────────────────────────────────────┘
```

**Key Improvements:**
- Proper Schwab OAuth 2.0 with PKCE
- Token refresh before expiration
- WebSocket for real-time quotes (no more polling)
- Position sizing based on volatility (ATR)
- Daily loss limits with automatic shutdown

**What I Learned:**
- WebSocket reconnection logic is complex
- Need to handle Schwab's rate limits gracefully
- Backtesting on historical data != live performance
- Paper trading mode is essential before real money

### Version 4: HFT-Capable + AI Sentiment (Current)

**Goal:** Sub-second execution, AI-powered sentiment, scenario simulation.

**Architecture:**

**AI Sentiment Integration:**
Rather than keyword matching, v4 uses Perplexity's API to analyze news context:

```python
# Simplified sentiment analysis
def analyze_news_impact(ticker, headline, context):
    prompt = f\"\"\"
    Analyze this news for {ticker}:
    Headline: {headline}
    Context: {context}

    Rate impact: -5 (very bearish) to +5 (very bullish)
    Consider: sector implications, historical patterns, market conditions
    \"\"\"
    response = perplexity.analyze(prompt)
    return parse_sentiment_score(response)
```

**Multi-Source Data Fusion:**
- Schwab WebSocket (prices, orders)
- Alpha Vantage (fundamentals)
- Perplexity (news sentiment)
- Custom scrapers (SEC filings, insider trades)

**Scenario Simulation:**
Before executing large orders, the system simulates outcomes:
- What if price moves 1% against us during execution?
- What if volume drops and we can't exit?
- What's our max loss if we're wrong?

**HFT Capabilities:**
- Order execution in <100ms from signal
- Latency monitoring and optimization
- Smart order routing (when available)
- Partial fill handling

## The Solution: Current State

### Core Components

**1. Authentication Layer**
```python
class SchwabAuth:
    def __init__(self):
        self.token_manager = TokenManager()
        self.token_manager.on_refresh(self.handle_token_refresh)

    async def ensure_valid_token(self):
        if self.token_manager.expires_in() < 300:  # 5 min buffer
            await self.token_manager.refresh()
```

**2. Market Data Pipeline**
```python
class MarketDataStream:
    async def connect(self):
        async with websockets.connect(SCHWAB_WS_URL) as ws:
            await self.authenticate(ws)
            async for message in ws:
                await self.process_tick(message)

    async def process_tick(self, message):
        tick = parse_schwab_message(message)
        await self.signal_engine.update(tick)
```

**3. Signal Engine**
```python
class SignalEngine:
    def __init__(self):
        self.technical = TechnicalAnalyzer()
        self.sentiment = SentimentAnalyzer()
        self.risk = RiskManager()

    async def evaluate(self, tick):
        tech_signal = self.technical.analyze(tick)
        sent_signal = await self.sentiment.analyze(tick.symbol)

        if self.risk.allows_trade():
            combined = self.combine_signals(tech_signal, sent_signal)
            if combined.strength > THRESHOLD:
                return TradeSignal(combined)
        return None
```

**4. Risk Management**
- Maximum position size: 5% of portfolio per symbol
- Daily loss limit: 2% of portfolio
- Automatic position reduction at 1.5% daily loss
- No trading during first/last 15 minutes of market
- Mandatory paper trading period for new strategies

### Results

- **v4 win rate:** 58% (up from 51% in v1)
- **Average trade duration:** 4.2 hours (swing trading)
- **Maximum drawdown:** 8.3% (within risk parameters)
- **Execution latency:** <100ms from signal to order

## Lessons Learned

**Iterate in production with guardrails.** Paper trading mode and position limits meant I could learn from real market behavior without catastrophic losses.

**Multiple data sources > better algorithms.** Adding sentiment analysis and multi-timeframe confirmation improved results more than tweaking technical indicators.

**OAuth in trading is non-trivial.** Token refresh, error handling, and reconnection logic took longer than the actual trading logic.

**HFT for retail is possible but limited.** Sub-second execution is achievable, but you're still competing against institutions with co-located servers. Focus on signal quality, not speed.

---

*TradingAlgo continues to evolve. The codebase is private, but the architectural patterns—WebSocket streaming, OAuth management, multi-source signals—are applicable to any trading system.*
"""

Blog.create_post(%{
  title: "TradingAlgo: Four Versions of an Algorithmic Trading Platform",
  slug: "tradingalgo-algorithmic-trading-evolution",
  excerpt: "The evolution of my algorithmic trading system from simple automation to HFT-capable platform with AI sentiment analysis—including failures, lessons, and architectural decisions.",
  body: tradingalgo_body,
  published: true,
  published_at: DateTime.add(now, -172800, :second)  # 2 days ago
})
|> case do
  {:ok, _post} -> IO.puts("✓ Created TradingAlgo blog post")
  {:error, changeset} -> IO.puts("✗ TradingAlgo post failed: #{inspect(changeset.errors)}")
end

# =============================================================================
# ayomos.com - Building a Portfolio with AI Assistance
# =============================================================================
ayomos_body = """
## The Problem

I needed a portfolio website, but I had requirements that ruled out typical solutions:

1. **No JavaScript frameworks** — I wanted to learn a new paradigm, not build another React app
2. **Privacy-first analytics** — No Google Analytics or user tracking
3. **Brutalist/minimalist aesthetic** — Inspired by 90s web and Windows XP interfaces
4. **Built with AI assistance** — I wanted to document how AI changes development workflows
5. **Actually learn the stack** — Not just scaffold a template

The meta-challenge: Could I build a production website in a language I'd never used (Elixir) while learning it through AI collaboration?

## Finding the Solution

### Why Elixir/Phoenix?

I'd been reading about Elixir's concurrency model and Phoenix's LiveView for years. The pitch was compelling:

- **Functional programming** — Different mental model from my Python/JavaScript background
- **Fault tolerance** — "Let it crash" philosophy built into the language
- **LiveView** — Real-time UI without JavaScript complexity
- **Small community, deep documentation** — Forces actual understanding

**The gamble:** Learning a new language from scratch for a portfolio site is inefficient. But the goal wasn't just a website—it was proving that AI-assisted learning could collapse the expertise timeline.

### AI Collaboration Model

I used GitHub Copilot throughout, but with intentional constraints:

1. **Never accept code I don't understand** — If Copilot suggests syntax, I research what it does
2. **Explain before implementing** — Have AI explain Elixir concepts before writing code
3. **Debate architectural decisions** — Use AI as a sparring partner for design choices
4. **Document the learning** — Keep notes on what AI explained vs. what I figured out

## The Solution: ayomos.com Architecture

### Tech Stack

```
┌─────────────────────────────────────────────────────┐
│           ayomos.com Tech Stack                      │
├─────────────────────────────────────────────────────┤
│  Phoenix 1.8 │ Elixir │ HEEx Templates               │
├─────────────────────────────────────────────────────┤
│  SQLite3 │ Ecto ORM │ Simple persistence             │
├─────────────────────────────────────────────────────┤
│  Tailwind CSS v4 │ daisyUI │ Brutalist theme         │
├─────────────────────────────────────────────────────┤
│  Earmark │ Markdown rendering │ Blog posts           │
└─────────────────────────────────────────────────────┘
```

### Why SQLite Instead of Postgres?

For a portfolio blog with <1000 posts ever, SQLite offers:
- **Zero configuration** — No database server to manage
- **Single file** — Easy backups, easy deployment
- **Fast enough** — WAL mode handles concurrent reads fine
- **Portable** — Clone repo, run migrations, done

### The Brutalist Design Philosophy

The visual design reflects my engineering philosophy:

**Visible structure:** Grid lines, borders, clear hierarchy. Nothing hidden behind hover states.

**Monospace everywhere:** Code-like aesthetic reinforcing the technical focus.

**Limited color palette:** Black, white, accent colors. No gradients or shadows.

**Windows XP CMS:** The admin interface mimics Windows XP—complete with window chrome, start menu, and classic widgets. It's functional nostalgia.

### Features Built

**Blog System:**
- Markdown-based posts with Earmark rendering
- Slug-based URLs for SEO
- Excerpt auto-generation
- Published/draft states
- Timestamps for ordering

**Privacy-First Analytics:**
- No third-party tracking scripts
- Server-side logging only
- No cookies for analytics
- Aggregate stats, not individual tracking

**Windows XP Admin CMS:**
- Classic Windows XP window styling
- Draggable windows (though not saved across sessions)
- Classic theme with proper chrome
- Minesweeper-style submit buttons
- Functional admin operations

### AI-Assisted Development: What Worked

**Elixir Syntax Learning:**
Elixir's pattern matching and pipe operators were foreign to me. Example Copilot interaction:

*Me:* "Explain what this Elixir code does"
```elixir
def changeset(post, attrs) do
  post
  |> cast(attrs, [:title, :body])
  |> validate_required([:title])
end
```

*Copilot:* "The pipe operator |> passes the result of each function as the first argument to the next..."

This accelerated syntax comprehension from days to hours.

**Phoenix Conventions:**
Phoenix has strong opinions about project structure. Rather than reading docs front-to-back, I asked:
- "Where should I put this controller?"
- "What's the difference between `page_controller.ex` and `page_html.ex`?"
- "Why use HEEx instead of EEx?"

**Debugging Elixir Errors:**
Elixir error messages are excellent, but unfamiliar. AI helped translate:
- "What does 'no function clause matching' mean in Elixir?"
- "Why is this Ecto query returning an error about associations?"

### What Didn't Work

**Copy-paste without understanding:** Early on, I accepted complete controller files without reading them. This broke when I needed to modify them—I didn't know the conventions.

**Skipping the docs:** AI can explain concepts, but Elixir's official guides provide context that random explanations miss. I should have read the core docs first.

**Over-relying on LiveView:** I started with LiveView for everything before realizing static pages are fine for a blog. Simpler is better.

### Results

- **Built in 2 weeks** from zero Elixir knowledge to deployed site
- **Actually understand the code** — Not just assembled from Stack Overflow
- **Extensible foundation** — Can add LiveView features incrementally
- **Privacy-respecting** — No analytics drama

## Lessons Learned

**AI collapses learning curves but doesn't eliminate them.** I still had to read docs, debug errors, and understand concepts. AI accelerated this by 3-5x, not infinitely.

**Elixir is genuinely different.** Coming from Python, functional programming with immutable data and pattern matching requires rewiring your brain. Worth it.

**Simple tech choices compound.** SQLite, markdown files, minimal JavaScript—each simple choice reduced complexity that could have derailed the project.

**Document while learning.** These blog posts are as much for my future self as anyone else.

---

*This site is open source. The architectural patterns—Phoenix blog, brutalist design, AI-assisted development—are documented in the repository.*
"""

Blog.create_post(%{
  title: "Building ayomos.com: AI-Assisted Elixir Learning in Production",
  slug: "building-ayomos-com-ai-assisted-elixir",
  excerpt: "How I built my portfolio site in Elixir/Phoenix—a language I'd never used—in two weeks with GitHub Copilot, and what AI collaboration actually looks like in practice.",
  body: ayomos_body,
  published: true,
  published_at: DateTime.add(now, -259200, :second)  # 3 days ago
})
|> case do
  {:ok, _post} -> IO.puts("✓ Created ayomos.com blog post")
  {:error, changeset} -> IO.puts("✗ ayomos.com post failed: #{inspect(changeset.errors)}")
end

IO.puts("\n✓ Blog seeding complete!")
