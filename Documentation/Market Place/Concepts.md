# Market Place

## 1. Basics

An `offer` is a solution available on the commercial marketplace containing one or more plans.
A `plan` is a component of the offer that defines an offer's scope and limits, and the associated pricing when applicable.

Example:
An offer can be a "Customized VM (Virtual Machine)." This offer could contain two plans: a basic plan with 4 GB of RAM and 16 GB of Storage and a standard plan with 8 GB of RAM and 32 GB of Storage. When purchasing an offer, you need to select a plan.


## 2. Roles and permissions

Public offers are available for purchase on Azure Marketplace or Microsoft AppSource. The person completing the purchase needs the right roles and permissions.

| Commercial Agreement               | Offer         | Role Required to Accept              | Role Required to Purchase or Subscribe |
|------------------------------------|---------------|--------------------------------------|----------------------------------------|
| Microsoft Customer Agreement (MCA) | Public offer  | n/a                                  | Subscription owner or contributor      |
|                                    | Private plan  | n/a                                  | Subscription owner or contributor      |
|                                    | Private offer | Billing account owner or contributor | Subscription owner or contributor      |
| Enterprise Agreement (EA)          | Public offer  | n/a                                  | Subscription owner or contributor      |
|                                    | Private plan  | n/a                                  | Subscription owner or contributor      |
|                                    | Private offer | Enterprise administrator             | Subscription owner or contributor      |


## 3. Private offers for purchase

A Microsoft partner creates a private offer for a specific customer, and the offer might contain custom prices, terms and conditions, and a solution's custom configurations. Private offers are available in Azure Marketplace. To learn about custom solutions using private offers, see the Overview of custom deal making (https://learn.microsoft.com/en-us/marketplace/private-offers-overview). 

A good example story at: https://learn.microsoft.com/en-us/marketplace/private-offers-overview#private-offer-a-sample-scenario

### 3.1 Purchase workflow

1) Float FinOps prepares the private offer and notify the customer when it's ready.
2) Customer needs to accept the offer with proper role permission.
3) After acceptance, customer needs to purchase the private offer with proper role permission.
4) After purchase, customer waits for enablement until the Configure your account button is available. Then use the button to redirect to Float FinOps website and complete the activation.


### 3.2 Permissions

| Agreement Type                          | Permissions to Accept Offer            | Permissions to Purchase or Subscribe                |
|-----------------------------------------|----------------------------------------|-----------------------------------------------------|
| Microsoft Customer Agreement (MCA)      | Billing account owner or contributor   | Subscription owner or subscription contributor      |
| Enterprise Agreement (EA)               | Enterprise administrator               | Subscription owner or subscription contributor      |
| Microsoft Online Service Program (MOSP) | Account administrator                  | Account administrator                               |


### 3.3 Subscribe

If your private offer purchase includes a software-as-a-service (SaaS) product, you must activate the SaaS product's subscription after subscribing to complete the purchase.

**Note**:
Check with the vendor that provided you with the private offer to understand your private offer's pricing at `renewal` and to determine the appropriate `auto renew` setting. It will be turned off by default.


- `Off`: The SaaS subscription terminates on the end date. There's no other billing on that SaaS subscription, even if your private offer ends after the end of the billing term.

- `On`: The SaaS subscription auto renews at the end of the billing term and billing continues.

    - If your private offer ends after the end of the billing term, your subscription renews at the private offer price.
    - If your private offer ends before the end of the billing term, and no other private offer is started, your subscription renews at the public offer price.
    - If your private offer ends before the end of the billing term, and a new private offer started, check with your vendor to confirm the price at which your subscription renews.

**Note**:
For SaaS, you need to sign-in and register on your ISV vendor's website using Entra `single sign-on` after subscribing to complete the private offer purchase.


### 3.4 Billing

Sample at: https://learn.microsoft.com/en-us/partner-center/marketplace-offers/saas-metered-billing#sample-offer

- `Flat Rate`: pay for included usage, counts the usage up to the included quantity in base without sending any usage events to Microsoft.
- `Metered bill`: measures the overage beyond the included quantity and starts emitting usage events to Microsoft for charging the overage usage.
- `Modeling tiered billing`: Let’s say Contoso wants to charge $449/mo for up to 100 shards, and then tiered pricing for any overage. Their application logic would keep track of the usage for the month, segment the usage accordingly and report it using the metering APIs below at the end of the period

