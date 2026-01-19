# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AyomosBlog.Repo.insert!(%AyomosBlog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AyomosBlog.Repo
alias AyomosBlog.Blog.Post

# Sample blog posts about Data Analytics and Enterprise Risk Management

posts = [
  %{
    title: "Data-Driven Risk Quantification: A Modern Approach",
    slug: "data-driven-risk-quantification",
    excerpt: "Exploring how advanced analytics and statistical methods are revolutionizing the way organizations measure and predict enterprise risks.",
    body: """
    In today's rapidly evolving business landscape, traditional approaches to risk management are no longer sufficient. Organizations are increasingly turning to data-driven methods to quantify and predict risks with greater accuracy.

    ## The Shift from Qualitative to Quantitative

    Historically, enterprise risk management relied heavily on qualitative assessments—expert judgment, surveys, and subjective ratings. While these methods provide valuable insights, they often lack the precision needed for strategic decision-making.

    Modern risk quantification leverages:
    - **Statistical modeling** to predict loss distributions
    - **Monte Carlo simulations** for scenario analysis
    - **Machine learning algorithms** for pattern recognition
    - **Time series analysis** for trend identification

    ## Key Benefits of Data-Driven Risk Quantification

    1. **Objectivity**: Reduces bias inherent in subjective assessments
    2. **Precision**: Provides confidence intervals and probability distributions
    3. **Scalability**: Can process vast amounts of data efficiently
    4. **Reproducibility**: Results can be validated and audited

    ## Implementation Considerations

    Successful implementation requires:
    - Quality data infrastructure
    - Skilled analytics talent
    - Executive buy-in and cultural shift
    - Robust model governance

    The journey from qualitative to quantitative risk management is not about replacing human judgment—it's about augmenting it with data-driven insights that enable more informed decisions.
    """,
    published: true,
    published_at: ~U[2026-01-15 10:00:00Z]
  },
  %{
    title: "Building an Effective ERM Framework",
    slug: "building-effective-erm-framework",
    excerpt: "Best practices for implementing enterprise risk management frameworks that align with organizational objectives and regulatory requirements.",
    body: """
    Enterprise Risk Management (ERM) is more than a compliance checkbox—it's a strategic capability that can drive competitive advantage. This post outlines key principles for building an effective ERM framework.

    ## Core Components of ERM

    A robust ERM framework typically includes:

    ### 1. Governance Structure
    - Clear roles and responsibilities
    - Board-level oversight
    - Risk committees and reporting lines

    ### 2. Risk Identification
    - Comprehensive risk taxonomy
    - Regular risk assessments
    - Emerging risk monitoring

    ### 3. Risk Assessment
    - Consistent evaluation criteria
    - Likelihood and impact matrices
    - Risk prioritization methods

    ### 4. Risk Response
    - Mitigation strategies
    - Risk transfer mechanisms
    - Acceptance criteria

    ### 5. Monitoring and Reporting
    - Key Risk Indicators (KRIs)
    - Dashboard and reporting
    - Escalation procedures

    ## Common Pitfalls to Avoid

    - **Siloed thinking**: Risk management across departments must be integrated
    - **Static frameworks**: ERM must evolve with the business
    - **Compliance focus only**: Strategic value should drive ERM, not just regulations
    - **Poor data quality**: Garbage in, garbage out applies to risk management

    ## The Role of Technology

    Modern ERM platforms enable:
    - Centralized risk registers
    - Automated data collection
    - Real-time monitoring
    - Advanced analytics capabilities

    A well-designed ERM framework transforms risk management from a defensive function into a strategic asset.
    """,
    published: true,
    published_at: ~U[2026-01-10 10:00:00Z]
  },
  %{
    title: "Predictive Analytics in Risk Management",
    slug: "predictive-analytics-risk-management",
    excerpt: "Leveraging machine learning and predictive modeling to build early warning systems and anticipate emerging risks before they materialize.",
    body: """
    The ability to anticipate risks before they materialize is the holy grail of risk management. Predictive analytics brings this capability within reach.

    ## From Reactive to Proactive

    Traditional risk management is often reactive—responding to events after they occur. Predictive analytics enables a proactive approach by:

    - Identifying patterns that precede risk events
    - Providing early warning signals
    - Enabling preemptive mitigation actions

    ## Key Predictive Techniques

    ### Regression Analysis
    Understanding relationships between variables and predicting outcomes based on historical patterns.

    ### Classification Models
    Categorizing risks and predicting which category future events will fall into.

    ### Time Series Forecasting
    Predicting future values based on historical trends and seasonality.

    ### Anomaly Detection
    Identifying unusual patterns that may indicate emerging risks.

    ## Building Early Warning Systems

    Effective early warning systems require:

    1. **Clear objectives**: What risks are we trying to predict?
    2. **Quality data**: Historical data with sufficient granularity
    3. **Appropriate models**: Matched to the prediction task
    4. **Actionable thresholds**: Clear escalation triggers
    5. **Feedback loops**: Continuous model improvement

    ## Challenges and Considerations

    - **Data availability**: Historical data may not exist for novel risks
    - **Model interpretability**: Black-box models may not be appropriate
    - **False positives**: Too many alerts lead to alert fatigue
    - **Changing dynamics**: Past patterns may not predict future behavior

    The key is to view predictive analytics as a complement to—not a replacement for—expert judgment and traditional risk assessment methods.
    """,
    published: true,
    published_at: ~U[2026-01-05 10:00:00Z]
  }
]

for post_attrs <- posts do
  %Post{}
  |> Post.changeset(post_attrs)
  |> Repo.insert!()
end

IO.puts("Seeded #{length(posts)} blog posts")
