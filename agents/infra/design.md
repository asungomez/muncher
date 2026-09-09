# Designing infrastructure

Read this when deciding *what* to provision — choosing a service, sizing a
resource, adding a component to the architecture. For how templates are written
once the decision is made, see [iac.md](iac.md).

## The principle

**Choose the cheapest option that does the job.**

This project is paid for out of the maintainer's own pocket. The budget for the
entire system is **7 USD per month**, and **zero is better than seven**. Cost is
not a tiebreaker applied after a technical decision; it is a design constraint of
the same weight as the functional requirements.

AWS pricing is easy to get wrong in the expensive direction. Charges accrue per
hour rather than per use, free tiers expire, data transfer and idle resources
bill silently, and a resource left running costs money whether or not anyone
uses it. Assume any service will cost more than it appears to until you have
checked.

## Never provision past the budget

**If the requirement cannot be met within the budget, stop and say so.** Do not
provision anyway and mention it afterwards. Do not pick the cheapest option that
still exceeds the budget and treat that as compliance. An unmet requirement the
maintainer knows about is a decision they can make; a surprise bill is not.

When you reach that point, report: what the requirement demands, what the
cheapest option that satisfies it costs, how far over budget that is, and what
the alternatives are — a reduced version that fits, a different service, or
dropping the requirement.

## How to decide

For any component, work through this before recommending anything:

1. **Is it needed at all?** The cheapest resource is the one not created. A
   requirement that can be met by an existing resource, by a static file, or by
   doing without, costs nothing.
2. **Enumerate the options that meet the requirement.** Usually more than one
   service can. List them rather than reaching for the obvious or the one you
   have seen most often.
3. **Price each one at this project's scale** — a single small application with
   little traffic — not at the scale the service is marketed for. Include what is
   easy to forget: hourly charges for idle time, storage billed separately from
   compute, data transfer out, per-request fees, the cost of a second instance
   for availability, and anything that bills per hour whether used or not.
4. **Check what the free tier actually covers**, whether it expires after twelve
   months or is perpetual, and what the price becomes when it ends or is
   exceeded. A free tier that lapses is a scheduled bill.
5. **Recommend the cheapest option that meets the requirement**, and state the
   monthly figure you arrived at. If a slightly more expensive option is
   materially better, present both with their costs and let the maintainer
   choose — do not silently spend the difference.

## Costs must be verified, not recalled

Never state a price from memory. AWS pricing changes, varies by region, and its
free-tier terms change. Look it up, cite where you looked, and give the region
you priced. If a figure cannot be verified, say that instead of estimating —
`agents/memoria/bibliography.md` applies the same standard to citations, and the
reasoning holds here for the same reason: an invented number that looks
plausible is worse than an acknowledged gap.

## Preferences that follow from the budget

- **Prefer services that cost nothing when idle** over ones that bill by the
  hour. Usage-based pricing suits a system with almost no usage; a provisioned
  instance does not.
- **Prefer managed and serverless** where it removes a resource that would
  otherwise run continuously.
- **Prefer one resource serving both environments** where doing so is safe, over
  duplicating a paid resource per environment. Where it is not safe — anything
  holding production data — say so and price both.
- **Smallest viable size, always.** Sizing for growth that has not happened is
  paying for it now.
- **Nothing highly available unless it is required.** A second availability zone
  usually doubles the cost of the resource.
- **Treat anything with an hourly charge as a red flag** to justify explicitly:
  NAT gateways, load balancers, provisioned databases and idle compute are the
  usual ways a small project's bill grows without anyone noticing.
- **Plan for teardown.** A development environment that can be deleted and
  recreated from the template costs nothing while it does not exist.

## Consequences for agents

- Include the monthly cost in any infrastructure proposal. A design without a
  price is not finished.
- When you add a resource, say what it costs and what it would cost if traffic
  grew tenfold.
- Flag anything that could grow without a ceiling — per-request billing with no
  cap, storage that only accumulates, logs retained forever.
- Recommend a budget alarm and cost visibility before recommending anything that
  bills by usage.
- If a task asks for something whose cheapest form does not fit in 7 USD per
  month, raise it as the first thing in your reply, not as a footnote.