Configure the `Flat Rate`, `metering service dimensions` in market place, then just call below usage APIs to send usage event. Microsoft will bill it based on usage.

The `overage billing` is done on the `next billing cycle` (monthly, but can be quarterly or early for some customers).

- For a monthly flat rate plan, the overage billing will be made for every month where overage has occurred. 
- For a yearly flat rate plan, once the quantity included in base per year is consumed, all additional usage emitted by the custom meter will be billed as overage during each billing cycle (monthly) until the end of the subscription's year term.

**Note**:
You must keep track of the usage in your code and only send usage events to Microsoft for the usage that is above the base fee.


#### 3.4.1 Dimension attributes

Before you publish the offer, a change made to these attributes from the context of any plan will affect the dimension definition across all plans. Once you publish the offer, these attributes will no longer be editable. These attributes are:

- ID
- Display Name
- Unit of Measure

The other attributes of a dimension are specific to each plan and can have different values from plan to plan. Before you publish the plan, you can edit these values and only this plan will be affected. Once you publish the plan, these attributes will no longer be editable. These attributes are:

- Price per unit in USD
- 1-month quantity included in base
- 1-year quantity included in base
- 2-year quantity included in base
- 3-year quantity included in base

Dimensions also have two special concepts, "enabled" and "Unlimited":

- `Enabled` indicates that this plan participates in this dimension. If you're creating a new plan that doesn't send usage events based on this dimension, you might want to leave this option unchecked. Also, any new dimensions added after a plan was first published shows up as "not enabled" on the already published plan. A disabled dimension won't show up in any lists of dimensions for a plan seen by customers.
- `Unlimited` represented by the "Unlimited" checkbox against each included quantity, indicates that this plan participates in this dimension, but doesn't emit usage against this dimension. If you want to indicate to your customers that the functionality represented by this dimension is included in the plan, but with no limit on usage. A dimension with infinite usage shows up in lists of dimensions for a plan seen by customers, with an indication that it will never incur a charge for this plan.


#### 3.4.2 Trial behavior constraints

Metered billing using the commercial marketplace metering service isn't compatible with offering a free trial. It's not possible to configure a plan to use both metered billing and a free trial.



## 4. API

### 4.1 Metered billing

#### 4.1.1 Metered billing single usage event

Only one usage event can be emitted for each hour of a calendar day per resource and dimension. If more than one unit is consumed in an hour, then accumulate all the units consumed in the hour and then emit it in a single event. 

More details about the API at: https://learn.microsoft.com/en-us/partner-center/marketplace-offers/marketplace-metering-service-apis#metered-billing-single-usage-event


### 4.1.2 Metered billing batch usage event

The batch usage event API allows you to emit usage events for more than one purchased resource at once. It also allows you to emit several usage events for the same resource as long as they're for different calendar hours. The maximal number of events in a single batch is 25.

More details at: https://learn.microsoft.com/en-us/partner-center/marketplace-offers/marketplace-metering-service-apis#metered-billing-batch-usage-event


### 4.1.3 Metered billing retrieve usage events

You can call the usage events API to get the list of usage events. ISVs can use this API to see the usage events that have been posted for a certain configurable duration of time and what state these events are at the point of calling the API.

More details at: https://learn.microsoft.com/en-us/partner-center/marketplace-offers/marketplace-metering-service-apis#metered-billing-retrieve-usage-events


### 4.2 Maintenance

- `Landing page flow`: Microsoft notifies the publisher that the publisher's SaaS offer was purchased by a customer in the marketplace.
- `Activation flow`: Publisher notifies Microsoft that a newly purchased SaaS account was configured on the publisher's side.
- `Update flow`: Change of purchased plan or the number of purchased seats or both.
- `Suspend and reinstate flow`: Suspending the purchased SaaS offer in case the customer's payment method is no longer valid. The suspended offer can be reinstated when the issue with payment method is resolved.
- `Webhook flows`: Microsoft notifies the publisher about SaaS subscription changes and cancellation triggered by the customer from the Microsoft side.



