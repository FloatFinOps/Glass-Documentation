# Virtual Machine Licensing Cost, Reservation, Saving Calculation, Breakeven Runtime Percentage

This documentation explains the calculation of virtual machine licensing Cost, Reservation, Saving, Breakeven Runtime Percentage.

## 1. Data Source

The value for calculatiion comes from the `GetFinOpsSummaryVM` API.

### 2. Data Source Details

There is an import process that inserts/updates the Azure price sheet list into the database on a monthly schedule. The table where this data is stored is named `MA_RetailPriceList`. All cost values are fetched from this table and are further calculated based on location, SKU, resource type, time frame, etc.

There is an import process that inserts/updates the Azure Sku info into the database on a monthly schedule. The table where this data is stored is named `SkuInfo`. All sku info are fetched from this table.

There is a table named `MA_SoftwareSubscriptionPriceSheet` which contains the info of License. All license info are fetched from this table. Currently, this table does not have any updating process, may need to add it if the license info was updated regularly by Azure.

### 3. License Cost

### 3.1 API

Licensing will only be calculated when the virtual machine is a valid candidate for hybrid benefit.

The logic to fetch the original price information from the database uses the following filters:

Hardware cost without license:
- `ArmRegionName == virtual machine's ArmLocation`
- `ArmSkuName == virtual machine's SKU`
- `ProductName == "Virtual Machines"`
- `SkuName != "Spot"`
- `SkuName != "Low Priority"`
- `Type == "Consumption"`
- `ProductName` does not end with "Windows"
- Order by `EffectiveStartDate`, and fetch the latest record.
named as `consumption`

Hardware cost with license:
- `ArmRegionName == virtual machine's ArmLocation`
- `ArmSkuName == virtual machine's SKU`
- `ProductName == "Virtual Machines"`
- `SkuName != "Spot"`
- `SkuName != "Low Priority"`
- `Type == "Consumption"`
- `ProductName` end with "Windows"
- Order by `EffectiveStartDate`, and fetch the latest record.
named as `osAndHardwarePaygCost`

The data has the unit of measure as `1 Hour`, so the cost of license per hour on pay as you go is:
    `osPaygCost` = `osAndHardwarePaygCost.RetailPrice` - `consumption.RetailPrice` 

In the API response, the above values are assigned to `item.hybridBenefis.osPaygCost`, which represents the 1-hour value of using hybrid benefit license for the selected virtual machine.

### 3.2. UI Usage

In the UI, there is a `Time Frame` option. When a time frame is selected, the time value is converted into hours, and the final display of the cost value in the UI is:
`Licensing Cost` = `item.hybridBenefis.osPaygCost` * (timeFrameData in hour)

#### Time Frame Example:

[
    { "timeFrame": "1 Hour", "value": 1 },
    { "timeFrame": "1 Day", "value": 24 },
    { "timeFrame": "1 Week", "value": 168 },
    { "timeFrame": "1 Month", "value": 720 },
    { "timeFrame": "1 Year", "value": 8640 }
]

### 4. License Benefit

### 4.1 Learn about Sku info of the virtual machine

The logic to fetch the sku information from the table `SkuInfo` uses the following filters:

- `SkuName == virtual machine's Size`
- `Location == virtual machine's ArmLocation`
From this, the sku info tells the `coresValue` of the selected virtual machine.

### 4.2 Determine license number

Need to know how many number of license needed to cover the virtual machine, current setting is `1 license` can cover `8 cores`, so the calculation is:
    `licenseNeededCount` = `coresValue` / 8;

### 4.3 Fetch license info

From table `MA_SoftwareSubscriptionPriceSheet`, fetch the license info by filters:

- `ProductTitle` Starts With `Windows Server Standard`
- `CoresMin == 8`
- `TermDuration == Annual`
From this, the result only return 2 record, for `1 Year` and `3 Years` separately.

### 4.4 Calculate License Needed Price Per Hour

The license info tells the ERP (Estimated Retail Price) of the license for 1 year term duration, then the calculation is:
    `licenseNeededPricePerHour` = (license.ERP / 8640) * `licenseNeededCount`

    *8640 is the total hour of 1 year

In the API response, the above values are assigned as `item.HybridBenefis[License duration].licenseNeededPricePerHour`, which will be used in UI.

### 4.5 Calculate Savings Per Hour

Now, the cost of license on Pay as You Go has been calculated as `osPaygCost` in step 3.1, and the cost of license on CSP has been calculated as `licenseNeededPricePerHour` in step 4.4.So, the saving calculation of a license is as below:
    `savingsPerHour` = `osPaygCost` - `licenseNeededPricePerHour`;

In the API response, the above values are assigned as `item.HybridBenefis[License duration].savingsPerHour`, which will be used in UI.

### 4.6 Calculate Breakeven RunTime Percentage

The breakeven runTime percentage calculation is as:
    `breakEvenRunTimePercentage` = `license.ERP` / `osPaygCost` / 8640
    *8640 is the total hour of 1 year

In the API response, the above values are assigned as `item.HybridBenefis[License duration].breakEvenRunTimePercentage`, which will be used in UI.

### 4.7 UI Usage

In the UI, there is `Time Frame` and `Commitment Periods` options. When option selected, the value in UI is calculated as:
    `Licensing Purchase` = `item.HybridBenefis[License duration].licenseNeededPricePerHour` * (timeFrameData in hour)
    `Licensing Saving` = `item.HybridBenefis[License duration].savingsPerHour` * (timeFrameData in hour)
    `Licensing BreakEvenRunTimePercentage` = `item.HybridBenefis[License duration].breakEvenRunTimePercentage` * (timeFrameData in hour)

